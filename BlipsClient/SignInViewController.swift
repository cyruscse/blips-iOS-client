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
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var profilePicture: UIImageView!     // Initially should show generic user picture
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    private var signInModel: SignInModel!
    
    func setSignInModel(signInModel: SignInModel) {
        self.signInModel = signInModel
    }
    
    func userLoggedIn(account: User) {
        signInButton.isHidden = true
        logOutButton.isHidden = false
        
        // Need to center these
        nameLabel.text = account.getName()
        nameLabel.sizeToFit()
        
        emailLabel.text = account.getEmail()
        emailLabel.sizeToFit()
    }
    
    @IBAction func logOutPressed(_ sender: Any) {
        logOutButton.isHidden = true
        nameLabel.text = ""
        emailLabel.text = ""
        
        GIDSignIn.sharedInstance().signOut()
        signInButton.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        GIDSignIn.sharedInstance().uiDelegate = self
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
