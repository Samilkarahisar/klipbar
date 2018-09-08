//
//  KlipViewController.swift
//  klipbar
//
//  Created by Ferruccio Balestreri on 30/08/2018.
//  Copyright © 2018 Ferruccio Balestreri. All rights reserved.
//

import Cocoa
import Alamofire
import SwiftyJSON
import QuartzCore


class KlipViewController: NSViewController {
    
    @IBOutlet var roomContent: NSTextField!
    @IBOutlet var roomCurrent: NSTextField!
    @IBOutlet weak var updateWheel: NSProgressIndicator!
    @IBOutlet weak var RoomUpdateButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateWheel.isHidden = true
        
    }
    
    
    private func getroomContent(room: String, completionHandler: @escaping (String?, NSError?) -> ()) -> () {
        
        let scriptUrl = "https://klipped.in/api/\(room)"
        // For Local Testing
        // let scriptUrl = "http://localhost:3000/api/\(room)"
            Alamofire.request(scriptUrl).responseJSON {
                (responseData)-> Void in
                
                if (responseData.result.value == nil){
                    return
                }
                let json = JSON(responseData.result.value!)
                let newRoomContent = json["content"].string
                completionHandler(newRoomContent, responseData.error as? NSError)
            }
        }
    }


extension KlipViewController {
    // Storyboard instantiation
    static func freshController() -> KlipViewController {
        //1.
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        //2.
        let identifier = NSStoryboard.SceneIdentifier(rawValue: "KlipViewController")
        //3.
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? KlipViewController else {
            fatalError("Why cant i find KlipViewController? - Check Main.storyboard")
        }
        return viewcontroller
    }
    @IBAction func updateRoom(_ sender: NSButton) {
        if (roomCurrent.stringValue != "" && roomContent.stringValue == ""){
            getContent(room: roomCurrent.stringValue)
            updateWheel.isHidden = false
            updateWheel.startAnimation(1)
            RoomUpdateButton.isHidden = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.updateWheel.stopAnimation(1)
                self.updateWheel.isHidden = true
                self.RoomUpdateButton.isHidden = false
            }
        }
        else if (roomCurrent.stringValue != "" && roomContent.stringValue != ""){
            postContent()
            updateWheel.isHidden = false
            updateWheel.startAnimation(1)
            RoomUpdateButton.isHidden = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.updateWheel.stopAnimation(1)
                self.updateWheel.isHidden = true
                self.RoomUpdateButton.isHidden = false
            }
        }
    }
    
    func getContent(room: String) -> Void {
        getroomContent(room: room){(newRoomContent, error) in
            if newRoomContent != nil {
                self.updateRoomContent(newRoomContent: newRoomContent)
            } else {
                print("Error in Room Content")
            }
        }
    }
    
    func postContent(){
        let urlString = "https://klipped.in/api/update-room"
        // For Local Testing
        //let urlString = "http://localhost:3000/api/update-room"
        
        let reqParameters: [String:String] = ["slug" : (roomCurrent.stringValue as String?)!,
                                              "content" : (roomContent.stringValue as String?)!]
        let reqHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        Alamofire.request(urlString, method: .post, parameters: reqParameters, headers: reqHeaders).responseString {
            response in
            return
        }

    }
    
    func updateRoomContent(newRoomContent: String?){
        if (newRoomContent! == "No Content"){
            roomContent.stringValue = ""
        }
        else{
            roomContent.stringValue = newRoomContent!
        }
    }

}
