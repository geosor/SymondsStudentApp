//
//  SplashViewController.swift
//  SymondsStudentApp
//
//  Created by Søren Mortensen on 14/03/2017.
//  Copyright © 2017 Søren Mortensen, George Taylor. All rights reserved.
//

import UIKit
import SSACore

/// Displays a title and a login button to the user.
///
/// This is the first view controller that is presented to the user upon opening app.
internal class SplashViewController: UIViewController {
    
    // MARK: - Properties
    
    /// A button that the user can tap to move on to the login screen.
    @IBOutlet internal weak var loginButton: UIButton!
    
    /// An indicator to show the user that a network request is ongoing.
    @IBOutlet internal weak var activityIndicator: UIActivityIndicatorView!
    
    /// A label displayed to inform the user that their login has failed.
    @IBOutlet internal weak var loginFailedLabel: UILabel!
    
    // MARK: - Functions
    
    /// Initiates the login process by performing a segue to a `LoginViewController`.
    ///
    /// This method is called when the login button is tapped.
    ///
    /// - Parameter sender: The sender of the IBAction.
    @IBAction internal func login(_ sender: UIButton) {
        self.indicateLoginFailed(false)
        self.indicateProgress(true)
        
        let userAuthenticator = UserAuthenticator()
        
        // swiftlint:disable:next force_cast
        let appDelegate = UIApplication.shared.delegate! as! AppDelegate
        appDelegate.userAuthenticator = userAuthenticator
        
        // swiftlint:disable:next force_try
        try! userAuthenticator.registerCompletion(for: .authorizationCode, completion: self.codeRecievedCompletion)
        
        let url = LoginService(keys: Keys.shared!).getAccessTokenURL
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    /// Completion callback for when an authorisation code is recieved from the Data Service.
    internal func codeRecievedCompletion() {
        self.indicateProgress(false)
        
        guard let keys = Keys.shared else {
            print("Could not retrieve keys when attempting to initate access token exchange.")
            self.indicateLoginFailed(true)
            return
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let userAuthenticator = appDelegate.userAuthenticator else {
            print("Could not retrieve user authenticator when attempting to initiate access token exchange.")
            self.indicateLoginFailed(true)
            return
        }
        
        guard let authCode = userAuthenticator.authorizationCode else {
            print("Could not retrieve authorization code when attempting to initiate access token exchange.")
            self.indicateLoginFailed(true)
            return
        }
        
        self.indicateProgress(true)
        LoginService(keys: keys).retrieveAccessToken(authCode,
                                                     grantType: .authorisationCode,
                                                     completion: self.accessTokenCompletion(_:))
    }
    
    /// Completion handler for when an authorisation code exchange has completed.
    ///
    /// - Parameters:
    ///   - result: The result of the exchange.
    internal func accessTokenCompletion(_ result: LoginService.Result<LoginService.AccessToken>) {
        self.indicateProgress(false)
        
        switch result {
        case .success(let token):
            DispatchQueue.main.async {
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                    let userAuthenticator = appDelegate.userAuthenticator else {
                    print("Could not retrieve user authenticator when attempting to register access token.")
                    self.indicateLoginFailed(true)
                    return
                }
                
                do {
                    try userAuthenticator.receiveAccessToken(token)
                    UserService(accessToken: token).makeRequest(completion: self.userDetailsCompletion(_:))
                } catch {
                    print(error)
                    self.indicateLoginFailed(true)
                }
            }
        case .error(let error):
            print(error)
            self.indicateLoginFailed(true)
        }
    }
    
    /// Completion handler for when a user details request has completed.
    ///
    /// - Parameter result: The result of the request.
    internal func userDetailsCompletion(_ result: UserService.Result<UserService.UserDetails>) {
        switch result {
        case .success(let details):
            DispatchQueue.main.async {
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                    let userAuthenticator = appDelegate.userAuthenticator else {
                        print("Could not retrieve user authenticator when attempting to register user details.")
                        self.indicateLoginFailed(true)
                        return
                }
                
                do {
                    try userAuthenticator.receiveUserDetails(details, forUserOfType: PrimaryUser.self)
                    let user = try userAuthenticator.getUser() as! PrimaryUser // swiftlint:disable:this force_cast
                    PrimaryUser.loggedIn = user
                    self.segueToMainView()
                } catch {
                    print(error)
                    self.indicateLoginFailed(true)
                }
            }
        case .error(let error):
            print(error)
            self.indicateLoginFailed(true)
        }
    }
    
    /// Segues to the main view when the login process has completed successfully.
    private func segueToMainView() {
        // Get a reference to the animations queue.
        let animationsQueue = DispatchQueue(label: "Animations")
        // Send a block to the animations queue, so that it doesn't execute before any other animations.
        animationsQueue.sync { [unowned self] in
            // Send the block from the animations queue to the main queue, because this block performs UI updates and
            // should not be called from a background thread.
            DispatchQueue.main.async { [unowned self] in
                // Segue to the main view.
                self.performSegue(withIdentifier: "Main", sender: nil)
            }
        }
    }
    
    /// Indicates to the user that an operation is in progress.
    ///
    /// - Parameter indicate: Determines whether to show progress or stop showing progress.
    private func indicateProgress(_ indicate: Bool) {
        DispatchQueue.main.async {
            // Hide/show the login button.
            self.loginButton.isHidden = indicate
            
            if indicate {
                // Start animating the activity indicator.
                self.activityIndicator.startAnimating()
            } else {
                // Stop animating the activity indicator.
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    /// Indicates to the user that a login attempt failed.
    ///
    /// - Parameter indicate: Determines whether to show the failure message or hide it.
    private func indicateLoginFailed(_ indicate: Bool) {
        DispatchQueue.main.async {
            self.loginFailedLabel.isHidden = !indicate
        }
    }
    
    // MARK: - UIViewController
    
    /// :nodoc:
    override internal func viewDidLoad() {
        super.viewDidLoad()
        
        // Round the corners of the login button a little bit.
        loginButton.layer.cornerRadius = 5
        // If this property isn't set to true, the button won't look right at the rounded corners.
        loginButton.clipsToBounds = true
    }
    
    /// :nodoc:
    override internal var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
