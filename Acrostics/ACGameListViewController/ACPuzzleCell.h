//
//  ACPuzzleCell.h
//  Acrostics
//
//  Created by Luokey on 11/4/15.
//  Copyright © 2015 Vakoms. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ACPuzzleCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView* wrapper;
@property (weak, nonatomic) IBOutlet UILabel* mNumberLabel;
@property (weak, nonatomic) IBOutlet UIImageView* mStateImageView;
@property (weak, nonatomic) IBOutlet UIButton* mItemButton;

- (void)setGameItemState:(DBLevel*)lLevel number:(NSInteger)pNumber;


@end
