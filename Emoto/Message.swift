//
//  Message.swift
//  Emoto
//
//  Created by Chris Proctor on 5/6/16.
//  Copyright © 2016 Chris Proctor. All rights reserved.
//

import UIKit

class Message: NSObject { // Also NSCoding for serialization.
    
    let UNSAVED = -1

    // MARK: Properties
    var text: String
    var emoto: UIImage?
    var author: String
    var id: Int?
    var timestamp: NSDate
    
    /*
    // MARK: Archiving Paths
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("emoto_messages")
    
    // MARK: Types
    struct PropertyKey {
        static let nameKey = "name"
        static let emotoKey = "emoto"
        static let authorKey = "author"
        
    }
    */
    
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
}
