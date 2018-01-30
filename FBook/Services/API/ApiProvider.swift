//
//  ApiProvider.swift
//  FBook
//
//  Created by Ban Nguyen Ngoc on 9/6/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import Foundation
import ReactiveSwift
import Moya
import Alamofire

public struct ApiProvider {

    fileprivate static var endpointClosure = { (target: API) -> Endpoint<API> in
        return Endpoint<API>(
            url: url(target),
            sampleResponseClosure: { .networkResponse(200, target.sampleData) },
            method: target.method,
            parameters: target.parameters,
            parameterEncoding: target.parameterEncoding)
    }

    fileprivate static var networkActivityClosure = { (change: NetworkActivityChangeType) -> Void in
        UIApplication.shared.isNetworkActivityIndicatorVisible = (change == .began)
    }

    fileprivate static func getProvider(_ token: String?) -> MoyaProvider<API> {
        var plugins: [PluginType] = [
            NetworkLoggerPlugin(verbose: true),
            NetworkActivityPlugin(networkActivityClosure: networkActivityClosure)
        ]
        if let token = token {
            plugins.append(CustomAccessTokenPlugin(token: token))
        }
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15
        let newManager = Alamofire.SessionManager(configuration: configuration)
        return MoyaProvider<API>(endpointClosure: endpointClosure, manager: newManager, plugins: plugins)
    }

    fileprivate static var authenticatedProvider: MoyaProvider<API>?
    fileprivate static let defaultProvider = getProvider(nil)

    static var accessToken: String? {
        get {
            return userDefaults.value(forKey: kAccessTokenKey) as? String
        }
        set {
            if let value = newValue {
                authenticatedProvider = getProvider(value)
            } else {
                authenticatedProvider = nil
            }
            userDefaults.set(newValue, forKey: kAccessTokenKey)
            userDefaults.synchronize()
        }
    }

    static var shared: MoyaProvider<API> {
        if let authenticatedProvider = authenticatedProvider {
            return authenticatedProvider
        } else if let accessToken = accessToken {
            authenticatedProvider = getProvider(accessToken)
            return authenticatedProvider ?? defaultProvider
        }
        return defaultProvider
    }

}

// MARK: - AccessTokenAuthorizable

/// A protocol for controlling the behavior of `AccessTokenPlugin`.
public protocol AccessTokenAuthorizable {
    /// Declares whether or not `AccessTokenPlugin` should add an authorization header
    /// to requests.
    var shouldAuthorize: Bool { get }
}

// MARK: - AccessTokenPlugin

public struct CustomAccessTokenPlugin: PluginType {
    /// The access token to be applied in the header.
    public let token: String

    public init(token: String) {
        self.token = token
    }
    /**
     Prepare a request by adding an authorization header if necessary.
     
     - parameters:
     - request: The request to modify.
     - target: The target of the request.
     - returns: The modified `URLRequest`.
     */
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        if let authorizable = target as? AccessTokenAuthorizable, authorizable.shouldAuthorize == false {
            return request
        }
        var request = request
        request.addValue(token, forHTTPHeaderField: "Authorization")
        return request
    }
}

func url(_ route: TargetType) -> String {
    return route.baseURL.absoluteString + route.path
}
