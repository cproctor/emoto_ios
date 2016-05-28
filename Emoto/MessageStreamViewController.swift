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
    @IBOutlet weak var messageEmotoImageView: UIImageView!
    
    // Other controllers may change this value; when the view loads
    // its value will be assigned to the true property.
    var futureMessageEmoto : Emoto? = nil
    var futureCurrentEmoto : Emoto? = nil
    var savedMessageText : String? = nil
    
    var myFormatter = NSDateFormatter()
    var yourFormatter = NSDateFormatter()
    var timeTimer: NSTimer?
    var messageReloadTimer: NSTimer?
    
    // MARK: Properties with observers
    var myProfile: UserProfile? {
        didSet {
            updateCopresenceWindow()
        }
    }
    
    var yourProfile: UserProfile? {
        didSet {
            updateCopresenceWindow()
        }
    }
    
    func viewDidAppear() {
        messagesTable.reloadData()
    }
    
    func updateCopresenceWindow() {
        print("Updating copresence window")
        guard myProfile != nil else { return }
        myFormatter.timeZone = NSTimeZone(name: myProfile!.timeZone)!
        myWeatherLabel.text = myProfile!.weather
        guard myProfile!.currentEmoto != nil else { return }
        myEmotoImageView.image = myProfile!.currentEmoto!.image
        
        guard yourProfile != nil else { return }
        yourFormatter.timeZone = NSTimeZone(name: yourProfile!.timeZone)!
        yourWeatherLabel.text = yourProfile!.weather
        guard yourProfile!.currentEmoto != nil else { return }
        yourEmotoImageView.image = yourProfile!.currentEmoto!.image
    }
    
    var messages : [Message] = [Message]() {
        didSet {
            if isViewLoaded() {
                messagesTable.reloadData()
            }
        }
    }
    
    var messageEmoto : Emoto? {
        didSet {
            guard let emoto = messageEmoto, let emotoImage = emoto.image else {
                messageEmotoImageView.image = UIImage(named: "EmotoPlaceholder")
                return
            }
            messageEmotoImageView.image = emotoImage
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        acceptFutureValues()
        if savedMessageText != nil {
            messagesInput.text = savedMessageText
        }
        
        self.navigationController?.navigationBarHidden = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MessageStreamViewController.keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MessageStreamViewController.keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MessageStreamViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        myFormatter.dateStyle = .NoStyle
        myFormatter.timeStyle = .ShortStyle
        yourFormatter.dateStyle = .NoStyle
        yourFormatter.timeStyle = .ShortStyle
        
        // Sync with the server. Shall we put this on a timer?
        // Profile should be saved in user defaults, so we always know who's here.
        fetchProfilesFromServer(getUsernameFromDefaults())
        
        // Set a timer to update the times in the copresence window
        updateTimes()
        timeTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector:#selector(MessageStreamViewController.updateTimes), userInfo: nil, repeats: true)
        
        messageReloadTimer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector:#selector(MessageStreamViewController.fetchMessagesFromServer), userInfo: nil, repeats: true)
        
        // Control the table view subclass
        self.messagesTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        messagesTable.delegate = self
        messagesTable.dataSource = self
    }
    
    func acceptFutureValues() {
        if futureMessageEmoto != nil {
            messageEmoto = futureMessageEmoto
            futureMessageEmoto = nil
        }
        if futureCurrentEmoto != nil {
            print("Updating current emoto based on future setting")
            myProfile!.currentEmoto = futureCurrentEmoto
            futureCurrentEmoto = nil
        }
    }
    
    func syncProfile() {
        /*

        
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
    
    func updateTimes() {
        let now = NSDate()
        myTimeLabel.text = myFormatter.stringFromDate(now)
        yourTimeLabel.text = yourFormatter.stringFromDate(now)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchMessagesFromServer() {
        EmotoAPI.getMessagesWithCompletion(self.getUsernameFromDefaults(), messageCompletion: reloadMessageTable) { (messages, error) -> Void in
            dispatch_async(dispatch_get_main_queue()) { // ensures the closure below will execute on the main thread.
                guard error == nil else { return }
                self.messages = messages!
            }
        }
    }
    
    func reloadMessageTable() {
        messagesTable.reloadData()
        tableViewScrollToBottom(false)
    }
    
    func tableViewScrollToBottom(animated: Bool) {
        
        let delay = 0.1 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(time, dispatch_get_main_queue(), {
            
            let numberOfSections = self.messagesTable.numberOfSections
            let numberOfRows = self.messagesTable.numberOfRowsInSection(numberOfSections-1)
            
            if numberOfRows > 0 {
                let indexPath = NSIndexPath(forRow: numberOfRows-1, inSection: (numberOfSections-1))
                self.messagesTable.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: animated)
            }
            
        })
    }
    
    func fetchProfilesFromServer(username: String) {
        EmotoAPI.getProfileWithCompletion(username, profileCompletion: updateCopresenceWindow) { (profiles, error) -> Void in
            dispatch_async(dispatch_get_main_queue()) { // ensures the closure below will execute on the main thread.
                if let myProfile = profiles!["self"] {
                    print("Got my profile")
                    self.myProfile = myProfile
                }
                if let yourProfile = profiles!["partner"] {
                    print("Got your profile")
                    self.yourProfile = yourProfile
                }
                self.fetchMessagesFromServer()
            }
        }
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
        let emoto = messageEmoto
        let date = NSDate()
        let text = messagesInput.text!
        if !text.isEmpty {
            let message = Message(text: text, emoto: emoto, author: self.myProfile!.username, timestamp: date)!
            messages += [message]
            reloadMessageTable()
            messagesInput.text = ""
            EmotoAPI.postNewMessageWithCompletion(message) { (savedMessage, error) -> Void in
                Flurry.logEvent("Stream:SentMessage")
                guard error == nil else {
                    print(error!.localizedDescription)
                    return
                }
                // TODO: Handle error
                self.saveMessages()
            }
        }
        view.endEditing(true)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: NSCoding
    func saveMessages() {
        /*do {
            try NSFileManager.defaultManager().createDirectoryAtURL(Message.ArchiveURL, withIntermediateDirectories: true, attributes: [:])
        } catch {
            print(error)
        }*/
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(messages, toFile: Message.ArchiveURL.path!)
        if !isSuccessfulSave {
            print("Failed to save messages...")
        }
    }
    
    // TODO: Move this to EmotoAPI.
    func loadMessages() -> [Message]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(Message.ArchiveURL.path!) as? [Message]
    }
    
    // CP: Don't understand.
    func adjustingHeight(show:Bool, notification:NSNotification) {
        /*
        var userInfo = notification.userInfo!
        let keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        let animationDurarion = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
        let changeInHeight = (CGRectGetHeight(keyboardFrame) + 10) * (show ? 1 : -1)
        UIView.animateWithDuration(animationDurarion, animations: { () -> Void in
            self.bottomConstraint.constant += changeInHeight
        })
        */
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let message = messages[indexPath.row]
        let text = message.text
        let font = UIFont(name: "Helvetica", size: 17.0)
        let height = heightForLabel(text, font: font!, width: 240)
        
        if (height < 50) {
            return 50
        } else {
            return height + 40
        }
    }
    
    func heightForLabel(text:String, font:UIFont, width:CGFloat) -> CGFloat
    {
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, width, CGFloat.max))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
    
    // When MyEmoto is tapped, segue to select a new current emoto.
    @IBAction func myEmotoImageViewWasTapped(sender: UITapGestureRecognizer) {
        performSegueWithIdentifier("SelectCurrentEmoto", sender: sender)
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    // MARK: - Navigation

    // There are two possible reasons for segueing to EmotoTableView: to select the user's current emoto, and to 
    // select the message's emoto. Here we tell the EmotoTableViewController which is our purpose.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "SelectCurrentEmoto") {
            Flurry.logEvent("Stream:StartedSettingCurrentEmoto")
            savedMessageText = messagesInput.text
            print("Selecting current emoto")
            let navCon = segue.destinationViewController as! UINavigationController
            let emotoTVCon = navCon.viewControllers.first as! EmotoTableViewController
            emotoTVCon.mode = "CURRENT EMOTO"
            emotoTVCon.modeDescription = "Current"
            emotoTVCon.navigationItem.title = "Set Current Emoto"
        }
        if (segue.identifier == "SelectMessageEmoto") {
            Flurry.logEvent("Stream:StartedSettingMessageEmoto")
            print("Selecting message emoto")
            let navCon = segue.destinationViewController as! UINavigationController
            let emotoTVCon = navCon.viewControllers.first as! EmotoTableViewController
            emotoTVCon.mode = "MESSAGE EMOTO"
            emotoTVCon.modeDescription = "Message"
            emotoTVCon.navigationItem.title = "Set Message Emoto"
        }
    }
    
    func getUsernameFromDefaults() -> String {
        //return "chris" // FOR TESTING
        let defaults = NSUserDefaults.standardUserDefaults()
        return defaults.objectForKey("username") as! String
    }
    
    func getTimeOfNewestMessageFromPartner() -> NSDate? {
        let partnerName = yourProfile!.username
        let partnerMessages = messages.filter({$0.author == partnerName})
        if let lastMessage = partnerMessages.last {
            return lastMessage.timestamp
        }
        else {
            return nil
        }
    }
}
