//
//  LoginViewController.swift
//  SymondsStudentApp
//
//  Created by Søren Mortensen on 17/03/2017.
//  Copyright © 2017 Søren Mortensen, George Taylor. All rights reserved.
//

import UIKit

/// Displays a login page to the user.
internal class LoginViewController: UIViewController, UIWebViewDelegate {
    
    // MARK: - Properties
    
    /// The web view that displays the login page to the user.
    @IBOutlet weak var webView: UIWebView!
    
    /// An activity indicator that displays the loading state of the web view.
    private weak var activityIndicator: UIActivityIndicatorView?
    
    // MARK: - Functions
    
    /// Called when the cancel button is tapped.
    @IBAction internal func cancelTapped(_ sender: UIBarButtonItem) {
        self.unwindToSplash()
    }
    
    /// Completion callback for when an authorisation code is recieved from the Data Service.
    internal func codeRecievedCompletion() {
        self.unwindToSplash()
    }
    
    /// Performs an unwind segue back to the splash screen.
    private func unwindToSplash() {
        self.performSegue(withIdentifier: "Splash", sender: nil)
    }
    
    // MARK: - Initialisers
    
    /// :nodoc:
    deinit {
        // swiftlint:disable:next force_cast
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.loginViewController = nil
    }
    
    // MARK: - UIViewController
    
    /// :nodoc:
    override internal func viewDidLoad() {
        super.viewDidLoad()
        
        // swiftlint:disable:next force_cast
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.loginViewController = self
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        self.navigationItem.setRightBarButton(
            UIBarButtonItem(customView: activityIndicator),
            animated: false)
        self.activityIndicator = activityIndicator
        
        webView.delegate = self
        webView.loadRequest(URLRequest(url: DataService.shared.getAccessTokenURL))
    }
    
    // MARK: - UIWebViewDelegate
    
    /// :nodoc:
    internal func webViewDidStartLoad(_ webView: UIWebView) {
        self.activityIndicator?.startAnimating()
    }
    
    /// :nodoc:
    internal func webViewDidFinishLoad(_ webView: UIWebView) {
        self.activityIndicator?.stopAnimating()
    }
    
}
