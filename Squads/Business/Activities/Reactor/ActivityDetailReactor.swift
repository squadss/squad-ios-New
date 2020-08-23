//
//  ActivityDetailReactor.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/7.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa

enum ActivityStatus: Int, Codable, Equatable {
    case prepare = 10            // 活动处于准备阶段, suqad中的任何人可以进来选自己的时间
    case setTime = 20            // 创建者已确认开始的时间
    case running = 30            // 活动进行中
}

class ActivityDetailReactor: Reactor {
    
    typealias Members = (list: Array<ActivityMember>, category: CrowdCategory)
    
    enum CrowdCategory: String {
        case responded  = "RESPONDED"
        case waiting    = "WAITING"
        case going      = "GOING"
        case reject     = "CAN'T MAKE IT"
        case busy       = "BUSY"
        case available  = "AVAILABLE"
    }
    
    enum Action {
        case requestDetail
        case setDetail(Array<TimePeriod>?, title: String?, location: SquadLocation?)
        case handlerGoing(isAccept: Bool)
        // 选择我的时间
        case selectTime(TimePeriod)
        case deleteEvent
    }
    
    enum Mutation {
        case setToast(String)
        case setLoading(Bool)
        case setRepos(detail: SquadActivity, top: Members?, bottom: Members?)
        case setSelectedTimes(Array<TimePeriod>)
        case setActivity(title: String?, location: SquadLocation?, status: ActivityStatus)
        case setExitActivity
    }
    
    struct State {
        var toast: String?
        var isLoading: Bool?
        // 是否退出该活动页
        var exitActivity: Bool?
        // 已经选中的时间
        var selectedTimes: Array<TimePeriod>?
        // 活动详情
        var repos: SquadActivity?
        // 我的资料, 从topMembers或bottomMembers中筛选出来的
        var currentMemberProfile: ActivityMember?
        var topMembers: MembersSection<ActivityMember>?
        var bottomMembers: MembersSection<ActivityMember>?
    }
    
    var initialState = State()
    var provider = OnlineProvider<SquadAPI>.init(stubClosure: { (api) in
        switch api {
//        case .getResponded, .getWaiting:
//            return .delayed(seconds: 1)
        default:
            return .never
        }
    })
    
    // 本地登录用户
    let accountId: Int = User.currentUser()!.id
    
    // 这里squadId其实后期可以拿掉, 有activityId就可以了
    let activityId: Int
    let squadId: Int
    
