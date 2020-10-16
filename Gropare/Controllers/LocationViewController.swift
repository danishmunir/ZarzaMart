//
//  LocationViewController.swift
//  Gropare
//
//  Created by Danish Munir on 13/10/2020.
//

import UIKit
import CoreLocation
import MapKit


class LocationViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK:- CoreLoction Declaration
    let locationManager = CLLocationManager()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        mapView.delegate = self
        mapView.showsUserLocation = true
        
    }
    
    
}

extension LocationViewController : CLLocationManagerDelegate, MKMapViewDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let locValue: CLLocation = manager.location else {
            return
        }
        getLocationAddress(location: locValue)
    
        
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            // handle the error
   }
    
    
    func dropPinZoomIn(placemark: MKPlacemark){   // This function will "poste" the dialogue bubble of the pin.
        var selectedPin: MKPlacemark?
        
        // cache the pin
        selectedPin = placemark    // MKPlacemark() give the details like location to the dialogue bubble. Place mark is initialize in the function getLocationAddress (location: ) who call this function.
        
        // clear existing pins to work with only one dialogue bubble.
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()    // The dialogue bubble object.
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name// Here you should test to understand where the location appear in the dialogue bubble.
        
        if let city = placemark.locality,
           let state = placemark.administrativeArea {
            annotation.subtitle = String((city))+String((state));
        } // To "post" the user's location in the bubble.
        
        mapView.addAnnotation(annotation)     // To initialize the bubble.
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)   // To update the map with a center and a size.
    }
    
    func getLocationAddress(location:CLLocation) {    // This function give you the user's address from a location like locationManager.coordinate (it is usually the user's location).
        let geocoder = CLGeocoder()
        
        print("-> Finding user address...")
        
        geocoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error)->Void in
            var placemark:CLPlacemark!
            
            if error == nil && placemarks!.count > 0 {
                placemark = placemarks![0] as CLPlacemark
                
                
                var addressString : String = ""
                if placemark.isoCountryCode == "TW" /*Address Format in Chinese*/ {
                    if placemark.country != nil {  // To have the country
                        addressString = placemark.country!
                    }
                    if placemark.subAdministrativeArea != nil {  // To have the subAdministrativeArea.
                        addressString = addressString + placemark.subAdministrativeArea! + ", "
                    }
                    if placemark.postalCode != nil {   // To ...
                        addressString = addressString + placemark.postalCode! + " "
                    }
                    if placemark.locality != nil {
                        addressString = addressString + placemark.locality!
                    }
                    if placemark.thoroughfare != nil {
                        addressString = addressString + placemark.thoroughfare!
                    }
                    if placemark.subThoroughfare != nil {
                        addressString = addressString + placemark.subThoroughfare!
                    }
                } else {
                    if placemark.subThoroughfare != nil {
                        addressString = placemark.subThoroughfare! + " "
                    }
                    if placemark.thoroughfare != nil {
                        addressString = addressString + placemark.thoroughfare! + ", "
                    }
                    if placemark.postalCode != nil {
                        addressString = addressString + placemark.postalCode! + " "
                    }
                    if placemark.locality != nil {
                        addressString = addressString + placemark.locality! + ", "
                    }
                    if placemark.administrativeArea != nil {
                        addressString = addressString + placemark.administrativeArea! + " "
                    }
                    if placemark.country != nil {
                        addressString = addressString + placemark.country!
                    }
                    
                    let new_placemark: MKPlacemark = MKPlacemark (placemark: placemark)
                    
                    // new_placemark initialize a variable of type MKPlacemark () from geocoder to use the function dropPinZoomIn (placemark:).
                    
                    
                    self.dropPinZoomIn (placemark: new_placemark)
                    
                    print (placemark.description)   // You can see the place mark's details like the country.
                    
                }
                
                
            }
        })
    }
}
