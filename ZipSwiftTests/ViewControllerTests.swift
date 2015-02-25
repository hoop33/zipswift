//
//  ViewControllerTests.swift
//  ZipSwift
//
//  Created by Rob Warner on 2/20/15.
//  Copyright (c) 2015 Coding in Shades. All rights reserved.
//

import UIKit
import XCTest
import MapKit
import CoreData

class ViewControllerTests: XCTestCase {
  
  var viewController: ViewController!
  
  lazy var managedObjectContext: NSManagedObjectContext = {
    let managedObjectModel = NSManagedObjectModel.mergedModelFromBundles(nil)
    let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel!)
    let persistentStore = persistentStoreCoordinator.addPersistentStoreWithType(NSInMemoryStoreType,
      configuration: nil,
      URL: nil,
      options: nil,
      error: nil
    )
    let managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
    managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
    return managedObjectContext
  }()
  
  lazy var place: Place = {
    let place = Place(entity: NSEntityDescription.entityForName("Place",
      inManagedObjectContext: self.managedObjectContext)!,
      insertIntoManagedObjectContext: self.managedObjectContext)
    place.city = "Jacksonville"
    place.state = "FL"
    place.latitude = "30.1459"
    place.longitude = "-81.5739"
    return place
  }()
  
  override func setUp() {
    super.setUp()
    let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle(forClass: self.dynamicType))
    viewController = storyboard.instantiateViewControllerWithIdentifier("ViewController") as! ViewController
    viewController.loadView()
  }
  
  override func tearDown() {
    super.tearDown()
  }

  func testSearchButtonShouldBeDisabled() {
    XCTAssertFalse(viewController.searchButton.enabled)
  }
  
  func testSearchButtonShouldBeEnabledWhenTextIs5Chars() {
    viewController.zipCode.text = "12345"
    viewController.zipCodeChanged(viewController.zipCode)
    XCTAssertTrue(viewController.searchButton.enabled)
  }
  
  func testSearchButtonShouldBeDisabledWhenTextIs4Chars() {
    viewController.zipCode.text = "1234"
    viewController.zipCodeChanged(viewController.zipCode)
    XCTAssertFalse(viewController.searchButton.enabled)
  }
  
  func testAddPlaceShouldAddAnnotation() {
    viewController.addPlaceToMap(place)
    let annotations = viewController.mapView.annotations as! [MKAnnotation]
    XCTAssertEqual(1, annotations.count)
    let annotation = annotations[0]
    XCTAssertEqual("Jacksonville, FL", annotation.title!)
    XCTAssertEqual("lat: 30.1459, long: -81.5739", annotation.subtitle!)
  }
}
