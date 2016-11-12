//
//  MDBSwiftUtils.swift
//  DealOn
//
//  Created by Akkshay Khoslaa on 4/25/16.
//  Copyright © 2016 Akkshay Khoslaa. All rights reserved.
//


import Foundation
import UIKit
import CoreLocation
class MDBSwiftUtils {
    
    
    /**
     Returns the time since an NSDate as a properly formatted string.
     
     - returns:
     time passed since oldTime as properly formatted string
     
     - parameters:
        - oldTime: we want to find time elapsed since this time
     */
    class func timeSince(_ oldTime: Date) -> String {
        var timePassedString = ""
        let currDate = Date()
        let passedTime:TimeInterval = currDate.timeIntervalSince(oldTime)
        if Double(passedTime) < 60.0 {
            timePassedString = String(Int(Double(passedTime)))
            if Int(Double(passedTime)) == 1 {
                timePassedString += " sec ago"
            } else {
                timePassedString += " secs ago"
            }
        } else if Double(passedTime) < 3600.0 {
            timePassedString = String(Int(Double(passedTime)/60))
            if Int(Double(passedTime)/60) == 1 {
                timePassedString += " min ago"
            } else {
                timePassedString += " mins ago"
            }
        } else if Double(passedTime) < 86400.0 {
            timePassedString = String(Int(Double(passedTime)/3600))
            if Int(Double(passedTime)/3600) == 1 {
                timePassedString += " hr ago"
            } else {
                timePassedString += " hrs ago"
            }
        } else {
            timePassedString = String(Int(Double(passedTime)/86400.0))
            if Int(Double(passedTime)/86400.0) == 1 {
                timePassedString += " day ago"
            } else {
                timePassedString += " days ago"
            }
        }
        
        return timePassedString
    }
    
    /**
     Returns a random number between 2 numbers.
     
     - returns:
     random number as CGFloat
     
     - parameters:
        - firstNum: the returned number must be greater than this
        - secondNum: the returned number must be less than this
     */
    class func randomNumBetween(_ firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
    
    
    /**
     Returns a currency formatted string.
     
     - returns:
     val formatted as a currency string
     
     - parameters:
        - val: value to be converted to currency string
     */
    class func doubleToCurrencyString(_ val: Double) -> String {
        if (val * 100).truncatingRemainder(dividingBy: 100) == 0 {
            return "$" + String(Int(val))
        } else {
            let currencyFormatter = NumberFormatter()
            currencyFormatter.numberStyle = .currency
            return currencyFormatter.string(from: NSNumber(value: val))!
        }
    }
    
    /**
     Formats a label to support dynamic content and expand to multiple lines if needed.
     
     - parameters:
        - label: the label to be formatted
     */
    class func formatMultiLineLabel(_ label: UILabel) {
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
    }
    
    /**
     Returns the expected height of the label based on the text. Assumes that label is formatted to support multiple lines and dynamic content.
     
     - returns:
     expected height of the label as CGFloat
     
     - parameters:
        - content: text that will be put in the label
        - maxWidth: the maxWidth the label can be
        - font: the font used by the label
     */
    class func getMultiLineLabelHeight(_ content: String, maxWidth: Int, font: UIFont) -> CGFloat {
        let contentString = content
        let maximumLabelSize: CGSize = CGSize(width: CGFloat(maxWidth), height: 1000)
        let options: NSStringDrawingOptions = [.truncatesLastVisibleLine, .usesLineFragmentOrigin]
        let attr : [String: AnyObject] = [NSFontAttributeName:  font]
        let labelBounds: CGRect = contentString.boundingRect(with: maximumLabelSize, options: options, attributes: attr, context: nil)
        let labelHeight: CGFloat = labelBounds.size.height
        return labelHeight
        
    }
  
    
    /**
     Starts location services by requesting authorization if needed.
     
     - parameters:
        - locationManager: CLLocationManager instance being used in your VC
        - currVC: the VC you are calling this function in. Make sure it includes CLLocationManagerDelegate
     */
    func startLocationServices(_ locationManager: CLLocationManager, currVC: CLLocationManagerDelegate) {
        locationManager.delegate = currVC
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = currVC
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    /**
     Check if location services are authorized, and if they are get the current location. Make sure you call startLocationServices() first.
     
     - returns:
     the current location as CLLocation if location services are authorized; otherwise returns CLLocation(latitude: 0, longitude: 0)
     
     - parameters:
        - locationManager: CLLocationManager instance being used in your VC
     */
    func getCurrentLocation(_ locationManager: CLLocationManager) -> CLLocation {
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorized){
                
                return locationManager.location!
                
        } else {
            return CLLocation(latitude: 0, longitude: 0)
        }
    }
    
    /**
     Shows a basic alert with an "OK" button to dismiss.
     
     - parameters:
        - title: title to display at the top of the alert
        - content: message to display in alert
        - currVC: the ViewController in which this function is being called
     */
    class func showBasicAlert(_ title: String, content: String, currVC: UIViewController) {
        let alert = UIAlertController(title: title, message: content, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
            alert.dismiss(animated: true, completion: nil)
            
        }))
        
        currVC.present(alert, animated: true, completion: nil)
    }
    

    
    
}
