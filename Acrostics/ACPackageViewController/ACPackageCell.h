//
//  CRPackageCell.h
//  Cryptograms
//
//  Created by Vasyl Sadoviy on 10/31/12.
//  Copyright (c) 2012 A Gamz LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ACPackageCell : UITableViewCell {
    IBOutlet UIView *wrapper;
	IBOutlet UILabel *mNameLabel;
    IBOutlet UIButton *mPlayGameButton;
}

@property (nonatomic) NSString *price;

- (void)setPackageInfo:(DBPackage*)pPackage indexPath:(NSIndexPath*)indexPath;

@end
