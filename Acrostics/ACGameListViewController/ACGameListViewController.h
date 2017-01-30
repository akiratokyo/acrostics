//
//  ACGameListViewController.h
//  Acrostics
//
//  Created by Ivan Podibka on 11/8/12.
//  Copyright (c) 2012 A Gamz LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ACPackageViewController;

@interface ACGameListViewController : UIViewController {
    
    NSMutableArray*     mLevelsDataSource;
}

@property (strong, nonatomic) ACPackageViewController* parentVC;

@property (nonatomic) NSInteger packageIndex;
@property (nonatomic) BOOL isFromList;

@property (nonatomic, retain) DBPackage *package;
@property (nonatomic, retain) DBLevel *level;


@end
