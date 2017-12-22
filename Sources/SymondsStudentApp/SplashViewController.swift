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
    /// - Parameter sender: The sender of the IBAction.
    @IBAction internal func login(_ sender: UIButton) {
        // This method is called when the login button is tapped.
        
        // Hide the login button.
        self.loginButton.isHidden = true
        // Start animating the activity indicator.
        self.activityIndicator.startAnimating()
        
        // Try to authenticate from details saved in Keychain.
        DataService.shared.authenticateFromSavedDetails { [unowned self] error in
            // Check if authentication was successful.
            if error != nil {
                // Authentication was unsuccessful.
                DispatchQueue.main.async { [unowned self] in
                    // Show the view controller containing the web view for login.
                    self.initiateLogin()
                }
            } else {
                // Authentication was successful!
                DispatchQueue.main.async { [unowned self] in
                    // Show the timetable view controller.
                    self.segueToMainView()
                }
            }
        }
    }
    
    /// Completion callback for when an authorisation code is recieved from the Data Service.
    internal func codeRecievedCompletion() {
        // Get a reference to the animations queue.
        let animationsQueue = DispatchQueue(label: "Animations")
        // Send a block to the animations queue.
        animationsQueue.sync { [unowned self] in
            // Dismiss the LoginViewController.
            self.dismiss(animated: true, completion: nil)
            // Show the login button again.
            self.activityIndicator.stopAnimating()
            self.loginButton.isHidden = false
        }
    }
    
    /// Completion handler for when an authorisation code exchange has completed.
    ///
    /// - Parameters:
    ///   - result: The result of the exchange.
    ///   - error: The error, if one occurred.
    internal func codeExchangeCompletion(_ result: DataService.AccessToken?,
                                         _ error: DataService.Error?) {
        guard error == nil else {
            self.loginFailedLabel.isHidden = false
            return
        }
        
        self.segueToMainView()
    }
    
    /// Segues to an instance of `LoginViewController` to initiate the login process.
    private func initiateLogin() {
        // Get a reference to the animations queue.
        let animationsQueue = DispatchQueue(label: "Animations")
        // Send a block to the animations queue, so that it doesn't execute before any other animations.
        animationsQueue.sync { [unowned self] in
            // Send the block from the animations queue to the main queue, because this block performs UI updates and
            // should not be called from a background thread.
            DispatchQueue.main.async { [unowned self] in
                // Segue to the login view.
                self.performSegue(withIdentifier: "Login", sender: nil)
            }
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
    
    // MARK: - Initialisers
    
    /// :nodoc:
    deinit {
        // Remove the app delegate's reference to this view controller.
        (UIApplication.shared.delegate as? AppDelegate)?.splashViewController = nil
    }
    
    // MARK: - UIViewController
    
    /// :nodoc:
    override internal func viewDidLoad() {
        super.viewDidLoad()
        
        // Give the app delegate a reference to this view controller.
        (UIApplication.shared.delegate as? AppDelegate)?.splashViewController = self
        
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
