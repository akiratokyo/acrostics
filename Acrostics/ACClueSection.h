//
//  ACClueSection.h
//  Acrostics
//
//  Created by roman.andruseiko on 11/14/12.
//  Copyright (c) 2012 A Gamz LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ACClueSection;

@protocol ACClueSectionDelegate <NSObject>
- (void)setClueSectionActive:(id)pSection;
- (void)setNeedSelectNumber:(NSString*)pNumber;
- (void)setLetter:(NSString*)pLetter needActiveNext:(BOOL)pNeedActive;
- (void)scrollToSection:(id)pSection;
- (void)showKeyboardForSection:(ACClueSection *)section;
@end

@interface ACClueSection : UIView

@property (nonatomic) NSInteger buttonsCount;
@property (nonatomic) NSInteger index;
@property (nonatomic, weak) id <ACClueSectionDelegate> delegate;
@property (nonatomic) NSInteger buttonIndex;

@property (nonatomic) NSString* maxClue;
@property (nonatomic) NSInteger maxButtonCount;


- (void)initWithClue:(NSString*)pClue answer:(NSString*)pAnswer andQuestion:(NSArray*)pQuestion
            andTitle:(NSString*)pTitle andMaxClue:(NSString*)maxClue andMaxButtonCount:(NSInteger)maxButtonCount;
- (void)changeFontAndSizeForMaxWidth:(CGFloat)maxWidth sectionCount:(NSInteger)sectionCount maxButtonCount:(NSInteger)maxButtonCount decreaseFont:(BOOL)decreaseFont;
- (CGSize)getCurrentSize;
- (void)deselectSection;
- (void)setHighlightForSection;
- (void)solveSection;
- (void)clearSection;
- (void)setSelectedButtonWithTag:(NSInteger)pButtonTag;
- (void)setLetter:(NSString*)pLetter;
- (void)setActiveButtonForNumber:(NSString*)pNumber;
- (void)setActiveButtonForNumberWithoutDraw:(NSString*)pNumber;
- (BOOL)setActiveNextFreeButton:(BOOL)pFromStart;
- (BOOL)setActivePreviousButton:(BOOL)pFromStart;
- (BOOL)removeTitleForIndex:(NSInteger)pIndex;
- (void)removeSelectedTitle;
- (void)setTitle:(NSString*)pTitle forNumber:(NSString*)pNumber;

- (NSString*)getQuestionNumberWith:(NSInteger)index;
@end
