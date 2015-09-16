//
//  MasterViewController.swift
//  SimpleChatIOS
//
//  Created by Julian Asamer on 27/01/15.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import UIKit

class ChatPeerCell: UITableViewCell {
    private var kvoContext = 0
    private var chatPeer: ChatRoom?
    
    func configure(chatPeer: ChatRoom) {
        self.chatPeer = chatPeer
        self.textLabel?.text = chatPeer.remoteDisplayName ?? "Loading display name..."
        chatPeer.addObserver(self, forKeyPath: "remoteDisplayName", options: .New, context: &kvoContext)
    }
    
    override func prepareForReuse() {
        self.chatPeer?.removeObserver(self, forKeyPath: "remoteDisplayName")
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context == &kvoContext {
            self.textLabel?.text = chatPeer?.remoteDisplayName ?? "Loading display name..."
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
}

class MasterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    private var kvoContext = 0
    var localPeer: LocalChatPeer = LocalChatPeer()
    var detailViewController: DetailViewController? = nil

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var displayName: UITextField!
    
    @IBAction func start(sender: AnyObject) {
        displayName.enabled = false
        self.localPeer.start(displayName.text!)
        
        self.localPeer.addObserver(self, forKeyPath: "chatRooms", options: .New, context: &kvoContext)
    }

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context == &kvoContext {
            self.tableView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayName.becomeFirstResponder()
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = ((controllers[controllers.count-1] as! UINavigationController).topViewController as! DetailViewController)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            self.tableView.deselectRowAtIndexPath(selectedIndexPath, animated: true);
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = localPeer.chatRooms[indexPath.row]
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.chatRoom = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("returning \(localPeer.chatRooms.count) elements.")
        return localPeer.chatRooms.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ChatPeerCell

        let object = localPeer.chatRooms[indexPath.row]
        cell.configure(object)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showDetail", sender: self);
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

