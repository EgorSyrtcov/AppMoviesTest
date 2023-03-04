import UIKit

final class SettingsViewController: UIViewController {
    
    // MARK: Public
    var viewModel: SettingsViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupUI()
    }
    
    private func setup() {
        title = "Settings"
        view.backgroundColor = .white
    }
    
    private func setupUI() {
        
    }
}
