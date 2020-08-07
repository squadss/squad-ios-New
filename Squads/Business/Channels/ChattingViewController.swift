//
//  ChattingViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/7.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import Hero
import RxSwift
import RxCocoa
import MessageKit
import InputBarAccessoryView

enum ConversationAction: Equatable {
    case create(squadId: Int)
    case load(groupId: String, groupName: String, squadId: Int)
    
    static func == (lhs: ConversationAction, rhs: ConversationAction) -> Bool {
        switch (lhs, rhs) {
        case (.create(let l_id), .create(let r_id)): return l_id == r_id
        case (.load(let l_gid, _, let l_sid), .load(let r_gid, _, let r_sid)): return l_gid == r_gid && l_sid == r_sid
        default: return false
        }
    }
    
    var groupId: String? {
        switch self {
        case .create: return nil
        case let .load(groupId, _, _): return groupId
        }
    }
}

struct CreateChannel: Codable {
    let id: Int
    let squadId: Int
    let channelName: String
    let headImgUrl: String
    let ownerAccountId: Int
}


struct Sender: SenderType {
    let senderId: String
    let displayName: String
    let avatar: String?
}

// 因为MessageType协议中有个sender属性和V2TIMMessage中的sender重名了, 所以不能用V2TIMMessage直接遵守MessageType
final class MessageElem: Comparable {
    
    let timMessage: V2TIMMessage
    
    // 如果是接收到的消息, 资源需要下载, 如果是发送者的消息,资源在本地不需要下载, 所以要判断消息发送者是否为自己
    
    // 下载资源
    func loadResource(result: @escaping (Result<Void, GeneralError>) -> Void)  {
        
    }
    
    // 获取下载资源必要的准备条件
    func prepareResource(result: @escaping (Result<Void, GeneralError>) -> Void)  {
        
    }
    
    init(timMessage: V2TIMMessage) {
        self.timMessage = timMessage
    }
    
    var isValidType: Bool {
        return true
    }
    
    var description: String {
        switch timMessage.elemType {
        case .ELEM_TYPE_TEXT: //文字消息
            let text = timMessage.textElem.text!
            return text
        case .ELEM_TYPE_SOUND:
            return "[Audio]"
        case .ELEM_TYPE_VIDEO:
            return "[Video]"
        case .ELEM_TYPE_IMAGE:
            return "[Photo]"
        case .ELEM_TYPE_FILE:
            return "[File]"
        case .ELEM_TYPE_FACE:
            return "[Face]"
        case .ELEM_TYPE_LOCATION:
            return "[Location]"
        case .ELEM_TYPE_NONE:
            return "[Unknown]"
        case .ELEM_TYPE_CUSTOM:
            return "[Unknown]"
        case .ELEM_TYPE_GROUP_TIPS:
            return "[Unknown]"
        @unknown default:
            return "[Unknown]"
        }
    }
    
    static func == (lhs: MessageElem, rhs: MessageElem) -> Bool {
        return lhs.timMessage.msgID == rhs.timMessage.msgID
    }

    static func < (lhs: MessageElem, rhs: MessageElem) -> Bool {
        return lhs.timMessage.timestamp.timeIntervalSince1970 < rhs.timMessage.timestamp.timeIntervalSince1970
    }
}

extension MessageElem: MessageType {
    
    public var sender: SenderType {
        return Sender(senderId: timMessage.sender, displayName: timMessage.nickName ?? "未知昵称", avatar: timMessage.faceURL ?? "")
    }

    /// The unique identifier for the message.
    var messageId: String {
        return timMessage.msgID
    }

    /// The date the message was sent.
    var sentDate: Date {
        return timMessage.timestamp as Date
    }

    /// The kind of message and its underlying kind.
    var kind: MessageKind {
        switch timMessage.elemType {
        case .ELEM_TYPE_TEXT:   //文本消息
            let text = timMessage.textElem.text!
            return .text(text)
        default:    //语音消息
            return .text("Default消息")
        }
    }
}

