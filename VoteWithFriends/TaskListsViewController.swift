//
//  TaskListsViewController.swift
//
//
//  Created by Matt and Emma Miszewski
//  Copyright © 2016+ Emma Miszewski. All rights reserved.
//


import UIKit
import RealmSwift
import BWWalkthrough
import Contacts
import ContactsUI

@available(iOS 9.0, *)
class TaskListsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FBSDKLoginButtonDelegate, BWWalkthroughViewControllerDelegate {

    var lists : Results<TaskList>!
    var tasks2 : Results<Task>!
    var isEditingMode = false
    var currentCreateAction:UIAlertAction!
    // Run Once
    var token: dispatch_once_t = 0
    // Contacts
    var contactStore = CNContactStore()
    var myContacts = [CNContact]()
    var notificationToken: NotificationToken!
    var realm: Realm!
    
    //All Actions here Disconnected
    @IBOutlet weak var taskListsTableView: UITableView!
    @IBOutlet weak var navigationTitle: UINavigationItem!
    @IBOutlet weak var webView: UIWebView!
    @IBAction func backAction(sender: AnyObject) {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    @IBAction func forwardAction(sender: AnyObject) {
        if webView.canGoForward {
            webView.goForward()
        }
    }
    @IBAction func refreshAction(sender: AnyObject) {
        webView.reload()
    }
    @IBAction func stopAction(sender: AnyObject) {
        webView.stopLoading()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.readTasksAndUpdateUI()
        
        lists = uiRealm.objects(TaskList)
        if lists.isEmpty == true{
            showWalkthrough()
            }
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setupRealm()
        
        let backgroundImage = UIImage(named: "HRC")?.resizableImageWithCapInsets(UIEdgeInsetsMake(0, 0, 0, 0), resizingMode: .Stretch)
        self.navigationController?.navigationBar.setBackgroundImage(backgroundImage, forBarMetrics: .Default)
        // Getting Contacts
        lists = uiRealm.objects(TaskList)
        if lists.isEmpty == true{
            requestForAccess { (accessGranted) -> Void in
                if accessGranted {
                    // Fetch contacts from address book
                    let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactEmailAddressesKey, CNContactPhoneNumbersKey]
                    let containerId = CNContactStore().defaultContainerIdentifier()
                    let predicate: NSPredicate = CNContact.predicateForContactsInContainerWithIdentifier(containerId)
                    do {
                        self.myContacts = try CNContactStore().unifiedContactsMatchingPredicate(predicate, keysToFetch: keysToFetch)
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            let contactFriends = self.myContacts as NSArray
                            var count = 1
                            for contact in contactFriends {
                                var fname = ""
                                fname = contact.givenName
                                var lname = ""
                                lname = contact.familyName
                                var phone = ""
                                for number in contact.phoneNumbers {
                                    guard let numberValue = number.value as? CNPhoneNumber else {
                                        continue
                                    }
                                    phone = (String(numberValue.stringValue.characters.filter({ !["-", "(", ")"].contains($0) })))
                                }
                                let fid = NSUUID().UUIDString
                                //let fid = "1"
                                let completeName = ((fname) as! String) + (" ") + ((lname) as! String)
                                let uniqueID = (fid)
                                
                                let newTaskList = TaskList()
                                newTaskList.fname = (fname as! String)
                                newTaskList.lname = (lname as! String)
                                newTaskList.name = (completeName as String)
                                newTaskList.phone = (phone as! String)
                                newTaskList.fid = (fid as String)

                                try! uiRealm.write{
                                    uiRealm.add(newTaskList)
                                    print("Should Create Realm Update in ROS")
                                }
                            }
                        })
                    } catch _ {
                        print("Error retrieving contacts")
                    }
                }
            }
            
        }
        setupRealm()
        // for swift 2.0 Xcode 7
        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }

    override func viewDidAppear(animated: Bool) {
        
        //Updates the view immediately
        self.readTasksAndUpdateUI()
    }

    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }

    func requestForAccess(completionHandler:(accessGranted : Bool) -> Void)
    {
        let authorizationStatus = CNContactStore.authorizationStatusForEntityType(.Contacts)
        switch authorizationStatus {
        case .Authorized:
            completionHandler(accessGranted: true)
        case .Denied, .NotDetermined:
            self.contactStore.requestAccessForEntityType(.Contacts, completionHandler: { (access, accessError) -> Void in
                if access {
                    completionHandler(accessGranted: access)
                }
                else {
                    if authorizationStatus == .Denied {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            let message = "\(accessError!.localizedDescription)\n\nPlease allow the app to access your contacts through the Settings. VoteWithFriends can't work without it."
                            self.showMessage(message)
                        })
                    }
                }
            })
        default:
            completionHandler(accessGranted: false)
        }
    }


