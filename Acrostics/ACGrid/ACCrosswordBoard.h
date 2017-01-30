//
//  ACCrosswordBoard.h
//  Acrostics
//
//  Created by Oleg.Sehelin on 13.11.12.
//  Copyright (c) 2012 A Gamz LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACCrosswordSection.h"

@protocol ACCrosswordBoardDelegate <NSObject>
-(void) activeCrosswordSectionWithTag:(NSNumber*)pSectionTag andIsAutomaticRun:(NSNumber*)pIsRun;
-(void) erraseCallForTag:(NSNumber*)pTag;
-(void) makeHitWithLetter:(NSString*)pString andTag:(NSNumber*)pTag;
@end

@interface ACCrosswordBoard : UIView <ACCrosswordSectionDelegate> 

@property (nonatomic) CGFloat maxWidth;
@property (nonatomic) int minSectionCount;
@property (nonatomic) int maxSectionCount;

@property (nonatomic) int decreaseForRegularMode;
@property (nonatomic) int sectionCount;
@property (nonatomic) int sectionSize;
@property (nonatomic) CGFloat borderSize;
@property (nonatomic) CGFloat marginSize;


@property (nonatomic, weak) id<ACCrosswordBoardDelegate> delegate;
@property (nonatomic) NSInteger activeSectionTag;

- (void)initLevelDataWithQuestion:(NSString *)pQuestion lettersNumbers:(NSString*)pString andAnswer:(NSString*)pAnswer;
- (void)resetSectionCounts;
- (void)resetGridParams:(int)diffCount;
//- (void)drawGridForOrientation:(UIInterfaceOrientation)pOrientation;
- (void)drawGridForOrientation:(UIInterfaceOrientation)pOrientation completion:(void (^)(BOOL finished))completion;
- (void)makeHintForSectionWithTag:(NSInteger)pTag;
- (void)solveGame;
- (NSInteger)eraseErrors;
- (NSInteger)returnIndexWithFirstLetter;
// set Letter into section when user activate section on the board
- (void)setLetter:(NSString*)pLetter andRunToNextSection:(BOOL)pRun;

// set letter into section with current tag
- (void)setLetter:(NSString*)pLetter forSectionWithTag:(NSInteger)pTag;

// this method call when user select some section on the glue and it highlight sections in grid with same number and letters in the top right corner
- (void) highlightSectionForTag:(NSInteger)pTag;

// method check if all sections are full
- (BOOL) checkIfSectionsFull;

// check result
- (BOOL) checkGame;

// clear current section
- (void)clearSectionWithIndex:(NSInteger)pIndex  andGoToPreviousSection:(BOOL)pValue;

//return current state of answer string
- (NSString*) getAnswerString;

//set all letters empty
-(void)removeAllLetters;

//clear gameboard
- (void)clearBoard;

//return number of sections for current game
- (NSInteger) getAllSectionsNumber;

@end
