//
//  Copyright © 2015 Egghead Games LLC. All rights reserved.
//

import UIKit

@IBDesignable @objc public class ResultsStarView: UIView {
    @IBInspectable public var mainColor: UIColor! = UIColor.blackColor() {
        didSet {
            update(withColor: mainColor)
        }
    }
    @IBOutlet private var timeTakenLabel: UILabel!
    @IBOutlet private var averageTimeLabel: UILabel!
    @IBOutlet private var slider: UISlider!
    @IBOutlet private var centerSeparator: UIView!
    private var timeTaken = 0.0
    
    var view: UIView!

    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    public func set(averageTime averageTime: Double, timeTaken: Double) {
        averageTimeLabel.text = stringAsHHMM(averageTime)
        let maximumValue = Float(averageTime * 2.0)
        slider.maximumValue = maximumValue
        timeTakenLabel.text = stringAsHHMM(timeTaken)
        self.timeTaken = timeTaken
    }
    
    public func updateAnimated() {
        var value = slider.maximumValue
        if timeTaken > 20 {
            value -= Float(timeTaken)
        }
        UIView.animateWithDuration(2,
            delay: 0,
            usingSpringWithDamping: 0.3,
            initialSpringVelocity: 0.4,
            options: UIViewAnimationOptions.CurveEaseInOut,
            animations: { () -> Void in
                self.slider.setValue(value, animated: true)
            }, completion: nil)
    }
    
    private func stringAsHHMM(seconds: Double) -> String {
        guard seconds > 0 else {
            return ""
        }
        let mins = Int(seconds / 60.0)
        return String.localizedStringWithFormat("%02d:%02d", mins, Int(seconds) - (mins * 60))
    }
    
    private func commonInit() {
        xibSetup()
        let starImage = UIImage(named: "star")
        slider.setThumbImage(starImage, forState: .Normal)
        update(withColor: mainColor)
    }
    
    private func update(withColor color: UIColor) {
        slider.maximumTrackTintColor = color
        averageTimeLabel.textColor = color
        timeTakenLabel.backgroundColor = color
        centerSeparator.backgroundColor = color
    }
    
    private func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        self.addSubview(view)
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "ResultsStarView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        return view
    }
    
}