//    //In another Swift file...
//    func setupRealm2(user: SyncUser){
//        // Create the configuration
//
//        let realmURL = NSURL(string: "realm://emmabiz.com:9080/~/VWF")
//
//        Realm.Configuration.defaultConfiguration = Realm.Configuration(syncConfiguration: SyncConfiguration(user: user, realmURL: realmURL!))
//
//        // Open the Realm
//        _ = try! Realm()
//    }

    
//    func setupRealm() {
//        //AuthForm.swift
//        let signUpCredentials = SyncCredentials.usernamePassword("mattmiszewski@gmail.com", password: "Psmor0xx", register: true)
//        let serverURL = "http://emmabiz.com:9080"
//        let username = "mattmiszewski@gmail.com"
//        let password = "Psmor0xx"
//
//        SyncUser.logInWithCredentials(SyncCredentials.usernamePassword(username, password: password), authServerURL: NSURL(string: "http://emmabiz.com:9080")!, onCompletion: { user, error in
//            guard let user = user else {
//                fatalError(String(error))
//            }
//           self.setupRealm2(user)
//        })
//    }
        
        
    
//    func setupRealmOLD() {
//        // Log in existing user with username and password
//        let username = "mattmiszewski@gmail.com"
//        let password = "Psmor0xx"

//        SyncUser.logInWithCredentials(SyncCredentials.usernamePassword(username, password: password), authServerURL: NSURL(string: "http://emmabiz.com:9080")!, onCompletion: { user, error in
//            guard let user = user else {
//                fatalError(String(error))
//            }
//            //Open Realm
//            let configuration = Realm.Configuration(
//                syncConfiguration: SyncConfiguration(user: user, realmURL: NSURL(string: "realm://emmabiz.com:9080/~/VWF")!)
//            )
//            self.realm = try! Realm(configuration: configuration)
//            print("Realm Setup Occured")

            // Notify us when Realm changes

            /*self.notificationToken = self.realm.addNotificationBlock { _ in
                print("Realm Update Occured")
            }*/
//        })
//    }

    //    deinit {
