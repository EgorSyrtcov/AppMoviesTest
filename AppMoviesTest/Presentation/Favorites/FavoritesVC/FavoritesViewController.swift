import UIKit
import Combine

final class FavoritesViewController: UIViewController {
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.registerClassForCell(FavoritesCell.self)
        tableView.backgroundColor = .white
        tableView.dataSource = self
        tableView.rowHeight = 120
        return tableView
    }()
    
    // MARK: Private
    private var cancellables: Set<AnyCancellable> = []
    private var movies = [MovieRealmModel]()
    
    // MARK: Public
    var viewModel: FavoritesViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupUI()
        viewModelBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.updateRealmModelsSubject.send()
    }
    
    private func setup() {
        title = "Favorites"
        view.backgroundColor = .white
    }
    
    private func viewModelBinding() {
        viewModel.updateMoviesFromRealmPublisher
            .sink { [weak self] returnValue in
                guard let self = self else { return }
                self.movies = returnValue
                self.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private func setupUI() {
        view.addSubviews(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: FavoritesCell = tableView.dequeueReusableCell(for: indexPath)
        let movie = movies[indexPath.row]
        cell.setupMovie(movie)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                viewModel.deleteRealmModelSubject.send(movies[indexPath.row])
            }
        }
}
