//
//  SignInViewController.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-01-20.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class SignInViewController: UIViewController, GIDSignInUIDelegate, UserAccountObserver {
    @IBOutlet weak var signInButton: GIDSignInButton!
    @IBOutlet weak var actionSheetButton: UIBarButtonItem!
    @IBOutlet weak var profilePicture: UIImageView!     // Initially should show generic user picture
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    private var signInModel: SignInModel!
    
    func setSignInModel(signInModel: SignInModel) {
        self.signInModel = signInModel
    }
    
    func userLoggedIn(account: User) {
        signInButton.isHidden = true
        profilePicture.isHidden = false
        actionSheetButton.isEnabled = true
        
        // Need to center these
        nameLabel.text = account.getName()
        nameLabel.sizeToFit()
        nameLabel.center.x = self.view.center.x
        
        emailLabel.text = account.getEmail()
        emailLabel.sizeToFit()
        emailLabel.center.x = self.view.center.x
        
        profilePicture.image = account.getImage()
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width / 2
        profilePicture.layer.borderWidth = 3
        profilePicture.layer.borderColor = UIColor.gray.cgColor
        profilePicture.contentMode = .scaleAspectFill
    }
    
    func logOut() {
        profilePicture.isHidden = true
        actionSheetButton.isEnabled = false
        nameLabel.text = ""
        emailLabel.text = ""
        profilePicture.image = nil
        
        GIDSignIn.sharedInstance().signOut()
        signInButton.isHidden = false
        
        signInModel.userLoggedOut()
    }
    
    @IBAction func presentActionSheet(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let logOutAction = UIAlertAction(title: "Log Out", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.logOut()
        })
        
        let clearHistoryAction = UIAlertAction(title: "Clear History", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            print("need to implement")
        })
        
        let deleteAccountAction = UIAlertAction(title: "Delete Account", style: .destructive, handler: { (alert: UIAlertAction!) -> Void in
            print("need to implement")
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert: UIAlertAction!) -> Void in
            
        })
        
        alertController.addAction(logOutAction)
        alertController.addAction(clearHistoryAction)
        alertController.addAction(deleteAccountAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func loadUser() {
        signInModel.userLoaded(loaded: NSKeyedUnarchiver.unarchiveObject(withFile: User.ArchiveURL.path) as? User ?? nil)
    }
    
    func getSignInStatus() -> Bool {
        return signInModel.isUserLoggedIn()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadUser()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        // Refresh this view if user already logged in
        if (signInModel.isUserLoggedIn() == true) {
            self.userLoggedIn(account: signInModel.getAccount())
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
