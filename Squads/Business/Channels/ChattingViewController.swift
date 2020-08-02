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
import ImSDK
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

final class ChattingViewController: InputBarViewController {
    
    private var contentView = MessagesContentView()
    private var createChannelsView: CreateChannelsView?
    
    private var messageList: [MessageElem] = []
    private var conversation: Conversation?
    
    private var provider = OnlineProvider<SquadAPI>()
    private var disposeBag = DisposeBag()
    private var conversationActionRelay: BehaviorRelay<ConversationAction>!
    
    init(action: ConversationAction) {
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentView.isMessagesControllerBeingDismissed = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        contentView.removeKeyboardObservers()
        contentView.isMessagesControllerBeingDismissed = true
        // 移除消息监听, 释放资源
        conversation?.free()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        contentView.isMessagesControllerBeingDismissed = false
    }
    
    private func setupView() {
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
                    self.loadMessages(groupId: groupId)
                }
            })
            .disposed(by: disposeBag)
        
        inputBar.sendButton.onTouchUpInside { [unowned self] (item) in
            guard let text = self.inputBar.inputTextView.text, let sender = User.currentUser() else {
                return
            }
            let elem = MessageElem(text: text, sender: sender)
            self.sendMessage(message: elem)
        }
    }

    private func loadMessages(groupId: String) {
        
        conversation = ConversationManager.shared.holdChat(with: .GROUP, id: groupId)
        
        // 监听消息
        conversation?.listenerNewMessage(completion: { [unowned self] list in
            self.messageList = list + self.messageList
            self.contentView.messagesCollectionView.reloadData()
        })
        
        loadFirstMessages()
    }
    
    @objc
    private func loadMoreMessages() {
        // 加载消息
        conversation?.loadRecentMessages(count: 20, completion: { [unowned self] result in
            switch result {
            case .success(let list):
                self.messageList = list + self.messageList
                self.contentView.messagesCollectionView.reloadData()
                self.contentView.refreshControl.endRefreshing()
            case .failure(let error):
                self.showToast(message: error.message)
            }
        })
    }
    
    // 第一次加载消息
    private func loadFirstMessages() {
        conversation?.loadRecentMessages(count: 20, completion: { [unowned self] result in
            switch result {
            case .success(let list):
                self.messageList = list
                self.contentView.messagesCollectionView.reloadData()
                self.contentView.messagesCollectionView.scrollToBottom()
            case .failure(let error):
                self.showToast(message: error.message)
            }
        })
    }
    
    // 发送一条消息
    private func sendMessage(message: MessageElem) {
        conversation?.send(message: message, result: { [unowned self](result) in
            switch result {
            case .success:
                self.messageList.append(message)
                self.contentView.messagesCollectionView.reloadData()
                self.contentView.messagesCollectionView.scrollToBottom()
            case .failure(let error):
                self.showToast(message: error.message)
            }
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
            
            let groupManager = TIMManager.sharedInstance()?.groupManager()
            
            let info = TIMCreateGroupInfo()
            info.groupType = "Public"
            info.addOpt = TIMGroupAddOpt.GROUP_ADD_ANY
            info.group = groupId
            info.faceURL = faceURL
            info.groupName = groupName
            info.membersInfo = inviteMembers.map {
                let memberInfo = TIMCreateGroupMemberInfo()
                memberInfo.role = .GROUP_MEMBER_ROLE_MEMBER
                memberInfo.member = $0
                return memberInfo
            }
            
            groupManager?.createGroup(info, succ: { (id) in
                observer.onNext(.success(id!))
                observer.onCompleted()
            }, fail: { (code, message) in
                observer.onNext(.failure(.custom(message ?? "未知错误")))
                observer.onCompleted()
            })
            
            return Disposables.create()
        }
    }
}

extension ChattingViewController: MessageCellDelegate, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    func didTapBackground(in cell: MessageCollectionViewCell) {
        contentView.messageInputBar.inputTextView?.resignFirstResponder()
    }
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        let friendReactor = FriendProfileReactor()
        let friendVC = FriendProfileViewController(reactor: friendReactor)
        navigationController?.pushViewController(friendVC, animated: true)
    }
    
}

import RxSwift

extension Reactive where Base: MessagesCollectionView {
    
    func dataSource(isScrollToBottom: Bool = false, ownerSender: SenderType) -> Binder<Array<MessageType>> {
        return Binder(self.base) { collectionView, list in
            
            let proxy = RxMessagesDataSourceProxy.proxy(for: self.base)
            proxy.ownerSender = ownerSender
            proxy.messageList = list
            
            collectionView.reloadData()
            if isScrollToBottom {
                collectionView.scrollToBottom()
            }
        }
    }
}

class RxMessagesDataSourceProxy: DelegateProxy<MessagesCollectionView, MessagesDataSource>, MessagesDataSource, DelegateProxyType {
    
    static func setCurrentDelegate(_ delegate: MessagesDataSource?, to object: MessagesCollectionView) {
        object.messagesDataSource = delegate
    }
    
    var ownerSender: SenderType!
    var messageList: [MessageType]!
    
    init(collectionView: MessagesCollectionView) {
        super.init(parentObject: collectionView, delegateProxy: RxMessagesDataSourceProxy.self)
    }
    
    func currentSender() -> SenderType {
        return ownerSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
         return messageList[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
    
    static func registerKnownImplementations() {
        self.register{ RxMessagesDataSourceProxy(collectionView: $0) }
    }
    
    static func currentDelegate(for object: MessagesCollectionView) -> MessagesDataSource? {
        return object.messagesDataSource
    }
    
}
