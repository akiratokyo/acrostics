//
//  ACCrosswordSection.h
//  Acrostics
//
//  Created by Oleg.Sehelin on 13.11.12.
//  Copyright (c) 2012 A Gamz LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ACCrosswordSectionDelegate <NSObject>

- (void)setActiveSectionWithTag:(NSInteger)tag;
- (void)showKeyboard;

@end

@interface ACCrosswordSection : UIView

@property (nonatomic, weak) id<ACCrosswordSectionDelegate> delegate;
@property (nonatomic) BOOL isActive;
@property (nonatomic) BOOL isEnable;

- (id)initWithTitleNumber:(NSInteger)pNumber andTitleLetter:(NSString*)pLetter; 

// set background when select this section
- (void)setSectionActiveState;
// set background when this section has same letter
- (void)setSameSectionSate;

- (void)deselectSection;
- (void)setLetter:(NSString*)pLetter;
- (void)setPunctuation:(NSString*)pPunctuation;
- (void)setGap;

// return letter from righttop corner
- (NSString *)returnCornerLetter;
// return answer letter
- (NSString *)returnAnswerLetter;

- (void)buttonPressed:(id)pSender;

//change size and font for different orientations
- (void)changeFontAndSizeForLandscape:(BOOL)pValue sectionCount:(int)sectionCount;
- (void)changeFontAndSizeForMaxWidth:(CGFloat)maxWidth numberFontSize:(CGFloat)numberFontSize answerFontSize:(CGFloat)answerFontSize;

//change size and font for different portrait orientations
- (void)changeFontAndSizeForAnotherPortrait;

//disable selection for current section
- (void)unactiveSection;

@end
