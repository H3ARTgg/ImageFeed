struct UserResult: Codable {
    let profileImage: [String: String]?
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}
