import UIKit
import SnapKit

final class InteractiveHeader: UICollectionReusableView {
    
    static let identifier = "InteractiveHeader"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .black
        label.text = "HEADER"
        label.font = UIFont.boldSystemFont(ofSize: 30)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    func setUp(title: String) {
        titleLabel.text = title
    }
    
    private func setupUI() {
        addSubviews(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top)
            make.right.equalTo(self.snp.right)
            make.left.equalTo(self.snp.left)
            make.bottom.equalTo(self.snp.bottom)
        }
    }
    
}
