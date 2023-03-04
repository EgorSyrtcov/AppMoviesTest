import UIKit

final class FavoritesViewController: UIViewController {
    
    // MARK: Public
    var viewModel: FavoritesViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupUI()
    }
    
    private func setup() {
        title = "Favorites"
        view.backgroundColor = .white
    }
    
    private func setupUI() {
        
    }


}


