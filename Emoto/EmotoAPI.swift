//
//  EmotoAPI.swift
//  Emoto
//
//  Created by Chris Proctor on 5/10/16.
//  Copyright © 2016 Chris Proctor. All rights reserved.
//
import Foundation

let baseURL = "http://104.131.45.220/api/v1"

public class EmotoAPI {
    
    class func postSignup(username:String) {
    }
    
    class func getMessagesWithSuccess(username:String, success:(data: [Message]?) -> Void) {
        print("GET \(username) messages")
        let messagesURL = NSURL(string: "\(baseURL)/users/\(username)/messages")!
        
        httpGetRequest(messagesURL) {(data, error) -> Void in
            guard data != nil else {
                print("No data received from server")
                return
            }
            do {
                var messages = [Message]()
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                
                if let messagesJson = json["messages"] as? [[String: AnyObject]] {
                    for messageJson in messagesJson {
                        let message = Message(json: messageJson)
                        messages.append(message!)
                    }
                }
                success(data: messages)
            } catch {
                print("error deserializing JSON: \(error)")
            }
        }
    }
    
    class func getStatusWithSuccess(username: String, success: (data: [String : UserProfile]) -> Void) {
        print("GET \(username) profile")
        let profileUrl = NSURL(string: "\(baseURL)/users/\(username)/status")!
        
        httpGetRequest(profileUrl) {(data, error) -> Void in
            guard data != nil else {
                print("No data received from server")
                return
            }
            do {
                var profiles = [String: UserProfile]()
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! JSON
                if let myProfile : UserProfile = "self" <~~ json {
                    profiles["self"] = myProfile
                }
                if let partnerProfile : UserProfile = "partner" <~~ json {
                    profiles["partner"] = partnerProfile
                }
                success(data: profiles)
            } catch {
                print("error deserializing JSON: \(error)")
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
}