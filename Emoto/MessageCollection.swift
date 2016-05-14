//
//  MessageCollection.swift
//  Emoto
//
//  Created by Chris Proctor on 5/10/16.
//  Copyright © 2016 Chris Proctor. All rights reserved.
//

struct MessageCollection: Decodable {
    
    let messages: [Message]?
    
    init?(json: JSON) {
        print(json)
        messages = "messages" <~~ json
        print(messages)
    }
    
}