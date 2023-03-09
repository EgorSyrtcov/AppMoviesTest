import UIKit
import Combine

final class MainViewController: UIViewController {
    
    lazy private var activityIndicator: UIActivityIndicatorView = {
        var activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .white
        return activityIndicator
    }()
    
    lazy private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 15, left: 20, bottom: 20, right: 20)
        layout.itemSize = CGSize(width: self.view.frame.width - 80, height: 400)
        layout.minimumLineSpacing = 30
        layout.scrollDirection = .vertical
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(MovieViewCell<MovieCardView>.self)
        collection.register(InteractiveHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: InteractiveHeader.identifier)
        collection.showsVerticalScrollIndicator = false
        collection.dataSource = self
        collection.delegate = self
        collection.alwaysBounceVertical = true
        collection.refreshControl = refreshControl
        return collection
    }()
    
    lazy private var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
        return refreshControl
    }()
    
    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.searchBar.placeholder = "Search"
        sc.searchBar.searchTextField.delegate = self
        sc.searchBar.delegate = self
        return sc
    }()
    
    // MARK: Public
    var viewModel: MainViewModel!
    
    // MARK: Private
    private var popularMovies = [Movie]()
    private var upcomingMovies = [Movie]()
    private var section: Section = .popular
    private var isLoadingMore = false
    private var isActiveRefreshControl = true
    
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupNavigationBarButton()
        setupUI()
        viewModelBinding()
    }
    
    private func setup() {
        title = "Movies"
        view.backgroundColor = .white
    }
    
    private func setupNavigationBarButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Filter", style: .done, target: self, action: #selector(categoryButtonTapped))
        navigationItem.searchController = searchController
    }
    
    private func viewModelBinding() {
        
        viewModel.isLoadingPublisher
            .sink { [weak self] in self?.update(isShown: $0) }
            .store(in: &cancellables)
        
        viewModel.updateCategoryPublisher
            .sink { [weak self] returnValue in
                guard let self = self else { return }
                self.section = returnValue
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
            .store(in: &cancellables)
        
        viewModel.updatePopularMoviesPublisher
            .sink { [weak self] returnValue in
                guard let self = self else { return }
                self.popularMovies = returnValue
                self.isLoadingMore = false
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
            .store(in: &cancellables)
        
        viewModel.updateUncomingMoviesPublisher
            .sink { [weak self] returnValue in
                guard let self = self else { return }
                self.upcomingMovies = returnValue
                self.isLoadingMore = false
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
            .store(in: &cancellables)
        
        viewModel.errorPublisher
            .sink { [weak self] error in
                guard let self = self else { return }
                self.showAlert(title: error.title, subtitle: error.subtitle) }
            .store(in: &cancellables)
        
        viewModel.searchMoviesPublisher
            .sink { [weak self] returnValue in
                
                switch self?.section {
                case .popular:
                    self?.popularMovies = returnValue
                case .upcoming:
                    self?.upcomingMovies = returnValue
                default:
                    break
                }
                
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupUI() {
        view.addSubviews(collectionView, activityIndicator)
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalTo(collectionView.snp.center)
            make.size.equalTo(CGSize(width: 50, height: 50))
        }
    }
    
    // MARK: Actions
    @objc func categoryButtonTapped(sender: UIButton!) {
        // Create an alert controller
        let alertController = UIAlertController(title: "Filter", message: "Select sections to show", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Popular", style: .default, handler: { [weak self] _ in
            self?.viewModel.filterButtonDidTapSubject.send(.popular)
        }))
        alertController.addAction(UIAlertAction(title: "Uncoming", style: .default, handler: { [weak self] _ in
            self?.viewModel.filterButtonDidTapSubject.send(.upcoming)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    @objc private func didPullToRefresh(_ sender: Any) {
        refreshControl.endRefreshing()
        
        guard isActiveRefreshControl else { return }
        viewModel.didPullToRefreshSubject.send()
    }
}

extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch self.section {
        case .popular:
            return popularMovies.count
        case .upcoming:
            return upcomingMovies.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch self.section {
        case .popular:
            let cell = collectionView.dequeueCell(cellType: MovieViewCell<MovieCardView>.self, for: indexPath)
            let model = popularMovies[indexPath.item]
            cell.containerView.update(with: model)
            return cell
        case .upcoming:
            let cell = collectionView.dequeueCell(cellType: MovieViewCell<MovieCardView>.self, for: indexPath)
            let model = upcomingMovies[indexPath.item]
            cell.containerView.update(with: model)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch self.section {
        case .popular:
            let header = self.collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: InteractiveHeader.identifier, for: indexPath) as? InteractiveHeader
            header?.setUp(title: self.section.rawValue)
            return header ?? UICollectionReusableView()
        case .upcoming:
            let header = self.collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: InteractiveHeader.identifier, for: indexPath) as? InteractiveHeader
            header?.setUp(title: self.section.rawValue)
            return header ?? UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 30.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch self.section {
        case .popular:
            let movie = popularMovies[indexPath.item]
            viewModel.detailCellDidTapSubject.send(movie)
        case .upcoming:
            let movie = upcomingMovies[indexPath.item]
            viewModel.detailCellDidTapSubject.send(movie)
        }
    }
}

extension MainViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard !searchController.isActive else { return }
        guard !isLoadingMore else { return }
        
        let offset = scrollView.contentOffset.y
        let totalContentHeight = scrollView.contentSize.height
        let totalScrollViewFixedHeight = scrollView.frame.size.height
        
        if offset > (totalContentHeight - totalScrollViewFixedHeight) {
            isLoadingMore = true
            viewModel.scrollLoadingMoreSubject.send()
        }
    }
}

extension MainViewController {
    
    // Action viewModelBinding
    private func update(isShown: Bool) {
        
        DispatchQueue.main.async {
            if isShown {
                self.activityIndicator.startAnimating()
            }
            else {
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    private func showAlert(title: String?, subtitle: String?, completion: (() -> Void)? = nil) {
        if title == nil {
            return
        }
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in completion?() }))
            self.present(alert, animated: true)
        }
    }
}

extension MainViewController: UISearchResultsUpdating, UISearchBarDelegate, UITextFieldDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        
        let searchText = (searchController.searchBar.text ?? "")
        viewModel.searchTextSubject.send(searchText)
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isActiveRefreshControl = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        let indexPath = IndexPath(row: 0, section: 0)
        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
        viewModel.searchTextSubject.send(nil)
        isActiveRefreshControl = true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        viewModel.searchTextSubject.send(nil)
        return true
    }
}
