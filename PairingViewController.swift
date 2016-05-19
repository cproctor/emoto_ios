//
//  PairingViewController.swift
//  Emoto
//
//  Created by Chris Proctor on 5/18/16.
//  Copyright © 2016 Chris Proctor. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class PairingViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {
    
    var username : String?
    var myProfile : UserProfile?
    var userLocation : CLLocation?

    @IBOutlet weak var pairCodePrompt: UILabel!
    @IBOutlet weak var pairCodeLabel: UILabel!
    @IBOutlet weak var pairCodeTextField: UITextField!
    @IBOutlet weak var stackViewCenterY: NSLayoutConstraint!
    
    var locationManager: CLLocationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pairCodeTextField.delegate = self
        
        reloadView()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PairingViewController.reloadView), name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    func reloadView() {
        print("Initiating Pairing View")
        // get location permissions
        
        locationManager = CLLocationManager()
        locationManager!.delegate = self
        locationManager!.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager!.distanceFilter = kCLDistanceFilterNone;
        locationManager!.startUpdatingLocation()
        
        switch CLLocationManager.authorizationStatus() {
        case .AuthorizedWhenInUse, .AuthorizedAlways:
            print("We have location permission. Requesting location.")
            locationManager!.requestLocation() // Calls locationManager(manager:didUpdateLocations locations)
            break
        case .NotDetermined:
            print("Requesting location permission")
            locationManager!.requestWhenInUseAuthorization() // Calls locationManager(:didChangeAuthorizationStatus)
            break
        case .Denied:
            print("Location permission denied. Prompt user to change settings.")
            promptToChangeSettings() // Then the user will re-open the app.
            break
        case .Restricted:
            print("This device cannot use location services.")
        }
    }
    
    // Called after requesting location permission.
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .AuthorizedWhenInUse, .AuthorizedAlways:
            manager.requestLocation() // Calls locationManager(manager:didUpdateLocations locations)
            break
        case .NotDetermined:
            print("Not determined. Why not?")
            break
        case .Denied:
            print("Location permission denied. Prompt user to change settings.")
            promptToChangeSettings() // Then the user will re-open the app.
            break
        case .Restricted:
            print("This device cannot use location services.")
        }
    }
    
    // If there is an error.
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error.localizedDescription)
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("Found user's location: \(location)")
            if userLocation == nil {
                locationManager!.stopUpdatingLocation()
                userLocation = location
                userLocationObtained()
            }
        }
    }
    
    // After successfully getting location permissions...
    func userLocationObtained() {
        
        let latitude = Float(userLocation!.coordinate.latitude)
        let longitude = Float(userLocation!.coordinate.longitude)
        let defaults = NSUserDefaults.standardUserDefaults()
        username = defaults.objectForKey("username") as? String
        if username == nil {
            print("Creating new user")
            let newUsername = generateNewUsername()
            EmotoAPI.postSignupWithCompletion(newUsername, latitude: latitude, longitude: longitude) { (profile, error) -> Void in
                guard error == nil else { print("error in signup"); return }
                self.myProfile = profile!
                self.userProfileObtained()
            }
        }
        else {
            print("Fetching existing user profile")
            EmotoAPI.postUpdateLocationWithCompletion(username!, latitude: latitude, longitude: longitude) { (profile, error) -> Void in
                guard error == nil else { print("error in signup"); return }
                self.myProfile = profile!
                self.userProfileObtained()
            }
        }
    }
    
    func userProfileObtained() {
        print("User profile obtained")
        dispatch_async(dispatch_get_main_queue()) { // ensures the closure below will execute on the main thread.
            self.pairCodeLabel.text = "Your pair code is \(self.myProfile!.pairCode)."
        }
    }
    
    // Leaves the user either out of the app (come on back in!) or sitting on the login screen with
    // nothing to do...
    func promptToChangeSettings() {
        let alertController = UIAlertController(
            title: "Emoto Needs Location Access",
            message: "Emoto is about building copresence; it needs your location to function. Please open this app's settings and set location access to 'Always'.",
            preferredStyle: .Alert
        )
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .Default) { (action) in
            if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                UIApplication.sharedApplication().openURL(url)
            }
        }
        alertController.addAction(openAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func generateNewUsername() -> String {
        //return "\(UIDevice.currentDevice().name)_\(random())"
        return "user\(random())"
    }

    // MARK: Text Field Delegate
    
    func textFieldDidBeginEditing(textfield: UITextField) {
        stackViewCenterY.constant = -100
    }
    
    func textFieldDidEndEditing(textfield: UITextField) {
        stackViewCenterY.constant = 0
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let enteredCode = textField.text!.uppercaseString
        EmotoAPI.postPairWithCompletion(myProfile!.username, pairCode: enteredCode) { (profiles, error) -> Void in
            guard error == nil else {
                dispatch_async(dispatch_get_main_queue()) { // ensures the closure below will execute on the main thread.
                    self.pairCodePrompt.text = "Sorry, wrong code. Try again?"
                    self.pairCodeTextField.text = ""
                    return
                }
                return
            }
            dispatch_async(dispatch_get_main_queue()) { // ensures the closure below will execute on the main thread.
                textField.resignFirstResponder()
                self.performSegueWithIdentifier("PairingSuccessful", sender: self)
            }
        }
        return true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
}
