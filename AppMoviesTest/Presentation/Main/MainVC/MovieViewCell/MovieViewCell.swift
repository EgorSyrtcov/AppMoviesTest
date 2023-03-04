import UIKit
import SnapKit

final class MovieViewCell<T: UIView>: UICollectionViewCell {
    
    let containerView: T
    
    override init(frame: CGRect) {
        self.containerView = T(frame: .zero)
        super.init(frame: frame)
        setupUI()
       
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.contentView.addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }
    }
}
