//
//  ImageHelper.swift
//  DeliciousNotes
//
//  Created by Amelia Boli on 12/21/16.
//  Copyright © 2016 Appogenic. All rights reserved.
//

import UIKit

class ImageFetcher {
    // Creates the image that should be associated with the restaurant
    static func generateImage(imageUrl: String?) -> UIImage? {
        guard let photoUrl = imageUrl,
            let url = URL(string: photoUrl) else {
                #if DEBUG
                    print("There was a problem creating the url from \(imageUrl)")
                #endif
                return nil
        }

        var imageData: NSData? = nil

        do {
            imageData = try NSData(contentsOf: url, options: .mappedIfSafe)
        } catch {
            #if DEBUG
                print("There was a problem fetching the data from the image url: \(url). Error: \(error)")
            #endif
            return nil
        }

        let image = UIImage(data: imageData as! Data)
        return image
    }
}
