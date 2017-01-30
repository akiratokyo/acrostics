//  Copyright © 2015 Egghead Games LLC. All rights reserved.

import UIKit
import MessageUI

class CongratulationViewController: UIViewController {
    
    @IBOutlet weak var titleItem: UINavigationItem!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var quotationLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var hintCountButton: UIButton!
    @IBOutlet weak var statsWrapper: UIView!
    
    @IBOutlet weak var resultStarView: ResultsStarView!
    
    @IBOutlet weak var quotationLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var questionLabelTop: NSLayoutConstraint!
    @IBOutlet weak var resultHeight: NSLayoutConstraint!
    @IBOutlet weak var hintWrapperBottom: NSLayoutConstraint!
    
    var level: DBLevel?
    
    private let praiseList = ["That's the way!", "Woohoo!", "Amazing!", "Good work!", "Congratulations!", "Good going!", "Well done!", "Bravo!"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preferredContentSize = CGSizeMake(500, 700)
        
        self.titleItem.title = praiseList[Int(arc4random_uniform(UInt32(praiseList.count)))]
        
        self.quotationLabel.text = self.level!.dbQuotation
        self.authorLabel.text = NSString(format: "— %@\n%@", self.level!.dbAuthor, self.level!.dbSource) as String
        
        let timeTaken: Double? = self.level?.dbCurrentTime.doubleValue
        let averageTime: Double? = self.level?.dbAverageTime.doubleValue
        self.resultStarView.set(averageTime: averageTime!, timeTaken: timeTaken!)
        
        self.hintCountButton.setTitle(self.level!.dbHints.stringValue, forState: UIControlState.Normal)
        
        //add gesture recognizer
        let lSwipeGestureRecognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer()
        lSwipeGestureRecognizer.addTarget(self, action: Selector("backToGamePlayVC"))
        lSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(lSwipeGestureRecognizer)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        Appirater.appLaunched(true)
        Appirater.setAppId("580847667")
        Appirater.setDaysUntilPrompt(1)
        Appirater.setUsesUntilPrompt(10)
        Appirater.setSignificantEventsUntilPrompt(-1)
        Appirater.setTimeBeforeReminding(2)
        Appirater.setDebug(false)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.resultStarView.updateAnimated()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.backToGamePlayVC()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.doneButton.hidden = UIScreen.mainScreen().bounds.size.height > self.view.frame.size.height
        
        let width: CGFloat = CGRectGetWidth(self.view.frame)
        
        let lMaxSize: CGSize = CGSizeMake(width * 648 / 768, 1000)
        let lExpectedSize: CGSize = (self.quotationLabel.text! as NSString).boundingRectWithSize(lMaxSize, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:self.quotationLabel.font], context: nil).size
        self.quotationLabelHeight.constant = lExpectedSize.height + 10;
        
        
        if (width < 420) {
            self.questionLabelTop.constant = 20;
            self.hintWrapperBottom.constant = 30;
            self.resultHeight.constant = (width - 40) / 2;
        }
        else {
            self.questionLabelTop.constant = 60;
            self.hintWrapperBottom.constant = 60;
            self.resultHeight.constant = 215;
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func backToGamePlayVC() {
        self.performSegueWithIdentifier(Segue_UnwindToGamePlayViewController, sender: nil)
    }
    
    @IBAction func tapDoneButton(sender: UIButton) {
        self.backToGamePlayVC()
    }
}
