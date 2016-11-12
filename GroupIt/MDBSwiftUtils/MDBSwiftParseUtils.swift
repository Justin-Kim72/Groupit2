//
//  MDBSwiftParseUtils.swift
//  DealOn
//
//  Created by Akkshay Khoslaa on 4/25/16.
//  Copyright © 2016 Akkshay Khoslaa. All rights reserved.
//

import Foundation
import UIKit
import Parse
import CoreLocation
class MDBSwiftParseUtils {
    
    
    /**
     Sets the image of an imageview asynchronously.
     
     - parameters:
        - file: PFFile containing image
        - imageView: UIImageView that you want to set the image of
     */
    class func setImageViewImageFromFile(_ file: PFFile, imageView: UIImageView) {
        file.getDataInBackground {
            (imageData: Data?, error: Error?) -> Void in
            if error == nil {
                if let imageData = imageData {
                    let image = UIImage(data:imageData)
                    imageView.image = image
                }
            }
        }
    }
    
    /**
     Sets the image of a UIButton asynchronously.
     
     - parameters:
        - file: PFFile containing image
        - button: UIButton that you want to set the image of
     */
    class func setButtonImageFromFile(_ file: PFFile, button: UIButton) {
        file.getDataInBackground {
            (imageData: Data?, error: Error?) -> Void in
            if error == nil {
                if let imageData = imageData {
                    let image = UIImage(data:imageData)
                    button.setImage(image, for: UIControlState())
                }
            }
        }
    }
    
    /**
     Sets the image of an imageview asynchronously using a pointer that is passed in.
     
     - parameters:
        - pointer: PFObject that needs to be fetched that contains the PFFile
        - imageView: UIImageView that you want to set the image of
     */
    class func setImageViewImageFromPointer(_ pointer: PFObject, imageView: UIImageView) {
        pointer.fetchIfNeededInBackground {
            (imageObject: PFObject?, error: Error?) -> Void in
            let headerImageFile = imageObject!["img"] as! PFFile
            headerImageFile.getDataInBackground {
                (imageData: Data?, error: Error?) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        let image = UIImage(data:imageData)
                        imageView.image = image
                    }
                }
            }
            
        }
        
    }
    
    /**
     Sets the image of an imageview asynchronously using a pointer that is passed in.
     
     - parameters:
        - pointer: PFObject that needs to be fetched that contains the PFFile
        - imageView: UIImageView that you want to set the image of
        - imageFieldName: Name of the field containing the PFFile
     */
    class func setImageViewImageFromPointer(_ pointer: PFObject, imageFieldName: String, imageView: UIImageView) {
        pointer.fetchIfNeededInBackground {
            (imageObject: PFObject?, error: Error?) -> Void in
            let headerImageFile = imageObject!["img"] as! PFFile
            headerImageFile.getDataInBackground {
                (imageData: Data?, error: Error?) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        let image = UIImage(data:imageData)
                        imageView.image = image
                    }
                }
            }
            
        }
        
    }
    
    /**
     Sets the image of an imageview asynchronously using a pointer that is passed in.
     
     - parameters:
        - pointer: PFObject that needs to be fetched that contains the PFFile
        - imageView: UIImageView that you want to set the image of
        - imageFieldName: Name of the field containing the PFFile
     */
    class func setButtonImageFromPointer(_ pointer: PFObject, imageFieldName: String, button: UIButton) {
        pointer.fetchIfNeededInBackground {
            (imageObject: PFObject?, error: Error?) -> Void in
            let headerImageFile = imageObject!["img"] as! PFFile
            headerImageFile.getDataInBackground {
                (imageData: Data?, error: Error?) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        let image = UIImage(data:imageData)
                        button.setImage(image, for: UIControlState())
                    }
                }
            }
            
        }
        
    }
    
    /**
     Returns the distance between 2 locations as a formatted string.
     
     - returns:
     distance between 2 locations as a String
     
     - parameters:
        - firstLocation: first location geopoint
        - secondLocation: second location geopoint
     */
    class func getDistanceString(_ firstLocation: PFGeoPoint, secondLocation: PFGeoPoint) -> String {
        return String(Double(round(10*firstLocation.distanceInMiles(to: secondLocation))/10)) + " mi"
    }
    
    /**
     Check if location services are authorized, and if they are get the current location. Make sure you call MDBSwiftUtils.startLocationServices() first.
     
     - returns:
     the current location as PFGeoPoint if location services are authorized; otherwise returns PFGeoPoint(latitude: 0, longitude: 0)
     
     - parameters:
        - locationManager: CLLocationManager instance being used in your VC
     */
    func getCurrentLocationGeoPoint(_ locationManager: CLLocationManager) -> PFGeoPoint {
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorized){
                
                let currentLocation = locationManager.location
                return PFGeoPoint(location: currentLocation)
                
        } else {
            return PFGeoPoint(latitude: 0, longitude: 0)
        }
    }
    
    
    
}
