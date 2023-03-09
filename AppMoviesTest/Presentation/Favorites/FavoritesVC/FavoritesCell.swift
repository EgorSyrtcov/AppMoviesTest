import UIKit
import SnapKit
import Kingfisher

class FavoritesCell: UITableViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.italicSystemFont(ofSize: 20)
        return label
    }()
    
    private let posterImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleToFill
        iv.layer.cornerRadius = 10
        iv.clipsToBounds = true
        return iv
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let margins = UIEdgeInsets(top: 11, left: 22, bottom: 11, right: 18)
        contentView.frame = contentView.frame.inset(by: margins)
        contentView.layer.cornerRadius = 8
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        selectionStyle = .none
    }
    
    private func setupUI() {
        
        contentView.addSubviews(posterImageView, titleLabel)
        
        posterImageView.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top)
            make.left.equalTo(contentView.snp.left)
            make.width.equalTo(100)
            make.bottom.equalTo(contentView.snp.bottom)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top)
            make.left.equalTo(posterImageView.snp.right).offset(10)
            make.right.equalTo(contentView.snp.right)
            make.bottom.equalTo(contentView.snp.bottom)
        }
    }
    
    func setupMovie(_ movie: MovieRealmModel?) {
        guard let movie = movie else { return }
        titleLabel.text = movie.title
        KF.url(URL(string: movie.poster))
            .placeholder(UIImage(named: "posterDefault"))
            .loadDiskFileSynchronously()
            .cacheMemoryOnly()
            .fade(duration: 0.25)
            .set(to: posterImageView)
    }
}