//        notificationToken.stop()
//    }

    
    func setupRealm() {
        // Authenticating the User
        let username = "mattmiszewski@gmail.com"
        let password = "Psmor0xx"
        SyncUser.logInWithCredentials(SyncCredentials.usernamePassword(username, password: password), authServerURL: NSURL(string: "http://emmabiz.com:9080")!, onCompletion:
        { user, error in
            if let user = user {
                // Opening a remote Realm
                let realmURL = NSURL(string: "realm://emmabiz.com:9080/~/VWF3")!
                let config = Realm.Configuration(syncConfiguration: SyncConfiguration(user: user, realmURL: realmURL))
                let uiRealm = try! Realm(configuration: config)
                // Any changes made to this Realm will be synced across all devices!
            } else if let error = error {
                // handle error
            }
        })
    }
    
    
    
    
    func showWalkthrough(){
        
        dispatch_once(&token) {
        let stb = UIStoryboard(name: "Main", bundle: nil)
        let walkthrough = stb.instantiateViewControllerWithIdentifier("container") as! BWWalkthroughViewController
        let page_one = stb.instantiateViewControllerWithIdentifier("page1") as UIViewController
        let page_two = stb.instantiateViewControllerWithIdentifier("page2") as UIViewController
        let page_three = stb.instantiateViewControllerWithIdentifier("page3") as UIViewController
        
        // Attach the pages to the master
        walkthrough.delegate = self
        walkthrough.addViewController(page_one)
        walkthrough.addViewController(page_two)
        walkthrough.addViewController(page_three)
        
        self.presentViewController(walkthrough, animated: true, completion: nil)
        }
        navigationController?.popToRootViewControllerAnimated(true)
        print("At End of Wlkthru")
    }

    func showMessage(message: String) {
        let alert = UIAlertController(title: "MyContacts", message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func fetchContacts()  {
            let contactFriends = self.myContacts as NSArray
            var count = 1
        
        for contact in contactFriends {
                    var fname = ""
                    fname = contact.givenName
                    var lname = ""
                    lname = contact.familyName
                    let fid = NSUUID().UUIDString
                    let completeName = ((fname) as! String) + (" ") + ((lname) as! String)
                    let uniqueID = (fid)
                    //write name and fid to Realm
                    let newTaskList = TaskList()
                    newTaskList.fname = (fname as! String)
                    newTaskList.lname = (lname as! String)
                    newTaskList.name = (completeName as String)
                    newTaskList.fid = (fid as String)
                    try! uiRealm.write{
                        uiRealm.add(newTaskList)
                        self.readTasksAndUpdateUI()
                    }
        }
}

//  FB Profile Subroutine
//    func fetchProfile()  {
//        print("in fetchProfile function") //Print success to Console
//        let parameters = ["fields": "id, email, first_name, last_name, picture"]
//        FBSDKGraphRequest(graphPath: "me/taggable_friends", parameters: parameters).startWithCompletionHandler { (connection, result, error) -> Void in
//            if error != nil {
//                print(error)
//                return
//            }
            //attempt to switch
            //let CNFriends = self.myContacts as NSArray
            //print(CNFriends.count)
//            let friends = result.valueForKey("data") as! NSArray
//            var count = 1
            //gets taggable friends, puts in array, constructs full name, pulls fid
//            if let array = friends as? [NSDictionary] {
//                print("made it BEFORE array")
//                for friend : NSDictionary in array {
//                    print("Made it to array")
//                    let fname = friend.valueForKey("first_name") as! NSString
//                    let lname = friend.valueForKey("last_name") as! NSString
//                    //let fid = 1 as! NSString
//                    let fid = friend.valueForKey("id") as! NSString
//                    let completeName = (fname as String) + (" ") + (lname as String) as NSString
//                    let uniqueID = (fid as String) as NSString
//                    print(completeName)
//                    print(fname)
//                    count++
//                    //write name and fid to Realm
//                    let newTaskList = TaskList()
//                    newTaskList.fname = (fname as String)
//                    newTaskList.lname = (lname as String)
//                    newTaskList.name = (completeName as String)
//                    newTaskList.fid = (uniqueID as String)
//                    try! uiRealm.write{
//                        uiRealm.add(newTaskList)
//                        self.readTasksAndUpdateUI()
//                    }
//                }
//            }
//        }
//    }


//Define FB Login Button Functions (not used as FB turned off)
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
    }
    
    func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }
    
    //Main Update Subroutine
    func readTasksAndUpdateUI(){
        lists = uiRealm.objects(TaskList)
        print(lists)
        self.taskListsTableView.setEditing(false, animated: true)
        self.taskListsTableView.reloadData()
    }
    
    // MARK: - User Actions - Sort Subroutines
    @IBAction func didSelectSortCriteria(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            // A-Z
            self.lists = self.lists.sorted("name")
        }
        else{
            // date
            self.lists = self.lists.sorted("createdAt", ascending:false)
        }
    self.readTasksAndUpdateUI()
}
    
    //  Disabled Main Edit Button
    @IBAction func didClickOnEditButton(sender: UIBarButtonItem) {
        isEditingMode = !isEditingMode
        self.taskListsTableView.setEditing(isEditingMode, animated: true)
    }
    
    //  Disabled Add Button
    @IBAction func didClickOnAddButton(sender: UIBarButtonItem) {
        displayAlertToAddTaskList(nil)
    }
    
    //Enable the create action of the alert only if textfield text is not empty
    func listNameFieldDidChange(textField:UITextField){
        self.currentCreateAction.enabled = textField.text?.characters.count > 0
    }
    
    //Alert Popup to Add Voter (Currently disabled)
    func displayAlertToAddTaskList(updatedList:TaskList!){
        var title = "New HRC Voter to Activate"
        var doneTitle = "Create"
        print (updatedList.tasks.count)
        if updatedList != nil{
            title = "Update HRC Voter List"
            doneTitle = "Update"
        }
        let alertController = UIAlertController(title: title, message: "Type Name of Hillary Voter.", preferredStyle: UIAlertControllerStyle.Alert)
        let createAction = UIAlertAction(title: doneTitle, style: UIAlertActionStyle.Default) { (action) -> Void in
            
            let listName = alertController.textFields?.first?.text
            if updatedList != nil{
                // update mode
                try! uiRealm.write{
                    updatedList.name = listName!
                    self.readTasksAndUpdateUI()
                }
            }  else  {
                let newTaskList = TaskList()
                newTaskList.name = listName!
                
                try! uiRealm.write{
                    uiRealm.add(newTaskList)
                    self.readTasksAndUpdateUI()
                }
            }
        }
        
        alertController.addAction(createAction)
        createAction.enabled = false
        self.currentCreateAction = createAction
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Hillary Voter Name"
            textField.addTarget(self, action: #selector(TaskListsViewController.listNameFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
            if updatedList != nil{
                textField.text = updatedList.name
            }
        }
        self.presentViewController(alertController, animated: true, completion: nil)
    }

