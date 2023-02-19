protocol OAuth2ServiceProtocol: AnyObject {
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void)
}
