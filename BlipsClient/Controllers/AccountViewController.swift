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
    
    private var signInVC: SignInViewController?
    private var signInModel: SignInModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /*if signInModel!.isUserLoggedIn() == false {
            loadUser()
        }
        
        actionSheetButton.isEnabled = signInModel!.isUserLoggedIn()*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setSignInModel(inSignInModel: SignInModel) {
        self.signInModel = inSignInModel
    }
    
    func getSignInStatus() -> Bool {
        return signInModel!.isUserLoggedIn()
    }
    
    func userLoggedIn(account: User) {
        actionSheetButton.isEnabled = true
        
    }
    
    func userLoggedOut() {
        actionSheetButton.isEnabled = false
    }
    
    @IBAction func presentActionSheet(_ sender: UIBarButtonItem) {
        let guestStatus: Bool = signInModel?.userIsGuest() ?? false
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let clearHistoryAction = UIAlertAction(title: "Clear History", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.signInModel!.clearAttractionHistory()
        })
        
        let logOutAction = UIAlertAction(title: "Log Out", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.signInModel!.userLoggedOut(deleteUser: false)
        })
        
        let deleteAccountAction = UIAlertAction(title: "Delete Account", style: .destructive, handler: { (alert: UIAlertAction!) -> Void in
            self.signInModel!.userLoggedOut(deleteUser: true)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert: UIAlertAction!) -> Void in })
        
        if guestStatus == false {
            alertController.addAction(logOutAction)
        }
        
        alertController.addAction(clearHistoryAction)
        
        if guestStatus == false {
            alertController.addAction(deleteAccountAction)
        }
        
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func loadUser() {
        signInModel!.userLoaded(loaded: NSKeyedUnarchiver.unarchiveObject(withFile: User.ArchiveURL.path) as? User ?? nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /*if let destinationVC = segue.destination as? SignInViewController {
            signInVC = destinationVC
            signInModel!.addUserAccountObserver(observer: destinationVC)
            
            if signInModel!.isUserLoggedIn() {
                destinationVC.userLoggedIn(account: signInModel!
                    .getAccount())
            }
            else {
                destinationVC.userLoggedOut()
            }
        }*/
        
        super.prepare(for: segue, sender: sender)
    }
}
