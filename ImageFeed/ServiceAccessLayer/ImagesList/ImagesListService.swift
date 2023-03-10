import Foundation
import UIKit

final class ImagesListService {
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    
    func fetchPhotosNextPage() {
        guard self.task != nil else {
            task?.resume()
            return
        }
        
        let nextPage = lastLoadedPage == nil
            ? 1
            : lastLoadedPage! + 1
        
        let request = URLRequest.makeHTTPRequest(path: "/photos" + "?page=\(nextPage)", httpMethod: "GET")
        let task = URLSession.shared.objectTask(for: request) {
            [weak self] (result: Result<PhotoResult, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let photoResult):
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
                let date = dateFormatter.date(from: photoResult.createdAt)
                
                let photo = Photo(id: photoResult.id,
                                  size: CGSize(width: photoResult.width, height: photoResult.height),
                                  createdAt: date,
                                  welcomeDescription: photoResult.description,
                                  thumbImageURL: photoResult.urls["thumb"] ?? "",
                                  largeImageURL: photoResult.urls["full"] ?? "",
                                  isLiked: photoResult.isLiked)
                
                self.photos.append(photo)
                self.task = nil
                NotificationCenter.default.post(
                    name: ImagesListService.didChangeNotification,
                    object: self)
            case .failure(let error):
                print(error)
                self.task = nil
            }
        }
        self.task = task
        task.resume()
    }
}
