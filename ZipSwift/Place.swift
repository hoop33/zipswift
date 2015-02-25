//
//  Place.swift
//  ZipSwift
//
//  Created by Rob Warner on 2/24/15.
//  Copyright (c) 2015 Coding in Shades. All rights reserved.
//

import Foundation
import CoreData

@objc(Place)
class Place: NSManagedObject {
  @NSManaged var city: String?
  @NSManaged var latitude: String?
  @NSManaged var longitude: String?
  @NSManaged var state: String?
  @NSManaged var zipCode: ZipCode
}