final class ChattingViewController: MessagesViewController, CustomNavigationBarItem {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    private var provider = OnlineProvider<SquadAPI>()
    private var disposeBag = DisposeBag()
    private var currentGroupAction: BehaviorRelay<ConversationAction>!
    
    lazy var audioController = BasicAudioController(messageCollectionView: messagesCollectionView)
    
    // 记录当前页的消息列表
    
    private var flagMessage: V2TIMMessage?
    private var messageList: [MessageElem] = []
    private let refreshControl = UIRefreshControl()
    private var createChannelsView: CreateChannelsView?
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    private let currentUser: Sender
    
    init(action: ConversationAction) {
        
        let user = User.currentUser()!
        currentUser = Sender(senderId: String(user.id), displayName: user.nickname, avatar: user.avatar)
        
        super.init(nibName: nil, bundle: nil)
        currentGroupAction = BehaviorRelay<ConversationAction>(value: action)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMessageCollectionView()
        configureMessageInputBar()
        setupBackBarItem()
        addTouchAction()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        V2TIMManager.sharedInstance()?.add(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 设置群消息已读
        if let groupId = currentGroupAction.value.groupId {
            V2TIMManager.sharedInstance()?.markGroupMessage(asRead: groupId, succ: {
                //TODO: 群消息置为已读
            }, fail: { (code, message) in
                //TODO: 将群消息置为已读操作失败
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        V2TIMManager.sharedInstance()?.remove(self)
    }
    
    private func addTouchAction() {
        currentGroupAction
            .distinctUntilChanged()
            .subscribe(onNext: { [unowned self] action in
                switch action {
                case .create:
                    // 将底部InputBar隐藏掉
                    self.isInputBarHidden = true
                    // 构建创建squad视图
                    self.setupCreateChannelsView()
                case .load(let groupId, let groupName, _):
                    // 将底部InputBar显示出来
                    self.isInputBarHidden = false
                    // 移除创建squad视图
                    self.removeCreateChannelsView()
                    // 创建会话, 加载消息
                    self.loadMessages(groupId: groupId, isFirst: true)
                    // 标题
                    self.title = groupName
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func configureMessageCollectionView() {
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        // 设置值后, cell的topLabel高度计算就出现问题了, 暂时不改此值
//        messagesCollectionView.messagesCollectionViewFlowLayout.sectionInset.top = 8
//        messagesCollectionView.messagesCollectionViewFlowLayout.sectionInset.bottom = 20
        scrollsToBottomOnKeyboardBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
        
        messagesCollectionView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(loadMoreMessages), for: .valueChanged)
    }
    
    private func configureMessageInputBar() {
        messageInputBar.delegate = self
        messageInputBar.inputTextView.theme.tintColor = UIColor.secondary
        messageInputBar.separatorLine.backgroundColor = UIColor(hexString: "#EEEEEE")
        messageInputBar.sendButton.theme.titleColor(from: UIColor.secondary, for: .normal)
        messageInputBar.sendButton.theme.titleColor(from: UIColor.secondary.map{ $0?.withAlphaComponent(0.3) }, for: .highlighted)
    }
    
    //MARK: - Input Bar
    
    var isInputBarHidden: Bool = false {
        didSet {
            isInputBarHiddenDidChange()
        }
    }
    
    func isInputBarHiddenDidChange() {
        if isInputBarHidden, isFirstResponder {
            resignFirstResponder()
        } else if !isFirstResponder {
            becomeFirstResponder()
        }
    }
    
    @discardableResult
    override func resignFirstResponder() -> Bool {
        messageInputBar.inputTextView.resignFirstResponder()
        return super.resignFirstResponder()
    }
    
    // MARK: - Helpers
    
    func insertMessage(_ message: MessageElem) {
        messageList.append(message)
        // Reload last section to update header/footer labels and insert a new one
        messagesCollectionView.performBatchUpdates({
            messagesCollectionView.insertSections([messageList.count - 1])
            if messageList.count >= 2 {
                messagesCollectionView.reloadSections([messageList.count - 2])
            }
        }, completion: { [weak self] _ in
            if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        })
    }
    
    func isLastSectionVisible() -> Bool {
        
        guard !messageList.isEmpty else { return false }
        
        let lastIndexPath = IndexPath(item: 0, section: messageList.count - 1)
        
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
}

// MARK: - MessagesDataSource
extension ChattingViewController: MessagesDataSource {
    
    func currentSender() -> SenderType {
        return self.currentUser
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if let timestamp = timeTipIfNeeded(current: message.sentDate, reference: messageList[safe: indexPath.section - 1]?.sentDate) {
            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: timestamp), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        }
        return nil
    }
    
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return NSAttributedString(string: "Read", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
    
    private func timeTipIfNeeded(current: Date, reference: Date?) -> Date? {
        if let referenceDate = reference {
            //判断时间间隔是否大于5分钟, 如果大于五分钟就返回followDate, 否则返回nil
            return current.timeIntervalSince(referenceDate) > TimeInterval(5*60) ? current : nil
        }
        return current
    }

}

extension ChattingViewController: MessageCellDelegate {
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        let friendReactor = FriendProfileReactor()
        let friendVC = FriendProfileViewController(reactor: friendReactor)
        navigationController?.pushViewController(friendVC, animated: true)
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("Message tapped")
    }
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        print("Image tapped")
    }
    
    func didTapCellTopLabel(in cell: MessageCollectionViewCell) {
        print("Top cell label tapped")
    }
    
    func didTapCellBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom cell label tapped")
    }
    
    func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
        print("Top message label tapped")
    }
    
    func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom label tapped")
    }

    func didTapPlayButton(in cell: AudioMessageCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell),
            let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView) else {
                print("Failed to identify message when audio cell receive tap gesture")
                return
        }
        guard audioController.state != .stopped else {
            // There is no audio sound playing - prepare to start playing for given audio message
            audioController.playSound(for: message, in: cell)
            return
        }
        if audioController.playingMessage?.messageId == message.messageId {
            // tap occur in the current cell that is playing audio sound
            if audioController.state == .playing {
                audioController.pauseSound(for: message, in: cell)
            } else {
                audioController.resumeSound()
            }
        } else {
            // tap occur in a difference cell that the one is currently playing sound. First stop currently playing and start the sound for given message
            audioController.stopAnyOngoingPlaying()
            audioController.playSound(for: message, in: cell)
        }
    }

    func didStartAudio(in cell: AudioMessageCell) {
        print("Did start playing audio sound")
    }

    func didPauseAudio(in cell: AudioMessageCell) {
        print("Did pause audio sound")
    }

    func didStopAudio(in cell: AudioMessageCell) {
        print("Did stop audio sound")
    }

    func didTapAccessoryView(in cell: MessageCollectionViewCell) {
        print("Accessory view tapped")
    }

}

// MARK: - MessageLabelDelegate, MessagesLayoutDelegate

extension ChattingViewController: MessageLabelDelegate, MessagesLayoutDelegate {
    
