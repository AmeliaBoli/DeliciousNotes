//
//  AlertProtocol.swift
//  DeliciousNotes
//
//  Created by Amelia Boli on 12/21/16.
//  Copyright © 2016 Appogenic. All rights reserved.
//

import UIKit

protocol AlertDelegate: class {
    func createNetworkingAlert(error: ErrorType) -> UIAlertController
}

extension AlertDelegate {
    func createNetworkingAlert(error: ErrorType) -> UIAlertController {
        var message = "Something went wrong"

        switch error {
        case .error(let embeddedMessage): message = embeddedMessage
        case .network: message = "You do not seem to be connected to the internet. Please connect and try again. A connection is required for this app."
        default: break
        }

        let alert = UIAlertController(title: "Network Problems", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        return alert
    }
}
