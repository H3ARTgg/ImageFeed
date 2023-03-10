import Foundation
import UIKit

struct PhotoResult: Codable {
    let id: String
    let width: Int
    let height: Int
    let createdAt: String
    let description: String
    let isLiked: Bool
    let urls: [String: String]
    
    private enum CodingKeys: String, CodingKey {
        case id
        case width
        case height
        case createdAt = "created_at"
        case description
        case isLiked = "liked_by_user"
        case urls
    }
}
