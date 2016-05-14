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
    
    var messages = [Message]()
    var selectedEmoto = UIImage(named: "Sunset")
    var myFormatter: NSDateFormatter?
    var yourFormatter: NSDateFormatter?
    var timer: NSTimer?
    
    // Refreshes the table view with new content
    // See: https://www.andrewcbancroft.com/2015/03/17/basics-of-pull-to-refresh-for-swift-developers/
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
    }()
    
    
    @IBAction func didTapEmotoButton(sender: UIButton) {
        performSegueWithIdentifier("ChangeEmoto", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MessageStreamViewController.keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MessageStreamViewController.keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        myFormatter = NSDateFormatter()
        myFormatter!.dateStyle = .NoStyle
        myFormatter!.timeStyle = .ShortStyle
        yourFormatter = NSDateFormatter()
        yourFormatter!.dateStyle = .NoStyle
        yourFormatter!.timeStyle = .ShortStyle
        
        messages.removeAll()
        
        updateTimeZones()
        updateWeathers()
        updateTimes()
        
        loadMessages("chris")
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector:#selector(MessageStreamViewController.updateTimes), userInfo: nil, repeats: true)
        
        self.messagesTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.messagesTable.addSubview(self.refreshControl)
        messagesTable.delegate = self
        messagesTable.dataSource = self
    }
    
    func updateTimeZones() {
        // TODO: We should be receiving timeZone data from the server.
        // For now, we stub it out.
        myFormatter!.timeZone = NSTimeZone(name: "US/Eastern")!
        yourFormatter!.timeZone = NSTimeZone(name: "US/Pacific")!
    }
    
    func updateTimes() {
        let now = NSDate()
        myTimeLabel.text = myFormatter!.stringFromDate(now)
        yourTimeLabel.text = yourFormatter!.stringFromDate(now)
    }
    
    func updateWeathers() {
        // TODO: We should be receiving weather data from the backend from time to time.
        // For now, we stub it out.
        myWeatherLabel.text = "Cloudy"
        yourWeatherLabel.text = "Sunny"
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        // Do some reloading of data and update the table view's data source
        // Fetch more objects from a web service, for example...
        
        // Simply adding an object to the data source for this example
        self.messagesTable.reloadData()
        refreshControl.endRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadMessages(username: String) {
        EmotoAPI.getMessagesWithSuccess(username) { (msg) -> Void in
            self.messages += msg!
            self.messagesTable.reloadData()
        }
    }
    
    func loadSampleMessages () {
        let emoto1 = UIImage(named: "Blue Sky")
        let emoto2 = UIImage(named: "Stormy")
        let emoto3 = UIImage(named: "Sunset")
        
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
        
        let cellIdentifier = "MessageStreamTableCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! MessageStreamTableViewCell
        
        let message = messages[indexPath.row]
        cell.messageText.text = message.text
        cell.emoto.image = message.emoto
        
        print("printing message: ", message.text)
        
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
            let msg1 = Message(text: text1, emoto: emoto1, author: "chris", timestamp: date1)!
            messages += [msg1]
            messagesInput.text = ""
            messagesTable.reloadData()
            saveMessages()
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
