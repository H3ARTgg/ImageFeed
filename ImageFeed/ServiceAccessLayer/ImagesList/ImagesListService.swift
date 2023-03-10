import Foundation
import UIKit

final class ImagesListService {
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    private let photosPerPage: Int = 10
    
    func fetchPhotosNextPage() {
        if task != nil {
            return
        }
        
        let nextPage = lastLoadedPage == nil
            ? 1
            : lastLoadedPage! + 1
        
        var request = URLRequest.makeHTTPRequest(
            path: "/photos"
            + "?page=\(nextPage)"
            + "&&per_page=\(photosPerPage)",
            httpMethod: "GET"
        )
        guard let token = TokenStorage.token else { return }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.objectTask(for: request) {
            [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let photos):
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                
                for photo in photos {
                    let date = dateFormatter.date(from: photo.createdAt)
                    let newPhoto = Photo(
                        id: photo.id,
                        size: CGSize(width: photo.width, height: photo.height),
                        createdAt: date,
                        welcomeDescription: photo.description,
                        thumbImageURL: photo.urls.thumb,
                        largeImageURL: photo.urls.full,
                        isLiked: photo.isLiked)
                    self.photos.append(newPhoto)
                }
                
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
