import UIKit
import Kingfisher

public final class ImagesListCell: UITableViewCell {
    // MARK: - Outlets and Properties
    @IBOutlet weak var imageCell: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    weak var delegate: ImagesListCellDelegate?
    var presenterDelegate: ImagesListCellPresenterDelegate?
    
    static let reuseIdentifier = "ImagesListCell"
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        imageCell.kf.cancelDownloadTask()
    }
    
    @IBAction func likeButtonClicked() {
        delegate?.imageListCellDidTapLike(self)
    }
    
    func setIsLike(_ isLiked: Bool) {
        if isLiked {
            likeButton.setImage(UIImage(named: "like_button_on"), for: .normal)
        } else {
            likeButton.setImage(UIImage(named: "like_button_off"), for: .normal)
        }
    }
    
    func configCell(with photo: Photo, and indexPath: IndexPath) {
        guard let url = URL(string: photo.thumbImageURL) else {
            assertionFailure("No url from thumbImageURL")
            return
        }
        imageCell.kf.indicatorType = .activity
        imageCell.kf.setImage(with: url, placeholder: UIImage(named: "stub_photo"), options: .none) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let image):
                self.presenterDelegate?.updatePhotosImages(with: image.image, for: indexPath)
            case .failure(_):
                print("failed to get image")
            }
        }
        
        dateLabel.text = dateFormatter.string(from: photo.createdAt ?? Date())
        setIsLike(photo.isLiked)
    }
}
