//  Copyright © 2015 Egghead Games LLC. All rights reserved.

import UIKit
import MessageUI

class HelpViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var mWebView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let localFilePath = NSBundle.mainBundle().URLForResource("help", withExtension: "html") {
            self.mWebView.loadRequest(NSURLRequest(URL: localFilePath))
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - rotation
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        self.mWebView.reload()
    }
    
    
    func gestureHandler(pGestureRecognizer: UISwipeGestureRecognizer) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    // MARK: - UIWebViewDelegate

    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        let lUrl: NSString = request.URL!.absoluteString
        
        if navigationType == UIWebViewNavigationType.LinkClicked {
            if (lUrl.isEqualToString("http://itunes.apple.com/app/id573935171") ||
                lUrl.isEqualToString("http://itunes.apple.com/app/id866175353") ||
                lUrl.isEqualToString("https://itunes.apple.com/us/app/logic-problems-classic!/id879060318") ||
                lUrl.isEqualToString("http://itunes.apple.com/app/id577100878") ||
                lUrl.isEqualToString("https://www.facebook.com/EggheadGames") ||
                lUrl.isEqualToString("http://eggheadgames.com/acrostics?src=acro-ios") ||
                lUrl.isEqualToString("http://eggheadgames.com?src=acro-ios") ||
                lUrl.isEqualToString("http://eggheadgames.com/?src=acro-ios") ||
                lUrl.isEqualToString("http://www.puzzlebaron.com")) {
                    UIApplication.sharedApplication().openURL(request.URL!)
                    return false
            }
            else if (lUrl.hasPrefix("mailto")) {
                let lMailController: MFMailComposeViewController = MFMailComposeViewController()
                lMailController.mailComposeDelegate = self;
                lMailController.setToRecipients(["support@eggheadgames.com"])
                lMailController.setSubject("Acrostics question (ipad)")
                self.presentViewController(lMailController, animated: true, completion: nil)
                return false
            }
        }
        
        return true
    }
    
    // MARK: - MFMailComposeViewController delegate

    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        switch result {
        case MFMailComposeResultSent:
            let lAlertSent: UIAlertController = UIAlertController(title: nil, message: "Message sent", preferredStyle: UIAlertControllerStyle.Alert)
            lAlertSent.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(lAlertSent, animated: true, completion: nil)
            break;
        case MFMailComposeResultFailed:
            let lAlertFailed: UIAlertController = UIAlertController(title: nil, message: "Message failed", preferredStyle: UIAlertControllerStyle.Alert)
            lAlertFailed.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(lAlertFailed, animated: true, completion: nil)
            break;
        default:
            break;
        }
    }
}
