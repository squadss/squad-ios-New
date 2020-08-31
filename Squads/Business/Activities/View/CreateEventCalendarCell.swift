//
//  CreateEventCalendarCell.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/11.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxSwift
import JTAppleCalendar

class CreateEventCalendarCell: BaseTableViewCell {
    
    var disposeBag = DisposeBag()
    private var didSelectedDateSubject = PublishSubject<[Date]>()
    var didSelectedDateObservable: Observable<[Date]> {
        return didSelectedDateSubject.asObservable()
    }
    
    private var calendarView: JTACMonthView!
    private var weekViewStack: UIStackView!
    private var headerView: CalendarHandleView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override func setupView() {
        weekViewStack = UIStackView(arrangedSubviews: ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"].map{ text in
            let label = UILabel()
            label.attributedText = NSAttributedString(string: text, attributes: [
                .foregroundColor: UIColor(red: 0.571, green: 0.571, blue: 0.571, alpha: 1),
                .font: UIFont.systemFont(ofSize: 10, weight: .bold),
                .paragraphStyle: NSParagraphStyle.lineHeightMultiple(1.34)
            ])
            label.numberOfLines = 1
            label.textAlignment = .center
            return label
        })
        weekViewStack.axis = .horizontal
        weekViewStack.distribution = .fillEqually
        weekViewStack.alignment = .fill
        contentView.addSubview(weekViewStack)
        
        calendarView = JTACMonthView()
        calendarView.isPagingEnabled = true
        calendarView.scrollDirection = .horizontal
        calendarView.calendarDataSource = self
        calendarView.calendarDelegate = self
        calendarView.minimumLineSpacing = 4
        calendarView.minimumInteritemSpacing = 1
        calendarView.register(CellView.self, forCellWithReuseIdentifier: "CellView")
        calendarView.backgroundColor = .white
        calendarView.showsVerticalScrollIndicator = false
        calendarView.showsHorizontalScrollIndicator = false
        contentView.addSubview(calendarView)
        calendarView.visibleDates { [unowned self] (visibleDates: DateSegmentInfo) in
            self.setupViewsOfCalendar(from: visibleDates)
        }
        
        headerView = CalendarHandleView()
        headerView.previousBtn.addTarget(self, action: #selector(previousBtnDidTapped), for: .touchUpInside)
        headerView.nextBtn.addTarget(self, action: #selector(nextBtnDidTapped), for: .touchUpInside)
        contentView.addSubview(headerView)
    }
    
    func selectDates(dates: [Date]) {
        calendarView.selectDates(dates)
    }
    
    private func setupViewsOfCalendar(from visibleDates: DateSegmentInfo) {
        guard let startDate = visibleDates.monthDates.first?.date else {
            return
        }
//        let calendar = Calendar.current
//        let month = calendar.dateComponents([.month], from: startDate).month!
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "MMM"
//        let monthName = dateFormatter.monthSymbols[(month-1) % 12]
//        let year = calendar.component(.year, from: startDate)
        
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        let monthName = dateFormatter.string(from: startDate)
        let year = calendar.component(.year, from: startDate)
        
        headerView.titleLab.text = monthName + " " + String(year)

//        let dateBelongsTo = calendarView.cellStatus(for: startDate)?.dateBelongsTo
//        switch dateBelongsTo {
//        case .followingMonthOutsideBoundary:
//            headerView.nextBtn.isEnabled = false
//        case .previousMonthOutsideBoundary:
//            headerView.previousBtn.isEnabled = false
//        default:
//            headerView.nextBtn.isEnabled = true
//            headerView.previousBtn.isEnabled = true
//        }
    }
 
    private func handleCellConfiguration(cell myCustomCell: CellView, date: Date, cellState: CellState) {
        
        if Calendar.current.isDateInToday(date) {
            myCustomCell.dotView.isHidden = false
        } else {
            myCustomCell.dotView.isHidden = true
        }
        
        if cellState.isSelected {
            myCustomCell.selectedView.isHidden = false
            myCustomCell.dayLabel.textColor = .white
        } else {
            switch cellState.dateBelongsTo {
            case .thisMonth:
                myCustomCell.selectedView.isHidden = true
                myCustomCell.dayLabel.textColor = UIColor(hexString: "#4F4F4F")
            case .followingMonthOutsideBoundary, .previousMonthOutsideBoundary:
                myCustomCell.selectedView.isHidden = true
                myCustomCell.dayLabel.textColor = .lightGray
            case .followingMonthWithinBoundary, .previousMonthWithinBoundary:
                myCustomCell.selectedView.isHidden = true
                myCustomCell.dayLabel.textColor = .lightGray
            }
        }
        
        if cellState.text == "1" {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM"
            let month = formatter.string(from: date)
            myCustomCell.dayLabel.text = month
            print(month)
        } else {
            myCustomCell.dayLabel.text = cellState.text
        }
    }
    
    @objc
    private func previousBtnDidTapped() {
        calendarView.scrollToSegment(.previous, completionHandler: { [unowned self] in
            let visibleDates = self.calendarView.visibleDates()
            self.setupViewsOfCalendar(from: visibleDates)
        })
    }
    
    @objc
    private func nextBtnDidTapped() {
        calendarView.scrollToSegment(.next, completionHandler: { [unowned self] in
            let visibleDates = self.calendarView.visibleDates()
            self.setupViewsOfCalendar(from: visibleDates)
        })
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        headerView.frame = CGRect(x: (bounds.width - 160)/2, y: 0, width: 160, height: 44)
        weekViewStack.frame = CGRect(x: 35, y: headerView.frame.maxY + 10, width: bounds.width - 70, height: 18)
        calendarView.frame = CGRect(x: 40, y: weekViewStack.frame.maxY + 14, width: bounds.width - 80, height: bounds.height - weekViewStack.frame.maxY - 14)
    }
    
}

extension CreateEventCalendarCell: JTACMonthViewDataSource, JTACMonthViewDelegate {
    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        
        let startDate = Date()
        let calendar = Calendar.current
        let endDate = calendar.date(byAdding: .month, value: 5, to: startDate)!
        
