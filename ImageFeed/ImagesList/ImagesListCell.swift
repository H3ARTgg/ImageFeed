import UIKit

final class ImagesListCell: UITableViewCell {
    // MARK: - Outlets and Properties
    @IBOutlet weak var imageCell: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    static let reuseIdentifier = "ImagesListCell"
    
    
}
