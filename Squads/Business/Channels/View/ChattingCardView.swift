//
//  ChattingCardView.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/11.
//  Copyright © 2020 Squads. All rights reserved.
//

import MessageKit
import ReactorKit
import RxSwift
import RxCocoa
import RxDataSources

class ChattingCardView: BaseView {
    
    var headerView = ChattingCardHeaderView()
    var contentView = MessagesContentView()
    var messageList: [MockMessage] = []
    
    private var borderLayer = CAShapeLayer()
    override var frame: CGRect {
        didSet {
            guard frame != oldValue && frame != .zero else { return }
            print(frame)
            let roundPath = UIBezierPath(roundedRect: bounds,
                                         byRoundingCorners: [.topLeft, .topRight],
                                         cornerRadii: CGSize(width: 20, height: 20))
            borderLayer.path = roundPath.cgPath
        }
    }
    
    func loadFirstMessages() {
//        DispatchQueue.global(qos: .userInitiated).async {
//            let count = UserDefaults.standard.mockMessagesCount()
//            SampleData.shared.getMessages(count: count) { messages in
//                DispatchQueue.main.async {
        self.messageList = [MockMessage(sender: MockUser(senderId: "1", displayName: "Tom"), messageId: "1", sentDate: Date(), kind: .text("Hello!")), MockMessage(sender: MockUser(senderId: "2", displayName: "小丽"), messageId: "2", sentDate: Date(), kind: .text("你好啊")), MockMessage(sender: MockUser(senderId: "1", displayName: "Tom"), messageId: "3", sentDate: Date(), kind: .text("Good morning!"))]
        self.contentView.messagesCollectionView.reloadData()
        self.contentView.messagesCollectionView.scrollToBottom()
//                }
//            }
//        }
    }
    
    override func setupView() {
        
        borderLayer.fillColor = UIColor(red: 0.946, green: 0.946, blue: 0.946, alpha: 1).cgColor
        layer.addSublayer(borderLayer)
        
        contentView.messagesCollectionView.messageCellDelegate = self
        contentView.messagesCollectionView.messagesDataSource = self
        contentView.messagesCollectionView.messagesLayoutDelegate = self
        contentView.messagesCollectionView.messagesDisplayDelegate = self
        contentView.backgroundColor = UIColor(red: 0.946, green: 0.946, blue: 0.946, alpha: 1)
        contentView.refreshControl.addTarget(self, action: #selector(loadMoreMessages), for: .valueChanged)
        addSubviews(headerView, contentView)
    }
    
    @objc
    func loadMoreMessages() {
//        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 1) {
//            SampleData.shared.getMessages(count: 20) { messages in
//                DispatchQueue.main.async {
//                    self.messageList.insert(contentsOf: messages, at: 0)
//                    self.messagesCollectionView.reloadDataAndKeepOffset()
//                    self.refreshControl.endRefreshing()
//                }
//            }
//        }
        
        //TODO: 加载更多消息
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        headerView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 70)
        contentView.frame = CGRect(x: 0, y: headerView.frame.maxY, width: bounds.width, height: bounds.height - headerView.frame.maxY)
    }
}

extension ChattingCardView: MessageCellDelegate, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    func didTapBackground(in cell: MessageCollectionViewCell) {
        contentView.messageInputBar.inputTextView?.resignFirstResponder()
    }
    
    func currentSender() -> SenderType {
        return MockUser(senderId: "1", displayName: "Tom")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
    
}

//Test
struct MockUser: SenderType, Equatable {
    var senderId: String
    var displayName: String
}

struct MockMessage: MessageType {
    
    var sender: SenderType
    
    var messageId: String
    
    var sentDate: Date
    
    var kind: MessageKind
    
}

extension ChattingCardView {
    
    static func hero() -> ChattingCardView {
        let card = ChattingCardView()
        card.hero.id = "ChattingCardView"
        card.headerView.hero.id = "ChattingCardHeaderView"
        card.contentView.hero.id = "ChattingCardContentView"
        card.headerView.switchBtn.hero.id = "ChattingCardHeaderSwitchView"
        card.headerView.switchBtn.hero.modifiers = [.fade]
        card.contentView.messagesCollectionView.hero.id = "MessagesCollectionView"
        card.contentView.messageInputBar.hero.id = "MessageInputBar"
        return card
    }
}

