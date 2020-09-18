//
//  KlipViewController.swift
//  klipbar


import Cocoa
import Alamofire
import SwiftyJSON
import QuartzCore



extension String {
    func subStringAfterLastDash(_ char: Character) -> String {
        guard let subrange = self.range(of: "\(char)\\s*(\\S[^\(char)]*)$", options: [.regularExpression, .backwards]) else { return self }
        return String(self[subrange.upperBound...])
    }
}
class KlipViewController: NSViewController, NSTextFieldDelegate {
    
    @IBOutlet var roomContent: NSTextField!
    var fname = "";
    var roomCurrent: String!
    @IBOutlet weak var fileImageView: NSImageView!
    @IBOutlet weak var fileIcon: NSImageCell!
    @IBOutlet weak var fileName: NSTextFieldCell!
    
    @IBOutlet weak var fileError: NSTextField!
    
    
    @IBOutlet weak var fileBin: NSButton!
    @IBOutlet weak var fileNameText: NSTextField!
    @IBOutlet weak var klipURI: NSTextField!
    var chemin=""
    var fileBase64=""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    // First create a FileManager instance
        let fileManager = FileManager.default
        roomContent.delegate=self
        fileImageView.isHidden=true
        fileNameText.isHidden=true
        fileError.isHidden=true;
        fileBin.isHidden=true;
        
        if let someString = DataContainer.shared.someString {
            print("j'ai recu =>" + someString);
           
            roomCurrent=someString;

            
            // fileManager.createFile(atPath: "~/Downloads/"+DataContainer.shared.fileName!, contents: Data(base64Encoded: DataContainer.shared.fileData!, options: .ignoreUnknownCharacters))
        }
        
        if let someContent = DataContainer.shared.content {
        print(someContent);
        roomContent.stringValue = someContent;
        klipURI.stringValue="klipped.in/"+roomCurrent;
        }
        if let someName = DataContainer.shared.fileName {
            fname=someName;
            let icon = NSWorkspace.shared.icon(forFile: roomContent.stringValue)
            fileNameText.stringValue=fname
            fileNameText.isHidden=false
            fileBin.isHidden=false;
            fileImageView.image=icon
            fileImageView.isHidden = false
        }
      
    
    }
    
 func getDocumentsDirectory() -> URL {
     let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
     return paths[0]
 }
    
    private func getIconForUrl(_ path: String) -> NSImage?
    {
        return NSWorkspace.shared.icon(forFile: path)
    }
    
    func controlTextDidChange(_ obj: Notification) {
        
        let roomContent = obj.object as! NSTextField
        
        if(fileImageView.isHidden == true){//il faudrait changer ceci à la longueur de fileName de shared.
        if(roomContent.stringValue.contains("/Users")){
            
             print(roomContent.stringValue)
             let icon = NSWorkspace.shared.icon(forFile: roomContent.stringValue)
             let data = FileManager.default.contents(atPath: roomContent.stringValue)
            
             if(data!.count>0){
                 fileImageView.isHidden=false
            
                 let fileName = roomContent.stringValue
                 let fileArray = fileName.components(separatedBy: "/")
                 let finalFileName = fileArray.last
                 fileNameText.stringValue=finalFileName!
                 fileNameText.isHidden=false
                 fileBin.isHidden=false;
                 fileImageView.image=icon
                 
                 fileBase64 = data!.base64EncodedString()
                
                 roomContent.stringValue="";
                 //on a bien récup un fichier
             }
            
        }
        }else if(roomContent.stringValue.contains("/Users")){//si y'a deja un fichier de montré mais qu'on nous jette encore un fichier dans le conteneur
            fileError.stringValue="There is already a file in this room. You may want to delete it before uploading another.";
            fileError.isHidden=false;
            roomContent.stringValue="";
            let seconds = 3.0
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            self.fileError.isHidden=true;
            }
        }
        
    }
    
    @IBOutlet weak var test: NSProgressIndicator!
    
    private func getroomContent(room: String, completionHandler: @escaping (String?, NSError?) -> ()) -> () {
        
       // let scriptUrl = "https://klipped.in/api/\(room)"
        // For Local Testing
         let scriptUrl = "http://localhost:2000/api/\(room)"
        
            AF.request(scriptUrl).responseJSON {
                (responseData)-> Void in
                
                switch responseData.result {
                case let .success(value):
                    let json = JSON(value)
                    let newRoomContent = json.string
                    completionHandler(newRoomContent, responseData.error as? NSError)
                    //il faut reset les states des autres variaables genre fileBase64 et fileName
                case let .failure(error):
                    print(error)
                }
            }
        }
    }

extension KlipViewController {
    // Storyboard instantiation
    static func freshController() -> KlipViewController {
        //1.
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        //2.
        let identifier = "KlipViewController"
        //3.
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? KlipViewController else {
            fatalError("Why cant i find KlipViewController? - Check Main.storyboard")
        }
        return viewcontroller
    }
    
    @IBAction func deleteFile(_ sender: NSButton) {
        fileNameText.stringValue="";
        fileBase64="";
        fileImageView.isHidden=true;
        fileBin.isHidden=true;
    }
    @IBAction func updateRoom(_ sender: NSButton) {
 
    }
    
    @IBAction func downloadFile(_ sender: Any) {
         
                let savePanel = NSSavePanel()
                savePanel.title = "Save Example..."
                savePanel.prompt = "Save to file"
                savePanel.nameFieldLabel = "Pick a name"
                savePanel.nameFieldStringValue = fname;
        //        savePanel.isExtensionHidden = false
                savePanel.canSelectHiddenExtension = true
        // savePanel.allowedFileTypes = ["png"]

                let result = savePanel.runModal()

                switch result {
                case .OK:
                    guard let saveURL = savePanel.url else { return }
                if let someData = DataContainer.shared.fileData {
                    FileManager.default.createFile(atPath: saveURL.relativePath, contents: Data(base64Encoded: someData))
                    print(saveURL.relativePath)
                } else {
                        let alert = NSAlert()
                        alert.messageText = "Error"
                        alert.informativeText = "Failed to save image."
                        alert.alertStyle = .informational
                        alert.addButton(withTitle: "OK")
                        alert.runModal()
                    }
                case .cancel:
                    print("User Cancelled")
                default:
                    print("Panel shouldn't be anything other than OK or Cancel")
                }
    }
    @IBAction func goBack(_ sender: Any) {
        print("goback");
        DataContainer.shared.someString=nil;
        if let myViewController = self.storyboard?.instantiateController(withIdentifier: "SearchController") as? SearchController {
            self.view.window?.contentViewController = myViewController
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
        //let urlString = "https://klipped.in/api/update-room"
        // For Local Testing
        let urlString = "http://localhost:2000/api/update-room"
        print(roomCurrent)
        print(roomContent.stringValue)
        print(fileBase64)
        print(fileName.stringValue)
        let reqParameters: [String:String] = ["slug" : (roomCurrent as String?)!,
                                              "content" : (roomContent.stringValue as String?)!,
                                                 "fileBase64":(fileBase64 as String?)!,
                                                 "fileName":(fileName.stringValue as String?)!]
                                           
        let reqHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        print(reqParameters)
        AF.request(urlString, method: .post, parameters: reqParameters).responseString {
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
