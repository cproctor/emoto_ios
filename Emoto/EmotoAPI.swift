//
//  EmotoAPI.swift
//  Emoto
//  Provides methods for accessing backend API calls. Each method is invoked with a closure 
//  with two arguments: the optional data type returned on success, and an optional error.
//
//  Created by Chris Proctor on 5/10/16.
//  Copyright © 2016 Chris Proctor. All rights reserved.
//
// TODO: Calls to the API should also take care of persisting / updating locally. 
// TODO: In general, show messages locally immediately, to create the impression of reduced latency. But that doesn't happen here.

import Foundation

let baseURL = "http://104.131.45.220/api/v1"

public class EmotoAPI {
    
    class func postSignupWithCompletion(username:String, latitude: Float, longitude: Float, completion: (profile: UserProfile?, error: NSError?) -> Void) {
        let signupURL = NSURL(string: "\(baseURL)/users/new")!
        let params = [
            "username": username,
            "latitude": latitude,
            "longitude": longitude
        ]
        httpJsonPostRequest(signupURL, payload: params as! JSON) { (json, error) -> Void in
            guard error == nil else { completion(profile: nil, error: error); return }
            if let profile = UserProfile(json: json!) {
                completion(profile: profile, error: nil)
            } else {
                completion(profile: nil, error: err("Invalid profile data returned"))
            }
        }
    }
    
    class func postUpdateLocationWithCompletion(username:String, latitude: Float, longitude: Float, completion: (profile: UserProfile?, error: NSError?) -> Void) {
        let signupURL = NSURL(string: "\(baseURL)/users/\(username)/location")!
        let params = [
            "username": username,
            "latitude": latitude,
            "longitude": longitude
        ]
        httpJsonPostRequest(signupURL, payload: params as! JSON) { (json, error) -> Void in
            guard error == nil else { completion(profile: nil, error: error); return }
            if let profile = UserProfile(json: json!) {
                completion(profile: profile, error: nil)
            } else {
                completion(profile: nil, error: err("Invalid profile data returned"))
            }
        }
    }
    
    class func getMessagesWithCompletion(username:String, messageCompletion: (()->Void)?, completion:(messages: [Message]?, error: NSError?) -> Void) {
        httpJsonGetRequest(NSURL(string: "\(baseURL)/users/\(username)/messages")!) { (json, error) -> Void in
            guard error == nil else { completion(messages: nil, error: error); return }
            var messages = [Message]()
            if let messagesJson = json!["messages"] as? [JSON] {
                for messageJson in messagesJson {
                    let message = Message(json: messageJson, completion: messageCompletion)
                    messages.append(message!)
                }
                completion(messages: messages, error: nil)
            }
            else {
                completion(messages: nil, error: err("Invalid JSON returned for messages."))
            }
        }
    }
    
    class func postNewMessageWithCompletion(message: Message, completion: (message : Message?, error: NSError?) -> Void) {
        let newMessageUrl = NSURL(string: "\(baseURL)/users/\(message.author)/messages/new")!
        httpJsonPostRequest(newMessageUrl, payload: message.toJSON()!) { (json, error) -> Void in
            guard error == nil else { completion(message: nil, error: error); return }
            if let savedMessage = Message(json: json!) {
                completion(message: savedMessage, error: nil)
            } else {
                completion(message: nil, error: err("Invalid JSON returned for messages."))
            }
        }
    }
    
    // When successful, returns a dictionary of profiles, possibly including keys for "self" and "partner"
    class func getProfileWithCompletion(username: String, profileCompletion: (()->Void)?, completion: (profiles: [String : UserProfile]?, error: NSError?) -> Void) {
        httpJsonGetRequest(NSURL(string: "\(baseURL)/users/\(username)/status")!) { (json, error) -> Void in
            guard error == nil else { completion(profiles: nil, error: error); return }
            var profiles = [String: UserProfile]()
            guard let myProfileJson = json!["self"] as? JSON else {
                completion(profiles: nil, error: err("Invalid JSON returned for profiles."))
                return
            }
            guard let myProfile = UserProfile(json: myProfileJson, completion: profileCompletion) else {
                completion(profiles: nil, error: err("Invalid JSON returned for profiles."))
                return
            }
            profiles["self"] = myProfile
            
            // Possibly, there is no partner.
            if let yourProfileJson = json!["partner"] as? JSON {
                guard let yourProfile = UserProfile(json: yourProfileJson, completion: profileCompletion) else {
                    completion(profiles: nil, error: err("Invalid JSON returned for profiles."))
                    return
                }
                profiles["partner"] = yourProfile
            }
            completion(profiles: profiles, error: nil)
        }
    }
    
