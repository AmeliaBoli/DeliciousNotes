//
//  NetworkingProtocol.swift
//  DeliciousNotes
//
//  Created by Amelia Boli on 11/20/16.
//  Copyright © 2016 Appogenic. All rights reserved.
//

import UIKit

protocol Networking {
    func urlFromComponents(scheme: String, host: String, path: String?, withPathExtension: String?, parameters: [String: Any]?) -> URL?
    func taskForHTTPMethod(request: URLRequest, completionHandlerForMethod: @escaping (_ result: Data?, _ error: ErrorType?) -> Void) -> URLSessionDataTask
    func deserializeJSONWithCompletionHandler(data: Data, completionHandlerForDeserializeJSON: (_ result: Any?, _ error: ErrorType?) -> Void)
    func toggleNetworkIndicator(turnOn: Bool)
}

extension Networking {
    // MARK: Protocol Methods
    func urlFromComponents(scheme: String, host: String, path: String?, withPathExtension: String?, parameters: [String: Any]?) -> URL? {

        let components = NSURLComponents()
        components.scheme = scheme
        components.host = host

        if let path = path {
            components.path = path + (withPathExtension ?? "")
        }

        components.queryItems = [URLQueryItem]()

        if let parameters = parameters {
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems?.append(queryItem)
            }
        }

        guard let url = components.url else {
            #if DEBUG
                print("There was a problem creating the URL")
            #endif
            return nil
        }

        return url
    }

    func taskForHTTPMethod(request: URLRequest, completionHandlerForMethod: @escaping (_ result: Data?, _ error: ErrorType?) -> Void) -> URLSessionDataTask {

        let task = URLSession.shared.dataTask(with: request) { (data, response, receivedError) in

            self.toggleNetworkIndicator(turnOn: false)

            /* GUARD: Was there an error? */
            guard receivedError == nil else {
                var errorToPass = ErrorType.error((receivedError!.localizedDescription))
                if (receivedError! as NSError).code == -1009 {
                    errorToPass = ErrorType.network
                }
                completionHandlerForMethod(nil, errorToPass)
                return
            }

            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                completionHandlerForMethod(nil, .noStatusCode)
                return
            }

            guard statusCode >= 200 && statusCode <= 299 else {
                completionHandlerForMethod(nil, .notOkayStatusCode(statusCode))
                return
            }

            /* GUARD: Was there any data returned? */
            guard let data = data else {
                completionHandlerForMethod(nil, .noData)
                return
            }

            completionHandlerForMethod(data, nil)
        }

        toggleNetworkIndicator(turnOn: true)
        task.resume()
        return task
    }

    func deserializeJSONWithCompletionHandler(data: Data, completionHandlerForDeserializeJSON: (_ result: Any?, _ error: ErrorType?) -> Void) {
        var parsedData: Any?

        do {
            parsedData = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        } catch {
            completionHandlerForDeserializeJSON(nil, .jsonSerialization)
        }
        completionHandlerForDeserializeJSON(parsedData, nil)
    }

    // MARK: Extension Helpers
    func toggleNetworkIndicator(turnOn: Bool) {
        let application = UIApplication.shared

        if turnOn && !application.isNetworkActivityIndicatorVisible {
            application.isNetworkActivityIndicatorVisible = true
        } else if !turnOn && application.isNetworkActivityIndicatorVisible {
            application.isNetworkActivityIndicatorVisible = false
        }
    }
}
