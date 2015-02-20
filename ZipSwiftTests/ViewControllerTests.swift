//
//  ViewControllerTests.swift
//  ZipSwift
//
//  Created by Rob Warner on 2/20/15.
//  Copyright (c) 2015 Coding in Shades. All rights reserved.
//

import UIKit
import XCTest

class ViewControllerTests: XCTestCase {
  
  var viewController: ViewController!
  
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
}
