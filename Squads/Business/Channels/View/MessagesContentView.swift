//
//  MessagesContentView.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/10.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView

class MessageInputBar: BaseView {
    var inputTextView: InputTextView?
    
    override func setupView() {
        inputTextView = InputTextView()
        addSubview(inputTextView!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        inputTextView?.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 44)
    }
}

class MessagesContentView: BaseView {
    
    let refreshControl = UIRefreshControl()
    var messagesCollectionView = MessagesCollectionView()
    var messageInputBar = MessageInputBar()
    
    // TODO: 在外部记录当前视图控制器的是否已经dismiss, 处理键盘收起/打开用
    var isMessagesControllerBeingDismissed: Bool = false
    // 和键盘弹出的属性相关
    var scrollsToBottomOnKeyboardBeginsEditing: Bool = false
    
    // 选中的cell, 用户显示menu信息
    public var selectedIndexPathForMenu: IndexPath?
    
    public var isTypingIndicatorHidden: Bool {
        return messagesCollectionView.isTypingIndicatorHidden
    }
    
    override func setupView() {
        messagesCollectionView.delegate = self
        messagesCollectionView.dataSource = self
        messagesCollectionView.keyboardDismissMode = .interactive
        messagesCollectionView.alwaysBounceVertical = true
        messagesCollectionView.backgroundColor = UIColor(red: 0.946, green: 0.946, blue: 0.946, alpha: 1)
        messagesCollectionView.addSubview(refreshControl)
        addSubviews(messagesCollectionView, messageInputBar)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        messageInputBar.frame = CGRect(x: 0, y: bounds.height - 50, width: bounds.width, height: 50)
        messagesCollectionView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: messageInputBar.frame.minY)
    }
}

extension MessagesContentView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let collectionView = collectionView as? MessagesCollectionView else {
            fatalError("需要使用MessagesCollectionView")
        }
        return collectionView.messagesDataSource?.numberOfItems(inSection: section, in: collectionView) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let messagesCollectionView = collectionView as? MessagesCollectionView else {
            fatalError("需要使用MessagesCollectionView")
        }

        guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
            fatalError("需要使用MessagesCollectionView")
        }

        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)

        switch message.kind {
        case .text, .attributedText, .emoji:
            let cell = messagesCollectionView.dequeueReusableCell(TextMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            cell.hero.modifiers = [.fade]
            return cell
        case .photo, .video:
            let cell = messagesCollectionView.dequeueReusableCell(MediaMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        case .location:
            let cell = messagesCollectionView.dequeueReusableCell(LocationMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        case .audio:
            let cell = messagesCollectionView.dequeueReusableCell(AudioMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        case .contact:
            let cell = messagesCollectionView.dequeueReusableCell(ContactMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        case .custom:
            return messagesDataSource.customCell(for: message, at: indexPath, in: messagesCollectionView)
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let collectionView = collectionView as? MessagesCollectionView else {
            fatalError("需要使用MessagesCollectionView")
        }
        let sections = collectionView.messagesDataSource?.numberOfSections(in: collectionView) ?? 0
        return collectionView.isTypingIndicatorHidden ? sections : sections + 1
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let messagesFlowLayout = collectionViewLayout as? MessagesCollectionViewFlowLayout else { return .zero }
        return messagesFlowLayout.sizeForItem(at: indexPath)
    }

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {

        guard let messagesCollectionView = collectionView as? MessagesCollectionView else {
            fatalError("需要使用MessagesCollectionView")
        }
        guard let layoutDelegate = messagesCollectionView.messagesLayoutDelegate else {
            fatalError("需要使用MessagesCollectionView")
        }
        
        return layoutDelegate.headerViewSize(for: section, in: messagesCollectionView)
    }

    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? TypingIndicatorCell else { return }
        cell.typingBubble.startAnimating()
    }

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard let messagesCollectionView = collectionView as? MessagesCollectionView else {
            fatalError("需要使用MessagesCollectionView")
        }
        guard let layoutDelegate = messagesCollectionView.messagesLayoutDelegate else {
            fatalError("需要使用MessagesCollectionView")
        }
        return layoutDelegate.footerViewSize(for: section, in: messagesCollectionView)
    }

    open func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else { return false }

        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)

        switch message.kind {
        case .text, .attributedText, .emoji, .photo:
            selectedIndexPathForMenu = indexPath
            return true
        default:
            return false
        }
    }

    open func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return (action == NSSelectorFromString("copy:"))
    }

    open func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
            fatalError("需要使用MessagesCollectionView")
        }
        let pasteBoard = UIPasteboard.general
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)

        switch message.kind {
        case .text(let text), .emoji(let text):
            pasteBoard.string = text
        case .attributedText(let attributedText):
            pasteBoard.string = attributedText.string
        case .photo(let mediaItem):
            pasteBoard.image = mediaItem.image ?? mediaItem.placeholderImage
        default:
            break
        }
    }
}
