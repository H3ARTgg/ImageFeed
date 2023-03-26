public struct ProfileResult: Codable {
    let username: String
    let name: String
    var bio: String?
    
    public init(username: String, name: String, bio: String?) {
        self.username = username
        self.name = name
        self.bio = bio
    }
}
