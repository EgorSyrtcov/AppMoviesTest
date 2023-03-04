import UIKit
import SnapKit
import Combine

final class MainViewController: UIViewController {
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 15, left: 20, bottom: 20, right: 20)
        layout.itemSize = CGSize(width: self.view.frame.width - 40, height: 300)
        layout.minimumLineSpacing = 30
        layout.scrollDirection = .vertical
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(MovieViewCell<MovieCardView>.self)
        collection.register(InteractiveHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: InteractiveHeader.identifier)
        collection.dataSource = self
        collection.delegate = self
        return collection
    }()
    
    // MARK: Public
    var viewModel: MainViewModel!
    
    // MARK: Private
    private var popularMovies = [Movie]()
    private var upcomingMovies = [Movie]()
    private var section: Section = .popular
    
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupNavigationBarButton()
        setupUI()
        viewModelBinding()
    }
    
    private func setup() {
        title = "Main"
        view.backgroundColor = .white
    }
    
    private func setupNavigationBarButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Filter", style: .done, target: self, action: #selector(categoryButtonTapped))
    }
    
    private func viewModelBinding() {
        viewModel.updateCategoryPublisher
            .sink { [weak self] returnValue in
                guard let self = self else { return }
                self.section = returnValue
                self.collectionView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private func setupUI() {
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view)
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
    
}
