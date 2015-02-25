//
//  Persistence.swift
//  ZipSwift
//
//  Created by Rob Warner on 2/22/15.
//  Copyright (c) 2015 Coding in Shades. All rights reserved.
//

import Foundation
import CoreData

class Persistence: NSObject {
  
  var managedObjectStore: RKManagedObjectStore? = {
    // Load all the model files
    let managedObjectModel = NSManagedObjectModel.mergedModelFromBundles(nil)
    
    // Create the store
    let managedObjectStore = RKManagedObjectStore(managedObjectModel: managedObjectModel)
    
    // Add the model to the store
    var error: NSError? = nil
    let storeURL = RKApplicationDataDirectory().stringByAppendingPathComponent("ZipSwift.sqlite")
    managedObjectStore.addSQLitePersistentStoreAtPath(storeURL,
      fromSeedDatabaseAtPath: nil,
      withConfiguration: nil,
      options: [
        NSInferMappingModelAutomaticallyOption: true,
        NSMigratePersistentStoresAutomaticallyOption: true
      ],
      error: &error)
    
    // Create the managed object contexts
    managedObjectStore.createManagedObjectContexts()

    // Return the managed object store
    return managedObjectStore
  }()
  
  func saveContext() {
    var error: NSError? = nil
    if let managedObjectContext = self.managedObjectStore?.mainQueueManagedObjectContext {
      if managedObjectContext.hasChanges && !managedObjectContext.save(&error) {
        println("Error saving: \(error?.description) \(error?.userInfo?.description)")
        abort()
      }
    }
  }
}