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
    case load(groupId: String, squadId: Int)
    
    static func == (lhs: ConversationAction, rhs: ConversationAction) -> Bool {
        switch (lhs, rhs) {
        case (.create(let l_id), .create(let r_id)): return l_id == r_id
        case (.load(let l_gid, let l_sid), .load(let r_gid, let r_sid)): return l_gid == r_gid && l_sid == r_sid
        default: return false
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

struct SquadMember: Codable {
    let id: Int
    let accountId: Int
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
        return Sender(senderId: timMessage.sender, displayName: timMessage.nickName, avatar: timMessage.faceURL)
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

final class ChattingViewController: InputBarViewController {
    
    private var contentView = MessagesContentView()
    private var createChannelsView: CreateChannelsView?
    
    private var messageList: [MessageElem] = []
    
    private var provider = OnlineProvider<SquadAPI>()
    private var disposeBag = DisposeBag()
    private var conversationActionRelay: BehaviorRelay<ConversationAction>!
    
    private let currentUser: Sender
    
    init(action: ConversationAction) {
        
        let user = User.currentUser()!
        currentUser = Sender(senderId: String(user.id), displayName: user.nickname, avatar: user.avatar)
        
        super.init(nibName: nil, bundle: nil)
        conversationActionRelay = BehaviorRelay<ConversationAction>(value: action)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.theme.backgroundColor = UIColor.background
        setupView()
        addTouchAction()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        contentView.addKeyboardObservers()
        V2TIMManager.sharedInstance()?.add(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentView.isMessagesControllerBeingDismissed = false
        // 设置群消息已读
        if case let .load(groupId, _) = conversationActionRelay.value {
            V2TIMManager.sharedInstance()?.markGroupMessage(asRead: groupId, succ: {
                //TODO: 群消息置为已读
            }, fail: { (code, message) in
                //TODO: 将群消息置为已读操作失败
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        contentView.removeKeyboardObservers()
        contentView.isMessagesControllerBeingDismissed = true
        V2TIMManager.sharedInstance()?.remove(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        contentView.isMessagesControllerBeingDismissed = false
    }
    
    private func setupView() {
        contentView.messagesCollectionView.messagesDataSource = self
        contentView.messagesCollectionView.messageCellDelegate = self
        contentView.messagesCollectionView.messagesLayoutDelegate = self
        contentView.messagesCollectionView.messagesDisplayDelegate = self
        contentView.backgroundColor = UIColor(red: 0.946, green: 0.946, blue: 0.946, alpha: 1)
        contentView.refreshControl.addTarget(self, action: #selector(loadMoreMessages), for: .valueChanged)
        view.addSubviews(contentView)
        contentView.snp.safeFull(parent: self)
    }
    
    private func addTouchAction() {
        conversationActionRelay
            .distinctUntilChanged()
            .subscribe(onNext: { [unowned self] action in
                switch action {
                case .create:
                    // 将底部InputBar隐藏掉
                    self.isInputBarHidden = true
                    // 构建创建squad视图
                    self.setupCreateChannelsView()
                case .load(let groupId, _):
                    // 将底部InputBar显示出来
                    self.isInputBarHidden = false
                    // 移除创建squad视图
                    self.removeCreateChannelsView()
                    // 创建会话, 加载消息
                    self.loadMessages(groupId: groupId, isFirst: true)
                }
            })
            .disposed(by: disposeBag)
        
        inputBar.sendButton.onTouchUpInside { [unowned self] (item) in
            guard let text = self.inputBar.inputTextView.text else {
                return
            }
            if let message = V2TIMManager.sharedInstance()?.createTextMessage(text) {
                self.sendMessage(message: message)
            }
        }
    }

    private var lastMsg: V2TIMMessage?
    
    private func loadMessages(groupId: String, isFirst: Bool) {
        
        V2TIMManager.sharedInstance()?.getGroupHistoryMessageList(groupId, count: 20, lastMsg: lastMsg, succ: { (list) in
            
            guard let list = list, !list.isEmpty else {
                //将下拉加载恢复为默认状态
                if !isFirst { self.contentView.refreshControl.endRefreshing() }
                return
            }
            
            // 将拉取到的第一条消息, 置为指针, 便于下次拉取
            if let message = list.first {
                self.lastMsg = message
            }
            
            //TODO: 利用多线程下载任务
            var newList = Array<MessageElem>()
            for msg in list {
                let message = MessageElem(timMessage: msg)
                newList.append(message)
            }
            if isFirst {
                self.messageList = newList.sorted()
                self.contentView.messagesCollectionView.reloadData()
                self.contentView.messagesCollectionView.scrollToBottom()
            } else {
                self.messageList = newList.sorted() + self.messageList
                self.contentView.messagesCollectionView.reloadData()
                self.contentView.refreshControl.endRefreshing()
            }
        }, fail: { (code, message) in
            self.showToast(message: message ?? "获取消息未知错误")
        })
        
    }
    
    @objc
    private func loadMoreMessages() {
        guard case let .load(groupId, _) = conversationActionRelay.value else { return }
        loadMessages(groupId: groupId, isFirst: false)
    }
    
    // 发送一条消息
    private func sendMessage(message: V2TIMMessage) {

        guard case let .load(groupId, _) = conversationActionRelay.value else { return }
        
        let pushInfo = V2TIMOfflinePushInfo()
        pushInfo.title = "\(groupId)发来一条消息"
        pushInfo.desc = "这是内容: \(message.description)"
        
        V2TIMManager.sharedInstance()?.send(message, receiver: nil, groupID: groupId, priority: .PRIORITY_DEFAULT, onlineUserOnly: false, offlinePushInfo: pushInfo, progress: { (progress) in
            print("进度: \(progress)")
        }, succ: {
            
            if self.lastMsg == nil {
                print("message: \(message.msgID)")
                self.lastMsg = message
            }
            
            let message = MessageElem(timMessage: message)
            self.messageList.append(message)
            self.contentView.messagesCollectionView.reloadData()
            self.contentView.messagesCollectionView.scrollToBottom()
            
        }, fail: { (code, message) in
            self.showToast(message: message ?? "发送未知错误")
        })
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
            case let .create(squadId) = conversationActionRelay.value else {
            return
        }
        
        // 拿到groupName, avatarData后准备发起请求去创建该channel
        let createChannel: Observable<Result<CreateChannel, GeneralError>> = provider.request(target: .createChannel(squadId: squadId, name: groupName, avatar: avatarData, ownerAccountId: accountId), model: CreateChannel.self, atKeyPath: .data).asObservable()
        let members: Observable<Result<Array<String>, GeneralError>> = provider.request(target: .getMembersFromSquad(squadId: squadId), model: Array<SquadMember>.self, atKeyPath: .data).asObservable()
            .map{
                switch $0 {
                case .success(let list):
                    // 获取squad中的所有成员, 过滤掉自己
                    return .success(list.filter{ User.currentUser()?.id != $0.accountId }.map{ String($0.accountId) })
                case .failure(let error):
                    return .failure(error)
                }
            }
        
        Observable
            .zip(createChannel, members)
            .flatMap { [unowned self] (channelResult, membersResult) -> Observable<Result<String, GeneralError>> in
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
                case .success(let groupId):
                    self.conversationActionRelay.accept(.load(groupId: groupId, squadId: squadId))
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
                                     inviteMembers: Array<String> = []) -> Observable<Result<String, GeneralError>> {
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
                observer.onNext(.success(groupId))
                observer.onCompleted()
            }, fail: { (code, message) in
                observer.onNext(.failure(.custom(message ?? "未知错误")))
                observer.onCompleted()
            })
            
            return Disposables.create()
        }
    }
}

extension ChattingViewController: V2TIMAdvancedMsgListener {
    
    /// 收到新消息
    func onRecvNewMessage(_ msg: V2TIMMessage!) {
        let message = MessageElem(timMessage: msg)
        self.messageList.insert(message, at: 0)
        self.contentView.messagesCollectionView.reloadData()
        print("收到新消息: \(msg)")
    }

    /// 收到消息已读回执（仅单聊有效）
    func onRecvC2CReadReceipt(_ receiptList: [V2TIMMessageReceipt]!) {
        
    }

    /// 收到消息撤回
    func onRecvMessageRevoked(_ msgID: String!) {
        
    }
    
}

extension ChattingViewController: MessageCellDelegate, MessagesLayoutDelegate, MessagesDisplayDelegate, MessagesDataSource {
    
    func didTapBackground(in cell: MessageCollectionViewCell) {
        contentView.messageInputBar.inputTextView?.resignFirstResponder()
    }
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        let friendReactor = FriendProfileReactor()
        let friendVC = FriendProfileViewController(reactor: friendReactor)
        navigationController?.pushViewController(friendVC, animated: true)
    }

    func currentSender() -> SenderType {
        return self.currentUser
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
}