    func didSelectAddress(_ addressComponents: [String: String]) {
        print("Address Selected: \(addressComponents)")
    }
    
    func didSelectDate(_ date: Date) {
        print("Date Selected: \(date)")
    }
    
    func didSelectPhoneNumber(_ phoneNumber: String) {
        print("Phone Number Selected: \(phoneNumber)")
    }
    
    func didSelectURL(_ url: URL) {
        print("URL Selected: \(url)")
    }
    
    func didSelectTransitInformation(_ transitInformation: [String: String]) {
        print("TransitInformation Selected: \(transitInformation)")
    }

    func didSelectHashtag(_ hashtag: String) {
        print("Hashtag selected: \(hashtag)")
    }

    func didSelectMention(_ mention: String) {
        print("Mention selected: \(mention)")
    }

    func didSelectCustom(_ pattern: String, match: String?) {
        print("Custom data detector patter selected: \(pattern)")
    }

    // 时间戳消息的高度
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        let timestamp = timeTipIfNeeded(current: message.sentDate, reference: messageList[safe: indexPath.section - 1]?.sentDate)
        if timestamp != nil {
            return 25.0
        }
        return 0
    }
    
    // 用户昵称消息的高度
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
}

// MARK: - MessageInputBarDelegate

extension ChattingViewController: InputBarAccessoryViewDelegate {

    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {

        // Here we can parse for which substrings were autocompleted
        let attributedText = messageInputBar.inputTextView.attributedText!
        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.enumerateAttribute(.autocompleted, in: range, options: []) { (_, range, _) in

            let substring = attributedText.attributedSubstring(from: range)
            let context = substring.attribute(.autocompletedContext, at: 0, effectiveRange: nil)
            print("Autocompleted: `", substring, "` with context: ", context ?? [])
        }

        let components = inputBar.inputTextView.components
        messageInputBar.inputTextView.text = String()
        messageInputBar.invalidatePlugins()

        // Send button activity animation
        messageInputBar.sendButton.startAnimating()
        messageInputBar.inputTextView.placeholder = "Sending..."
        insertMessages(components) { [weak self](msg) in
            self?.messageInputBar.sendButton.stopAnimating()
            self?.messageInputBar.inputTextView.placeholder = "Aa"
            self?.insertMessage(msg)
            self?.messagesCollectionView.scrollToBottom(animated: true)
        }
    }

