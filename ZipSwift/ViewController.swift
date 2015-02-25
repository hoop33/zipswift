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

  var persistence: Persistence?
  
  @IBOutlet weak var zipCode: UITextField!
  @IBOutlet weak var searchButton: UIButton!
  @IBOutlet weak var mapView: MKMapView!
  
  @IBAction func zipCodeChanged(sender: AnyObject) {
    searchButton.enabled = count(zipCode.text) == 5
  }
  
  @IBAction func searchZipCode(sender: AnyObject) {
    zipCode.resignFirstResponder()
    loadZipCode(zipCode.text)
  }
  
  func configureRestKit() {
    let url = NSURL(string: "http://api.zippopotam.us")
    let client = AFHTTPClient(baseURL: url)
    let manager = RKObjectManager(HTTPClient: client)
    
    persistence = Persistence()

    // Set up zip code mapping
    let zipCodeMapping = RKEntityMapping(forEntityForName: "ZipCode", inManagedObjectStore: persistence?.managedObjectStore)
    zipCodeMapping.addAttributeMappingsFromDictionary([
      "post code": "code"
    ])
    zipCodeMapping.identificationAttributes = ["code"]
    
    // Set up place mapping
    let placeMapping = RKEntityMapping(forEntityForName: "Place",
      inManagedObjectStore: persistence?.managedObjectStore)
    placeMapping.addAttributeMappingsFromDictionary([
      "place name": "city",
      "state abbreviation": "state",
      "latitude": "latitude",
      "longitude": "longitude"
    ])
    
    // Set up the relationship between them
    zipCodeMapping.addPropertyMapping(RKRelationshipMapping(
      fromKeyPath: "places",
      toKeyPath: "places",
      withMapping: placeMapping
    ))
    
    // Add the response descriptor to the manager
    let responseDescriptor = RKResponseDescriptor(
      mapping: zipCodeMapping,
      method: .GET,
      pathPattern: "/us/:zipcode",
      keyPath: nil,
      statusCodes: NSIndexSet(index: RKStatusCodeClassSuccessful)
    )
    manager.addResponseDescriptor(responseDescriptor)
    
    // Add the object store to the manager
    manager.managedObjectStore = persistence?.managedObjectStore
  }
  
  func fetchFromCoreData(code: String) -> Bool {
    let fetchRequest = NSFetchRequest(entityName: "ZipCode")
    fetchRequest.predicate = NSPredicate(format: "code = %@", code)
    var error: NSError?
    let manager = RKObjectManager.sharedManager()
    if let results = manager.managedObjectStore.mainQueueManagedObjectContext.executeFetchRequest(fetchRequest, error: &error) as? [ZipCode] {
      if (results.count > 0) {
        let item = results[0]
        println("Fetched \(item.code) from Core Data")
        displayZipCode(item)
        return true
      }
    } else {
      println("Error fetching: \(error) \(error?.userInfo)")
    }
    return false
  }
  
  func loadFromAPI(code: String) {
    let manager = RKObjectManager.sharedManager()
    manager.getObjectsAtPath("/us/\(code)",
      parameters: nil,
      success: { (operation, mappingResult) -> Void in
        let item = mappingResult.firstObject() as! ZipCode
        println("Loaded \(item.code) from the API")
        self.displayZipCode(item)
      },
      failure: { (operation, error) -> Void in
        println("\(error)")
      }
    )
  }
  
  func loadZipCode(code: String) {
    if (!fetchFromCoreData(code)) {
      loadFromAPI(code)
    }
  }
  
  func displayZipCode(item: ZipCode) {
    for place in item.places {
      self.addPlaceToMap(place as! Place)
    }
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
  
  func didTapMap(sender: AnyObject) {
    zipCode.resignFirstResponder()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureRestKit()
    
    let mapTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "didTapMap:")
    mapView.addGestureRecognizer(mapTapGestureRecognizer)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}

