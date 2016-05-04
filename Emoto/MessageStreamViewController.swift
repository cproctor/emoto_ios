//
//  CopresenceWindowViewController.swift
//  Emoto
//
//  Created by Chris Proctor on 5/3/16.
//  Copyright © 2016 Chris Proctor. All rights reserved.
//

import UIKit

class MessageStreamViewController: UIViewController {

    // MARK: Properties
    @IBOutlet weak var myTimeLabel: UILabel!
    @IBOutlet weak var myWeatherLabel: UILabel!
    @IBOutlet weak var yourTimeLabel: UILabel!
    @IBOutlet weak var yourWeatherLabel: UILabel!

    var myFormatter: NSDateFormatter?
    var yourFormatter: NSDateFormatter?
    var timer: NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myFormatter = NSDateFormatter()
        myFormatter!.dateStyle = .NoStyle
        myFormatter!.timeStyle = .ShortStyle
        yourFormatter = NSDateFormatter()
        yourFormatter!.dateStyle = .NoStyle
        yourFormatter!.timeStyle = .ShortStyle
        updateTimeZones()
        
        updateWeathers()
        updateTimes()
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector:#selector(MessageStreamViewController.updateTimes), userInfo: nil, repeats: true)
    }
    
    func updateTimeZones() {
        // TODO: We should be receiving timeZone data from the server.
        // For now, we stub it out.
        myFormatter!.timeZone = NSTimeZone(name: "US/Pacific")!
        yourFormatter!.timeZone = NSTimeZone(name: "US/Eastern")!
    }
    
    func updateTimes() {
        let now = NSDate()
        myTimeLabel.text = myFormatter!.stringFromDate(now)
        yourTimeLabel.text = yourFormatter!.stringFromDate(now)
    }
    
    func updateWeathers() {
        // TODO: We should be receiving weather data from the backend from time to time.
        // For now, we stub it out.
        myWeatherLabel.text = "Sunny"
        yourWeatherLabel.text = "Hail"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
