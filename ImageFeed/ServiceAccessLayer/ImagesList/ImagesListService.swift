import Foundation
import UIKit
import SwiftKeychainWrapper

final class ImagesListService {
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    private let photosPerPage: Int = 10
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    private var likeTask: URLSessionTask?
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()
    
    func fetchPhotosNextPage(completion: @escaping (Error) -> Void) {
        if task != nil {
            return
        }
        
        var nextPage: Int = 1
        if let lastLoadedPage = lastLoadedPage {
            nextPage = lastLoadedPage + 1
            self.lastLoadedPage = nextPage
        } else {
            lastLoadedPage = 1
        }

        var request = URLRequest.makeHTTPRequest(
            path: "/photos"
            + "?page=\(nextPage)"
            + "&&per_page=\(photosPerPage)",
            httpMethod: "GET"
        )
        guard let token = TokenStorage.shared.token else {
            assertionFailure("No token")
            return
            
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.objectTask(for: request) {
            [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let photos):
                for photo in photos {
                    guard let date = self.dateFormatter.date(from: photo.createdAt) else {
                        enum Fail: Error {
                            case FailedToMakeDate
                        }
                        completion(Fail.FailedToMakeDate)
                        return
                    }
                    let newPhoto = Photo(
                        id: photo.id,
                        size: CGSize(width: photo.width, height: photo.height),
                        createdAt: date,
                        welcomeDescription: photo.description,
                        thumbImageURL: photo.urls.thumb,
                        largeImageURL: photo.urls.full,
                        isLiked: photo.isLiked
                    )
                    // Проверка на дублирование
                    if self.photos.count > 0 {
                        if self.photos.contains(where: { $0.id == newPhoto.id }) {
                            continue
                        } else {
                            self.photos.append(newPhoto)
                        }
                    } else {
                        self.photos.append(newPhoto)
                    }
                }
                
                self.task = nil
                NotificationCenter.default.post(
                    name: ImagesListService.didChangeNotification,
                    object: self)
            case .failure(let error):
                print(error)
                completion(error)
                self.task = nil
            }
        }
        self.task = task
        task.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        if likeTask != nil {
            return
        }
        
        var request: URLRequest
        if isLike {
            request = URLRequest.makeHTTPRequest(path: "/photos/\(photoId)/like", httpMethod: "DELETE")
        } else {
            request = URLRequest.makeHTTPRequest(path: "/photos/\(photoId)/like", httpMethod: "POST")
        }
        guard let token = TokenStorage.shared.token else {
            assertionFailure("no token")
            return
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.voidTask(for: request) {
            [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(_):
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    let photo = self.photos[index]
                    
                    let newPhoto = Photo(
                        id: photo.id,
                        size: photo.size,
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.welcomeDescription,
                        thumbImageURL: photo.thumbImageURL,
                        largeImageURL: photo.largeImageURL,
                        isLiked: !photo.isLiked
                    )
                    self.photos[index] = newPhoto
                }
                completion(.success(Void()))
            case .failure(let error):
                completion(.failure(error))
            }
            self.likeTask = nil
        }
        task.resume()
        self.likeTask = task
    }
}
