//
//  TasksViewController.swift
//
//
//  Created by Matt and Emma Miszewski
//  Copyright © 2016+ Emma Miszewski. All rights reserved.
//

import UIKit
import RealmSwift
import Social
import MessageUI

class TasksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMessageComposeViewControllerDelegate {
    
    let textMessageRecipients = "1-425-753-0165"
    var selectedList : TaskList!
    var openTasks : Results<Task>!
    var completedTasks : Results<Task>!
    var voted : Results<Task>!
    var currentCreateAction:UIAlertAction!
    var isEditingMode = false
    var pasteable = ""
    // Run Once
    var token: dispatch_once_t = 0
    var notificationToken: NotificationToken!
    var realm: Realm!
    
    @IBOutlet weak var tasksTableView: UITableView!

    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        //Set Color
        //let attributes: AnyObject = [ NSForegroundColorAttributeName: UIColor.orangeColor()]
        //self.navigationController!.navigationBar.titleTextAttributes = attributes as? [String : AnyObject]
        
        //Set Font Size
        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Arial", size: 14.0)!, NSForegroundColorAttributeName: UIColor.orangeColor()];
        
        
        
        self.title = selectedList.name
        if self.selectedList.tasks.count == 0 {
            self.autoAddFBTask(nil)
        }
        
        if(!NSUserDefaults.standardUserDefaults().boolForKey("firstlaunch1.0")){
            //Put any code here and it will be executed only once.
            print("Is a first launch")
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "firstlaunch1.0")
            NSUserDefaults.standardUserDefaults().synchronize();
        }
        //setupRealm()
        readTasksAndUpateUI()
    }
    
    // MARK: - User Actions -
    @IBAction func didClickOnEditTasks(sender: AnyObject) {
        isEditingMode = !isEditingMode
        self.tasksTableView.setEditing(isEditingMode, animated: true)
    }
    @IBAction func didClickOnNewTask(sender: AnyObject) {
        self.displayAlertToAddTask(nil)
    }

    func readTasksAndUpateUI(){
        
        completedTasks = self.selectedList.tasks.filter("isCompleted = true")
        openTasks = self.selectedList.tasks.filter("isOpen = true")
        voted = self.selectedList.tasks.filter("hasVoted = true")
        
        self.tasksTableView.reloadData()
    }
    
    func setupRealm() {
        // Log in existing user with username and password
        let username = "mattmiszewski@gmail.com"
        let password = "Psmor0xx"
        
        SyncUser.logInWithCredentials(SyncCredentials.usernamePassword(username, password: password), authServerURL: NSURL(string: "http://emmabiz.com:9080")!, onCompletion: { user, error in
            guard let user = user else {
                fatalError(String(error))
            }
            
            
            // Open Realm  "realm://emmabiz.com:9080/~/realmtasks"
            let configuration = Realm.Configuration(
                syncConfiguration: SyncConfiguration(user: user, realmURL: NSURL(string: "realm://emmabiz.com:9080/~/VWF")!)
            )
            
            uiRealm = try! Realm(configuration: configuration)
            print("Realm Setup")
            
            // Notify us when Realm changes
            
            /*self.notificationToken = self.realm.addNotificationBlock { _ in
                //self.readTasksAndUpdateUI()   //updateList()
                //updateList()
                print("Realm Update Occured")
            }*/
        })
        
        
    }
    
