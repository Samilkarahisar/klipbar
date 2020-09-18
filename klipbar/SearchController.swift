//
//  KlipViewController.swift
//  klipbar


import Cocoa
import Alamofire
import SwiftyJSON
import QuartzCore

class SearchController: NSViewController, NSTextFieldDelegate {
    
    @IBOutlet weak var roomName: NSTextField!;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(DataContainer.shared.someString)
    
    }
    
    @IBAction func openRoom(_ sender: NSButton) {
        //print(roomName.stringValue);
        
        DataContainer.shared.someString=roomName.stringValue;
        getroomContent(room: roomName.stringValue);
      
       if let myViewController = self.storyboard?.instantiateController(withIdentifier: "KlipViewController") as? KlipViewController {
           self.view.window?.contentViewController = myViewController
       }
        
    }
    
    private func getroomContent(room: String) {
        
       // let scriptUrl = "https://klipped.in/api/\(room)"
        // For Local Testing
         let scriptUrl = "http://localhost:2000/api/\(room)"
        
            AF.request(scriptUrl).responseJSON {
                (responseData)-> Void in
                
                switch responseData.result {
                case let .success(value):
                    let json = JSON(value)
                    print(json);
                    DataContainer.shared.fileName = json["fileName"].stringValue as String;
                    DataContainer.shared.fileData = json["fileData"].stringValue as String;
                    DataContainer.shared.content =  json["content"].stringValue as String;
                    //il faut reset les states des autres variaables genre fileBase64 et fileName
                case let .failure(error):
                    print(error)
                }
            }
}
}
    

extension SearchController {
    
    static func freshController() -> SearchController {
          //1.
          let storyboard = NSStoryboard(name: "Main", bundle: nil)
          //2.
          let identifier = "SearchController"
          //3.
          guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? SearchController else {
              fatalError("Why cant i find KlipViewController? - Check Main.storyboard")
            
        }
          return viewcontroller
      }
}
