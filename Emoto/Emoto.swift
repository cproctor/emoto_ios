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
        
    // MARK: Properties
    var id: Int?
    var name: String
    var imageUrl: NSURL?
    var image: UIImage?

    // MARK: Archiving Paths
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("emotos")
    
    // Returns the file URL at which an Emoto with the given ID should be saved.
    class func archiveFilePath(id: Int) -> String {
        return Emoto.ArchiveURL.URLByAppendingPathComponent("emoto_\(id)").absoluteString
    }
    
    // Checks whether an archived copy of an Emoto with the given ID exists.
    class func localArchiveExists(id: Int) -> Bool {
        let fileManager = NSFileManager.defaultManager()
        return fileManager.fileExistsAtPath(Emoto.archiveFilePath(id))
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
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(name, forKey: "name")
        if image != nil {
            coder.encodeObject(image!, forKey: "image")
        }
        if imageUrl != nil {
            coder.encodeObject(imageUrl!, forKey: "imageUrl")
        }
        coder.encodeInteger(id!, forKey: "id")
    }
    
    required convenience init?(coder decoder: NSCoder) {
        let name = decoder.decodeObjectForKey("name") as! String
        let image = decoder.decodeObjectForKey("image") as? UIImage
        let imageUrl = decoder.decodeObjectForKey("imageUrl") as? NSURL
        let id = decoder.decodeIntegerForKey("id")
        
        // Must call designated initializer.
        self.init(name: name, image: image, imageUrl: imageUrl, id: id)
    }
    
    // MARK: Decodable protocol
    // When an emoto is loaded from JSON, we load its image from archive if possible.
    required init?(json: JSON) {
        guard let id: Int = "id" <~~ json else { return nil}
        
        if Emoto.localArchiveExists(id) {
            guard let savedEmoto = NSKeyedUnarchiver.unarchiveObjectWithFile(Emoto.archiveFilePath(id)) as? Emoto else { return nil }
            self.id = savedEmoto.id
            self.name = savedEmoto.name
            self.image = savedEmoto.image
            self.imageUrl = savedEmoto.imageUrl
            super.init()
            print("Loaded Emoto \(self.name) from archive")
        }
        else {
            guard let name: String = "name" <~~ json else { return nil}
            guard let imageUrl: NSURL = "url" <~~ json else { return nil}
            self.id = id
            self.name = name
            self.imageUrl = imageUrl
            super.init()
            dispatch_async(dispatch_get_main_queue()) {
                let data = NSData(contentsOfURL: imageUrl)
                dispatch_async(dispatch_get_main_queue(), {
                    self.image = UIImage(data: data!)
                    guard self.save() else {
                        print("ERROR. Could not archive")
                        return
                    }
                    print("Loaded Emoto \(self.name) from server")
                })
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
    
    func save() -> Bool {
        // Attempt to save in user defaults. Also not working.
        /*
        let savedEmoto = NSKeyedArchiver.archivedDataWithRootObject(self)
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(savedEmoto, forKey: "emoto_\(self.id)")
        return true
        */
        
        // For some reason I can't archive to file.
        return NSKeyedArchiver.archiveRootObject(self, toFile: Emoto.archiveFilePath(self.id!))
    }
}




