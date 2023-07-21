import Foundation
import UIKit

public struct Photo {
    public let id: String
    public let size: CGSize
    public let createdAt: Date?
    public let welcomeDescription: String?
    public let thumbImageURL: String
    public let largeImageURL: String
    public let isLiked: Bool
    
    public init(
        id: String,
        size: CGSize,
        createdAt: Date?,
        welcomeDescription: String?,
        thumbImageURL: String,
        largeImageURL: String,
        isLiked: Bool
    ) {
        self.id = id
        self.size = size
        self.createdAt = createdAt
        self.welcomeDescription = welcomeDescription
        self.thumbImageURL = thumbImageURL
        self.largeImageURL = largeImageURL
        self.isLiked = isLiked
    }
}
