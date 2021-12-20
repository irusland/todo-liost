//
//  Auth.swift
//  TodoLiost
//
//  Created by Ruslan Sirazhetdinov on 26.11.2021.
//

import Foundation
import UIKit
import WebKit
import CocoaLumberjack

protocol IAuthentificator {
    var isLoggedIn: Bool { get }
}

@objc protocol AuthentificationDelegate {
    func authentificationFinished()
}

class AuthViewController: UIViewController, IAuthentificator, URLSessionDataDelegate {
    private(set) var authCredentials: OAuthCredentials?

    weak var authentificationDelegate: AuthentificationDelegate?

    lazy var session: URLSession = {
        return URLSession(configuration: .default, delegate: self, delegateQueue: .main)
    }()

    var isLoggedIn: Bool = false

    let webView: WKWebView = {
        var webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()

    override func viewDidLoad() {
        view.addSubview(webView)

        setupSubviews()
    }

    override func viewWillAppear(_ animated: Bool) {
        guard let url = URL(string: "https://oauth.yandex.ru/authorize?response_type=token&client_id=0d0970774e284fa8ba9ff70b6b06479a") else { return }
        let urlRequest = URLRequest(url: url)

        webView.load(urlRequest)
    }

    func webView(didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        if let url = webView.url, url.absoluteString.starts(with: "https://accounts.google.com") {
            UIApplication.shared.open(url, options: [:])
        }
    }

    func setupSubviews() {
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        webView.navigationDelegate = self
    }
}

extension AuthViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            if url.path == "/verification_code" {
                if let fragmentParams = url.fragmentParams, let accessToken = fragmentParams["access_token"], let tokenType = fragmentParams["token_type"], let expiresIn = fragmentParams["expires_in"], let expiresTime = TimeInterval(expiresIn) {

                    authCredentials = OAuthCredentials(accessToken: accessToken, tokenType: tokenType, expiresIn: expiresTime)
                    isLoggedIn = true
                    DDLogInfo("Logged in \(String(describing: authCredentials))")
                    dismiss(animated: true)
                    authentificationDelegate?.authentificationFinished()
                }

            }
        }
        decisionHandler(.allow)
    }
}

struct OAuthCredentials {
    let accessToken: String
    let tokenType: String?
    let expiresIn: TimeInterval?

    public init(accessToken: String, tokenType: String, expiresIn: TimeInterval) {
        self.accessToken = accessToken
        self.tokenType = tokenType
        self.expiresIn = expiresIn
    }
}

extension URL {
    var fragmentParams: [String: String]? {
        var components = URLComponents()
        components.query = self.fragment
        guard let queryItems = components.queryItems else {
            return nil
        }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
}
