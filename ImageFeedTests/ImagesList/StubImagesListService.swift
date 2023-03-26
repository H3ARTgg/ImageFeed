import Foundation
import CoreGraphics
import ImageFeed

final class StubImagesListService: ImagesListServiceProtocol {
    let didChangeNotification: Notification.Name = Notification.Name(rawValue: "service")
    var photos: [Photo] = []
    var isSuccessFetchPhotos: Bool = false
    var isSuccessChangeLike: Bool = false
    var lastLoadedInts: Int?
    
    init(isSuccessFetchPhotos: Bool, isSuccessChangeLike: Bool) {
        self.isSuccessFetchPhotos = isSuccessFetchPhotos
        self.isSuccessChangeLike = isSuccessChangeLike
    }
    
    func fetchPhotosNextPage(completion: @escaping (Error) -> Void) {
        if isSuccessFetchPhotos {
            var nextInts: Int = 10
            if let lastLoadedInts = lastLoadedInts {
                nextInts = lastLoadedInts + 10
                self.lastLoadedInts = nextInts
            } else {
                lastLoadedInts = 10
            }
            for i in 0..<nextInts {
                let photo = Photo(
                    id: "\(i)",
                    size: CGSize(width: 10, height: 10),
                    createdAt: Date(),
                    welcomeDescription: "welcome",
                    thumbImageURL: "thumbURL",
                    largeImageURL: "largeURL",
                    isLiked: false)
                photos.append(photo)
            }
            NotificationCenter.default.post(
                name: self.didChangeNotification,
                object: self)
        } else {
            enum Errors: Error {
                case noPhotos
            }
            completion(Errors.noPhotos)
        }
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        if isSuccessChangeLike {
            if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                let oldPhoto = self.photos[index]
                let newPhoto = Photo(
                    id: oldPhoto.id,
                    size: oldPhoto.size,
                    createdAt: oldPhoto.createdAt,
                    welcomeDescription: oldPhoto.welcomeDescription,
                    thumbImageURL: oldPhoto.thumbImageURL,
                    largeImageURL: oldPhoto.largeImageURL,
                    isLiked: !oldPhoto.isLiked
                )
                self.photos[index] = newPhoto
                completion(.success(Void()))
            }
        } else {
            enum Errors: Error {
                case cantLike
            }
            completion(.failure(Errors.cantLike))
        }
    }
    
}