    private func insertMessages(_ data: [Any], successCompletion: @escaping(MessageElem) -> Void) {
        for component in data {
            if let str = component as? String {
                if let message = V2TIMManager.sharedInstance()?.createTextMessage(str) {
                    self.sendMessage(message: message, successCompletion: successCompletion)
                }
            } else if let img = component as? UIImage {
//                let message = MockMessage(image: img, user: user, messageId: UUID().uuidString, date: Date())
//                insertMessage(message)
//                let user = self.currentSender
            }
        }
    }
}

extension ChattingViewController: MessagesDisplayDelegate {
    func didTapBackground(in cell: MessageCollectionViewCell) {
        messageInputBar.inputTextView.resignFirstResponder()
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if let sender = message.sender as? Sender  {
            let placeholder = UIImage(named: "Avatar Placeholder")?.drawColor(.black)
            avatarView.kf.setImage(with: sender.avatar?.asURL, placeholder: placeholder, options: nil, progressBlock: nil, completionHandler: nil)
        } else {
            avatarView.initials = "?"
        }
    }
}

extension ChattingViewController: V2TIMAdvancedMsgListener {
    
    private func loadMessages(groupId: String, isFirst: Bool) {
        
        V2TIMManager.sharedInstance()?.getGroupHistoryMessageList(groupId, count: 20, lastMsg: self.flagMessage, succ: { (list) in

            guard let list = list, !list.isEmpty else {
                //将下拉加载恢复为默认状态
                if !isFirst { self.refreshControl.endRefreshing() }
                return
            }

            // 将拉取到的最后一条消息(时间戳最靠前, 最老), 置为下次拉取的指针
            if let message = list.last {
                self.flagMessage = message
            }

            //TODO: 利用多线程下载任务
            var newList = Array<MessageElem>()
            for msg in list {
                let message = MessageElem(timMessage: msg)
                newList.append(message)
            }
            // 虽然sdk已经为我们将消息内容排好序了, 可我们这里进行多线程下载任务后, 任务完成的时间是不确定的, 所以下面再重新排序一下
            if isFirst {
                self.messageList = newList.sorted()
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToBottom()
            } else {
                self.messageList = newList.sorted() + self.messageList
                self.messagesCollectionView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }, fail: { (code, message) in
            self.showToast(message: message ?? "获取消息未知错误")
        })
    }

    @objc
    private func loadMoreMessages() {
        if let groupId = currentGroupAction.value.groupId  {
            loadMessages(groupId: groupId, isFirst: false)
        } else {
            refreshControl.endRefreshing()
        }
    }

    // 发送一条消息
    private func sendMessage(message: V2TIMMessage, successCompletion: @escaping (MessageElem) -> Void) {

        guard let groupId = currentGroupAction.value.groupId else { return }

        let pushInfo = V2TIMOfflinePushInfo()
        pushInfo.title = "\(groupId)发来一条消息"
        pushInfo.desc = "这是内容: \(message.description)"

        V2TIMManager.sharedInstance()?.send(message, receiver: nil,
                                            groupID: groupId,
                                            priority: .PRIORITY_DEFAULT,
                                            onlineUserOnly: false,
                                            offlinePushInfo: pushInfo,
                                            progress: { _ in },
                                            succ: {
            
            // 如果为空, 表示本地没有加载到消息, 这时将发送出去的第一条消息置为指针, 下次拉取资料就以这个指针指向为准
            if self.flagMessage == nil {
                self.flagMessage = message
            }
            
            // 将本条消息显示在列表中
            let message = MessageElem(timMessage: message)
            successCompletion(message)
        }, fail: { (code, message) in
            self.showToast(message: message ?? "发送未知错误")
        })
    }
    
    /// 收到新消息
    func onRecvNewMessage(_ msg: V2TIMMessage!) {
        // 只有当前会话才可以处理
        guard let groupId = currentGroupAction.value.groupId, msg.groupID == groupId else { return }
        
        let message = MessageElem(timMessage: msg)
        self.messageList.append(message)
        self.messagesCollectionView.reloadData()
    }

    /// 收到消息已读回执（仅单聊有效）
    func onRecvC2CReadReceipt(_ receiptList: [V2TIMMessageReceipt]!) {
        
    }

    /// 收到消息撤回
    func onRecvMessageRevoked(_ msgID: String!) {
        
    }
    
}

//MARK: - Create Channel
extension ChattingViewController {
    