    class func postPairWithCompletion(username: String, pairCode: String, completion: (profiles: [String : UserProfile]?, error: NSError?) -> Void) {
        let pairUrl = NSURL(string: "\(baseURL)/users/\(username)/pair/\(pairCode)")!
        httpJsonPostRequest(pairUrl, payload: [:]) { (json, error) -> Void in
            guard error == nil else { completion(profiles: nil, error: error); return }
            var profiles = [String: UserProfile]()
            if let myProfile : UserProfile = "self" <~~ json! {
                profiles["self"] = myProfile
                if let partnerProfile : UserProfile = "partner" <~~ json! {
                    profiles["partner"] = partnerProfile
                }
                completion(profiles: profiles, error: nil)
            }
            else {
                completion(profiles: nil, error: err("Invalid JSON returned for profiles."))
            }
        }
    }
    
    class func postUnpairWithCompletion(username: String, completion: (profiles: [String : UserProfile]?, error: NSError?) -> Void) {
        let unpairUrl = NSURL(string: "\(baseURL)/users/\(username)/unpair")!
        httpJsonPostRequest(unpairUrl, payload: [:]) { (json, error) -> Void in
            guard error == nil else { completion(profiles: nil, error: error); return }
            var profiles = [String: UserProfile]()
            if let myProfile : UserProfile = "self" <~~ json! {
                profiles["self"] = myProfile
                if let partnerProfile : UserProfile = "partner" <~~ json! {
                    profiles["partner"] = partnerProfile
                }
                completion(profiles: profiles, error: nil)
            }
            else {
                completion(profiles: nil, error: err("Invalid JSON returned for profiles."))
            }
        }
    }
    
    class func postRegisterPushNotificationsWithCompletion(username: String, deviceToken: String, completion: (profile: UserProfile?, error: NSError?) -> Void) {
        let pairUrl = NSURL(string: "\(baseURL)/users/\(username)/register_push_notifications")!
        httpJsonPostRequest(pairUrl, payload: ["token": deviceToken]) { (json, error) -> Void in
            guard error == nil else { completion(profile: nil, error: error); return }
            if let profile = UserProfile(json: json!) {
                completion(profile: profile, error: nil)
            } else {
                completion(profile: nil, error: err("Invalid profile data returned"))
            }
        }
    }
    
    class func getEmotosWithCompletion(emotoCompletion: (()->Void)?, completion: (emotos: [Emoto]?, error: NSError?) -> Void) {
        httpJsonGetRequest(NSURL(string: "\(baseURL)/emotos")!) { (json, error) -> Void in
            guard error == nil else { completion(emotos: nil, error: error); return }
            var emotos = [Emoto]()
            if let emotosJson = json!["emotos"] as? [JSON] {
                for emotoJson in emotosJson {
                    let emoto = Emoto(json: emotoJson, completion: emotoCompletion)
                    emotos.append(emoto!)
                }
                completion(emotos: emotos, error: nil)
            }
            else {
                completion(emotos: nil, error: err("Invalid JSON returned for emotos."))
            }
        }
    }
    
    class func postPresentWithCompletion(username: String, completion: (profile: UserProfile?, error: NSError?) -> Void) {
        let presentURL = NSURL(string: "\(baseURL)/users/\(username)/present")!
        httpJsonPostRequest(presentURL, payload: [:]) { (json, error) -> Void in
            guard error == nil else { completion(profile: nil, error: error); return }
            if let profile = UserProfile(json: json!) {
                completion(profile: profile, error: nil)
            } else {
                completion(profile: nil, error: err("Invalid profile data returned"))
            }
        }
    }
    
    class func postAbsentWithCompletion(username: String, completion: (profile: UserProfile?, error: NSError?) -> Void) {
        let presentURL = NSURL(string: "\(baseURL)/users/\(username)/absent")!
        httpJsonPostRequest(presentURL, payload: [:]) { (json, error) -> Void in
            guard error == nil else { completion(profile: nil, error: error); return }
            if let profile = UserProfile(json: json!) {
                completion(profile: profile, error: nil)
            } else {
                completion(profile: nil, error: err("Invalid profile data returned"))
            }
        }
    }
    
