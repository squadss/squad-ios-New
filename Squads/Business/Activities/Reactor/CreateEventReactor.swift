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
import MapKit

enum EventCategory: Int, Codable, CaseIterable, Equatable {
    case food = 1
    case virtual = 2
    case hangout = 3
    case work = 4
    case exercise = 5
    case other = 6
    
    var themeColor: UIColor {
        switch self {
        case .food: return UIColor(red: 0.925, green: 0.384, blue: 0.337, alpha: 1)
        case .virtual: return UIColor(red: 0.616, green: 0.89, blue: 0.796, alpha: 1)
        case .hangout: return UIColor(red: 1, green: 0.664, blue: 0.438, alpha: 1)
        case .work: return UIColor(red: 0.157, green: 0.31, blue: 0.522, alpha: 1)
        case .exercise: return UIColor(red: 0.302, green: 0.69, blue: 0.78, alpha: 1)
        case .other: return UIColor(red: 0.532, green: 0.432, blue: 0.817, alpha: 1)
        }
    }
    
    var title: String {
        switch self {
        case .food: return "Food"
        case .virtual: return "Virtual"
        case .hangout: return "Hangout"
        case .work: return "Work"
        case .exercise: return "Exercise"
        case .other: return "Other"
        }
    }
    
    var image: UIImage? {
        return UIImage(named: "Event " + title)
    }
    
    static func == (lhs: EventCategory, rhs: EventCategory) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

struct CreateEventLabels: CreateEventModelPrimaryKey {
    var list: Array<EventCategory>
    var selected: EventCategory?
}

struct SquadLocation: Codable, Equatable {
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
    
    init(from decoder: Decoder) throws {
        address = try decoder.decode("address")
        longitude = try decoder.decode("longitude", as: String.self).asDouble()
        latitude = try decoder.decode("latitude", as: String.self).asDouble()
    }
    
    init(item: MKMapItem) {
        self.address = item.name ?? "Unknown Address"
        self.longitude = item.placemark.coordinate.longitude
        self.latitude = item.placemark.coordinate.latitude
    }
    
    init(address: String, longitude: Double, latitude: Double) {
        self.address = address
        self.longitude = longitude
        self.latitude = latitude
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
    
    var isTitle: Bool {
        switch self {
        case .title: return true
        case .location: return false
        }
    }
    
    var toLocation: SquadLocation? {
        switch self {
        case .title: return nil
        case let .location(value, _): return value
        }
    }
}

struct CreateEventCalendar: CreateEventModelPrimaryKey {
    // 选中的日期
    var selectedDate: Array<Date>
    
    init(selectedDate: Array<Date> = [Date()]) {
        self.selectedDate = selectedDate
    }
}

struct CreateEventAvailability: CreateEventModelPrimaryKey {
    var dateList: Array<TimePeriod>!
}

protocol CreateEventModelPrimaryKey { }

class CreateEventReactor: Reactor {
    
    enum Action {
        case selectCategory(EventCategory)
        case selectedDates(Array<Date>)
        case selectedTextEditor(CreateEventTextEditor)
        // 创建活动
        case createActivity(Array<TimePeriod>?)
        // 选择我的时间
        case selectTime(TimePeriod)
    }
    
    enum Mutation {
        case setCategory(EventCategory)
        case setDates(Array<Date>)
        case setTextEditor(CreateEventTextEditor)
        case setToast(String)
        case setLoading(Bool)
        case setActivityId(Int)
        case setSelectedTimes(Array<TimePeriod>)
    }
    
    struct State {
        var repos: Array<CreateEventModelPrimaryKey> = [
            CreateEventLabels(list: EventCategory.allCases, selected: nil),
            CreateEventTextEditor.title(text: ""),
            CreateEventTextEditor.location(value: nil, attachImageNamed: "CreateEvent Location"),
            CreateEventCalendar(),
            CreateEventAvailability()
        ]
        var activityId: Int?
        var toast: String?
        var isLoading: Bool?
    }
    
    var initialState = State()
    var provider = OnlineProvider<SquadAPI>()
    
    let squadId: Int
    init(squadId: Int) {
        self.squadId = squadId
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .selectCategory(let category):
            return Observable.just(.setCategory(category))
        case .selectedDates(let list):
            return Observable.just(.setDates(list))
        case .selectedTextEditor(let model):
            return Observable.just(.setTextEditor(model))
        case .selectTime(let time):
            // 暂时只允许一个时间段
            return Observable.just(.setSelectedTimes([time]))
        case .createActivity(let myTime):
            
            guard let selectedType = (currentState.repos[0] as? CreateEventLabels)?.selected else {
                return Observable.just(.setToast(NSLocalizedString("createEvent.categoryTip", comment: "")))
            }
            
            guard case .title(let text) = (currentState.repos[1] as? CreateEventTextEditor) else {
                return Observable.just(.setToast(NSLocalizedString("createEvent.titleTip", comment: "")))
            }
            
            guard let myTime = myTime, !myTime.isEmpty else {
                return Observable.just(.setToast(NSLocalizedString("createEvent.selectTimeTip", comment: "")))
            }
            
            let location = (currentState.repos[2] as? CreateEventTextEditor)?.toLocation
            
            return provider.request(target: .createActivity(type: selectedType, squadId: squadId, title: text, location: location), model: SquadActivity.self, atKeyPath: .data).asObservable().flatMap { [unowned self] result -> Observable<Mutation> in
                switch result {
                case .success(let model):
                    return self.provider
                        .request(target: .joinActivity(activityId: model.id, myTime: myTime), model: GeneralModel.Plain.self)
                        .asObservable()
                        .map { _ in Mutation.setActivityId(model.id)  }
                case .failure(let error):
                    return Observable.just(.setToast(error.message))
                }
            }.startWith(.setLoading(true))
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
        case .setTextEditor(let model):
            switch model {
            case let .location(value, attachImageNamed):
                state.repos[2] = CreateEventTextEditor.location(value: value, attachImageNamed: attachImageNamed)
            case let .title(text):
                state.repos[1] = CreateEventTextEditor.title(text: text)
            }
        case .setToast(let s):
            state.isLoading = false
            state.toast = s
        case .setLoading(let s):
            state.toast = nil
            state.isLoading = s
        case .setActivityId(let s):
            state.isLoading = false
            state.activityId = s
        case .setSelectedTimes(let list):
            state.repos[4] = CreateEventAvailability(dateList: list)
        }
        return state
    }
}
