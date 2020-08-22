//
//  Rx+TImer.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/26.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension Observable where Element: Hashable {
    
    /**
     用 Rx 封装的 Timer
     # 用法 #
     ```swift
     
     Observable<TimeInterval>.timer(duration: 5, interval: 1)
     .subscribe(
     onNext: { remain in
     print("剩余：", remain)
     },
     onCompleted: {
     print("计时结束！")
     }
     )
     .disposed(by: disposeBag)
     
     ```
     
     ## 结果 ##
     
     ```swift
     剩余： 5.0
     剩余： 4.0
     剩余： 3.0
     剩余： 2.0
     剩余： 1.0
     剩余： 0.0
     计时结束！
     ```
     - parameter duration: 总时长
     - parameter interval: 时间间隔
     - parameter ascending: true 为顺数计时，false 为倒数计时
     */
    
    public static func timer(duration: Int,
                             interval: Int,
                             ascending: Bool = false,
                             scheduler: SchedulerType = MainScheduler.instance)
        -> Observable<Int> {
            let count = Int(duration / interval) + 1
            return Observable<Int>.timer(.seconds(0), period: .seconds(interval), scheduler: scheduler)
                .map { $0 * interval }
                .map { ascending ? $0 : (duration - $0) }
                .take(count)
    }
}
