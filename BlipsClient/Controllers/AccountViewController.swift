//
//  AccountViewController.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-01-27.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController, UserAccountObserver {
    @IBOutlet weak var actionSheetButton: UIBarButtonItem!
    
    private var signInModel: SignInModel?
    private var userSignedIn = false
    private var userIsGuest = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        actionSheetButton.isEnabled = userSignedIn
    }

    func userLoggedIn(account: User) {
        actionSheetButton.isEnabled = true
        userSignedIn = true
        userIsGuest = account.isGuest()
    }
    
    func userLoggedOut() {
        actionSheetButton.isEnabled = false
        userSignedIn = false
    }
    
    func guestReplaced() {
        let alert = UIAlertController(title: "Save Guest History and Options", message: "Do you want to merge your history and options with the guest account's history and options?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in self.signInModel?.mergeGuestHistory() }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { _ in return }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func setSignInModel(signInModel: SignInModel) {
        self.signInModel = signInModel
    }
    
    @IBAction func presentActionSheet(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let clearHistoryAction = UIAlertAction(title: "Clear History and Settings", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.signInModel?.clearAttractionHistory()
        })
        
        let logOutAction = UIAlertAction(title: "Log Out", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.signInModel?.userLoggedOut(deleteUser: false)
        })
        
        let deleteAccountAction = UIAlertAction(title: "Delete Account", style: .destructive, handler: { (alert: UIAlertAction!) -> Void in
            self.signInModel?.userLoggedOut(deleteUser: true)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert: UIAlertAction!) -> Void in })
        
        if userIsGuest == false {
            alertController.addAction(logOutAction)
        }
        
        alertController.addAction(clearHistoryAction)
        
        if userIsGuest == false {
            alertController.addAction(deleteAccountAction)
        }
        
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? SignInViewController {
            signInModel!.addUserAccountObserver(observer: destinationVC)
        }
        
        if let optionsVC = segue.destination as? AccountOptionsTableViewController {
            signInModel!.addUserAccountObserver(observer: optionsVC)
        }
        
        super.prepare(for: segue, sender: sender)
    }
}
