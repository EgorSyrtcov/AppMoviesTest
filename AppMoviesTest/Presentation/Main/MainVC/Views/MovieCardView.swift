import UIKit
import SnapKit

final class MovieCardView: UIView {
    
    private let posterImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "posterDefault")
        iv.contentMode = .scaleToFill
        iv.layer.cornerRadius = 10
        iv.clipsToBounds = true
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    private let yearLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 10)
        return label
    }()
    
    private let genreLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 10)
        return label
    }()
    
    lazy private var likeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.layer.cornerRadius = 5
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with movie: Movie) {
        titleLabel.text = movie.originalTitle
        yearLabel.text = movie.releaseDate
        genreLabel.text = "Жанр: \(movie.genre)"
        posterImageView.downloaded(from: movie.poster)
    }

    private func setup() {
        self.backgroundColor = .lightGray
        self.setShadow()
    }
    
    private func setupUI() {
        addSubviews(posterImageView, likeButton, titleLabel, yearLabel, genreLabel)
        
        posterImageView.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top)
            make.right.equalTo(self.snp.right)
            make.left.equalTo(self.snp.left)
            make.bottom.equalTo(self.snp.bottom)
        }
        
        likeButton.snp.makeConstraints { make in
            make.top.equalTo(posterImageView.snp.top).offset(10)
            make.right.equalTo(posterImageView.snp.right).offset(-10)
            make.size.equalTo(CGSize(width: 25, height: 25))
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(posterImageView.snp.top).offset(10)
            make.right.equalTo(likeButton.snp.left).offset(-10)
            make.left.equalTo(posterImageView.snp.left).offset(10)
        }
        
        genreLabel.snp.makeConstraints { make in
            make.bottom.equalTo(self.snp.bottom).offset(-10)
            make.left.equalTo(self.snp.left).offset(10).priority(.high)
            make.height.equalTo(30)
        }
        
        yearLabel.snp.makeConstraints { make in
            make.bottom.equalTo(genreLabel.snp.bottom)
            make.right.equalTo(self.snp.right).offset(-15).priority(.high)
            make.left.equalTo(genreLabel.snp.right).priority(.high)
            make.height.equalTo(30)
        }
    }
    
    private func setShadow() {
        layer.cornerRadius = 10
        layer.masksToBounds = false
        layer.shadowOpacity = 0.83
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowColor = UIColor.black.cgColor
    }
}
