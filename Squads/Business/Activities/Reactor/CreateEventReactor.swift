//
//  CreateEventReactor.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/11.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa

enum EventCategory: CaseIterable, Equatable {
    case food
    case coffee
    case hangout
    case work
    case exercise
    case other
    
    var themeColor: UIColor {
        switch self {
        case .food: return UIColor(red: 0.925, green: 0.384, blue: 0.337, alpha: 1)
        case .coffee: return UIColor(red: 0.616, green: 0.89, blue: 0.796, alpha: 1)
        case .hangout: return UIColor(red: 1, green: 0.664, blue: 0.438, alpha: 1)
        case .work: return UIColor(red: 0.157, green: 0.31, blue: 0.522, alpha: 1)
        case .exercise: return UIColor(red: 0.302, green: 0.69, blue: 0.78, alpha: 1)
        case .other: return UIColor(red: 0.532, green: 0.432, blue: 0.817, alpha: 1)
        }
    }
    
    var title: String {
        switch self {
        case .food: return "Food"
        case .coffee: return "Coffee"
        case .hangout: return "Hangout"
        case .work: return "Work"
        case .exercise: return "Exercise"
        case .other: return "Other"
        }
    }
    
    static func == (lhs: EventCategory, rhs: EventCategory) -> Bool {
        return lhs.title == rhs.title
    }
}

struct CreateEventLabels: CreateEventModelPrimaryKey {
    var list: Array<EventCategory>
    var selected: EventCategory?
}

struct SquadLocation: Equatable {
    // 地址
    var address: String
    // 经度
    var longitude: Double
    // 纬度
    var latitude: Double
    
    static func == (lhs: SquadLocation, rhs: SquadLocation) -> Bool {
        return lhs.address == rhs.address
            && lhs.longitude == rhs.longitude
            && lhs.latitude == rhs.latitude
    }
}

enum CreateEventTextEditor: CreateEventModelPrimaryKey, Equatable {
    case title(text: String)
    case location(value: SquadLocation?, attachImageNamed: String?)
    
    static func == (lhs: CreateEventTextEditor, rhs: CreateEventTextEditor) -> Bool {
        switch (lhs, rhs) {
        case (.title(let l_t), .title(let r_t)): return l_t == r_t
        case (.location(let l_v, _), .location(let r_v, _)): return l_v == r_v
        default: return false
        }
    }
    
    var placeholder: String? {
        switch self {
        case .title: return "Enter title"
        case .location: return "Enter location"
        }
    }
}

struct CreateEventCalendar: CreateEventModelPrimaryKey {
    // 选中的日期
    var selectedDate: Array<Date>
    
    init(selectedDate: Array<Date> = []) {
        self.selectedDate = selectedDate
    }
}

struct CreateEventAvailability: CreateEventModelPrimaryKey {
    var dateList: Array<Date>!
}

protocol CreateEventModelPrimaryKey { }

class CreateEventReactor: Reactor {
    
    enum Action {
        case selectCategory(EventCategory)
        case selectedDates(Array<Date>)
    }
    
    enum Mutation {
        case setCategory(EventCategory)
        case setDates(Array<Date>)
    }
    
    struct State {
        var repos: Array<CreateEventModelPrimaryKey>
    }
    
    var initialState: State
    
    init() {
        initialState = State(repos: [CreateEventLabels(list: EventCategory.allCases, selected: nil),
                                     CreateEventTextEditor.title(text: ""),
                                     CreateEventTextEditor.location(value: nil, attachImageNamed: "CreateEvent Location"),
                                     CreateEventCalendar(),
                                     CreateEventAvailability()])
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .selectCategory(let category):
            return Observable.just(.setCategory(category))
        case .selectedDates(let list):
            return Observable.just(.setDates(list))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .setCategory(let category):
            var labels = state.repos[0] as! CreateEventLabels
            labels.selected = category
            state.repos[0] = labels
        case .setDates(let listDate):
            state.repos[3] = CreateEventCalendar(selectedDate: listDate)
            state.repos[4] = CreateEventAvailability(dateList: listDate)
        }
        return state
    }
}
