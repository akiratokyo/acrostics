//
//  ACCluesBoard.h
//  Acrostics
//
//  Created by roman.andruseiko on 11/14/12.
//  Copyright (c) 2012 A Gamz LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACClueSection.h"

@protocol ACCluesBoardDelegate <NSObject>
- (void)setCluesBoardSelected:(NSString*)pNumber;
- (void)showKeyboard;
@end

@interface ACCluesBoard : UIScrollView <ACClueSectionDelegate>

@property (nonatomic, weak) id <ACCluesBoardDelegate> mDelegate;
@property (nonatomic) NSInteger selectedSection;
@property (nonatomic) NSInteger selectedButton;

@property (nonatomic) CGFloat maxWidth;
@property (nonatomic) int minSectionCount;
@property (nonatomic) int maxSectionCount;

@property (nonatomic) int decreaseForRegularMode;
@property (nonatomic) int sectionCount;

@property (nonatomic) NSString* maxClue;
@property (nonatomic) NSInteger maxButtonCount;


- (void)initBoardWithClues:(NSArray*)pClues questions:(NSDictionary *)pQuestions andAnswers:(NSArray*)pAnswers maxWidth:(CGFloat)width;
- (void)resetSectionCounts;
- (void)resetCluesParams:(int)diffCount;
//- (void)drawBoard;
- (void)drawBoardWithCompletion:(void (^)())completion;
- (void)setLetter:(NSString*)pLetter needActiveNext:(BOOL)pNeedActive;
- (void)setActiveButtonForNumber:(NSString*)pNumber andDrawGrid:(BOOL)pValue;
- (void)setActiveButtonForSection:(NSInteger)section forButtonIndex:(NSInteger)buttonIndex;
- (void)removeTitleForIndex:(NSInteger)pIndex needActivePrevious:(BOOL)pNeedActive;
- (void)clearBoard;
- (void)clearBoardWithoutSelectionFirstSection;
- (void)setTitle:(NSString*)pTitle forNumber:(NSString*)pNumber;
- (void)solveBoard;
@end
