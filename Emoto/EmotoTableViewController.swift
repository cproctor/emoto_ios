//
//  EmotoTableViewController.swift
//  Emoto
//
//  Created by Graduates on 5/8/16.
//  Copyright © 2016 Chris Proctor. All rights reserved.
//

import UIKit

class EmotoTableViewController: UITableViewController {

    var mode : String?
    var modeDescription : String?
    var selectedEmoto : Emoto? = nil
    var emotos : [Emoto] = [Emoto]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //loadSamplePictures()
        
        fetchEmotosFromServer()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return emotos.count
    }
    
    func fetchEmotosFromServer() {
        EmotoAPI.getEmotosWithCompletion(reload) { (emotos, error) -> Void in
            dispatch_async(dispatch_get_main_queue()) { // ensures the closure below will execute on the main thread.
                self.emotos = emotos!
            }
        }
    }
    
    func reload() {
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "EmotoTableCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! EmotoTableViewCell
        
        let emoto = emotos[indexPath.row]
        cell.imageChoice.image = emoto.image
        cell.emotoLabel.text = emoto.name
        
        // Could put emoto name here too.
        // Configure the cell...
        
        return cell
       
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let selectedCell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        selectedCell.contentView.backgroundColor = UIColor.redColor()
        let row = indexPath.row
        selectedEmoto = emotos[row]
        print("Selected emoto \(selectedEmoto!.name)")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "EmotoWasSelected") {
            let svc = segue.destinationViewController as! MessageStreamViewController
            Flurry.logEvent("Emoto:Selected\(modeDescription)Emoto")
            if mode == "CURRENT EMOTO" { // We came here to set the current emoto.
                // TODO READ USERNAME FROM USER DEFAULTS
                EmotoAPI.postUpdateCurrentEmotoWithCompletion(getUsernameFromDefaults(), currentEmoto: selectedEmoto!, profileCompletion: svc.updateCopresenceWindow) { (profile, error) -> Void in
                    guard error == nil else {
                        print("Error selecting emoto")
                        return
                    }
                    print("Saving emoto selection: \(self.selectedEmoto!.name)")
                    print(self.selectedEmoto!.debugDescription)
                    svc.myProfile = profile
                }
            }
            if mode == "MESSAGE EMOTO" { // We came here to set a message emoto.
                svc.futureMessageEmoto = selectedEmoto!
            }
        }
        else {
            Flurry.logEvent("Emoto:CancelledSelecting\(modeDescription)Emoto")
        }
    }
    
    func getUsernameFromDefaults() -> String {
        return "chris"
        let defaults = NSUserDefaults.standardUserDefaults()
        return defaults.objectForKey("username") as! String
    }
    
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
