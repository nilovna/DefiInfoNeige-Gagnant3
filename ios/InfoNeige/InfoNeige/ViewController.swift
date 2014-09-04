//
//  ViewController.swift
//  InfoNeige
//
//  Created by Van Du Tran on 2014-07-27.
//
//

import CoreLocation
import MapKit
import UIKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    let locationManager: CLLocationManager = CLLocationManager ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestWhenInUseAuthorization()
        self.mapView.userTrackingMode = MKUserTrackingMode.Follow
        self.mapView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
//        self.streetSidesOverlays()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    /*
    func streetSidesOverlays() {
        let fileName = NSBundle.mainBundle().pathForResource("cote", ofType: "json")
        var error: NSError?
        let overlayData = NSData.dataWithContentsOfFile(fileName, options: NSDataReadingOptions.DataReadingMapped, error: &error)
        let streetSides: NSDictionary = NSJSONSerialization.JSONObjectWithData(overlayData, options: NSJSONReadingOptions.AllowFragments, error: nil) as NSDictionary
        let sides: NSArray = streetSides.objectForKey("features") as NSArray
        for side in sides {
            if let geometry = side["geometry"] as? NSDictionary {
                
                // a one line string
                if let type = geometry["type"] as? NSString {
                    if type.isEqualToString("LineString") {
                        let coordinates: NSArray = geometry["coordinates"] as NSArray
                        
                        var oneSegment = [CLLocationCoordinate2D]()
                        
                        for coordinate in coordinates {
                            let numberOfCoordinates: UInt8 = UInt8(coordinates.count.asUnsigned())
                            var latitude: CLLocationDegrees = coordinate[0] as CLLocationDegrees
                            var longitude: CLLocationDegrees = coordinate[1] as CLLocationDegrees
                            var onePoint:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
                            
                            oneSegment += onePoint
                        }
                        
                        var path = MKPolyline(coordinates: &oneSegment, count: coordinates.count)
//                        println("\(oneSegment)")
                        
                        self.mapView.addOverlay(path, level: MKOverlayLevel.AboveRoads)
//                        println(self.mapView.overlays)
//                        self.mapView.addOverlays([path], level: MKOverlayLevel.AboveRoads)
                    }
                }
                else {
                    continue;
                }
                
            }
            else {
                continue;
            }
        }
    }
*/
    
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        println("didUpdateUserLocation")
    }
    
    /*
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        println("rendererForOverlay")
        if overlay is MKPolyline {
            var renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor(red: 74.0/255.0, green: 144.0/255.0, blue: 226.0/255/0, alpha: 1.0)
            renderer.lineWidth = 6.0
            return renderer
        }
        
        return nil
    }
*/
}

