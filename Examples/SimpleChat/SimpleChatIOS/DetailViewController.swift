//
//  DetailViewController.swift
//  SimpleChatIOS
//
//  Created by Julian Asamer on 27/01/15.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import UIKit
import QuickLook

private var kvoContext = 0

class ChatView : UIView {
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    @IBOutlet var chatText: UITextView!
    @IBOutlet var controlsView: UIView!
    @IBOutlet var typedTextField: UITextField!
    @IBOutlet weak var progressView: UIProgressView!
}

class DetailViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ChatRoomDelegate, QLPreviewControllerDelegate, QLPreviewControllerDataSource {
    var chatView: ChatView { get { return self.view as ChatView } }
    let previewController = QLPreviewController()
    var previewedItemURL: NSURL? = nil
    
    var chatRoom: ChatRoom? {
        willSet {
            if let chatRoom = chatRoom {
                chatRoom.removeObserver(self, forKeyPath: "chatText")
                chatRoom.removeObserver(self, forKeyPath: "remoteDisplayName")
                chatRoom.removeObserver(self, forKeyPath: "fileProgress")
            }
        }
        didSet {
            self.configureView()
        }
    }

    func configureView() {
        if let chatRoom: ChatRoom = self.chatRoom {
            chatRoom.delegate = self
            self.updateView()
            
            chatRoom.addObserver(self, forKeyPath: "chatText", options: NSKeyValueObservingOptions.New, context: &kvoContext)
            chatRoom.addObserver(self, forKeyPath: "remoteDisplayName", options: .New, context: &kvoContext)
            chatRoom.addObserver(self, forKeyPath: "fileProgress", options: .New, context: &kvoContext)
        }
    }
    
    func updateView() {
        self.chatView.chatText.text = chatRoom?.chatText
        if let displayName = chatRoom?.remoteDisplayName {
            self.navigationItem.title = "Chat with \(displayName)"
        } else {
            self.navigationItem.title = "Loading display name..."
        }
        self.chatView.chatText.scrollRangeToVisible(NSMakeRange(countElements(self.chatView.chatText.text) - 1, 0))
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if (context == &kvoContext) {
            if keyPath == "fileProgress" {
                self.chatView.progressView.progress = Float(self.chatRoom?.fileProgress ?? 0) / 100.0
            } else {
                self.updateView()
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardDidHideNotification, object: nil)
        
        self.chatView.chatText.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "hideKeyboard"))
        
        previewController.delegate = self
        previewController.dataSource = self
        
        self.configureView()
    }

    func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let duration: Double = userInfo[UIKeyboardAnimationDurationUserInfoKey]!.doubleValue
        let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey]!.unsignedLongValue
        let keyboardFrameEnd = self.view.convertRect(userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue(), toView: nil)
        
        UIView.animateWithDuration(
            duration,
            delay: 0,
            options:  UIViewAnimationOptions.BeginFromCurrentState | UIViewAnimationOptions(curve),
            animations: { () -> Void in
                self.chatView.bottomConstraint.constant = keyboardFrameEnd.size.height
                self.view.layoutIfNeeded()
                self.chatView.chatText.scrollRangeToVisible(NSMakeRange(self.chatView.chatText.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) - 1, 0))
            },
            completion: { _ in ()}
        )
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let duration: Double = userInfo[UIKeyboardAnimationDurationUserInfoKey]!.doubleValue
        let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey]!.unsignedLongValue
        
        UIView.animateWithDuration(
            duration,
            delay: 0,
            options: UIViewAnimationOptions.BeginFromCurrentState | UIViewAnimationOptions(curve),
            animations: {
                self.chatView.bottomConstraint.constant = 0
                self.view.layoutIfNeeded()
            },
            completion: { (b) -> Void in () }
        )
    }
    
    func hideKeyboard() {
        self.chatView.typedTextField.resignFirstResponder()
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.chatRoom?.sendMessage(textField.text)
        textField.text = ""
        
        return false
    }
    
    @IBAction func sendFile(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePicker.delegate = self
        self.presentViewController(imagePicker, animated: true, completion: {})
    }
    func chatRoom(_: ChatRoom, completedReceivingFileAtPath path: String) {
        self.previewedItemURL = NSURL(fileURLWithPath: path)
        self.previewController.reloadData()
        self.presentViewController(self.previewController, animated: true, completion: {})
    }
    func chatRoom(_: ChatRoom, pathForSavingFileWithName fileName: String) -> String? {
        return NSTemporaryDirectory().stringByAppendingPathComponent(fileName)
    }
    
    func getTempPath() -> String {
        return NSTemporaryDirectory().stringByAppendingPathComponent(NSUUID().UUIDString)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        if let let image = (info[UIImagePickerControllerEditedImage] ?? info[UIImagePickerControllerOriginalImage]) as? UIImage {
            let directory = getTempPath()
            NSFileManager.defaultManager().createDirectoryAtPath(directory, withIntermediateDirectories: true, attributes: nil, error: nil)
            let path = directory.stringByAppendingPathComponent("image.jpg")
            UIImageJPEGRepresentation(image, 1).writeToFile(path, atomically: true)
            self.chatRoom?.sendFile(path)
        } else if let path = (info[UIImagePickerControllerMediaURL] as? NSURL)?.path {
            self.chatRoom?.sendFile(path)
        }
        
        picker.dismissViewControllerAnimated(true, completion: {})
    }
    
    func numberOfPreviewItemsInPreviewController(controller: QLPreviewController!) -> Int {
        return previewedItemURL == nil ? 0 : 1
    }
    func previewController(controller: QLPreviewController!, previewItemAtIndex index: Int) -> QLPreviewItem! {
        return previewedItemURL
    }
    func previewControllerDidDismiss(controller: QLPreviewController!) {
        self.previewedItemURL = nil
    }
}