    init(activityId: Int, squadId: Int) {
        self.activityId = activityId
        self.squadId = squadId
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .requestDetail:
            
            let responded: Observable<Result<Array<ActivityMember>, GeneralError>> = provider.request(target: .getResponded(activityId: activityId), atKeyPath: .data).asObservable()
            
            let waiting: Observable<Result<Array<User>, GeneralError>> = provider.request(target: .getWaiting(activityId: activityId), atKeyPath: .data).asObservable()
            
            let detail: Observable<Result<SquadActivity, GeneralError>> = provider.request(target: .queryActivityInfo(activityId: activityId), atKeyPath: .data).asObservable()
            
            return Observable.zip(responded, waiting, detail).map { (respondedResult, waitingResult, detailResult) in
                switch (respondedResult, waitingResult, detailResult) {
                case (.success(let respondedList), .success(let waitingList), .success(let model)):
                    return .setRepos(detail: model, top: (respondedList, .responded), bottom: (waitingList.map{ ActivityMember(activityId: self.activityId, user: $0) }, .waiting))
                case (.success(let respondedList), .failure, .success(let model)):
                    return .setRepos(detail: model, top: (respondedList, .responded), bottom: nil)
                case (.failure, .success(let waitingList), .success(let model)):
                    return .setRepos(detail: model, top: nil, bottom: (waitingList.map{ ActivityMember(activityId: self.activityId, user: $0) }, .waiting))
                case (.failure(_), .failure(_), .success(let model)):
                    return .setRepos(detail: model, top: nil, bottom: nil)
                case (.success, .failure, .failure(let error)),
                     (.failure, .success, .failure(let error)),
                     (.success, .success, .failure(let error)),
                     (.failure, .failure, .failure(let error)):
                    return .setToast(error.message)
                }
            }.startWith(.setLoading(true))
        case .handlerGoing(let isAccept):
            return provider.request(target: .updateActivityMemberInfo(activityId: activityId, myTime: nil, isGoing: isAccept), model: GeneralModel.Plain.self).asObservable().map { result in
                switch result {
                case .success(let plain): return .setToast(plain.message)
                case .failure(let error): return .setToast(error.message)
                }
            }
        case let .setDetail(times, title, location):
            return provider.request(target: .setActivityInfo(activityId: activityId, squadId: squadId, title: title, location: location, setTime: times?.first, status: .setTime), model: GeneralModel.Plain.self).asObservable().map { result in
                switch result {
                case .success: return .setActivity(title: title, location: location, status: .setTime)
                case .failure(let error): return .setToast(error.message)
                }
            }.startWith(.setLoading(true))
        case .selectTime(let time):
            // 根据选中时间, 显示颜色图层
            var list: Array<TimePeriod> = currentState.topMembers?.list.flatMap{ $0.myTime } ?? []
            list.append(time)
            let newList = adjustColors(list)
            return Observable.just(.setSelectedTimes(newList))
        case .deleteEvent:
            return provider.request(target: .deleteActivity(activityId: activityId), model: GeneralModel.Plain.self).asObservable().map { result in
                switch result {
                case .success: return .setExitActivity
                case .failure(let error): return .setToast(error.message)
                }
            }.startWith(.setLoading(true))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .setLoading(let s):
            state.toast = nil
            state.isLoading = s
        case .setToast(let s):
            state.isLoading = false
            state.toast = s
        case let .setRepos(detail, top, bottom):
            var currentMemberProfile: ActivityMember?
            if let unwrappedTop = top {
                let list = unwrappedTop.list
                currentMemberProfile = list.first(where: { $0.accountId == accountId })
                state.topMembers = MembersSection(title: unwrappedTop.category.rawValue, list: list)
                
                // 页面加载进来, 需要显示出响应者的所选的时间
//                if detail.activityStatus == .prepare {
//                    let list: Array<ActivityMember> = unwrappedTop.list
//                    state.selectedTimes = list.flatMap{ $0.myTime }
//                }
            }
            if let unwrappedBottom = bottom {
                var list = unwrappedBottom.list
                let index = list.firstIndex(where: { $0.accountId == accountId })
                index.flatMap { currentMemberProfile = list.remove(at: $0) }
                state.bottomMembers = MembersSection(title: unwrappedBottom.category.rawValue, list: list)
            }
            state.repos = detail
            state.isLoading = false
            state.currentMemberProfile = currentMemberProfile
        case .setSelectedTimes(let list):
            state.selectedTimes = list
        case let .setActivity(title, location, activityStatus):
            if let unwrappedTitle = title {
                state.repos?.title = unwrappedTitle
            }
            if let unwrappedLocation = location {
                state.repos?.position = unwrappedLocation
            }
            state.repos?.activityStatus = activityStatus
            state.isLoading = false
        case .setExitActivity:
            state.isLoading = false
            state.toast = "Delete Success!"
            state.exitActivity = true
        }
        return state
    }
    
    // 通过IM里的群功能发送一条通告
    private func sentNotification(title: String) {
        V2TIMManager.sharedInstance()?.getJoinedGroupList({ (list) in
            var info = list?.first
            info?.notification = "这是我发送的通知"
            V2TIMManager.sharedInstance()?.setGroupInfo(info, succ: {
               print("修改成功")
            }, fail: { (code, message) in
               print("修改失败: \(message)")
            })
        }, fail: { (_, message) in
            print("获取群资料失败")
        })
    }
    
    // 整合颜色
    private func adjustColors(_ list: Array<TimePeriod>) -> Array<TimePeriod> {
        
        // 将时间按照每半小时一个格, 一天分为48个格来承载
        var halfHourGrids = Array<Int>(repeating: 0, count: 48)
        var currentDate: Date?
        var minNum: Int = 1
        var maxNum: Int = 1
        for time in list {
            if currentDate == nil {
                currentDate = time.middleDate
            }
            let startHour = converHalfHour(time.beginning)
            let endHour = converHalfHour(time.end)
            (startHour..<endHour).forEach { current in
                let num = halfHourGrids[current] + 1
                halfHourGrids[current] = num
                minNum = min(num, minNum)
                maxNum = max(num, maxNum)
            }
        }
        
        let calendar = Calendar.current
        guard let unwrappedCurrentDate = currentDate else {
            return []
        }
        let components = calendar.dateComponents([.year, .month, .day], from: unwrappedCurrentDate)
        guard let zeroDayTimestamp = calendar.date(from: components)?.timeIntervalSince1970 else {
            return []
        }
        
        // 颜色跨度
        func colorWith(_ elem: Int) -> TimeColor {
            if maxNum - minNum > 5 {
                switch elem {
                case minNum: return .level1
                case minNum + 1: return .level2
                case minNum + 2..<maxNum - 1: return .level3
                case maxNum - 1: return .level4
                case maxNum: return .level5
                default: return .normal
                }
            } else {
                switch elem {
                case minNum: return .level1
                case minNum + 1: return .level2
                case minNum + 2: return .level3
                case minNum + 3: return .level4
                case minNum + 4: return .level5
                default: return .normal
                }
            }
        }
        
        // 相邻两个时间点如果桶的数量相同, 将它们分到一组
        var newList = Array<TimePeriod>()
        var isContinuous: Bool = true
        for halfHour in halfHourGrids {
            
            let number = halfHourGrids[halfHour]
            
            if let time = newList.last {
                
                if number == time.num && isContinuous {
                    newList[newList.count - 1].end += 1800
                } else if number != 0 {
                    // 数组已经封口了, 需要重新添加一条数据
                    newList.append(TimePeriod(color: colorWith(number),
                                              beginning: zeroDayTimestamp + TimeInterval(halfHour * 1800),
                                              duration: 1800,
                                              num: number))
                    isContinuous = true
                }
            } else if number != 0 {
                // 数组还没有数据, 添加一条
                newList.append(TimePeriod(color: colorWith(number),
                                          beginning: zeroDayTimestamp + TimeInterval(halfHour * 1800),
                                          duration: 1800,
                                          num: number))
                isContinuous = true
            } else {
                isContinuous = false
            }
            
        }
        
        return newList
    }
    
    private func converHalfHour(_ timestamp: TimeInterval) -> Int {
        let currentDate = Date(timeIntervalSince1970: timestamp)
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: currentDate)
        return (components.hour ?? 0) * 2
    }
    /*
    func splitElement(prev time: TimePeriod, next current: TimePeriod) -> Array<TimePeriod> {
        
        let end = time.end
        let beginning = time.beginning
        var tempList = Array<TimePeriod>()
        
        // 首先判断两个元素他们的位置关系 (相交, 相邻, 包含)
        if beginning >= current.end || current.beginning >= end {
            // 相邻关系
            tempList.append(current)
            tempList.append(TimePeriod(color: time.color, beginning: beginning, end: end))
        } else if (beginning >= current.beginning && end <= current.end) || (current.beginning >= beginning && current.end <= end) {
            // 包含关系
            
            // large 包含 small
            let largeEnd = max(end, current.end)
            let smallEnd = min(end, current.end)
            let largeStart = min(beginning, current.beginning)
            let smallStart = max(beginning, current.beginning)
            let currentIsLarge: Bool = beginning >= current.beginning
            
            if smallStart - largeStart > 0 {
                let color: TimeColor = currentIsLarge ? current.color : time.color
                tempList.append(TimePeriod(color: color, beginning: largeStart, duration: smallStart - largeStart))
            }
            
            if largeEnd - smallEnd > 0 {
                let color: TimeColor = currentIsLarge ? current.color : time.color
                tempList.append(TimePeriod(color: color, beginning: smallEnd, duration: largeEnd - smallEnd))
            }
            
            if smallEnd != largeEnd || smallStart != largeStart {
                tempList.append(TimePeriod(color: current.color.next(), beginning: smallStart, end: smallEnd))
            }
            
        } else {
            // 相交关系
            let prevEnd = min(current.end, end)
            let nextEnd = max(current.end, end)
            let prevStart = min(current.beginning, beginning)
            let nextStart = max(current.beginning, beginning)
            let currentIsPrev: Bool = (current.beginning <= beginning && current.end < end) || (current.beginning < beginning && current.end <= end)
            
            if nextStart - prevStart > 0 {
                let color: TimeColor = currentIsPrev ? current.color : time.color
                tempList.append(TimePeriod(color: color, beginning: prevStart, duration: nextStart - prevStart))
            }
            
            if nextEnd - prevEnd > 0 {
                let color: TimeColor = currentIsPrev ? current.color : time.color
                tempList.append(TimePeriod(color: color, beginning: prevEnd, duration: nextEnd - prevEnd))
            }
            
            tempList.append(TimePeriod(color: current.color.next(), beginning: nextStart, end: prevEnd))
        }
        
        return tempList
    }
    */
}

extension ActivityDetailReactor {
    
    // 是否为创建者
    func isOwner() -> Bool {
        return accountId == currentState.currentMemberProfile?.accountId
    }
    
}
