//
//  PairingViewController.swift
//  Emoto
//
//  Created by Chris Proctor on 5/18/16.
//  Copyright © 2016 Chris Proctor. All rights reserved.
//

/*
 Target bugs:
 
OK  1. State not clearly shown.
OK 2. There should be an onboarding screen explaining the app, and explaining the need to check for location.
OK 3. Requesting location permissions should actually work.
OK 4. Pairing should be persisted.
OK 4.5 While in pair code mode, should check from time to time whether the server has found a pairing.
OK 5. When a user logs in and has already been paired, onboarding flow should be skipped.
 6. Currently, changes to messages/emotos only update when changing screens. They should appear immediately.
 7. The app should not crash.
 */

/* 
 Onboarding flow:
 
 BEGIN 
    -> welcome
 
welcome
    - Show Emoto launch screen
    - Check location permissions
        * If denied -> requestLocationPermissionRepair
        * If not set -> requestLocationPermission
        * If allowed -> userStatusCheck
 
 requestLocationPermissionRepair
    - Show modal view requesting user to go allow location permissions. Go to settings button will leave the app.
 
 requestLocationPermission
    - Show modal view explaining the need for location.
    - Initiate location permission request. 
        -> welcome
 
 userStatusCheck
    - attempt to load user profile from defaultSettings.
        * If no profile found
            - create and save a profile. 
            -> userPairCheck
        * If profile found -> userPairCheck
 
 userPairCheck 
    - check for pairing.
        * If unpaired, show pair code and text input.
            - wait for a few seconds; -> userPairCheck
            - If text submitted, post to server; -> userPairCheck
        * If paired, segue to message stream controller.
 */

import Foundation
import CoreLocation
import UIKit

class PairingViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {
    
    var username : String?
    var myProfile : UserProfile?
    var userLocation : CLLocation?
    var deviceToken : String?
    var locationManager : CLLocationManager?

    @IBOutlet weak var pairCodePrompt: UILabel!
    @IBOutlet weak var pairCodeLabel: UILabel!
    @IBOutlet weak var pairCodeTextField: UITextField!
    @IBOutlet weak var stackViewCenterY: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pairCodeTextField.delegate = self
        locationManager = CLLocationManager()
        locationManager!.delegate = self
        locationManager!.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager!.distanceFilter = kCLDistanceFilterNone;
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.pairingController = self
        