//Start TableView Sections
    //Number of ROWS in Section
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let listsTasks = lists{
            return listsTasks.count
        }
        
        return 0
    }
    //Can we edit the ROW at IndexPath
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return true
    }
    
    //Cell For Row at IndexPath REVIEW THIS
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("listCell")
        let list2 = lists[indexPath.row]
        var list = CNContact()
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactEmailAddressesKey, CNContactPhoneNumbersKey]
        let contacts = [CNContact]()
        let contactsStore = CNContactStore()
        do {
            try contactsStore.enumerateContactsWithFetchRequest(CNContactFetchRequest(keysToFetch: keys)) {
                (contact, cursor) -> Void in
                if (!contact.phoneNumbers.isEmpty) {
                    let phoneNumberToCompareAgainst = (list2["phone"] as! String).componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet).joinWithSeparator("")
                    for phoneNumber in contact.phoneNumbers {
                        if let phoneNumberStruct = phoneNumber.value as? CNPhoneNumber {
                            let phoneNumberString = phoneNumberStruct.stringValue
                            let phoneNumberToCompare = phoneNumberString.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet).joinWithSeparator("")
                            if phoneNumberToCompare == phoneNumberToCompareAgainst {
                                list = contact
                            }
                        }
                    }
                }
            }
            
            if contacts.count == 0 {
                print("No contacts were found matching the given phone number.")
            }
        }
        catch {
            print("Unable to fetch contacts.")
        }
        
        
        
        //let list = self.myContacts[0]
        tasks2 = uiRealm.objects(Task)

        try! uiRealm.write{
            if list2.tasks.first?.hasVoted == true {
                do {
                    let fullName = list2["name"] as! String //list.givenName + " " + list.familyName
                    //let attributeString = NSMutableAttributedString(string: list.name)
                    let attributeString = NSMutableAttributedString(string: fullName)
                    attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0,attributeString.length))
                    cell?.textLabel?.attributedText = attributeString
                    cell?.detailTextLabel?.text = "VOTED!!"
                }
                catch {}
            } else {
                cell!.textLabel?.attributedText =  nil
                cell?.textLabel?.text = list2["name"] as! String//list.givenName + " " + list.familyName
                
                if list2.tasks.count == 0 {
                    cell?.detailTextLabel?.text = "Activate this Voter"
                } else {
                    cell?.detailTextLabel?.text = "\(list2.tasks.count) Tasks"
                }
            }
        }
        tableView.tableFooterView = UIView(frame: .zero)
        return cell!
    }


    
    //Delete and Edit Actions on Swipe
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .Destructive, title: "😈 Delete") { (deleteAction, indexPath) -> Void in
            let listToBeDeleted = self.lists[indexPath.row]
            try! uiRealm.write{
                uiRealm.delete(listToBeDeleted)
                //_ = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector(self.readTasksAndUpdateUI()), userInfo: nil, repeats: false)
                //tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                self.readTasksAndUpdateUI()
                //self.presentViewController(self.presentingViewController!, animated: true, completion: nil)
            }
        }
        
        
        // Edit Action if you want to add back in; also include the return statement below
        let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "🎯 Edit") { (editAction, indexPath) -> Void in
            editAction.backgroundColor = UIColor.clearColor()
            let listToBeUpdated = self.lists[indexPath.row]
            self.displayAlertToAddTaskList(listToBeUpdated)
        }
        return [deleteAction, editAction]
        
      // return [deleteAction]
        
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("openTasks", sender: self.lists[indexPath.row])
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let tasksViewController = segue.destinationViewController as! TasksViewController
        tasksViewController.selectedList = sender as! TaskList
    }
}
