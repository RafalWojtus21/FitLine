//
//  EditPersonalDataScreenViewController.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 12/01/2024.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class EditPersonalDataScreenViewController: BaseViewController, EditPersonalDataScreenView {
    typealias ViewState = EditPersonalDataScreenViewState
    typealias Effect = EditPersonalDataScreenEffect
    typealias Intent = EditPersonalDataScreenIntent
    
    @IntentSubject() var intents: Observable<EditPersonalDataScreenIntent>
    
    private let effectsSubject = PublishSubject<Effect>()
    private let bag = DisposeBag()
    private let presenter: EditPersonalDataScreenPresenter
    
    private var userInfoSubject = PublishSubject<UserInfo>()
    private var sexSubject = BehaviorSubject<[SexDataModel]>(value: [])
    private var numberOfRowsSubject = PublishSubject<Int>()
    private let rowHeight = 60
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(PersonalDataCell.self)
        tableView.backgroundColor = .quaternaryColor.withAlphaComponent(0.3)
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .quinaryColor.withAlphaComponent(0.6)
        tableView.layer.cornerRadius = 16
        tableView.rowHeight = CGFloat(rowHeight)
        tableView.showsVerticalScrollIndicator = true
        tableView.indicatorStyle = .white
        return tableView
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton().apply(style: .secondary, title: "Done")
        button.backgroundColor = .secondaryColor
        button.layer.cornerRadius = 16
        return button
    }()
    
    init(presenter: EditPersonalDataScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        layoutView()
        bindControls()
        effectsSubject.subscribe(onNext: { [weak self] effect in self?.trigger(effect: effect) })
            .disposed(by: bag)
        presenter.bindIntents(view: self, triggerEffect: effectsSubject)
            .subscribe(onNext: { [weak self] state in self?.render(state: state) })
            .disposed(by: bag)
        _intents.subject.onNext(.viewLoaded)
    }
    
    private func layoutView() {
        view.backgroundColor = .primaryColor
        title = "Edit personal data"
        
        view.addSubview(tableView)
        view.addSubview(doneButton)
        
        doneButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(42)
            $0.height.equalTo(56)
            $0.bottom.equalToSuperview().inset(56)
        }
    }
    
    private func configureSexTextField(_ textField: UITextField) {
        let sexPicker = UIPickerView()
        textField.inputView = sexPicker
        
        sexSubject.asObservable().bind(to: sexPicker.rx.itemTitles) { _, element in
            textField.text = element.sex
            return element.sex
        }
        .disposed(by: bag)
    }
    
    private func calculateHeightForTableView(numberOfRows: Int) {
        let tableViewHeight = numberOfRows * rowHeight
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(46)
            $0.left.right.equalToSuperview().inset(16)
            $0.height.equalTo(tableViewHeight).priority(.high)
            $0.bottom.equalTo(doneButton.snp.top).offset(24).priority(.medium)
        }
    }
    
    private func bindControls() {
        userInfoSubject
            .bind(to: tableView.rx.items(cellIdentifier: PersonalDataCell.reuseIdentifier, cellType: PersonalDataCell.self)) { _, item, cell in
                cell.configure(with: PersonalDataCell.ViewModel(type: item))
            }
            .disposed(by: bag)
        
        numberOfRowsSubject.distinctUntilChanged()
            .subscribe(onNext: { [weak self] in
                self?.calculateHeightForTableView(numberOfRows: $0)
            })
            .disposed(by: bag)
        
        let cellSelectedIntent = tableView.rx.modelSelected(UserInfoType.self)
            .map { return Intent.cellSelected($0) }
        let doneButtonIntent = doneButton.rx.tap.map {
            Intent.doneButtonIntent
        }
        
        Observable.merge(cellSelectedIntent, doneButtonIntent)
            .bind(to: _intents.subject)
            .disposed(by: bag)
    }
    
    private func trigger(effect: Effect) {
        switch effect {
        case .edit(let userInfoType):
            let alertController = UIAlertController(title: "", message: "Edit your \(userInfoType.description.lowercased())", preferredStyle: .alert)
            
            alertController.addTextField { textField in
                let currentValue: String
                switch userInfoType {
                case .firstName(let firstName):
                    currentValue = firstName
                case .lastName(let lastName):
                    currentValue = lastName
                case .sex(let sex):
                    self.configureSexTextField(textField)
                    currentValue = sex.sex
                case .age(let age):
                    currentValue = "\(age)"
                case .height(let height):
                    currentValue = "\(height)"
                case .weight(let weight):
                    currentValue = "\(weight)"
                }
                textField.text = currentValue
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            let doneAction = UIAlertAction(title: Localization.General.okMessage, style: .default, handler: { [weak self, weak alertController] _ in
                guard let self, let textFieldText = alertController?.textFields?.first?.text else { return }
                self._intents.subject.onNext(.edit(userInfoType, newValue: textFieldText))
            })
            
            alertController.addAction(cancelAction)
            alertController.addAction(doneAction)
            present(alertController, animated: true, completion: nil)
        default:
            break
        }
    }
    
    func render(state: ViewState) {
        guard let userInfo = state.userInfo else { return }
        sexSubject.onNext(state.sexDataModel)
        userInfoSubject.onNext(userInfo)
        let mirror = Mirror(reflecting: userInfo)
        numberOfRowsSubject.onNext(mirror.children.count)
    }
}
