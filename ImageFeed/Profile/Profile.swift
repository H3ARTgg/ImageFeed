struct Profile: Codable {
    let username: String?
    let name: String?
    let bio: String?
    var loginName: String {
        guard let username = username else { return "" }
        return "@" + username
    }
}
