//
//  SplashViewController.swift
//  SymondsStudentApp
//
//  Created by Søren Mortensen on 14/03/2017.
//  Copyright © 2017 Søren Mortensen, George Taylor. All rights reserved.
//

import UIKit

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
        DataService.shared.authenticateFromSavedDetails { error in
            // Check if authentication was successful.
            if let _ = error {
                // Authentication was unsuccessful.
                DispatchQueue.main.async {
                    // Show the view controller containing the web view for login.
                    self.initiateLogin()
                }
            } else {
                // Authentication was successful!
                DispatchQueue.main.async {
                    // Show the timetable view controller.
                    self.segueToMainView()
                }
            }
        }
    }

    /// Unwind segue from `LoginViewController`.
    ///
    /// - Parameter sender: The sender of the action.
    @IBAction internal func unwindFromLogin(_ sender: UIStoryboardSegue) {
        self.activityIndicator.stopAnimating()
        self.loginButton.isHidden = false
    }

    /// Completion handler for when an authorisation code exchange has completed.
    ///
    /// - Parameters:
    ///   - result: The result of the exchange.
    ///   - error: The error, if one occurred.
    internal func codeExchangeCompletion(_ result: DataService.AuthenticationResult?,
                                         _ error: DataService.Error?) {
        guard error == nil else {
            self.loginFailedLabel.isHidden = false
            return
        }

        self.segueToMainView()
    }

    /// Segues to an instance of `LoginViewController` to initiate the login process.
    private func initiateLogin() {
        self.performSegue(withIdentifier: "Login", sender: nil)
    }

    /// Segues to the main view when the login process has completed successfully.
    private func segueToMainView() {

    }

    // MARK: - Initialisers

    /// :nodoc:
    deinit {
        // swiftlint:disable:next force_cast
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.splashViewController = nil
    }

    // MARK: - UIViewController

    /// :nodoc:
    override internal func viewDidLoad() {
        super.viewDidLoad()

        // swiftlint:disable:next force_cast
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.splashViewController = self

        // Round the corners of the login button a little bit.
        loginButton.layer.cornerRadius = 5
        // If this property isn't set to true, the button won't look right at
        // the rounded corners.
        loginButton.clipsToBounds = true
    }

    /// :nodoc:
    override internal var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}
