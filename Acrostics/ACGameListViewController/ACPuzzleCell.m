//
//  ACPuzzleCell.m
//  Acrostics
//
//  Created by Luokey on 11/4/15.
//  Copyright © 2015 Vakoms. All rights reserved.
//

#import "ACPuzzleCell.h"
#import "ACAppDelegate.h"

@implementation ACPuzzleCell


- (void)setGameItemState:(DBLevel*)lLevel number:(NSInteger)pNumber {
    self.mNumberLabel.text = [NSString stringWithFormat:@"%@", @(pNumber)];
    self.mStateImageView.image = [ACAppDelegate getPuzzleStateImage:lLevel];
}


@end