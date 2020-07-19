//
//  CreateEventViewController.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/11.
//  Copyright © 2020 Squads. All rights reserved.
//

import UIKit
import RxDataSources

class CreateEventViewController: ReactorViewController<CreateEventReactor>, UITableViewDelegate {

    private var tableView = UITableView(frame: .zero, style: .grouped)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.theme.backgroundColor = UIColor.background
    }
    
    override func setupView() {
        //自定义导航栏按钮
        let leftBtn = UIButton()
        leftBtn.setTitle("Cancel", for: .normal)
        leftBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        leftBtn.theme.titleColor(from: UIColor.text, for: .normal)
        leftBtn.addTarget(self, action: #selector(leftBtnDidTapped), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBtn)
        
        //自定义右导航按钮
        let rightBtn = UIButton()
        rightBtn.setTitle("Save", for: .normal)
        rightBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        rightBtn.setTitleColor(UIColor(red: 0.925, green: 0.384, blue: 0.337, alpha: 1), for: .normal)
        rightBtn.addTarget(self, action: #selector(rightBtnBtnDidTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBtn)
        
        tableView.register(Reusable.createEventTextEditedCell)
        tableView.register(Reusable.createEventLabelsCell)
        tableView.register(Reusable.createEventCalendarCell)
        tableView.register(Reusable.createEventAvailabilityCell)
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 20))
        tableView.theme.backgroundColor = UIColor.background
        view.addSubview(tableView)
        
    }
    
    override func setupConstraints() {
        tableView.snp.safeFull(parent: self)
    }
    
    override func bind(reactor: CreateEventReactor) {
        
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, CreateEventModelPrimaryKey>>(configureCell: { data, tableView, indexPath, model in
            switch model {
            case is CreateEventTextEditor:
                let cell = tableView.dequeue(Reusable.createEventTextEditedCell)!
                cell.dataSource = model as? CreateEventTextEditor
                cell.inputCompleted.subscribe(onNext: {
                    print($0)
                })
                .disposed(by: cell.disposeBag)
                cell.selectionStyle = .none
                return cell
            case is CreateEventLabels:
                let cell = tableView.dequeue(Reusable.createEventLabelsCell)!
                cell.labels = model as? CreateEventLabels
                cell.itemTapped
                    .distinctUntilChanged()
                    .map{ Reactor.Action.selectCategory($0) }
                    .bind(to: reactor.action)
                    .disposed(by: cell.disposeBag)
                cell.selectionStyle = .none
                return cell
            case is CreateEventCalendar:
                let cell = tableView.dequeue(Reusable.createEventCalendarCell)!
                cell.selectionStyle = .none
                return cell
            case is CreateEventAvailability:
                let cell = tableView.dequeue(Reusable.createEventAvailabilityCell)!
                cell.selectionStyle = .none
                return cell
            default:
                fatalError("未配置cell")
            }
        })
        
        reactor.state
            .map{ $0.repos.map{ SectionModel(model: "", items: [$0])} }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 20))
        let titleLab = UILabel(frame: CGRect(x: 33, y: 0, width: 200, height: 17))
        titleLab.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        titleLab.theme.textColor = UIColor.secondary
        switch section {
        case 0: titleLab.text = "CATEGORY"
        case 1: titleLab.text = "TITLE"
        case 2: titleLab.text = "LOCATION"
        case 3: titleLab.text = "DATE"
        case 4: titleLab.text = "ADD YOUR AVAILABILITY"
        default: break
        }
        titleView.addSubview(titleLab)
        return titleView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return 110
        case 1: return 60
        case 2: return 60
        case 3: return 180
        case 4: return 300
        default: fatalError("未配置height")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    @objc
    private func leftBtnDidTapped() {
        dismiss(animated: true)
    }
    
    @objc
    private func rightBtnBtnDidTapped() {
        dismiss(animated: true)
    }
}
