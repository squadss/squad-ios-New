//
//  ReusePool.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/20.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit

final class ReusePool<T: UIView> {
  private var storage: [T]

  init() {
    storage = [T]()
  }

  func enqueue(views: [T]) {
    views.forEach{$0.frame = .zero}
    storage.append(contentsOf: views)
  }

  func dequeue() -> T {
    guard !storage.isEmpty else {return T()}
    return storage.removeLast()
  }
}
