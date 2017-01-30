//
//  ACKeywordBoard.h
//  Acrostics
//
//  Created by Oleg.Sehelin on 15.11.12.
//  Copyright (c) 2012 A Gamz LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ACKeywordBoardDelegate <NSObject>
- (void)setKeywordBoardActive:(NSInteger)tag;
- (void)showKeyboard;
@end

@interface ACKeywordBoard : UIView 

@property (nonatomic) CGFloat buttonWidth;

@property (nonatomic) NSString *answer;
@property (nonatomic, weak) id<ACKeywordBoardDelegate> delegate;
@property (nonatomic) NSInteger activeSection;

// init method
- (void) initWithIndexArray:(NSArray*)pIndexArray andKeytype:(NSString*)pKeytype;

// draw conteiner label in center
- (void) moveToCenter:(CGFloat)width;

// set active section if it has corect tag
- (void) setActiveSectionIfPossibleForCurrentTag:(NSInteger)pTag andDrawBorder:(BOOL)pValue;

// set highlight section if user select another letter than first from glue
- (void) setHighlightSection:(NSInteger)pTag;

// deselect active section
- (void) deselectSection;

//set letter in active section
- (void) setLetter:(NSString*)pLetter andNeedActivateNext:(BOOL)pValue;

//clear section at index
- (void) clearSectionWithTag:(NSInteger)pTag andRunToPrevious:(BOOL)pValue;
- (void) clearSectionWithTag:(NSInteger)pTag;

//clear board
- (void)clearBoard;

// set letter for current cell if possible
- (void) setLetter:(NSString*)pLetter toSectionWithTagIfPossible:(NSInteger)pTag;

//solve game
- (void) solveGame;

@end