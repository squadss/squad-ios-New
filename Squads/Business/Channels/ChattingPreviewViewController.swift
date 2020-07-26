//
//  ChattingPreviewViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/20.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import Hero
import MessageKit
import InputBarAccessoryView

class ChattingPreviewViewController: ReactorViewController<ChattingPreviewReactor> {
    
    var chattingView: ChattingCardView!
    
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
        
        chattingView = ChattingCardView.hero()
        chattingView.headerView.switchBtn.addTarget(self, action: #selector(btnDidTapped), for: .touchUpInside)
        chattingView.headerView.switchBtn.isSelected = true
        chattingView.loadFirstMessages()
        view.addSubviews(chattingView)
    }
    
    @objc
    private func btnDidTapped() {
        dismiss(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        chattingView.contentView.addKeyboardObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        chattingView.contentView.isMessagesControllerBeingDismissed = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        chattingView.contentView.removeKeyboardObservers()
        chattingView.contentView.isMessagesControllerBeingDismissed = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        chattingView.contentView.isMessagesControllerBeingDismissed = false
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        let friendReactor = FriendProfileReactor()
        let friendVC = FriendProfileViewController(reactor: friendReactor)
        navigationController?.pushViewController(friendVC, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        chattingView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
    }
}
