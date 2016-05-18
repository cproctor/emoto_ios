//
//  CopresenceTableViewCell.swift
//  Emoto
//
//  Created by Graduates on 5/6/16.
//  Copyright © 2016 Chris Proctor. All rights reserved.
//
// NOT USED
//

import UIKit

class CopresenceTableViewCell: UITableViewCell {

//    @IBOutlet weak var partnerTime: UILabel!
//    @IBOutlet weak var partnerWeather: UILabel!
//    @IBOutlet weak var myTime: UILabel!
//    @IBOutlet weak var myWeather: UILabel!
    
    var myFormatter: NSDateFormatter?
    var yourFormatter: NSDateFormatter?
    var timer: NSTimer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        myFormatter = NSDateFormatter()
//        myFormatter!.dateStyle = .NoStyle
//        myFormatter!.timeStyle = .ShortStyle
//        yourFormatter = NSDateFormatter()
//        yourFormatter!.dateStyle = .NoStyle
//        yourFormatter!.timeStyle = .ShortStyle
//        updateTimeZones()
//            
//        updateWeathers()
//        updateTimes()
//        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector:#selector(MessageStreamViewController.updateTimes), userInfo: nil, repeats: true)
    }

//    override func setSelected(selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
//
//    func updateTimeZones() {
//        // TODO: We should be receiving timeZone data from the server.
//        // For now, we stub it out.
//        myFormatter!.timeZone = NSTimeZone(name: "US/Pacific")!
//        yourFormatter!.timeZone = NSTimeZone(name: "US/Eastern")!
//    }
//    
//    func updateTimes() {
//        let now = NSDate()
//        myTime.text = myFormatter!.stringFromDate(now)
//        partnerTime.text = yourFormatter!.stringFromDate(now)
//    }
//    
//    func updateWeathers() {
//        // TODO: We should be receiving weather data from the backend from time to time.
//        // For now, we stub it out.
//        myWeather.text = "Sunny"
//        partnerWeather.text = "Hail"
//    }
    
}
