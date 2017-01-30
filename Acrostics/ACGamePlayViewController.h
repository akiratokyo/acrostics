//
//  ACGamePlayViewController.h
//  Acrostics
//
//  Created by roman.andruseiko on 11/9/12.
//  Copyright (c) 2012 Vakoms. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ACGameBoard;
@interface ACGamePlayViewController : UIViewController{
    IBOutlet ACGameBoard *mGameBoard;
    IBOutlet UIButton *mBackButton;
    IBOutlet UIButton *mOptionsButton;
}

- (IBAction)backPressed;
- (IBAction)optionsPressed;

@end
