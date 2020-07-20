//
//  ChattingViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/7.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import Hero
import MessageKit
import InputBarAccessoryView

class ChattingViewController: ReactorViewController<ChattingReactor> {
    
    var contentView = MessagesContentView()
    var messageList: [MockMessage] = []
    
    open override var canBecomeFirstResponder: Bool {
        return true
    }
    
    open lazy var messageInputBar = InputBarAccessoryView()

    open override var inputAccessoryView: UIView? {
        return messageInputBar
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.theme.backgroundColor = UIColor.background
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        contentView.addKeyboardObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentView.isMessagesControllerBeingDismissed = false
        
        //FIXME: - 它不属于这, 放着只是为了测试使用
        setupCreateChannelsView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        contentView.removeKeyboardObservers()
        contentView.isMessagesControllerBeingDismissed = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        contentView.isMessagesControllerBeingDismissed = false
    }
    
    override func setupView() {
        contentView.messagesCollectionView.messageCellDelegate = self
        contentView.messagesCollectionView.messagesDataSource = self
        contentView.messagesCollectionView.messagesLayoutDelegate = self
        contentView.messagesCollectionView.messagesDisplayDelegate = self
        contentView.backgroundColor = UIColor(red: 0.946, green: 0.946, blue: 0.946, alpha: 1)
        contentView.refreshControl.addTarget(self, action: #selector(loadMoreMessages), for: .valueChanged)
        view.addSubviews(contentView)
    }
    
    override func setupConstraints() {
        contentView.snp.safeFull(parent: self)
    }
    
    override func bind(reactor: ChattingReactor) {
        
    }

    @objc
    private func loadMoreMessages() {
        loadFirstMessages()
    }
    
    func loadFirstMessages() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.messageList = [MockMessage(sender: MockUser(senderId: "2", displayName: "小丽"), messageId: "1", sentDate: Date(), kind: .text("你好")), MockMessage(sender: MockUser(senderId: "2", displayName: "小丽"), messageId: "2", sentDate: Date(), kind: .text("你你好你好你好你好好")), MockMessage(sender: MockUser(senderId: "2", displayName: "小丽"), messageId: "3", sentDate: Date(), kind: .text("你好你好你好你好你好你好"))]
            self.contentView.messagesCollectionView.reloadData()
            self.contentView.messagesCollectionView.scrollToBottom()
            self.contentView.refreshControl.endRefreshing()
        }
    }
    
    private func setupCreateChannelsView() {
        
        guard let navView = navigationController?.view else { return }
        
        let createView = CreateChannelsView()
        createView.bounds = CGRect(x: 0, y: 0, width: navView.bounds.width - 32, height: 357)
        createView.center = CGPoint(x: navView.bounds.midX, y: navView.bounds.midY)
        createView.backgroundColor = .white
        createView.layer.cornerRadius = 8
        createView.layer.shadowOpacity = 1
        createView.layer.shadowRadius = 20
        createView.layer.shadowOffset = CGSize(width: 0, height: 2)
        createView.layer.shadowColor = UIColor(red: 0.148, green: 0.141, blue: 0.512, alpha: 0.25).cgColor
        
        let tempView = UIView(frame: navView.bounds)
        tempView.addSubview(createView)
        tempView.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        navView.addSubview(tempView)
        
        createView.closeBtn.rx.tap
            .subscribe(onNext: {
                UIView.animate(withDuration: 0.25, animations: {
                    createView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                    tempView.alpha = 0
                }, completion: { _ in
                    tempView.removeFromSuperview()
                })
            })
            .disposed(by: disposeBag)
    }
}

extension ChattingViewController: MessageCellDelegate, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    func didTapBackground(in cell: MessageCollectionViewCell) {
        contentView.messageInputBar.inputTextView?.resignFirstResponder()
    }
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        let friendReactor = FriendProfileReactor()
        let friendVC = FriendProfileViewController(reactor: friendReactor)
        navigationController?.pushViewController(friendVC, animated: true)
    }
    
    func currentSender() -> SenderType {
        return MockUser(senderId: "1", displayName: "哈哈哈")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
    
}
