//
// Created by Swen van Zanten on 02/04/2020.
// Copyright (c) 2020 Verge Currency. All rights reserved.
//

import Foundation
import Promises

class HiddenHttpSession {
    private let hiddenClient: HiddenClientProtocol

    init(hiddenClient: HiddenClientProtocol) {
        self.hiddenClient = hiddenClient
    }

    func dataTask(with request: URLRequest) -> Promise<HttpResponse> {
        return self.add { promise, session in
            let task = session.dataTask(with: request) { data, urlResponse, error in
                self.handleTaskCompletion(promise: promise, data: data, urlResponse: urlResponse, error: error)
            }

            task.resume()
        }
    }

    func dataTask(with url: URL) -> Promise<HttpResponse> {
        return self.add { promise, session in
            let task = session.dataTask(with: url) { data, urlResponse, error in
                self.handleTaskCompletion(promise: promise, data: data, urlResponse: urlResponse, error: error)
            }

            task.resume()
        }
    }

    private func add(
        completion: @escaping (Promise<HttpResponse>, URLSession) -> Void
    ) -> Promise<HttpResponse> {
        let promise = Promise<HttpResponse>.pending()

        self.process(request: HiddenHttpSessionRequest(promise: promise, completion: completion))

        return promise
    }

    private func process(request: HiddenHttpSessionRequest) {
        self.hiddenClient
            .getURLSession()
            .then { session in
                request.fulfill(session)
            }.catch { error in
                self.retryAfterError(originalRequest: request, error: error)
            }
    }

    private func retryAfterError(originalRequest: HiddenHttpSessionRequest, error: Error) {
        NotificationCenter.default.addObserver(
            forName: .didResolveHiddenHttpSessionError,
            object: self,
            queue: .main
        ) { notification in
            guard let request = notification.object as? HiddenHttpSessionRequest else {
                return originalRequest.reject(error)
            }

            self.process(request: request)
        }

        NotificationCenter.default.post(name: .didNotGetHiddenHttpSession, object: originalRequest)
    }

    private func handleTaskCompletion(
        promise: Promise<HttpResponse>,
        data: Data?,
        urlResponse: URLResponse?,
        error: Error?
    ) {
        if let error = error {
            return promise.reject(error)
        }

        promise.fulfill(HttpResponse(data: data, urlResponse: urlResponse))
    }
}
