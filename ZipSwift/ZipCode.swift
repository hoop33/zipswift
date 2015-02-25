//
//  ZipCode.swift
//  ZipSwift
//
//  Created by Rob Warner on 2/24/15.
//  Copyright (c) 2015 Coding in Shades. All rights reserved.
//

import Foundation
import CoreData

@objc(ZipCode)
class ZipCode: NSManagedObject {
  @NSManaged var code: String
  @NSManaged var places: NSSet
}
