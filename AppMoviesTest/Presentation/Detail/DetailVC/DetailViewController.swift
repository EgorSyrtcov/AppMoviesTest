import UIKit
import Combine
import SnapKit
import Kingfisher

final class DetailViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let containerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = .white
        return containerView
    }()
    
    private let posterImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "posterDefault")
        iv.contentMode = .scaleAspectFit
        iv.layer.cornerRadius = 10
        iv.clipsToBounds = true
        return iv
    }()
    
    private let separatorView: UIView = {
        let separatorView = UIView()
        separatorView.backgroundColor = .gray
        return separatorView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .red
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    private let originalTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont(name: "Montserrat-Regular", size: 18)
        return label
    }()
    
    private let descriptionMovieLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .lightGray
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    private let genreLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        label.font = UIFont(name: "Montserrat-Regular", size: 10)
        return label
    }()
    
    private let releaseDateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .systemBrown
        label.font = UIFont.systemFont(ofSize: 10)
        return label
    }()
    
    lazy private var likeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(didTapButtonAction), for: .touchUpInside)
        return button
    }()
    
    private var cancellables: Set<AnyCancellable> = []
    private var movieModel: Movie?
    
    // MARK: Public
    var viewModel: DetailViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupUI()
        viewModelBinding()
        settingsModel()
    }
    
    private func setup() {
        title = "Detail"
        view.backgroundColor = .white
    }
    
    private func viewModelBinding() {
        viewModel.movieDataPublisher
            .sink { [weak self] movie in
                guard let self = self else { return }
                self.movieModel = movie
            }
            .store(in: &cancellables)
        
        viewModel.showAlertSaveRealmBasePublisher
            .sink { [weak self] _ in
                self?.showAlert()
            }
            .store(in: &cancellables)
        
    }
    
    private func settingsModel() {
        guard let movie = movieModel else { return }
        titleLabel.text = movie.title
        originalTitleLabel.text = movie.originalTitle
        descriptionMovieLabel.text = movie.overview
        genreLabel.text = "Жанры: \(movie.genre)"
        releaseDateLabel.text = "Release at \(movie.releaseDate)"
        
        KF.url(URL(string: movie.poster))
          .placeholder(UIImage(named: "posterDefault"))
          .loadDiskFileSynchronously()
          .cacheMemoryOnly()
          .fade(duration: 0.25)
          .set(to: posterImageView)
    }
    
    private func setupUI() {
        
        let containerSize = containerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        scrollView.contentSize = containerSize
        
        view.addSubview(scrollView)
        scrollView.addSubviews(containerView)
        containerView.addSubviews(posterImageView, likeButton, titleLabel, originalTitleLabel, descriptionMovieLabel, separatorView, genreLabel, releaseDateLabel)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints { make in
            make.width.equalTo(scrollView.snp.width)
            make.centerX.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
        
        posterImageView.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.top).offset(10)
            make.left.right.equalToSuperview()
            make.height.equalTo(400)
        }
        
        likeButton.snp.makeConstraints { make in
            make.top.equalTo(posterImageView.snp.top)
            make.right.equalTo(posterImageView.snp.right).offset(-53)
            make.size.equalTo(CGSize(width: 50, height: 50))
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(posterImageView.snp.bottom).offset(20)
            make.right.equalTo(posterImageView.snp.right).offset(-10)
            make.left.equalTo(posterImageView.snp.left).offset(10)
        }
        
        originalTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.right.equalTo(titleLabel.snp.right).offset(-10)
            make.left.equalTo(titleLabel.snp.left).offset(10)
        }
        
        descriptionMovieLabel.snp.makeConstraints { make in
            make.top.equalTo(originalTitleLabel.snp.bottom).offset(10)
            make.right.equalTo(posterImageView.snp.right).offset(-20)
            make.left.equalTo(posterImageView.snp.left).offset(20)
        }
        
        separatorView.snp.makeConstraints { make in
            make.top.equalTo(descriptionMovieLabel.snp.bottom).offset(10)
            make.left.equalTo(descriptionMovieLabel.snp.left)
            make.right.equalTo(descriptionMovieLabel.snp.right).offset(-20)
            make.height.equalTo(1)
        }
        
        genreLabel.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom).offset(10)
            make.left.equalTo(separatorView.snp.left)
            make.right.equalTo(separatorView.snp.right)
        }
        
        releaseDateLabel.snp.makeConstraints { make in
            make.top.equalTo(genreLabel.snp.bottom).offset(10)
            make.left.equalTo(genreLabel.snp.left)
            make.right.equalTo(genreLabel.snp.right)
            make.bottom.equalToSuperview().offset(-30)
        }
    }
    
    // MARK: Actions
    @objc func didTapButtonAction(sender: UIButton!) {
        viewModel.didTapLikeSubject.send()
    }
    
    private func showAlert() {
        let alertController = UIAlertController(title: "Great!", message: "Your movie has been added to favorites", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}