        return ConfigurationParameters(startDate: startDate,
                                       endDate: endDate,
                                       numberOfRows: 2,
                                       generateInDates: .forAllMonths,
                                       generateOutDates: .tillEndOfGrid,
                                       firstDayOfWeek: .sunday,
                                       hasStrictBoundaries: nil)
    }
    
    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        let myCustomCell = calendar.dequeueReusableCell(withReuseIdentifier: "CellView", for: indexPath) as! CellView
        handleCellConfiguration(cell: myCustomCell, date: date, cellState: cellState)
        return myCustomCell
    }
    
    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        guard let myCustomCell = cell as? CellView else { return }
        handleCellConfiguration(cell: myCustomCell, date: date, cellState: cellState)
    }
    
    func calendar(_ calendar: JTACMonthView, willScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupViewsOfCalendar(from: visibleDates)
    }
    
    func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        guard let myCustomCell = cell as? CellView else { return }
        handleCellConfiguration(cell: myCustomCell, date: date, cellState: cellState)
    }
    
    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        guard let myCustomCell = cell as? CellView else { return }
        
        switch cellState.dateBelongsTo {
        case .followingMonthOutsideBoundary, .previousMonthOutsideBoundary:
            return
        case .previousMonthWithinBoundary:
            calendarView.scrollToSegment(.previous)
        case .followingMonthWithinBoundary:
            calendarView.scrollToSegment(.next)
        case .thisMonth:
            break
        }
        
        handleCellConfiguration(cell: myCustomCell, date: date, cellState: cellState)
        didSelectedDateSubject.onNext(calendar.selectedDates)
    }
}

class CellView: JTACDayCell {
    
    var selectedView: UIView!
    var dayLabel: UILabel!
    var dotView: UIView!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupView() {
        
        dotView = UIView()
        dotView.layer.cornerRadius = 2
        dotView.backgroundColor = .red
        dotView.isHidden = true
        
        selectedView = UIView()
        selectedView.layer.cornerRadius = 17.5
        selectedView.theme.backgroundColor = UIColor.secondary
        
        dayLabel = UILabel()
        dayLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        dayLabel.textAlignment = .center
        
        contentView.addSubviews(selectedView, dayLabel, dotView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        dayLabel.frame = bounds
        dotView.frame = CGRect(x: (bounds.width - 4)/2, y: bounds.height/2 + 10, width: 4, height: 4)
        selectedView.frame = CGRect(x: (bounds.width - 34)/2, y: (bounds.height - 34)/2, width: 34, height: 34)
    }
}

class CalendarHandleView: BaseView {
    
    var previousBtn = UIButton()
    var nextBtn = UIButton()
    var titleLab = UILabel()
    
    override func setupView() {
        
        titleLab.textAlignment = .center
        titleLab.font = UIFont.systemFont(ofSize: 14)
        titleLab.textColor = UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 1)
        
        previousBtn.setImage(UIImage(named: "chevron-left"), for: .normal)
        nextBtn.setImage(UIImage(named: "chevron-right"), for: .normal)
        
        addSubviews(previousBtn, nextBtn, titleLab)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previousBtn.frame = CGRect(x: 0, y: (bounds.height - 44)/2, width: 44, height: 44)
        nextBtn.frame = CGRect(x: bounds.width - 44, y: (bounds.height - 44)/2, width: 44, height: 44)
        titleLab.frame = CGRect(x: previousBtn.frame.maxX, y: 0, width: nextBtn.frame.minX - previousBtn.frame.maxX, height: bounds.height)
    }
}
