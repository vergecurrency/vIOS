//
//  URLSession.swift
//  VergeiOS
//
//  Created by Marvin Piekarek on 28.07.18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import Foundation

extension URLSession {
    public func requestTor(url: URL, completionFunc: @escaping ((Data?, URLResponse?, Error?) -> Void)) -> Void {
        var session: URLSession
        if url.absoluteString.range(of:"localhost") != nil || url.absoluteString.range(of:"127.0.0.1") != nil{
            session = URLSession(configuration: .default)
        } else {
            session = TorClient.shared.session
        }
        
        let task = session.dataTask(with: URLRequest(url: url), completionHandler: completionFunc)
        task.resume()
        
    }
}
