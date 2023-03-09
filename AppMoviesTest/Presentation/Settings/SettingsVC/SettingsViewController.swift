import UIKit

final class SettingsViewController: UIViewController {
    
    private let versionTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .red
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
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
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        versionTitleLabel.text = "Application Version: \(appVersion)"
    }
    
    private func setupUI() {
        view.addSubview(versionTitleLabel)
    
        versionTitleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
