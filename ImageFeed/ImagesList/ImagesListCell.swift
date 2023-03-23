import UIKit

final class ImagesListCell: UITableViewCell {
    // MARK: - Outlets and Properties
    @IBOutlet weak var imageCell: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    weak var delegate: ImagesListCellDelegate?
    
    static let reuseIdentifier = "ImagesListCell"
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageCell.kf.cancelDownloadTask()
    }
    
    @IBAction func likeButtonClicked() {
        delegate?.imageListCellDidTapLike(self)
    }
    
//    func configureGradient() {
//        let layer = CAGradientLayer()
//        //layer.bounds = CGRect(x: imageCell.frame.minX, y: imageCell.frame.maxY, width: imageCell.frame.size.width, height: 30)
//        layer.locations = [0, 1]
//        layer.colors = [
//            UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 0).cgColor,
//            UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1).cgColor
//        ]
//        layer.startPoint = CGPoint(x: 0.25, y: 0.5)
//        layer.endPoint = CGPoint(x: 0.75, y: 0.5)
//        layer.transform = CATransform3DMakeAffineTransform(
//            CGAffineTransform(
//                a: 0,
//                b: 0.54,
//                c: -0.54,
//                d: 0,
//                tx: 0.77,
//                ty: 0
//            )
//        )
//        layer.bounds = CGRect(x: self.bounds.minX, y: self.bounds.maxY, width: self.bounds.width, height: 30)
////        layer.bounds = self.bounds.insetBy(
////            dx: -0.5 * self.bounds.size.width,
////            dy: -0.5 * self.bounds.size.height)
//        layer.cornerRadius = 16
//        layer.masksToBounds = true
//
//        layer.position = self.center
//        self.layer.addSublayer(layer)
//  }
    
    func setIsLike(_ isLiked: Bool) {
        if isLiked {
            likeButton.setImage(UIImage(named: "like_button_on"), for: .normal)
        } else {
            likeButton.setImage(UIImage(named: "like_button_off"), for: .normal)
        }
    }
}
