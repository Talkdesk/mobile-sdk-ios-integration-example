//
//  AuthorizationController.swift
//  SDKSample
//
//  Copyright © 2018 Talkdesk. All rights reserved.
//

import Foundation
import TalkdeskSDK

/// Implements the `MediaSessionAuthorizationDelegate` protocol.
///
class AuthorizationController: MediaSessionAuthorizationDelegate {

    // MARK: - MediaSessionAuthorizationDelegate

    func shouldAuthorize() {
        AuthorizationService.register { authorization in
            TalkdeskSDK.authorize(with: authorization)
        }
    }
}

class AuthorizationService {

    // MARK: - Service configuration

    /// The URL where the authorization server is running.
    ///
    static let authorizationEndpoint = "http://localhost:5000/token/example-app-ios"

    /// The basic auth username (DEFAULT_USERNAME) defined in the authorization server.
    ///
    static let authorizationUsername = "user"

    /// The basic auth password (DEFAULT_PASSWORD) defined in the authorization server.
    ///
    static let authorizationPassword = "pwd"

    // MARK: -

    /// Performs a request to the authorization endpoint, and calls `completion` with
    /// a `MediaSessionAuthorization` parsed from the server response.
    ///
    static func register(_ completion: @escaping (MediaSessionAuthorization) -> Void ) {
        guard let authorizationRequest = buildAuthorizationRequest() else { return }
        let task = URLSession.shared.dataTask(with: authorizationRequest) { data, response, _ in
            guard let response = response as? HTTPURLResponse,
                response.statusCode == 201,
                let data = data else {
                completion(.notAuthorized(reason: "Unable to authorize."))
                return
            }

            completion(AuthorizationParser.parse(from: data))
        }

        task.resume()
    }

    /// Builds the request to the authorization endpoint based on the service configuration.
    ///
    static func buildAuthorizationRequest() -> URLRequest? {
        guard let authorizationURL = URL(string: authorizationEndpoint),
            let basicAuth = generateBasicAuth(username: authorizationUsername, password: authorizationPassword) else {
                TalkdeskSDK.authorize(with: .notAuthorized(reason: "Invalid authentication parameters."))
                return nil
        }

        var request: URLRequest = URLRequest(url: authorizationURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Basic \(basicAuth)", forHTTPHeaderField: "Authorization")
        return request
    }

    /// Generates a basic auth base64 string from the provided username and password.
    ///
    static func generateBasicAuth(username: String, password: String) -> String? {
        return "\(username):\(password)".data(using: .utf8)?.base64EncodedString()
    }
}

private class AuthorizationParser {

    private struct AuthResponse: Decodable {
        let authToken: String
    }

    static func parse(from data: Data) -> MediaSessionAuthorization {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        if let authResponse = try? decoder.decode(AuthResponse.self, from: data) {
            return .accessToken(authResponse.authToken)
        } else {
            return .notAuthorized(reason: "Unable to parse the response from the server.")
        }
    }
}
