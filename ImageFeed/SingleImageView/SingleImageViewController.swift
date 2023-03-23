import UIKit

final class SingleImageViewController: UIViewController {
    // MARK: - Outlets and Properties
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var imageView: UIImageView!
    private let logoImage = UIImage(named: "image_logo")!
    var photo: Photo?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        imageView.image = logoImage
        rescaleAndCenterImageInScrollView(image: imageView.image ?? UIImage())
        showLargeImage()
    }
    
    // MARK: - IBActions
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func didTapShareButton() {
        let imageArray: [UIImage] = [imageView.image ?? UIImage()]
        let shareController = UIActivityViewController(activityItems: imageArray, applicationActivities: nil)
        present(shareController, animated: true)
    }
    
}
// MARK: - showLargeImage, rescaleAndCenterImageInScrollView, Error
extension SingleImageViewController {
    private func showLargeImage() {
        guard let photo = photo else {
            assertionFailure("No photo in SingleImageViewController")
            return
        }
        
        let url = URL(string: photo.largeImageURL)!
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(
            with: url,
            placeholder: logoImage,
            options: .none) { [weak self] result in
                UIBlockingProgressHUD.dismiss()
                
                guard let self = self else { return }
                switch result {
                case .success(let image):
                    self.imageView.image = image.image
                    self.rescaleAndCenterImageInScrollView(image: image.image)
                case .failure(let error):
                    print(error)
                    self.showAdvancedError()
                }
            }
    }
    
    private func showAdvancedError() {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Попробовать ещё раз?",
            preferredStyle: .alert
        )
        
        let dismissAction = UIAlertAction(title: "Не надо", style: .default) { _ in
            alert.dismiss(animated: true)
        }
        
        let repeatAction = UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            guard let self = self else { return }
            guard let photo = self.photo else { return }
            UIBlockingProgressHUD.show()
            self.imageView.kf.setImage(
                with: URL(string: photo.largeImageURL)!,
                placeholder: self.logoImage,
                options: .none) { [weak self] result in
                    UIBlockingProgressHUD.dismiss()
                    
                    guard let self = self else { return }
                    switch result {
                    case .success(let image):
                        self.imageView.image = image.image
                        alert.dismiss(animated: true)
                    case .failure(let error):
                        print(error)
                        alert.dismiss(animated: true)
                        self.showAdvancedError()
                    }
                }
        }
        
        alert.addAction(dismissAction)
        alert.addAction(repeatAction)
        present(alert, animated: true)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}
    
    


// MARK: - UIScrollDelegate
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}
