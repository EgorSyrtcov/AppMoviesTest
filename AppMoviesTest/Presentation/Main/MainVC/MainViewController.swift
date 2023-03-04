import UIKit

final class MainViewController: UIViewController {
    
    // MARK: Public
    var viewModel: MainViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupUI()
    }
    
    private func setup() {
        title = "Main"
        view.backgroundColor = .white
    }
    
    private func setupUI() {
        
    }


}

