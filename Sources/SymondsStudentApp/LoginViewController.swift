//
//  LoginViewController.swift
//  SymondsStudentApp
//
//  Created by Søren Mortensen on 17/03/2017.
//  Copyright © 2017 Søren Mortensen, George Taylor. All rights reserved.
//

import UIKit
import SSACore

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
    
    // MARK: - UIViewController
    
    /// :nodoc:
    override internal func viewDidLoad() {
        super.viewDidLoad()
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        self.navigationItem.setRightBarButton(
            UIBarButtonItem(customView: activityIndicator),
            animated: false)
        self.activityIndicator = activityIndicator
        
        webView.delegate = self
        let url = LoginService(keys: Keys.shared!).getAccessTokenURL
        webView.loadRequest(URLRequest(url: url))
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

