//
//  Emoto.swift
//  Emoto
//
//  TODO: How do we check whether we already have a particular emoto?
//
//  Created by Chris Proctor on 5/6/16.
//  Copyright © 2016 Chris Proctor. All rights reserved.
//

import UIKit

class Emoto: NSObject, NSCoding, Glossy {
    
    let UNSAVED = -1
    
    // MARK: Properties
    var id: Int?
    var name: String
    var imageUrl: NSURL?
    var image: UIImage?

    // MARK: Archiving Paths
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("emotos")
    
    // MARK: Types
    struct PropertyKey {
        static let nameKey = "name"
        static let imageKey = "image"
        static let imageUrlKey = "imageUrl"
        static let idKey = "id"
    }
    
    // MARK: Initialization
    init?(name: String, image: UIImage?, imageUrl: NSURL?, id: Int = -1)  {
        self.name = name
        self.image = image
        self.imageUrl = imageUrl
        self.id = id
        
        super.init()
    }
    
    // MARK: NSCoding
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: PropertyKey.nameKey)
        aCoder.encodeObject(image, forKey: PropertyKey.imageKey)
        aCoder.encodeObject(imageUrl, forKey: PropertyKey.imageUrlKey)
        aCoder.encodeInteger(id!, forKey: PropertyKey.idKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObjectForKey(PropertyKey.nameKey) as! String
        let image = aDecoder.decodeObjectForKey(PropertyKey.imageKey) as? UIImage
        let imageUrl = aDecoder.decodeObjectForKey(PropertyKey.imageUrlKey) as? NSURL
        let id = aDecoder.decodeIntegerForKey(PropertyKey.idKey) 
        
        // Must call designated initializer.
        self.init(name: name, image: image, imageUrl: imageUrl, id: id)
    }
    
    // MARK: Decodable protocol
    // When an emoto is loaded from JSON, we load its image from archive if possible.
    required init?(json: JSON) {
        guard let id: Int = "id" <~~ json else { return nil}
        guard let name: String = "name" <~~ json else { return nil}
        guard let imageUrl: NSURL = "url" <~~ json else { return nil}
        
        self.id = id
        self.name = name
        self.imageUrl = imageUrl
        
        super.init()
        
        if localArchiveExists() {
            let archivedEmoto = NSKeyedUnarchiver.unarchiveObjectWithFile(archiveFilePath()) as! Emoto
            self.image = archivedEmoto.image
            print("Emoto loaded from JSON: \(self.name). Image file loaded from archive.")
        }
        else {
            // Asynchronously fetch the image, then save.
            print("Emoto loaded from JSON: \(self.name). Loading image...")
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                let data = NSData(contentsOfURL: imageUrl)
                dispatch_async(dispatch_get_main_queue(), {
                    self.image = UIImage(data: data!)
                    NSKeyedArchiver.archiveRootObject(self, toFile: self.archiveFilePath())
                    print("Image file fetched and archived for emoto \(self.name).")
                });
            }
        }
    }
    
    // Mark: Encodable protocol
    func toJSON() -> JSON? {
        return jsonify([
            "id" ~~> self.id,
            "name" ~~> self.name,
            "url" ~~> self.imageUrl
        ])
    }
    
    func localArchiveExists() -> Bool {
        let fileManager = NSFileManager.defaultManager()
        return fileManager.fileExistsAtPath(archiveFilePath())
    }
    
    func archiveFilePath() -> String {
        return Emoto.ArchiveURL.URLByAppendingPathComponent("\(id)").absoluteString
    }
}




