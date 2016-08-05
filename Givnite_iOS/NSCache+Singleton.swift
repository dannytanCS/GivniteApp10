//
//  NSCache+Singleton.swift
//  Givnite
//
//  Created by Danny Tan on 7/21/16.
//  Copyright © 2016 Givnite. All rights reserved.
//

import Foundation

extension NSCache {
    class var sharedInstance : NSCache {
        struct Static {
            static let instance : NSCache = NSCache()
        }
        return Static.instance
    }
}
