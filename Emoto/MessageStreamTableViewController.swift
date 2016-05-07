//
//  MessageStreamTableViewController.swift
//  Emoto
//
//  Created by Chris Proctor on 5/6/16.
//  Copyright © 2016 Chris Proctor. All rights reserved.
//

import UIKit

class MessageStreamTableViewController: UITableViewController {
    
    // MARK: Properties
    var messages = [Message]()
    
    var myFormatter: NSDateFormatter?
    var yourFormatter: NSDateFormatter?
    var timer: NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadSampleMessages()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return messages.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "MessageTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! MessageStreamTableViewCell
        
        let message = messages[indexPath.row]
        cell.messageText.text = message.text
        cell.emoto.image = message.emoto
        
        // Configure the cell...
        
        return cell
        
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as! CopresenceTableViewCell
        
        headerCell.backgroundColor = UIColor.lightGrayColor()
        
        return headerCell
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 103.0
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