    // 构建创建Channel的视图
    private func setupCreateChannelsView() {
        
        guard let navView = navigationController?.view, !navView.subviews.contains(where: { $0 is CreateChannelsView }) else { return
        }
        
        let createView = CreateChannelsView()
        createView.bounds = CGRect(x: 0, y: 0, width: navView.bounds.width - 32, height: 357)
        createView.center = CGPoint(x: navView.bounds.midX, y: navView.bounds.midY)
        createView.backgroundColor = .white
        createView.layer.cornerRadius = 8
        createView.layer.shadowOpacity = 1
        createView.layer.shadowRadius = 20
        createView.layer.shadowOffset = CGSize(width: 0, height: 2)
        createView.layer.shadowColor = UIColor(red: 0.148, green: 0.141, blue: 0.512, alpha: 0.25).cgColor
        self.createChannelsView = createView
        
        let blurEffect = UIBlurEffect(style: .extraLight)
        let effectView = UIVisualEffectView(effect: blurEffect)
        effectView.frame = navView.bounds
        effectView.contentView.addSubview(createView)
        navView.addSubview(effectView)
        
        createView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        UIView.animate(withDuration: 0.25, animations: {
            createView.transform = CGAffineTransform.identity
        })
        
        createView.confirmBtn.addTarget(self, action: #selector(createChannelConfirmBtnDidTapped(sender:)), for: .touchUpInside)
        createView.closeBtn.addTarget(self, action: #selector(createChannelCloseBtnDidTapped), for: .touchUpInside)
    }
    
    // 移除channel视图
    private func removeCreateChannelsView() {
        let effectView = navigationController?.view.subviews.first(where: { $0 is UIVisualEffectView })
        UIView.animate(withDuration: 0.25, animations: {
            effectView?.alpha = 0
        }, completion: { _ in
            effectView?.removeFromSuperview()
        })
    }
    
    @objc
    private func createChannelCloseBtnDidTapped() {
        let effectView = navigationController?.view.subviews.first(where: { $0 is UIVisualEffectView })
        self.navigationController?.popViewController(animated: false)
        UIView.animate(withDuration: 0.25, animations: {
            effectView?.alpha = 0
        }, completion: { _ in
            effectView?.removeFromSuperview()
        })
    }
    
    @objc
    private func createChannelConfirmBtnDidTapped(sender: UIButton) {
        
        sender.isEnabled = false
        showLoading(offsetY: 0)
        
        guard
            let accountId = User.currentUser()?.id,
            let groupName = createChannelsView?.textField.text,
            let avatarData = createChannelsView?.imageTextView.snapshot()?.pngData(),
            case let .create(squadId) = currentGroupAction.value else {
            return
        }
        
        // 拿到groupName, avatarData后准备发起请求去创建该channel
        let createChannel: Observable<Result<CreateChannel, GeneralError>> = provider.request(target: .createChannel(squadId: squadId, name: groupName, avatar: avatarData, ownerAccountId: accountId), model: CreateChannel.self, atKeyPath: .data).asObservable()
        let members: Observable<Result<Array<String>, GeneralError>> = provider.request(target: .getMembersFromSquad(squadId: squadId), model: Array<User>.self, atKeyPath: .data).asObservable()
            .map{
                switch $0 {
                case .success(let list):
                    // 获取squad中的所有成员, 过滤掉自己
                    return .success(list.filter{ User.currentUser()?.id != $0.id }.map{ String($0.id) })
                case .failure(let error):
                    return .failure(error)
                }
            }
        
        Observable
            .zip(createChannel, members)
            .flatMap { [unowned self] (channelResult, membersResult) -> Observable<Result<(String, String), GeneralError>> in
                switch (channelResult, membersResult) {
                case (.success(let model), .success(let members)):
                    return self.createGroupsFromTIM(groupId: String(model.id), groupName: model.channelName, faceURL: model.headImgUrl, inviteMembers: members)
                case (.failure(let channelError), .failure):
                    return Observable.just(.failure(.custom(channelError.message)))
                case (.failure(let channelError), .success):
                    return Observable.just(.failure(.custom(channelError.message)))
                case (.success(let model), .failure):
                    return self.createGroupsFromTIM(groupId: String(model.squadId), groupName: model.channelName, faceURL: model.headImgUrl, inviteMembers: [])
                }
            }
            .subscribe(onNext: { [unowned self] result in
                
                self.hideLoading()
                sender.isEnabled = true
                
                switch result {
                case .success(let groupId, let groupName):
                    self.currentGroupAction.accept(.load(groupId: groupId, groupName: groupName, squadId: squadId))
                case .failure(let error):
                    self.showToast(message: error.message)
                }
            })
            .disposed(by: disposeBag)
    }
    
    /// 从TIM中创建一个群
    /// - Parameter groupId: 自定义群组id
    /// - Parameter groupName: 群名称
    /// - Parameter faceURL: 群头像
    /// - Parameter inviteMembers: 准备受邀加入的成员列表
    private func createGroupsFromTIM(groupId: String,
                                     groupName: String,
                                     faceURL: String,
                                     inviteMembers: Array<String> = []) -> Observable<Result<(String, String), GeneralError>> {
        return Observable.create { (observer) -> Disposable in
            
            let memberList: Array<V2TIMCreateGroupMemberInfo> = inviteMembers.map {
                let memberInfo = V2TIMCreateGroupMemberInfo()
                memberInfo.role = .GROUP_MEMBER_ROLE_MEMBER
                memberInfo.userID = $0
                return memberInfo
            }
            
            let info = V2TIMGroupInfo()
            info.groupID = groupId
            info.groupType = "Work"
            info.faceURL = faceURL
            info.groupName = groupName
            
            V2TIMManager.sharedInstance()?.createGroup(info, memberList: memberList, succ: { (id) in
                observer.onNext(.success((groupId, groupName)))
                observer.onCompleted()
            }, fail: { (code, message) in
                observer.onNext(.failure(.custom(message ?? "未知错误")))
                observer.onCompleted()
            })
            
            return Disposables.create()
        }
    }
}



