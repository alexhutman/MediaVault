//
//  BlobExtensions.swift
//  MediaVault
//
//  Created by alex on 5/7/18.
//  Copyright © 2018 alex. All rights reserved.
//

import Foundation
import SQLite

extension UIImage: Value {
    public class var declaredDatatype: String {
        return Blob.declaredDatatype
    }
    public class func fromDatatypeValue(_ blobValue: Blob) -> UIImage {
        return UIImage(data: Data.fromDatatypeValue(blobValue))!
    }
    public var datatypeValue: Blob {
        return UIImagePNGRepresentation(self)!.datatypeValue
    }
    
}
