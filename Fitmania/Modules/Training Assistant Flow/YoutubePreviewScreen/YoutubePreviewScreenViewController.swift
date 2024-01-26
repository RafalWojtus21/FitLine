//
//  YoutubePreviewScreenViewController.swift
//  FitLine
//
//  Created by Rafał Wojtuś on 26/01/2024.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import YouTubeiOSPlayerHelper

final class YoutubePreviewScreenViewController: BaseViewController, YoutubePreviewScreenView {
    typealias ViewState = YoutubePreviewScreenViewState
    typealias Effect = YoutubePreviewScreenEffect
    typealias Intent = YoutubePreviewScreenIntent
    
    @IntentSubject() var intents: Observable<YoutubePreviewScreenIntent>
    
    private let effectsSubject = PublishSubject<Effect>()
    private let bag = DisposeBag()
    private let presenter: YoutubePreviewScreenPresenter
    
    private lazy var ytPlayerView = YTPlayerView()
    
    init(presenter: YoutubePreviewScreenPresenter) {
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
    }
    
    private func layoutView() {
        sheetPresentationController?.detents = [.medium()]
        view.addSubview(ytPlayerView)
        view.backgroundColor = .primaryColor
        
        ytPlayerView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(42)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(240)
        }
    }
    
    private func bindControls() {
    }
    
    private func trigger(effect: Effect) {
        switch effect {
        }
    }
    
    func render(state: ViewState) {
        if let videoID = state.videoID {
            ytPlayerView.load(withVideoId: videoID)
        }
    }
}
