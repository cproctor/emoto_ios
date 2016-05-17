//
//  UserProfile.swift
//  Emoto
//
//  Created by Chris Proctor on 5/14/16.
//  Copyright © 2016 Chris Proctor. All rights reserved.
//

import UIKit

class UserProfile: NSObject, NSCoding, Decodable { // Also NSCoding for serialization.
    
    // MARK: Properties
    var temperature : Float
    var city : String
    var latitude : Float
    var longitude : Float
    var timeZone: String
    var username : String
    var pairCode : String
    var weather : String
    var present : Bool
    var presentTimestamp : NSDate
    var currentEmoto : Emoto?
    var avatarUrl : NSURL?
    var weatherIconUrl : NSURL?
    
    
    // MARK: Archiving Paths
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("emoto_profiles")
    
    // MARK: Types
    struct PropertyKey {
        static let temperatureKey = "temperature"
        static let cityKey = "city"
        static let latitudeKey = "latitude"
        static let longitudeKey = "longitude"
        static let timeZoneKey = "time_zone"
        static let usernameKey = "username"
        static let pairCodeKey = "pair_code"
        static let weatherKey = "weather"
        static let presentKey = "present"
        static let presentTimestampKey = "presentTimestamp"
        static let currentEmotoKey = "currentEmoto"
        static let avatarUrlKey = "avatarUrl"
        static let weatherIconUrlKey = "weatherIcon"
    }
    
    // MARK: Initialization
    init?(temperature: Float, city: String, latitude: Float, longitude: Float, timeZone: String, username: String, pairCode: String, weather: String, present : Bool, presentTimestamp : NSDate, currentEmoto : Emoto?, avatarUrl: NSURL?, weatherIconUrl: NSURL?)  {
        
        self.temperature = temperature
        self.city = city
        self.latitude = latitude
        self.longitude = longitude
        self.timeZone = timeZone
        self.username = username
        self.pairCode = pairCode
        self.weather = weather
        self.present = present
        self.presentTimestamp = presentTimestamp
        self.currentEmoto = currentEmoto
        self.avatarUrl = avatarUrl
        self.weatherIconUrl = weatherIconUrl
        super.init()
    }
    
    // MARK: NSCoding
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeFloat(temperature, forKey: PropertyKey.temperatureKey)
        aCoder.encodeObject(city, forKey: PropertyKey.cityKey)
        aCoder.encodeFloat(latitude, forKey: PropertyKey.latitudeKey)
        aCoder.encodeFloat(longitude, forKey: PropertyKey.longitudeKey)
        aCoder.encodeObject(timeZone, forKey: PropertyKey.timeZoneKey)
        aCoder.encodeObject(username, forKey: PropertyKey.usernameKey)
        aCoder.encodeObject(pairCode, forKey: PropertyKey.pairCodeKey)
        aCoder.encodeObject(weather, forKey: PropertyKey.weatherKey)
        aCoder.encodeObject(present, forKey: PropertyKey.presentKey)
        aCoder.encodeObject(presentTimestamp, forKey: PropertyKey.presentTimestampKey)
        aCoder.encodeObject(currentEmoto, forKey: PropertyKey.currentEmotoKey)
        aCoder.encodeObject(avatarUrl, forKey: PropertyKey.avatarUrlKey)
        aCoder.encodeObject(weatherIconUrl, forKey: PropertyKey.weatherIconUrlKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let temperature = aDecoder.decodeObjectForKey(PropertyKey.temperatureKey) as! Float
        let city = aDecoder.decodeObjectForKey(PropertyKey.cityKey) as! String
        let latitude = aDecoder.decodeObjectForKey(PropertyKey.latitudeKey) as! Float
        let longitude = aDecoder.decodeObjectForKey(PropertyKey.longitudeKey) as! Float
        let timeZone = aDecoder.decodeObjectForKey(PropertyKey.timeZoneKey) as! String
        let username = aDecoder.decodeObjectForKey(PropertyKey.usernameKey) as! String
        let pairCode = aDecoder.decodeObjectForKey(PropertyKey.pairCodeKey) as! String
        let weather = aDecoder.decodeObjectForKey(PropertyKey.weatherKey) as! String
        let present = aDecoder.decodeObjectForKey(PropertyKey.presentKey) as! Bool
        let presentTimestamp = aDecoder.decodeObjectForKey(PropertyKey.presentTimestampKey) as! NSDate
        let currentEmoto = aDecoder.decodeObjectForKey(PropertyKey.currentEmotoKey) as? Emoto
        let avatarUrl = aDecoder.decodeObjectForKey(PropertyKey.avatarUrlKey) as? NSURL
        let weatherIconUrl = aDecoder.decodeObjectForKey(PropertyKey.weatherIconUrlKey) as? NSURL
        
        // Must call designated initializer.
        self.init(temperature: temperature, city: city, latitude: latitude, longitude: longitude, timeZone: timeZone, username: username, pairCode: pairCode, weather: weather, present: present, presentTimestamp: presentTimestamp, currentEmoto: currentEmoto, avatarUrl: avatarUrl, weatherIconUrl: weatherIconUrl)
    }
    
    // MARK: Decodable protocol
    required init?(json: JSON) {
        guard let temperature : Float = "temperature" <~~ json else { return nil }
        guard let city : String = "city" <~~ json else { return nil }
        guard let latitude : Float = "latitude" <~~ json else { return nil }
        guard let longitude : Float = "longitude" <~~ json else { return nil }
        guard let timeZone : String = "time_zone" <~~ json else { return nil }
        guard let username : String = "username" <~~ json else { return nil }
        guard let pairCode : String = "pair_code" <~~ json else { return nil }
        guard let weather : String = "weather" <~~ json else { return nil }
        guard let present : Bool = "present" <~~ json else { return nil }
        guard let presentTimestampString : String = "presence_timestamp" <~~ json else { return nil }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let presentTimestamp : NSDate! = dateFormatter.dateFromString(presentTimestampString)!
        
        if let currentEmotoJson = json["current_emoto"] as? JSON {
            if let emoto = Emoto(json: currentEmotoJson) {
                self.currentEmoto = emoto
            }
        }

        //guard let avatarUrl : NSURL = "avatar_url" <~~ json else { return nil }
        guard let weatherIconUrl : NSURL = "weather_icon_url" <~~ json else { return nil }
        
        self.temperature = temperature
        self.city = city
        self.latitude = latitude
        self.longitude = longitude
        self.timeZone = timeZone
        self.username = username
        self.pairCode = pairCode
        self.weather = weather
        self.present = present
        self.presentTimestamp = presentTimestamp
        //self.avatarUrl =
        self.weatherIconUrl = weatherIconUrl
    }
}
