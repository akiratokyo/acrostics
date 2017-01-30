//
//  ACGamePlayViewController.h
//  Acrostics
//
//  Created by Oleg.Sehelin on 13.11.12.
//  Copyright (c) 2012 A Gamz LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACCrosswordBoard.h"
#import "ACCluesBoard.h"
#import "ACKeywordBoard.h"

@interface ACGamePlayViewController : UIViewController  <ACCrosswordBoardDelegate, ACCluesBoardDelegate,ACKeywordBoardDelegate, UITextFieldDelegate>

@property (nonatomic, retain) DBLevel *level;

- (IBAction) backPressed;
- (IBAction) optionsButtonPressed:(id)pSender;


@end
