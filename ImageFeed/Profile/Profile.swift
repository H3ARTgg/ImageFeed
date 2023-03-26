public struct Profile {
    let username: String
    let name: String
    let bio: String?
    var loginName: String {
        return "@" + username
    }
    
    public init(username: String, name: String, bio: String?) {
        self.username = username
        self.name = name
        self.bio = bio
    }
}