    class func postUpdateCurrentEmotoWithCompletion(username: String, currentEmoto: Emoto, profileCompletion: (()->Void)?, completion: (profile: UserProfile?, error: NSError?) -> Void) {
        
        // TODO: Save the updated profile.
        
        let updateEmotoURL = NSURL(string: "\(baseURL)/users/\(username)/emoto")!
        httpJsonPostRequest(updateEmotoURL, payload: currentEmoto.toJSON()!) { (json, error) -> Void in
            guard error == nil else { completion(profile: nil, error: error); return }
            if let profile = UserProfile(json: json!, completion: profileCompletion) {
                completion(profile: profile, error: nil)
            } else {
                completion(profile: nil, error: err("Invalid profile data returned"))
            }
        }
    }
    

    // =============
    // Mark: HELPERS
    // =============
    
    // Shortcut to generate an appropriate NSError
    class func err(description: String) -> NSError {
        print("Error: \(description)")
        return NSError(domain:"com.emoto", code: 400, userInfo:[NSLocalizedDescriptionKey : description])
    }
    
    // A higher-level http GET request, which returns error unless the response has code 200 and the response
    // body can be decoded as json.
    class func httpJsonGetRequest(url: NSURL, completion: (json: JSON?, error: NSError?) -> Void) {
        httpGetRequest(url) { (data, error) -> Void in
            guard error == nil else {
                completion(json: nil, error: error)
                return
            }
            guard data != nil else {
                completion(json: nil, error: err("No data received from server"))
                return
            }
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! JSON
                completion(json: json, error: nil)
            } catch {
                completion(json: nil, error: err("error deserializing JSON: \(error)"))
                return
            }
        }
    }
    
    // A higher-level http POST request, which returns error unless the response has code 200 and the response
    // body can be decoded as json.
    class func httpJsonPostRequest(url: NSURL, payload: JSON, completion: (json: JSON?, error: NSError?) -> Void) {
        httpPostRequest(url, payload: payload) { (data, error) -> Void in
            guard error == nil else {
                completion(json: nil, error: error)
                return
            }
            guard data != nil else {
                completion(json: nil, error: err("No data received from server"))
                return
            }
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! JSON
                completion(json: json, error: nil)
            } catch {
                completion(json: nil, error: err("error deserializing JSON: \(error)"))
                return
            }
        }
    }

    
    // Issues a HTTP GET request, then runs the provided closure with the resulting data or error.
    // The Emoto Backend returns status code 200 or 400.
    class func httpGetRequest(url: NSURL, completion:(data: NSData?, error: NSError?) -> Void) {
        let session = NSURLSession.sharedSession()
        
        let loadDataTask = session.dataTaskWithURL(url) { (data, response, error) -> Void in
            if let responseError = error {
                completion(data: nil, error: responseError)
            } else if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    let statusError = NSError(domain:"com.emoto", code:httpResponse.statusCode, userInfo:[NSLocalizedDescriptionKey : "HTTP status code has unexpected value."])
                    completion(data: nil, error: statusError)
                } else {
                    completion(data: data, error: nil)
                }
            }
        }
        loadDataTask.resume()
    }
    
    // Issues a HTTP POST request with the provided JSON payload, then runs the provided closure with the resulting data or error.
    // The Emoto Backend returns status code 200 or 400.
    class func httpPostRequest(url: NSURL, payload: JSON, completion:(data: NSData?, error: NSError?) -> Void) {
        let request = NSMutableURLRequest(URL: url)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        do {
            try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(payload, options: [])
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            let postDataTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
                if let responseError = error {
                    completion(data: nil, error: responseError)
                } else if let httpResponse = response as? NSHTTPURLResponse {
                    if httpResponse.statusCode != 200 {
                        print(httpResponse.statusCode)
                        let statusError = NSError(domain:"com.emoto", code:httpResponse.statusCode, userInfo:[NSLocalizedDescriptionKey : "HTTP status code has unexpected value."])
                        completion(data: nil, error: statusError)
                    } else {
                        completion(data: data, error: nil)
                    }
                }
            }
            postDataTask.resume()
        } catch {
            print("POST failed.")
        }
    }
}