//
//  Message.swift
//  Emoto
//
//  Created by Chris Proctor on 5/6/16.
//  Copyright © 2016 Chris Proctor. All rights reserved.
//

import UIKit

<<<<<<< Updated upstream
class Message: NSObject, NSCoding { // Also NSCoding for serialization.
=======
class Message: NSObject, Decodable { // Also NSCoding for serialization.
>>>>>>> Stashed changes
    
    let UNSAVED = -1

    // MARK: Properties
    var text: String
    var emoto: UIImage?
    var author: String
    var id: Int?
    var timestamp: NSDate
    

    // MARK: Archiving Paths
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("emoto_messages")
    
    // MARK: Types
    struct PropertyKey {
        static let textKey = "text"
        static let emotoKey = "emoto"
        static let authorKey = "author"
        static let idKey = "id"
        static let timestampKey = "timestamp"
    }
    
    // MARK: Initialization
    init?(text: String, emoto: UIImage?, author: String, timestamp: NSDate, id: Int = -1)  {
        self.text = text
        self.emoto = emoto
        self.author = author
        self.timestamp = timestamp
        self.id = id
        
        super.init()
        
        
        if text.isEmpty || author.isEmpty {
            return nil
        }
        print("A message! Huzzah")
    }
    
    // MARK: NSCoding
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(text, forKey: PropertyKey.textKey)
        aCoder.encodeObject(emoto, forKey: PropertyKey.emotoKey)
        aCoder.encodeObject(author, forKey: PropertyKey.authorKey)
        aCoder.encodeObject(timestamp, forKey: PropertyKey.timestampKey)
        aCoder.encodeInteger(id!, forKey: PropertyKey.idKey)
        
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let text = aDecoder.decodeObjectForKey(PropertyKey.textKey) as! String
        // Because photo is an optional property of Meal, use conditional cast.
        let emoto = aDecoder.decodeObjectForKey(PropertyKey.emotoKey) as? UIImage
        let author = aDecoder.decodeObjectForKey(PropertyKey.authorKey) as? String
        let timestamp = aDecoder.decodeObjectForKey(PropertyKey.timestampKey) as? NSDate
        let id = aDecoder.decodeIntegerForKey(PropertyKey.idKey)
        
        // Must call designated initializer.
        self.init(text: text, emoto: emoto, author: author!, timestamp: timestamp!, id: id)
    }
    
    // MARK: Decodable protocol
    required init?(json: JSON) {
        guard let id: Int = "id" <~~ json else { return nil}
        guard let text: String = "text" <~~ json else { return nil}
        guard let author: String = "author" <~~ json else { return nil}
        let emoto : UIImage? = nil // TEMP
        guard let timestampString : String = "created_time" <~~ json else { return nil}
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        self.id = id
        self.text = text
        self.author = author
        self.emoto = UIImage(named: "Sunset")
        
        let timestamp : NSDate! = dateFormatter.dateFromString(timestampString)!
        self.timestamp = timestamp
        
        print("Message loaded from JSON: \(self.text)")
    }
}
