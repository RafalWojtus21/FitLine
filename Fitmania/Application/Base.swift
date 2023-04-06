import UIKit

protocol BaseView {}

protocol BasePresenter {}

protocol BaseInteractor {}

class BaseViewController: UIViewController {
    var showNavigationController = true
    var animatedTransitioning: UIViewControllerAnimatedTransitioning?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(!showNavigationController, animated: animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.foregroundColor: UIColor.white ]
        navigationController?.navigationBar.tintColor = .white
    }
    
    deinit {
        print("Deinit: \(self)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
}