//    deinit {
//        notificationToken.stop()
//    }

    
    // MARK: - UITableViewDataSource -
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if section == 0{
            return openTasks.count
        }
        if section == 1{
            return completedTasks.count
        }
        if section == 2{
            return voted.count
        }
        else
        {
            return 1
        }
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 18))
        let label = UILabel(frame: CGRect(x: 20, y: 20, width: tableView.frame.size.width - 12, height: 50))
        label.text = self.tableView(tableView, titleForHeaderInSection: section)
        
        if section == 0{
            
            label.numberOfLines = 2
        }
        if section == 1{
            label.numberOfLines = 0
        }
        if section == 2{
            label.numberOfLines = 0
        }
        
        label.textColor = UIColor.whiteColor()
        label.font = UIFont(name: "Raleway-Black", size: 16)
        
        view.addSubview(label)
        
        return view
    }
    
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 0{
            return "Tap to text message friend, Swipe to Update or Send FB Message"
        }
        if section == 1{
            return "I bugged them on FB to Vote"
        }
        if section == 2{
            return "They Voted!!!"
        }
        else {
            return "XXX"
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")
        var snap2 = ""
        var task: Task!
        if indexPath.section == 0{
            task = openTasks[indexPath.row]
        }
        if indexPath.section == 1{
            task = completedTasks[indexPath.row]
        }
        if indexPath.section == 2{
            task = voted[indexPath.row]
        } else {
        }
        cell?.textLabel?.text = task.name
        
        switch (indexPath.row)
        {
        case 0:
            snap2 = "Feedback.png"
        case 1:
            snap2 = "Donate.png"
        case 2:
            snap2 = "Volunteering-48.png"
        case 3:
            snap2 = "SMS-48.png"
        case 4:
            snap2 = "IdVerified.png"
        case 5:
            snap2 = "Search.png"
        case 6:
            snap2 = "RouteSign.png"
        case 7:
            snap2 = "ShakePhone.png"
        default:
            snap2 = "facebook@2x.png"
        }
        
        var image : UIImage = UIImage(named: snap2)!
        cell!.imageView!.image = image
        return cell!
    }


    func tweet(){
            let currentDate = NSDate()
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy"
            let eDateAsString = "11-08-2016"
            var currentDateAsString = "11-09-2016" //dummy
            currentDateAsString = dateFormatter.stringFromDate(currentDate)
        
        // Comparing dates
        if currentDateAsString.compare(eDateAsString) == NSComparisonResult.OrderedDescending {
            print("Date1 is Later than Date2")
            print("ELECTION DAY HAS PASSED")
            
            let image : UIImage = UIImage(named:"win.jpg")!
            let voter = "Hey " + selectedList.name + ",\r\n\n"
            let msg = "Thanks to your support HRC has won!!  See you at the inauguration."
            let pasteable = voter + msg
            let pasteboard = UIPasteboard.generalPasteboard()
            pasteboard.string = pasteable
            
            let socialController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            socialController.setInitialText(pasteable)
            socialController.addImage(image)
            self.presentViewController(socialController, animated: true, completion: nil)
        }
        else if currentDateAsString.compare(eDateAsString) == NSComparisonResult.OrderedAscending {
            print("Date1 is Earlier than Date2")
            print("Go Vote Erly if you can in your state")
            
            let image : UIImage = UIImage(named:"early.jpg")!
            let voter = "Hey " + selectedList.name + ",\r\n\n"
            let msg = "If you are in an Early Voting State, please get out and Vote. Early voting is a great way to show support early and move us toward a win."
            let pasteable = voter + msg
            let pasteboard = UIPasteboard.generalPasteboard()
            pasteboard.string = pasteable
            
            let socialController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            socialController.setInitialText(pasteable)
            socialController.addImage(image)
            self.presentViewController(socialController, animated: true, completion: nil)
        }
        else if currentDateAsString.compare(eDateAsString) == NSComparisonResult.OrderedSame {
            print("Same dates")
            print("IT IS ELECTION DAY")
            
            let image : UIImage = UIImage(named:"GOTV.jpg")!
            let voter = "Hey " + selectedList.name + ",\r\n\n"
            let msg = "Friendly reminder that today is election day.  Please get out and cast a vote for HRC."
            let pasteable = voter + msg
            let pasteboard = UIPasteboard.generalPasteboard()
            pasteboard.string = pasteable
            
            let socialController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            socialController.setInitialText(pasteable)
            socialController.addImage(image)
            self.presentViewController(socialController, animated: true, completion: nil)
        }
    }
    
    func autoAddFBTask(updatedTask:Task!){
        
        //let taskName = "Send Voter a Text Message to GOTV"
        let gotvTask = "Send SMS to GOTV"
        let fundTask = "Donate to the Cause"
        let volunteerTask = "Volunteer to Help"
        let autoTextTask = "Get Texts from the Campaign"
        let registerTask = "Register"
        let locationTask = "Find the Poll for you"
        let travelTask = "Plan Travel to Events"
        let callTask = "Make Calls to Help"
        
        var allTasks = [gotvTask,fundTask, volunteerTask, autoTextTask, registerTask, locationTask, travelTask, callTask]
        
        try! uiRealm.write {
            for string in allTasks {
                
                let newTask = Task()
                newTask.name = string
                newTask.notes = "facebook@2x.png"
                self.selectedList.tasks.append(newTask)
            }
            self.readTasksAndUpateUI()
        }
        
        self.readTasksAndUpateUI()
 
        
//        let newTask1 = Task()
//                newTask1.name = gotvTask
                //print(newTask.name + "YYY")
//                try! uiRealm.write{
//                    self.selectedList.tasks.append(newTask1)
//
//                    self.readTasksAndUpateUI()
//            }
    }
    
    func displayAlertToAddTask(updatedTask:Task!){
        var title = "New GOTV Task"
        var doneTitle = "Create"
        if updatedTask != nil{
            title = "Update GOTV Task"
            doneTitle = "Update"
        }
        
        let alertController = UIAlertController(title: title, message: "Task to motivate this Voter.", preferredStyle: UIAlertControllerStyle.Alert)
        let createAction = UIAlertAction(title: doneTitle, style: UIAlertActionStyle.Default) { (action) -> Void in
            
            let taskName = "Send Voter a Message on Facebook2"
            if updatedTask != nil{
                try! uiRealm.write{
                    updatedTask.name = taskName
                    try! uiRealm.commitWrite()
                    self.readTasksAndUpateUI()
                }
            }   else    {
                let newTask = Task()
                newTask.name = taskName
                try! uiRealm.write{
                    self.selectedList.tasks.append(newTask)
                    self.readTasksAndUpateUI()
                }
            }
            print(taskName)
        }
        alertController.addAction(createAction)
        createAction.enabled = false
        self.currentCreateAction = createAction
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "GOTV Task Name"
            textField.addTarget(self, action: #selector(TasksViewController.taskNameFieldDidChange(_:)) , forControlEvents: UIControlEvents.EditingChanged)
            if updatedTask != nil{
                textField.text = updatedTask.name
            }
        }
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    //Enable the create action of the alert only if textfield text is not empty
    func taskNameFieldDidChange(textField:UITextField){
        self.currentCreateAction.enabled = textField.text?.characters.count > 0
    }
    
    // A wrapper function to indicate whether or not a text message can be sent from the user's device
    func canSendText() -> Bool {
        return MFMessageComposeViewController.canSendText()
    }
    
    // Configures and returns a MFMessageComposeViewController instance
    func configuredMessageComposeViewController() -> MFMessageComposeViewController {
        let currentDate = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let eDateAsString = "11-08-2016"
        var currentDateAsString = "11-09-2016" //dummy
        currentDateAsString = dateFormatter.stringFromDate(currentDate)
        
        // GOTV SMS
        //date compare
        if currentDateAsString.compare(eDateAsString) == NSComparisonResult.OrderedDescending {
            print("Date1 is Later than Date2")
            print("ELECTION DAY HAS PASSED")
            
            //let image : UIImage = UIImage(named:"win.jpg")!
            let voter = "Hey " + selectedList.name + ",\r\n\n"
            let msg = "Thanks to your support HRC has won!!  See you at the inauguration."
            pasteable = voter + msg
            let pasteboard = UIPasteboard.generalPasteboard()
            pasteboard.string = pasteable
        }
        else if currentDateAsString.compare(eDateAsString) == NSComparisonResult.OrderedAscending {
            print("Date1 is Earlier than Date2")
            print("Go Vote Erly if you can in your state")
            
            //let image : UIImage = UIImage(named:"early.jpg")!
            let voter = "Hey " + selectedList.name + ",\r\n\n"
            let msg = "If you are in an Early Voting State, please get out and Vote. Early voting is a great way to show support early and move us toward a win."
            pasteable = voter + msg
            let pasteboard = UIPasteboard.generalPasteboard()
            pasteboard.string = pasteable
        }
        else if currentDateAsString.compare(eDateAsString) == NSComparisonResult.OrderedSame {
            print("Same dates")
            print("IT IS ELECTION DAY")
            
            //let image : UIImage = UIImage(named:"GOTV.jpg")!
            let voter = "Hey " + selectedList.name + ",\r\n\n"
            let msg = "Friendly reminder that today is election day.  Please get out and cast a vote for HRC."
            pasteable = voter + msg
            let pasteboard = UIPasteboard.generalPasteboard()
            pasteboard.string = pasteable
        }
        // GOTV SMS
        
        
        let messageComposeVC = MFMessageComposeViewController()
        messageComposeVC.messageComposeDelegate = self  //  Make sure to set this property to self, so that the controller can be dismissed!
        messageComposeVC.recipients = [selectedList.phone]
        //messageComposeVC.body = pasteable
        return messageComposeVC
    }
    
    // MFMessageComposeViewControllerDelegate callback - dismisses the view controller when the user is finished with it
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //Do this on tap of cell
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
//    tweet()
        //SMS
        
        //try if then loop on indexPath.row == 0 or 1 or 2
        //and then set messageComposeVC.body based upon row tapped
        //row 0 = gotv msg
        //row 1 = donate
        
        var currentMsg = ""
        
        switch (indexPath.row)
        {
        case 0:
            print("GOTV")
            currentMsg = "GOTV Message"
        case 1:
            print("Donate")
            currentMsg = "Donate Message"
        case 2:
            print("Volunteer")
            currentMsg = "Volunteer Message"
        case 3:
            print("Text")
            currentMsg = "Receive Texts"
        case 4:
            print("Register")
            currentMsg = "Register to Vote"
        case 5:
            print("Find")
            currentMsg = "Find Polls"
        case 6:
            print("Travel")
            currentMsg = "Travel to Event"
        case 7:
            print("Calls")
            currentMsg = "Make Calls"
        default:
            print("Default")
            currentMsg = "Oops, text sentin error"
        }
        
        print(currentMsg)
        
        if (canSendText()) {
            // Obtain a configured MFMessageComposeViewController
            let messageComposeVC = configuredMessageComposeViewController()
            messageComposeVC.body = currentMsg
            // Present the configured MFMessageComposeViewController instance
            // Note that the dismissal of the VC will be handled by the messageComposer instance,
            // since it implements the appropriate delegate call-back
            presentViewController(messageComposeVC, animated: true, completion: nil)
        } else {
            // Let the user know if his/her device isn't able to send text messages
            let errorAlert = UIAlertView(title: "Cannot Send Text Message", message: "Your device is not able to send text messages.", delegate: self, cancelButtonTitle: "OK")
            errorAlert.show()
        }
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .Default, title: "😈 Delete") { (deleteAction, indexPath) -> Void in
            UIButton.appearance().setTitleColor(UIColor.orangeColor(), forState: UIControlState.Normal)
            deleteAction.backgroundColor = UIColor.brownColor()

            //alternative subroutine
            var taskToBeDeleted: Task!
            if indexPath.section == 0{
                taskToBeDeleted = self.openTasks[indexPath.row]
            }
            if indexPath.section == 1 {
                taskToBeDeleted = self.completedTasks[indexPath.row]
            }
            if indexPath.section == 2{
                taskToBeDeleted = self.voted[indexPath.row]
            }
            try! uiRealm.write{
                uiRealm.delete(taskToBeDeleted)
                self.readTasksAndUpateUI()
            }
    }
        let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "❤️ FB msg") { (editAction, indexPath) -> Void in
            
            editAction.backgroundColor = UIColor.blueColor()
            UIButton.appearance().setTitleColor(UIColor.orangeColor(), forState: UIControlState.Normal)
            
            var taskToBeUpdated: Task!
            if indexPath.section == 0{
                taskToBeUpdated = self.openTasks[indexPath.row]
            }
            if indexPath.section == 1{
                taskToBeUpdated = self.completedTasks[indexPath.row]
            }
            if indexPath.section == 2{
                taskToBeUpdated = self.voted[indexPath.row]
            }
            try! uiRealm.write{
                //taskToBeUpdated.isCompleted = true
                taskToBeUpdated.isCompleted = false
                taskToBeUpdated.hasVoted = false
                taskToBeUpdated.isOpen = true
                self.readTasksAndUpateUI()
            }

            self.performSegueWithIdentifier("passNameSegue", sender: self)
            //self.tweet()
        }
        
        let doneAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "🇺🇸 Voted") { (doneAction, indexPath) -> Void in
            UIButton.appearance().setTitleColor(UIColor.orangeColor(), forState: UIControlState.Normal)
            var taskToBeUpdated: Task!
            //var personToBeUpdated: TaskList!
            //personToBeUpdated.fid = ""
            
            
            if indexPath.section == 0{
                taskToBeUpdated = self.openTasks[indexPath.row]
            }
            if indexPath.section == 1{
                taskToBeUpdated = self.completedTasks[indexPath.row]
            }
            if indexPath.section == 2{
                taskToBeUpdated = self.voted[indexPath.row]
            }
            
            try! uiRealm.write{
                taskToBeUpdated.isCompleted = false
                taskToBeUpdated.hasVoted = true
                taskToBeUpdated.isOpen = true
                //personToBeUpdated.voted = "Voted"
                self.readTasksAndUpateUI()
            }
        }
        return [deleteAction, editAction, doneAction]
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if (segue.identifier == "passNameSegue") {
            let svc = segue!.destinationViewController as! WebViewController;
            
            svc.toPass = selectedList.name
            svc.toPass2 = selectedList.fname
            svc.toPass3 = selectedList.lname
        }
    }
}
