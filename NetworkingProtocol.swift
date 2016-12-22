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
    func taskForHTTPMethod(request: URLRequest, completionHandlerForMethod: @escaping (_ result: Data?, _ error: NSError?) -> Void) -> URLSessionDataTask
    func deserializeJSONWithCompletionHandler(data: Data, completionHandlerForDeserializeJSON: (_ result: Any?, _ error: Error?) -> Void)
    func sendError(error: String, domain: String, code: Int, completionHandlerForSendError: (_ result: Data?, _ error: NSError?) -> Void)
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

    func taskForHTTPMethod(request: URLRequest, completionHandlerForMethod: @escaping (_ result: Data?, _ error: NSError?) -> Void) -> URLSessionDataTask {

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in

            self.toggleNetworkIndicator(turnOn: false)

            let domain = "taskForHTTPMethod"

            /* GUARD: Was there an error? */
            guard error == nil else {
                var errorString = "There was an error with your request: \(error)"
                if (error! as NSError).code == -1009 {
                    errorString = "We couldn't log you in. There seems to be a problem with your network connection."
                }
                self.sendError(error: errorString, domain: domain, code: -1009, completionHandlerForSendError: completionHandlerForMethod)
                return
            }

            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                self.sendError(error: "There seems to be no status code", domain: domain, code: 1, completionHandlerForSendError: completionHandlerForMethod)
                return
            }

            guard statusCode >= 200 && statusCode <= 299 else {
                var errorString = "Your request returned a status code other than 2xx!: \(statusCode)"

                if statusCode == 403 {
                    errorString = "We couldn't log you in. Your username or password seem incorrect."
                }

                self.sendError(error: errorString, domain: domain, code: 1, completionHandlerForSendError: completionHandlerForMethod)
                return
            }

            /* GUARD: Was there any data returned? */
            guard let data = data else {
                self.sendError(error: "No data was returned by the request!", domain: domain, code: 1, completionHandlerForSendError: completionHandlerForMethod)
                return
            }

            completionHandlerForMethod(data, nil)
        }

        toggleNetworkIndicator(turnOn: true)
        task.resume()
        return task
    }

    func deserializeJSONWithCompletionHandler(data: Data, completionHandlerForDeserializeJSON: (_ result: Any?, _ error: Error?) -> Void) {
        var parsedData: Any?

        do {
            parsedData = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        } catch {
            completionHandlerForDeserializeJSON(nil, .jsonSerialization)
        }
        completionHandlerForDeserializeJSON(parsedData, nil)
    }

    // MARK: Extension Helpers
    func sendError(error: String, domain: String, code: Int, completionHandlerForSendError: (_ result: Data?, _ error: NSError?) -> Void) {
        #if DEBUG
            print(error)
        #endif
        let userInfo = [NSLocalizedDescriptionKey : error]
        let nsError = NSError(domain: domain, code: code, userInfo: userInfo)
        completionHandlerForSendError(nil, nsError)
    }

    func toggleNetworkIndicator(turnOn: Bool) {
        let application = UIApplication.shared

        if turnOn && !application.isNetworkActivityIndicatorVisible {
            application.isNetworkActivityIndicatorVisible = true
        } else if !turnOn && application.isNetworkActivityIndicatorVisible {
            application.isNetworkActivityIndicatorVisible = false
        }
    }
}
