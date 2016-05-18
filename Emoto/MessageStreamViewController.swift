//
//  CopresenceWindowViewController.swift
//  Emoto
//
//  Created by Chris Proctor on 5/3/16.
//  Copyright © 2016 Chris Proctor. All rights reserved.
//

import UIKit

class MessageStreamViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: Properties
    @IBOutlet weak var myTimeLabel: UILabel!
    @IBOutlet weak var myWeatherLabel: UILabel!
    @IBOutlet weak var yourTimeLabel: UILabel!
    @IBOutlet weak var yourWeatherLabel: UILabel!
    @IBOutlet weak var messagesTable: UITableView!
    @IBOutlet weak var messagesInput: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var myEmotoImageView: UIImageView!
    @IBOutlet weak var yourEmotoImageView: UIImageView!
    
    var messages = [Message]()
    var myProfile: UserProfile?
    var yourProfile: UserProfile?
    var selectedEmoto : Emoto? = nil
    var myFormatter: NSDateFormatter?
    var yourFormatter: NSDateFormatter?
    var timer: NSTimer?
    var copresenceWindowTimer : NSTimer?
    
    // Refreshes the table view with new content
    // See: https://www.andrewcbancroft.com/2015/03/17/basics-of-pull-to-refresh-for-swift-developers/
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(MessageStreamViewController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
    }()
    
    @IBAction func didTapEmotoLogo(sender: UIBarButtonItem) {
        performSegueWithIdentifier("ChangeEmoto", sender: self)
    }
    
    @IBAction func didTapEmotoButton(sender: UIButton) {
        performSegueWithIdentifier("ChangeEmoto", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        syncProfile()
        self.navigationController?.navigationBarHidden = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MessageStreamViewController.keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MessageStreamViewController.keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MessageStreamViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        myFormatter = NSDateFormatter()
        myFormatter!.dateStyle = .NoStyle
        myFormatter!.timeStyle = .ShortStyle
        yourFormatter = NSDateFormatter()
        yourFormatter!.dateStyle = .NoStyle
        yourFormatter!.timeStyle = .ShortStyle
        
        messages.removeAll()
        
        updateTimeZones()
        updateCopresenceWindow()
        updateTimes()
        
        // Sync with the server. Shall we put this on a timer?
        // Profile should be saved in user defaults, so we always know who's here.
        fetchProfilesFromServer("chris")
        fetchMessagesFromServer("chris")
        
        // Set a timer to update the times in the copresence window
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector:#selector(MessageStreamViewController.updateTimes), userInfo: nil, repeats: true)
        
        copresenceWindowTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector:#selector(MessageStreamViewController.updateCopresenceWindow), userInfo: nil, repeats: true)
        
        // Control the table view subclass
        self.messagesTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.messagesTable.addSubview(self.refreshControl)
        messagesTable.delegate = self
        messagesTable.dataSource = self
    }
    
    func syncProfile() {
        /*
        // We're going to sync location.
        var locationManager: CLLocationManager! = CLLocationManager()
        locationManager.delegate = self
        
        switch CLLocationManager.authorizationStatus() {
        case .AuthorizedWhenInUse:
            // .We have access.
            break
        case .NotDetermined:
            locationManager.requestAlwaysAuthorization()
        case .Restricted, .Denied:
            let alertController = UIAlertController(
                title: "Location Access Disabled",
                message: "Emoto needs access to your location to function. Please open this app's settings and set location access to 'Always'.",
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
        
        
        locationManager.requestWhenInUseAuthorization()
        
        var profile : UserProfile
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let profileData = defaults.objectForKey("my_profile") else {
            let profile = NSKeyedUnarchiver.unarchiveObjectWithData(profileData)
            EmotoAPI.getProfileWithCompletion(profile!.username) { (profiles)
                
            }, completion: <#T##(profiles: [String : UserProfile]?, error: NSError?) -> Void#>)
        }
        else {
            // Sign up using the phone's name. Obviously won't work in production...
            let username = UIDevice.currentDevice().name
            EmotoAPI.postSignupWithCompletion(username, latitude: <#T##Float#>, longitude: <#T##Float#>, completion: <#T##(profile: UserProfile?, error: NSError?) -> Void#>)
        }
        */

    }
    
    func updateTimeZones() {
        guard myProfile != nil else { return }
        myFormatter!.timeZone = NSTimeZone(name: myProfile!.timeZone)!
        guard yourProfile != nil else { return }
        yourFormatter!.timeZone = NSTimeZone(name: yourProfile!.timeZone)!
    }
    
    func updateTimes() {
        let now = NSDate()
        myTimeLabel.text = myFormatter!.stringFromDate(now)
        yourTimeLabel.text = yourFormatter!.stringFromDate(now)
    }
    
    func updateCopresenceWindow() {
        guard myProfile != nil else { return }
        guard yourProfile != nil else { return }
        myWeatherLabel.text = myProfile!.weather
        yourWeatherLabel.text = yourProfile!.weather
        if let myCurrentEmoto = myProfile!.currentEmoto {
            myEmotoImageView.image = myCurrentEmoto.image
        }
        if let yourCurrentEmoto = yourProfile!.currentEmoto {
            yourEmotoImageView.image = yourCurrentEmoto.image
        }
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        self.messagesTable.reloadData()
        refreshControl.endRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchMessagesFromServer(username: String) {
        EmotoAPI.getMessagesWithCompletion(username) { (msg, error) -> Void in
            // TODO: Handle error
            self.messages += msg!
            self.messagesTable.reloadData()
        }
    }
    
    func fetchProfilesFromServer(username: String) {
        EmotoAPI.getProfileWithCompletion(username) { (profiles, error) -> Void in
            // TODO: Handle error
            if let myProfile = profiles!["self"] {
                self.myProfile = myProfile
            }
            if let yourProfile = profiles!["partner"] {
                self.yourProfile = yourProfile
            }
            self.updateTimeZones()
            self.updateCopresenceWindow()
            self.messagesTable.reloadData()
            self.messagesTable.layoutSubviews()
        }
    }
    
    func loadSampleMessages () {
        let emoto1 = Emoto(name: "Peaceful", image: UIImage(named: "Blue Sky"), imageUrl: nil, id: -2)
        let emoto2 = Emoto(name: "Stormy", image: UIImage(named: "Stormy"), imageUrl: nil, id: -3)
        let emoto3 = Emoto(name: "Awestruck", image: UIImage(named: "Sunset"), imageUrl: nil, id: -4)
        
        let date1 = NSDate()
        let date2 = NSDate()
        let date3 = NSDate()
        
        let msg1 = Message(text: "Good morning!", emoto: emoto1, author: "chris", timestamp: date1)!
        let msg2 = Message(text: "I stubbed my toe.", emoto: emoto2, author: "zuz", timestamp: date2)!
        let msg3 = Message(text: "But I feel better now.", emoto: emoto3, author: "zuz", timestamp: date3)!
        
        messages += [msg1, msg2, msg3]
    }
    
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let message = messages[indexPath.row]
        var cellIdentifier : String
        if myProfile!.username == message.author {
            cellIdentifier = "MessageStreamTableCellMine"
        }
        else {
            cellIdentifier = "MessageStreamTableCellYours"
        }
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! MessageStreamTableViewCell
        
        
        cell.messageText.text = message.text
        if message.emoto != nil {
            cell.emoto.image = message.emoto!.image
        }
        
        // Configure the cell...
        
        return cell
        
    }
    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        tableView.deselectRowAtIndexPath(indexPath, animated: true)
//        
//        let row = indexPath.row
//        print(messages[row])
//    }
    
    func keyboardWillShow(notification: NSNotification) {
//        self.view.frame.origin.y -= 150
        adjustingHeight(true, notification: notification)
    }
    
    func keyboardWillHide(notification: NSNotification) {
//        self.view.frame.origin.y += 150
        adjustingHeight(false, notification: notification)
    }
    
    @IBAction func sendMessage(sender: UIButton) {
        let emoto1 = selectedEmoto
        let date1 = NSDate()
        let text1 = messagesInput.text!
        if !text1.isEmpty {
            let msg1 = Message(text: text1, emoto: emoto1, author: self.myProfile!.username, timestamp: date1)!
            messagesInput.text = ""
            EmotoAPI.postNewMessageWithCompletion(msg1) { (savedMessage, error) -> Void in
                // TODO: Handle error
                self.messages += [savedMessage!]
                self.messagesTable.reloadData()
                self.saveMessages()
            }
        }
        view.endEditing(true)
    }
    
    // MARK: NSCoding
    func saveMessages() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(messages, toFile: Message.ArchiveURL.path!)
        if !isSuccessfulSave {
            print("Failed to save messages...")
        }
    }
    
    func loadMessages() -> [Message]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(Message.ArchiveURL.path!) as? [Message]
    }
    
    func adjustingHeight(show:Bool, notification:NSNotification) {
        var userInfo = notification.userInfo!
        let keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        let animationDurarion = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
        let changeInHeight = (CGRectGetHeight(keyboardFrame) + 10) * (show ? 1 : -1)
        UIView.animateWithDuration(animationDurarion, animations: { () -> Void in
            self.bottomConstraint.constant += changeInHeight
        })
        
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
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
