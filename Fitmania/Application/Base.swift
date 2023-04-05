import UIKit

protocol BaseView {}

protocol BasePresenter {}

protocol BaseInteractor {}

class BaseViewController: UIViewController {
    // swiftlint:disable: redundant_type_annotation
    var showNavigationController: Bool = true
    // swiftlint:enable: redundant_type_annotation
    var animatedTransitioning: UIViewControllerAnimatedTransitioning?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(!showNavigationController, animated: animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.foregroundColor: UIColor.black ]
        navigationController?.navigationBar.tintColor = .black
    }
    
    deinit {
        print("Deinit: \(self)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
}