        // Fire welcome when the app enters the foreground.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PairingViewController.welcome), name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    override func viewDidAppear(animated:Bool) {
        super.viewDidAppear(animated)
        //welcome()
    }
    
    func welcome() {
        print("welcome")
        Flurry.logEvent("Onboard:Begin")
        ensureLocationServicesAuthorization()
    }
    
    // MARK: Location Services Authorization
    
    func ensureLocationServicesAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .AuthorizedWhenInUse, .AuthorizedAlways:
            Flurry.logEvent("Onboard:DidAuthorizeLocationServicesAuthorization")
            ensureNotificationAuthorization()
        case .NotDetermined:
            requestLocationAuthorization()
        case .Denied:
            didDenyLocationServices()
        case .Restricted:
            didRestrictLocationServices()
        }
    }
    
    func requestLocationAuthorization() {
        print("Showing modal before requesting authorizations.")
        Flurry.logEvent("Onboard:DidRequestLocationServicesAuthorization")
        let alertController = UIAlertController(
            title: "App permissions",
            message: "Emoto is a messaging app which supports intimacy for long-distance couples. Emoto will now requst several required app permissions.",
            preferredStyle: .Alert
        )
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            print("user tapped OK in app permissions dialog")
            self.locationManager!.requestWhenInUseAuthorization()
        }
        alertController.addAction(OKAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        ensureLocationServicesAuthorization()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error.localizedDescription)
    }
    
    func didRestrictLocationServices() {
        print("location auth is restricted. displaying terminal modal. :(")
        Flurry.logEvent("Onboard:DidRestrictLocationServicesAuthorization")
        let alertController = UIAlertController(
            title: "Emoto Needs Location Access",
            message: "Your phone does not have access to location services, which are required to run Emoto.",
            preferredStyle: .Alert
        )
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func didDenyLocationServices() {
        print("location auth is denied. asking user to change settings.")
        Flurry.logEvent("Onboard:DidDenyLocationServicesAuthorization")
        let alertController = UIAlertController(
            title: "Emoto Needs Location Access",
            message: "Emoto is about building copresence; it needs your location to function. Please open this app's settings and set location access to 'Always'.",
            preferredStyle: .Alert
        )
        let openAction = UIAlertAction(title: "Open Settings", style: .Default) { (action) in
            if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                UIApplication.sharedApplication().openURL(url)
            }
        }
        alertController.addAction(openAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: Notification Services Authorization
    
    func ensureNotificationAuthorization() {
        print("ensure notification authorization")
        Flurry.logEvent("Onboard:DidRequestNotificationAuthorization")
        let settings = UIUserNotificationSettings(forTypes: .Alert, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
    }
    
    func didRegisterUserNotificationSettingsWithDeviceToken(deviceToken: String?) {
        print("notification settings registered. requesting user location.")
        self.deviceToken = deviceToken
        locationManager!.requestLocation()
    }
    
    // MARK: Location Lookup
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first!
        print("found user's location: \(location)")
        locationManager!.stopUpdatingLocation()
        userLocation = location
        obtainUserProfile()
    }
    
    // MARK: User Profile Configuration
    
    func obtainUserProfile() {
        let latitude = Float(userLocation!.coordinate.latitude)
        let longitude = Float(userLocation!.coordinate.longitude)
        let defaults = NSUserDefaults.standardUserDefaults()
        username = defaults.objectForKey("username") as? String
        if username == nil {
            print("Creating new user")
            Flurry.logEvent("Onboard:NewAccountCreated")
            let newUsername = generateNewUsername()
            EmotoAPI.postSignupWithCompletion(newUsername, latitude: latitude, longitude: longitude) { (profile, error) -> Void in
                guard error == nil else { print("error in signup"); return }
                defaults.setObject(newUsername, forKey: "username")
                self.myProfile = profile!
                self.username = self.myProfile!.username
                self.ensurePairing()
            }
        }
        else {
            print("Fetching existing user profile")
            Flurry.logEvent("Onboard:ExistingAccountLoaded")
            EmotoAPI.postUpdateLocationWithCompletion(username!, latitude: latitude, longitude: longitude) { (profile, error) -> Void in
                guard error == nil else { print("error in signup"); return }
                self.myProfile = profile!
                dispatch_async(dispatch_get_main_queue()) { // ensures the closure below will execute on the main thread.
                    self.ensurePairing()
                }
            }
        }
    }
    
    func ensurePairing() {
        print("User profile obtained. Checking whether user has partner.")
        // TODO: Update device token if necessary to enable push notifications.
        checkUserPairStatus(username!) { (userIsPaired) -> Void in
            dispatch_async(dispatch_get_main_queue()) { // ensures the closure below will execute on the main thread.
                if userIsPaired {
                    print("user has a partner")
                    self.didCompleteConfiguration()
                }
                else {
                    print("user not paired.")
                    self.requestPairing()
                }
            }
        }
    }
    
    func requestPairing() {
        pairCodeLabel.text = "Your pair code is \(self.myProfile!.pairCode)."
        pairCodePrompt.text = "Enter your partner's pair code."
        pairCodeTextField.hidden = false
        let triggerTime = (Int64(NSEC_PER_SEC) * 10) // Check again after 10 seconds
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
            self.ensurePairing()
        })
    }
    
    // MARK: Onboarding Complete
    
    func didCompleteConfiguration() {
        Flurry.logEvent("Onboard:Complete")
        self.performSegueWithIdentifier("PairingSuccessful", sender: self)
    }



    
    func generateNewUsername() -> String {
        //return "\(UIDevice.currentDevice().name)_\(random())"
        return "user\(random())"
    }

    // MARK: Text Field Delegate
    
    func textFieldDidBeginEditing(textfield: UITextField) {
        Flurry.logEvent("Onboard:StartedEnteringPairCode")
        stackViewCenterY.constant = -100
    }
    
    func textFieldDidEndEditing(textfield: UITextField) {
        stackViewCenterY.constant = 0
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        Flurry.logEvent("Onboard:SubmittedPairCode")
        let enteredCode = textField.text!.uppercaseString
        
        // TYPE EMOTO TO SKIP THIS.
        guard enteredCode != "EMOTO" else {
            textField.resignFirstResponder()
            Flurry.logEvent("Onboard:SkippedWithCheatCode")
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject("chris", forKey: "username")
            self.didCompleteConfiguration()
            return true
        }
        EmotoAPI.postPairWithCompletion(myProfile!.username, pairCode: enteredCode) { (profiles, error) -> Void in
            guard error == nil else {
                Flurry.logEvent("Onboard:WrongPairCode")
                dispatch_async(dispatch_get_main_queue()) { // ensures the closure below will execute on the main thread.
                    print("error while submitting pair code:")
                    print(error!.localizedDescription)
                    self.pairCodePrompt.text = "Sorry, wrong code. Try again?"
                    self.pairCodeTextField.text = ""
                    return
                }
                return
            }
            dispatch_async(dispatch_get_main_queue()) { // ensures the closure below will execute on the main thread.
                textField.resignFirstResponder()
                self.ensurePairing()
            }
        }
        return true
    }
    
    // MARK: Helpers
    func checkUserPairStatus(username: String, completion: (userIsPaired:Bool) -> Void) {
        EmotoAPI.getProfileWithCompletion(username, profileCompletion: nil) { (profiles, error) -> Void in
            guard error == nil else {
                print(error!.description)
                return
            }
            let userIsPaired = profiles!["partner"] != nil
            completion(userIsPaired: userIsPaired)
        }
    }

    // MARK: Required overrides
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
