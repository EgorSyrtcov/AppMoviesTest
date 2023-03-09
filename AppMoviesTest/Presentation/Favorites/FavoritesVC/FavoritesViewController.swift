import UIKit
import Combine

final class FavoritesViewController: UIViewController {
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.registerClassForCell(UITableViewCell.self)
        tableView.backgroundColor = .white
        tableView.dataSource = self
        tableView.rowHeight = 40
        tableView.translatesAutoresizingMaskIntoConstraints = false
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
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(for: indexPath)
        let movie = movies[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 20.0)
        cell.backgroundColor = .lightGray
        cell.textLabel?.text = movie.title
        return cell
    }
}
