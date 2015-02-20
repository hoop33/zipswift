//
//  ViewController.swift
//  ZipSwift
//
//  Created by Rob Warner on 2/18/15.
//  Copyright (c) 2015 Coding in Shades. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

  @IBOutlet weak var zipCode: UITextField!
  @IBOutlet weak var searchButton: UIButton!
  @IBOutlet weak var mapView: MKMapView!
  
  @IBAction func zipCodeChanged(sender: AnyObject) {
    searchButton.enabled = count(zipCode.text) == 5
  }
  
  @IBAction func searchZipCode(sender: AnyObject) {
    loadPlaces(zipCode.text)
  }
  
  func configureRestKit() {
    let url = NSURL(string: "http://api.zippopotam.us")
    let client = AFHTTPClient(baseURL: url)
    let manager = RKObjectManager(HTTPClient: client)
    
    let placeMapping = RKObjectMapping(forClass: Place.self)
    placeMapping.addAttributeMappingsFromDictionary([
      "place name": "city",
      "state abbreviation": "state",
      "latitude": "latitude",
      "longitude": "longitude"
    ])
    
    let responseDescriptor = RKResponseDescriptor(
      mapping: placeMapping,
      method: .GET,
      pathPattern: "/us/:zipcode",
      keyPath: "places",
      statusCodes: NSIndexSet(index: 200)
    )
    manager.addResponseDescriptor(responseDescriptor)
  }
  
  func loadPlaces(zipcode: String) {
    let manager = RKObjectManager.sharedManager()
    manager.getObjectsAtPath("/us/\(zipcode)",
      parameters: nil,
      success: { (operation, mappingResult) -> Void in
        let places = mappingResult.array() as! [Place]
        for place in places {
          self.addPlaceToMap(place)
        }
      },
      failure: { (operation, error) -> Void in
        println("\(error)")
      }
    )
  }
  
  func addPlaceToMap(place: Place) {
    if let latitude = place.latitude, longitude = place.longitude {
      let formatter = NSNumberFormatter()
      let location = CLLocationCoordinate2D(
        latitude: formatter.numberFromString(latitude)!.doubleValue,
        longitude: formatter.numberFromString(longitude)!.doubleValue
      )
      let span = MKCoordinateSpanMake(1, 1)
      let region = MKCoordinateRegionMake(location, span)
      self.mapView.setRegion(region, animated: true)
      
      let annotation = MKPointAnnotation()
      annotation.setCoordinate(location)
      annotation.title = "\(place.city!), \(place.state!)"
      annotation.subtitle = "lat: \(latitude), long: \(longitude)"
      self.mapView.addAnnotation(annotation)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureRestKit()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}

