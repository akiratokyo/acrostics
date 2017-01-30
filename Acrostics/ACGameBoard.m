//
//  ACGameBoard.m
//  Acrostics
//
//  Created by roman.andruseiko on 11/9/12.
//  Copyright (c) 2012 Vakoms. All rights reserved.
//

#import "ACGameBoard.h"

@implementation ACGameBoard

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    self.backgroundColor = [UIColor blackColor];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
