//
//  CRPackageCell.m
//  Cryptograms
//
//  Copyright (c) 2015 Egghead Games LLC. All rights reserved.
//


#import "ACPackageCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation ACPackageCell
@synthesize price;

-(void)awakeFromNib{
    [self.layer setBorderColor:[[UIColor blackColor] CGColor]];
}

#pragma mark - Global
- (void)setPackageInfo:(DBPackage*)pPackage indexPath:(NSIndexPath*)indexPath {
    if (pPackage) {
        
        mNameLabel.text = [pPackage.dbName hasPrefix:@"Acrostics: "] ? [pPackage.dbName substringFromIndex:@"Acrostics: ".length] : pPackage.dbName;
        
        if ([pPackage.dbIsEnable boolValue]) {
            mPlayGameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            mPlayGameButton.selected = YES;
        } else {
            mPlayGameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            mPlayGameButton.selected = NO;
            mPlayGameButton.tag = indexPath.row;
            if (price != nil) {
                [mPlayGameButton setTitle:[NSString stringWithFormat:@"%@", price] forState:UIControlStateNormal];
            } else {
                [mPlayGameButton setTitle:@"BUY" forState:UIControlStateNormal];
            }
        }
    }
}

@end
