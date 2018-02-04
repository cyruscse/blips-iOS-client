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
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var signInButton: GIDSignInButton!
    
    private var userLoggedIn: Bool = false
    private var account: User?
    
    func updateUIOnLogin() {
        if account?.isGuest() == true {
            nameLabel.text = "Offline Account"
            nameLabel.sizeToFit()
            nameLabel.center.x = self.view.center.x
            
            emailLabel.text = "History is saved on this device only"
            emailLabel.sizeToFit()
            emailLabel.center.x = self.view.center.x
            
            return
        }
        
        signInButton.isHidden = true
        profilePicture.isHidden = false
        
        nameLabel.text = account!.getName()
        nameLabel.sizeToFit()
        nameLabel.center.x = self.view.center.x
        
        emailLabel.text = account!.getEmail()
        emailLabel.sizeToFit()
        emailLabel.center.x = self.view.center.x
        
        profilePicture.image = account!.getImage()
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width / 2
        profilePicture.layer.borderWidth = 3
        profilePicture.layer.borderColor = UIColor.gray.cgColor
        profilePicture.contentMode = .scaleAspectFill
    }
    
    func userLoggedIn(account: User) {
        self.account = account
        userLoggedIn = true
        
        if (signInButton != nil) {
            updateUIOnLogin()
        }
    }
    
    func updateUIOnLogout() {
        profilePicture.isHidden = true
        nameLabel.text = ""
        emailLabel.text = ""
        profilePicture.image = nil
        
        signInButton.isHidden = false
    }
    
    func userLoggedOut() {
        userLoggedIn = false
        
        if self.viewIfLoaded?.window != nil {
            updateUIOnLogout()
        }
    }
    
    func guestReplaced() {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        
        if userLoggedIn {
            updateUIOnLogin()
        }
        else {
            updateUIOnLogout()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
