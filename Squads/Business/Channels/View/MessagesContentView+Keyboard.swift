//
//  MessagesContentView+Keyboard.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/10.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import MessageKit
import ReactorKit
import InputBarAccessoryView

extension MessagesContentView {
    
    /// 添加监听事件
    func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(MessagesContentView.handleKeyboardDidChangeState(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MessagesContentView.handleTextViewDidBeginEditing(_:)), name: UITextView.textDidBeginEditingNotification, object: nil)
    }

    /// 移除监听事件
    func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UITextView.textDidBeginEditingNotification, object: nil)
    }
    
    @objc
    private func handleTextViewDidBeginEditing(_ notification: Notification) {
        if scrollsToBottomOnKeyboardBeginsEditing {
            guard let inputTextView = notification.object as? InputTextView,
                inputTextView === messageInputBar.inputTextView else { return }
            messagesCollectionView.scrollToBottom(animated: true)
        }
    }

    @objc
    private func handleKeyboardDidChangeState(_ notification: Notification) {
        guard !isMessagesControllerBeingDismissed else { return }
        
        guard
            let keyboardEndFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let keyboardBeginFrame = notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect,
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
            else { return }
        
        UIView.animate(withDuration: duration, delay: 0.0, options: UIView.AnimationOptions(rawValue: curve), animations: {
            self.willShowKeyboardFromFrame(keyboardBeginFrame, toFrame: keyboardEndFrame)
        }, completion: nil)
    }

    private func willShowKeyboardFromFrame(_ beginFrame: CGRect, toFrame: CGRect) {
        
        // 屏幕安全边距
        let layoutInsets = UIApplication.shared.keyWindow?.layoutInsets ?? .zero
        
        if beginFrame.origin.y == UIScreen.main.bounds.height {
            //显示键盘
            willShowBottomHeight(toFrame.size.height - layoutInsets.bottom)
            //TOOD: 如果有控制面板, 可以在这里将控制面板置为nil
        } else if toFrame.origin.y == UIScreen.main.bounds.height {
            //隐藏键盘
            willShowBottomHeight(0)
        } else {
            willShowBottomHeight(toFrame.height - layoutInsets.bottom)
        }
        
    }
    
    private func willShowBottomHeight(_ bottomHeight: CGFloat) {
        
        let fromFrame = messageInputBar.frame
        let toHeight = (messageInputBar.inputTextView?.frame.height ?? 0) + bottomHeight
        
        let toFrame = CGRect(x: fromFrame.origin.x,
                             y: fromFrame.origin.y + (fromFrame.height - toHeight),
                             width: fromFrame.width,
                             height: toHeight)
        
        if bottomHeight == 0 && messageInputBar.frame.height == messageInputBar.inputTextView?.frame.height {
            return
        }
        
        messageInputBar.frame = toFrame
        messagesCollectionView.frame = CGRect(x: 0, y: 0, width: messagesCollectionView.frame.width, height: toFrame.minY)
    }
}
