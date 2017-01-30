//
//  ACCrosswordBoard.m
//  Acrostics
//
//  Created by Oleg.Sehelin on 13.11.12.
//  Copyright (c) 2012 A Gamz LLC. All rights reserved.
//

#import "ACCrosswordBoard.h"
#import <QuartzCore/QuartzCore.h>
#import "ACAppDelegate.h"

//#define MARGIN_LANDSCAPE 1.0f
//#define SECTION_COUNT_LANDSCAPE 25
//#define SECTION_SIZE_LANDSCAPE 40.0f


//#define MARGIN_PORTRAIT 3.0f
//#define MARGIN_PORTRAIT_MIN 1.0f
//#define MARGIN_LANDSCAPE 1.0f
//#define SECTION_COUNT_PORTRAIT 14
//#define SECTION_COUNT_PORTRAIT_MAX 20
//#define SECTION_COUNT_LANDSCAPE 25
//#define SECTION_SIZE 52.0f
//#define SECTION_SIZE_PORTRAIT 37.0f
//#define SECTION_SIZE_LANDSCAPE 40.0f


@interface ACCrosswordBoard () {
    
    NSInteger mDifference;
    NSInteger mActiveSectionTag;
    NSInteger mMaxTagNumber;
    
}

@property (nonatomic) NSMutableArray *sectionsArray;
@property (nonatomic) NSMutableString *answerString;
@property (nonatomic) NSMutableString *questionString;

@property (nonatomic) UIView *blackView;
@property (nonatomic) BOOL didAddSubviews;

//highlight selections for one word
- (void)highlightsTheSameSectionsForCornerLetter:(NSString*)pCornerLetter;

// after this method work onle section with current tag still stay select
- (void)deselectAllWithoutTag:(NSInteger)pTag;

// deselect all sections
- (void)deselectAll;

// jump to the next free section
- (void)runToNextSection;

// return number of full sections
- (NSInteger) returnNumberOfFullSections;

// method check if all sections are full
- (BOOL) checkIfSectionsFull;

// return string of letters from all sections
- (NSString*) returnUserAnswerString;

@end

@implementation ACCrosswordBoard

@synthesize delegate = mDelegate;
@synthesize activeSectionTag = mActiveSectionTag;

- (id)initWithFrame:(CGRect)frame
{
    frame = CGRectIntegral(frame);
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark -public methods -

- (void)initLevelDataWithQuestion:(NSString *)pQuestion lettersNumbers:(NSString*)pString andAnswer:(NSString*)pAnswer{
    self.backgroundColor = GRID_BACKGROUND_COLOR;
    self.sectionsArray = [[NSMutableArray alloc] init];
    self.answerString = [[NSMutableString alloc] initWithString:pAnswer];
    self.questionString = [[NSMutableString alloc] initWithString:pQuestion];
    mActiveSectionTag = -1;
    
    
//    self.decreaseForRegularMode = 0;
    self.decreaseForRegularMode = [getValDef(GRID_SECTION_DECREASE, @(0)) intValue];
    setVal(GRID_SECTION_DECREASE, @(_decreaseForRegularMode));
    
    self.sectionCount = GridSectionCount_Portrait_Max;
    
    [self resetGridParams:0];
    
    
    // delete gap in the end
    if ([[pQuestion substringWithRange:NSMakeRange([pQuestion length]-1, 1)] isEqualToString:@" "]) {
        [(NSMutableString*)pQuestion deleteCharactersInRange:NSMakeRange([pQuestion length]-1, 1)];
    }
    
    mDifference = 0; // value for empty sections in the end
    

    
    if ([pQuestion length] % self.sectionCount == 0) {
        mDifference = [pQuestion length] / self.sectionCount;
    } else {
        mDifference = [pQuestion length] / self.sectionCount + 1;
    }
    
    NSUInteger lCount = mDifference * self.sectionCount;
    

    NSInteger lNumberCount = 0;
    for (NSUInteger i=0; i<lCount; i++) {
        if (i<[pQuestion length]) {
            if ([[pQuestion substringWithRange:NSMakeRange(i, 1)] isEqualToString:@" "]) {
                ACCrosswordSection *lSection = [[ACCrosswordSection alloc] initWithTitleNumber:lNumberCount andTitleLetter:nil];
                [lSection setGap];
                lSection.tag = -1;
                [self.sectionsArray addObject:lSection];
            } else if ([[pQuestion substringWithRange:NSMakeRange(i, 1)] isEqualToString:@","] || [[pQuestion substringWithRange:NSMakeRange(i, 1)] isEqualToString:@"'"] || [[pQuestion substringWithRange:NSMakeRange(i, 1)] isEqualToString:@"."] || [[pQuestion substringWithRange:NSMakeRange(i, 1)] isEqualToString:@"!"] || [[pQuestion substringWithRange:NSMakeRange(i, 1)] isEqualToString:@"?"] || [[pQuestion substringWithRange:NSMakeRange(i, 1)] isEqualToString:@"-"] || [[pQuestion substringWithRange:NSMakeRange(i, 1)] isEqualToString:@"?"] || [[pQuestion substringWithRange:NSMakeRange(i, 1)] isEqualToString:@";"] || [[pQuestion substringWithRange:NSMakeRange(i, 1)] isEqualToString:@":"] || [[pQuestion substringWithRange:NSMakeRange(i, 1)] isEqualToString:@"\""]) {
                ACCrosswordSection *lSection = [[ACCrosswordSection alloc] initWithTitleNumber:lNumberCount andTitleLetter:nil];
//                DLog(@"punctuation");
                [lSection setPunctuation:[pQuestion substringWithRange:NSMakeRange(i, 1)]];
                lSection.tag = -1;
                [self.sectionsArray addObject:lSection];
            } else {
//                DLog(@"letter %@ and length %@",[(NSMutableString*)pQuestion substringWithRange:NSMakeRange(i, 1)],@(lNumberCount));
                ACCrosswordSection *lSection = [[ACCrosswordSection alloc] initWithTitleNumber:lNumberCount+1 andTitleLetter:[NSString stringWithFormat:@"%@ ",[(NSMutableString*)pString substringWithRange:NSMakeRange(lNumberCount, 1)]]];
                lSection.tag = lNumberCount;
                mMaxTagNumber = lNumberCount;
                lSection.delegate = self;
                [self.sectionsArray addObject:lSection];
                
                lNumberCount++;
            }
        } else {
            ACCrosswordSection *lSection = [[ACCrosswordSection alloc] initWithTitleNumber:lNumberCount andTitleLetter:nil];
            lSection.tag = -1;
            [lSection setGap];
            [self.sectionsArray addObject:lSection];
        }
    }
}

- (void)resetSectionCounts {
    
    if (self.maxWidth > 768.f) {
        self.minSectionCount = GridSectionCount_Landscape_Min;
        self.maxSectionCount = GridSectionCount_Landscape_Max;
    }
    else if (self.maxWidth > 694.f) {
        self.minSectionCount = GridSectionCount_Portrait_Min;
        self.maxSectionCount = GridSectionCount_Portrait_Max;
    }
    else if (self.maxWidth > 507.f) {
        self.minSectionCount = 16;
        self.maxSectionCount = 22;
    }
    else if (self.maxWidth > 438.f) {
        self.minSectionCount = 14;
        self.maxSectionCount = 18;
    }
    else {
        self.minSectionCount = 12;
        self.maxSectionCount = 18;
    }

    self.sectionCount = self.maxSectionCount - self.decreaseForRegularMode;
    if (self.sectionCount < self.minSectionCount)
        self.sectionCount = self.minSectionCount;
}

- (void)resetGridParams:(int)diffCount {
    
    self.decreaseForRegularMode += diffCount;
    setVal(GRID_SECTION_DECREASE, @(_decreaseForRegularMode));
    
    [self resetSectionCounts];
    
    self.borderSize = 1.f;
    self.sectionSize = (self.maxWidth - (self.sectionCount - 1) * self.borderSize) / self.sectionCount;
    self.marginSize = (self.maxWidth - self.sectionSize * self.sectionCount - self.borderSize * (self.sectionCount - 1)) / 2;
    
    
    /*
    self.sectionSize = self.maxWidth / self.sectionCount;
    int marginSize = self.maxWidth - self.sectionSize * self.sectionCount;
    if (marginSize == 0) {
        self.borderSize = 2.f;
        self.marginSize = 0.f;
        self.sectionSize = self.sectionSize - self.borderSize;
    }
    else {
        BOOL resolved = NO;
        int step = 0;
        int margin = marginSize;
        while (step < 3) {
            int sectionSize = self.sectionSize - step;
            int newMarginSize = self.maxWidth - sectionSize * self.sectionCount;
            int newMargin = newMarginSize % (self.sectionCount - 1);
            if (newMargin < 4) {
                resolved = YES;
                self.borderSize = newMarginSize / (self.sectionCount - 1);
                if (self.borderSize < 1)
                    self.borderSize = 1;
                self.sectionSize = (self.maxWidth - self.borderSize * (self.sectionCount - 1) - newMargin) / self.sectionCount;
                self.marginSize = (self.maxWidth - self.sectionSize * self.sectionCount - self.borderSize * (self.sectionCount - 1)) / 2;
                break;
            }
            
            if (newMargin < margin) {
                margin = newMargin;
                marginSize = newMarginSize;
            }
            step ++;
        }
        
        if (!resolved) {
            self.borderSize = marginSize / (self.sectionCount - 1);
            if (self.borderSize < 1)
                self.borderSize = 1;
            self.sectionSize = (self.maxWidth - self.borderSize * (self.sectionCount - 1) - margin) / self.sectionCount;
            self.marginSize = (self.maxWidth - self.sectionSize * self.sectionCount - self.borderSize * (self.sectionCount - 1)) / 2;
        }
    }
    */
    
//    NSLog(@"==== resetGridParams ===> %.2f : %d : %d : %.02f", self.maxWidth, self.sectionCount, self.sectionSize, self.borderSize);
}

- (void)drawGridForOrientation:(UIInterfaceOrientation)pOrientation
                    completion:(void (^)(BOOL finished))completion
{
    if (!self.sectionCount) {
        return;
    }
    
    if ([self.questionString length] % self.sectionCount == 0) {
        mDifference = [self.questionString length] / self.sectionCount;
    } else {
        mDifference = [self.questionString length] / self.sectionCount + 1;
    }
    
    
#define LABEL_SIZE_LANDSCAPE 15.0f
    
    CGFloat width = MIN(self.sectionSize / 3.5f, LABEL_SIZE_LANDSCAPE);
    
    CGRect numberLabelFrame = CGRectMake(1.f, 0.f, width * 2.f, width);
    numberLabelFrame = CGRectIntegral(numberLabelFrame);
    
    CGRect letterLabelFrame = CGRectMake(width * 2.5f - 1.f, 0.f, width, width);
    letterLabelFrame = CGRectIntegral(letterLabelFrame);
    
    CGFloat numberFontSize = [ACAppDelegate fontSizeForString:@"000" frame:numberLabelFrame isBoldFont:NO];
    numberFontSize = MIN(numberFontSize, [ACAppDelegate fontSizeForString:@"W" frame:letterLabelFrame isBoldFont:NO]);
    
    
    CGRect answerLabelFrame = CGRectMake(width * 0.5f, width, width * 2.5f, width * 2.5f);
    answerLabelFrame = CGRectIntegral(answerLabelFrame);
    if (self.maxWidth < 420.f) {
        answerLabelFrame = CGRectMake(width * 0.25f, width * 0.5f, width * 3.f, width * 3.f);
    }
    CGFloat answerFontSize = [ACAppDelegate fontSizeForString:@"W" frame:answerLabelFrame isBoldFont:YES];
    
    
    // standart size in portrait orientation
    for (NSUInteger i = 0; i < mDifference; i ++) {
        for (NSUInteger j = 0; j < self.sectionCount; j ++) {
            if (i > 0 && i * self.sectionCount + j >= self.sectionsArray.count) {
                break;
            }
            ACCrosswordSection *section = self.sectionsArray[(i * self.sectionCount + j)];
            CGRect newFrame;
            if (i == 0) {
                if (j == 0) {
                    newFrame = CGRectMake(self.marginSize, 2.0f, self.sectionSize, self.sectionSize);
                } else {
                    newFrame = CGRectMake(self.marginSize + j * (self.sectionSize + self.borderSize), 2.0f, self.sectionSize, self.sectionSize);
                }
            } else {
                if (j == 0) {
                    newFrame = CGRectMake(self.marginSize, 2.0 + i * (self.sectionSize + self.borderSize), self.sectionSize, self.sectionSize);
                } else {                    
                    newFrame = CGRectMake(self.marginSize + j * (self.sectionSize + self.borderSize), 2.0f + i * (self.sectionSize + self.borderSize), self.sectionSize, self.sectionSize);
                }
            }
            
            section.frame = newFrame;
            [section changeFontAndSizeForMaxWidth:self.maxWidth numberFontSize:numberFontSize answerFontSize:answerFontSize];
            
            if (!self.didAddSubviews) {
                [self addSubview:(ACCrosswordSection*)[self.sectionsArray objectAtIndex:(i * self.sectionCount + j)]];
            }
        }
    }
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            self.maxWidth,
                            mDifference * (self.sectionSize + self.borderSize) - self.borderSize + 2.f * 2);
    CGRect blackViewFrame = CGRectMake(0.0,
                                       2.f + mDifference * (self.sectionSize + self.borderSize) - self.borderSize,
                                       self.maxWidth,
                                       2.f);
    if (!self.blackView) {
        UIView *blackView = [[UIView alloc] initWithFrame:blackViewFrame];
        blackView.backgroundColor = GRID_BACKGROUND_COLOR;
        [self addSubview:blackView];
        self.blackView = blackView;
    } else {
        self.blackView.frame = blackViewFrame;
    }
    
    self.didAddSubviews = YES;
    if (completion) {
        completion(YES);
    }
}

- (void)setLetter:(NSString*)pLetter andRunToNextSection:(BOOL)pRun {
    for (NSInteger i=mActiveSectionTag; i<[self.sectionsArray count]; i++) {
        if (mActiveSectionTag == ((ACCrosswordSection*)[self.sectionsArray objectAtIndex:i]).tag) {

            [(ACCrosswordSection*)[self.sectionsArray objectAtIndex:i] setLetter:pLetter];
            
            if (pRun == YES) {
                [self deselectAll];
                [self runToNextSection];
            }
            break;
        }
    }
}

// set letter into section with current tag
- (void)setLetter:(NSString*)pLetter forSectionWithTag:(NSInteger)pTag {
    for (NSInteger i=pTag; i<[self.sectionsArray count]; i++) {
        if (pTag == ((ACCrosswordSection*)[self.sectionsArray objectAtIndex:i]).tag) {
            if ([pLetter isEqualToString:@" "] == YES) {
                pLetter = @"";
            }
            [(ACCrosswordSection*)[self.sectionsArray objectAtIndex:i] setLetter:pLetter];
            break;
        }
    }
}

// this method call when user select some section on the glue and it highlight sections in grid with same number and letters in the top right corner
- (void) highlightSectionForTag:(NSInteger)pTag {
    for (NSUInteger j=0; j<[self.sectionsArray count]; j++) {
        if (((ACCrosswordSection*)[self.sectionsArray objectAtIndex:j]).isEnable == YES) {
            if (((ACCrosswordSection*)[self.sectionsArray objectAtIndex:j]).tag == pTag-1) {
                [self deselectAll];
                [(ACCrosswordSection*)[self.sectionsArray objectAtIndex:j] setSectionActiveState];
                [self highlightsTheSameSectionsForCornerLetter:[(ACCrosswordSection*)[self.sectionsArray objectAtIndex:j] returnCornerLetter]];
            }
        }
    }
    mActiveSectionTag = pTag-1;
}

// check result
- (BOOL) checkGame {
    BOOL isCorrectAnswer = NO;
    if ([self checkIfSectionsFull] == YES) {
        if ([self.answerString isEqualToString:[self returnUserAnswerString]] == YES) {
            isCorrectAnswer = YES;
        }
    }
    return isCorrectAnswer;
}

// clear current section
- (void)clearSectionWithIndex:(NSInteger)pIndex  andGoToPreviousSection:(BOOL)pValue {
    for (NSUInteger j=0; j<[self.sectionsArray count]; j++) {
        if (((ACCrosswordSection*)[self.sectionsArray objectAtIndex:j]).isEnable == YES) {
            if (((ACCrosswordSection*)[self.sectionsArray objectAtIndex:j]).tag == pIndex-1) {
                if ([[(ACCrosswordSection*)[self.sectionsArray objectAtIndex:j] returnAnswerLetter] isEqualToString:@""] == NO && [(ACCrosswordSection*)[self.sectionsArray objectAtIndex:j] returnAnswerLetter] != nil) {
                    [(ACCrosswordSection*)[self.sectionsArray objectAtIndex:j] setLetter:@""];
                } else {
                    if (pValue == YES) {
                        pIndex --;
                        if (pIndex<=0 ) {
                            [self highlightSectionForTag:mMaxTagNumber+1];
                            for (NSInteger j=0; j<[self.sectionsArray count]; j++) {
                                if (((ACCrosswordSection*)[self.sectionsArray objectAtIndex:j]).isEnable == YES && ((ACCrosswordSection*)[self.sectionsArray objectAtIndex:j]).tag == mMaxTagNumber) {
                                    [(ACCrosswordSection*)[self.sectionsArray objectAtIndex:j] setLetter:@""];
                                    break;
                                }
                            }
                            
                            if (mDelegate && [mDelegate respondsToSelector:@selector(activeCrosswordSectionWithTag: andIsAutomaticRun:)]) {
                                [mDelegate performSelector:@selector(activeCrosswordSectionWithTag: andIsAutomaticRun:) withObject:[NSNumber numberWithInteger:mMaxTagNumber+1] withObject:[NSNumber numberWithBool:YES]];
                            }
                            
                        } else {
                            [self highlightSectionForTag:pIndex];
                            
                            for (NSInteger j=0; j<[self.sectionsArray count]; j++) {
                                if (((ACCrosswordSection*)[self.sectionsArray objectAtIndex:j]).isEnable == YES && ((ACCrosswordSection*)[self.sectionsArray objectAtIndex:j]).tag == pIndex-1) {
                                    [(ACCrosswordSection*)[self.sectionsArray objectAtIndex:j] setLetter:@""];
                                    break;
                                }
                            }

                            if (mDelegate && [mDelegate respondsToSelector:@selector(activeCrosswordSectionWithTag: andIsAutomaticRun:)]) {
                                [mDelegate performSelector:@selector(activeCrosswordSectionWithTag: andIsAutomaticRun:) withObject:[NSNumber numberWithInteger:pIndex] withObject:[NSNumber numberWithBool:NO]];
                            }

                        }
                    }
                }
            }
        }
    }
}

//return current state of answer string
- (NSString*) getAnswerString {
    NSMutableString *lResultString = [NSMutableString stringWithFormat:@""];
    
    for (NSUInteger j=0; j<[self.sectionsArray count]; j++) {
        if (((ACCrosswordSection*)[self.sectionsArray objectAtIndex:j]).isEnable == YES) {
            if ([(ACCrosswordSection*)[self.sectionsArray objectAtIndex:j] returnAnswerLetter] != nil && [[(ACCrosswordSection*)[self.sectionsArray objectAtIndex:j] returnAnswerLetter] isEqualToString:@""] == NO) {
                [lResultString appendString:[(ACCrosswordSection*)[self.sectionsArray objectAtIndex:j] returnAnswerLetter]];
            } else {
                [lResultString appendString:@" "];
            }
        }
    }

    return lResultString;
}

- (void)solveGame {
    NSInteger lCount = 0;
    for (NSUInteger i=0; i<[self.sectionsArray count]; i++) {
        if (((ACCrosswordSection*)[self.sectionsArray objectAtIndex:i]).isEnable == YES) {
            [(ACCrosswordSection*)[self.sectionsArray objectAtIndex:i] setLetter:[self.answerString substringWithRange:NSMakeRange(lCount, 1)]];
            lCount++;
            [(ACCrosswordSection*)[self.sectionsArray objectAtIndex:i] unactiveSection];
        }
    }
}

- (NSInteger)eraseErrors {
    NSInteger lCount = 0;
    NSInteger lResult = 0;
    for (NSUInteger i=0; i<[self.sectionsArray count]; i++) {
        if (((ACCrosswordSection*)[self.sectionsArray objectAtIndex:i]).isEnable == YES) {
            if ([[(ACCrosswordSection*)[self.sectionsArray objectAtIndex:i] returnAnswerLetter] isEqualToString:[self.answerString substringWithRange:NSMakeRange(lCount, 1)]] == NO && [[(ACCrosswordSection*)[self.sectionsArray objectAtIndex:i] returnAnswerLetter] isEqualToString:@""] == NO) {
                
                [(ACCrosswordSection*)[self.sectionsArray objectAtIndex:i] setLetter:@""];
                lResult++;
                if (mDelegate && [mDelegate respondsToSelector:@selector(erraseCallForTag:)]) {
                    [mDelegate performSelector:@selector(erraseCallForTag:) withObject:[NSNumber numberWithInteger:((ACCrosswordSection*)[self.sectionsArray objectAtIndex:i]).tag+1]];
                }
            }
            lCount ++;
        }
    }
    
    return lResult;
}

- (NSInteger)returnIndexWithFirstLetter {
    NSInteger lResult = -1;
    
    for (NSUInteger j=0; j<[self.sectionsArray count]; j++) {
        if (((ACCrosswordSection*)[self.sectionsArray objectAtIndex:j]).isEnable == YES) {
            if ([(ACCrosswordSection*)[self.sectionsArray objectAtIndex:j] returnAnswerLetter] != nil && [[(ACCrosswordSection*)[self.sectionsArray objectAtIndex:j] returnAnswerLetter] isEqualToString:@""] == NO && [[(ACCrosswordSection*)[self.sectionsArray objectAtIndex:j] returnAnswerLetter] isEqualToString:@" "] == NO) {
                lResult = ((ACCrosswordSection*)[self.sectionsArray objectAtIndex:j]).tag+1;
                break;
            }
        }
    }
    
    return lResult;
}

#pragma mark -Private methods-
// highlight sections with same letter in the corner
- (void)highlightsTheSameSectionsForCornerLetter:(NSString*)pCornerLetter {
    for (NSUInteger i=0; i<[self.sectionsArray count]; i++) {
        if ([pCornerLetter isEqualToString:[(ACCrosswordSection*)[self.sectionsArray objectAtIndex:i] returnCornerLetter]] == YES && ((ACCrosswordSection*)[self.sectionsArray objectAtIndex:i]).isActive == NO) {
            [(ACCrosswordSection*)[self.sectionsArray objectAtIndex:i] setSameSectionSate];
        }
    }
}

// after this method work onle section with current tag still stay select
- (void)deselectAllWithoutTag:(NSInteger)pTag {
    if (mActiveSectionTag != -1) {
        for (NSUInteger j=0; j<[self.sectionsArray count]; j++) {
            if (((ACCrosswordSection*)[self.sectionsArray objectAtIndex:j]).isEnable == YES) {
                if (((ACCrosswordSection*)[self.sectionsArray objectAtIndex:j]).tag != pTag ) {
                    [(ACCrosswordSection*)[self.sectionsArray objectAtIndex:j] deselectSection];
                }
            }
        }
    }
}

// deselect all sections
-(void)deselectAll {
    for (NSUInteger j=0; j<[self.sectionsArray count]; j++) {
        if (((ACCrosswordSection*)[self.sectionsArray objectAtIndex:j]).isEnable == YES) {
            [(ACCrosswordSection*)[self.sectionsArray objectAtIndex:j] deselectSection];
        }
    }
}

//set all letters empty
-(void)removeAllLetters {
    for (NSUInteger j=0; j<[self.sectionsArray count]; j++) {
        if (((ACCrosswordSection*)[self.sectionsArray objectAtIndex:j]).isEnable == YES) {
            [(ACCrosswordSection*)[self.sectionsArray objectAtIndex:j] setLetter:@""];
        }
    }
}

- (void)clearBoard{
    for (NSUInteger j=0; j<[self.sectionsArray count]; j++) {
        if (((ACCrosswordSection*)[self.sectionsArray objectAtIndex:j]).isEnable == YES) {
            if (j == 0) {
                [(ACCrosswordSection*)[self.sectionsArray objectAtIndex:j] setSectionActiveState];
            }else{
                [(ACCrosswordSection*)[self.sectionsArray objectAtIndex:j] deselectSection];
            }
            [(ACCrosswordSection*)[self.sectionsArray objectAtIndex:j] setLetter:@""];
        
        }
    }
    [((ACCrosswordSection*)[self.sectionsArray objectAtIndex:0]) buttonPressed:nil];
}

// jump to the next free section
- (void)runToNextSection {
    mActiveSectionTag++;
    if (mActiveSectionTag > mMaxTagNumber) {
        mActiveSectionTag = 0;
    }
    for (NSUInteger j=0; j<[self.sectionsArray count]; j++) {
        if (((ACCrosswordSection*)[self.sectionsArray objectAtIndex:j]).isEnable == YES) {
            if (((ACCrosswordSection*)[self.sectionsArray objectAtIndex:j]).tag == mActiveSectionTag) {
                    [(ACCrosswordSection*)[self.sectionsArray objectAtIndex:j] setSectionActiveState];
                    [self highlightsTheSameSectionsForCornerLetter:[(ACCrosswordSection*)[self.sectionsArray objectAtIndex:j] returnCornerLetter]];
                
                if (mDelegate && [mDelegate respondsToSelector:@selector(activeCrosswordSectionWithTag: andIsAutomaticRun:)]) {
                    [mDelegate performSelector:@selector(activeCrosswordSectionWithTag: andIsAutomaticRun:) withObject:[NSNumber numberWithInteger:mActiveSectionTag+1] withObject:[NSNumber numberWithBool:YES]];
                }
                
            }
        }
    }
}

// return number of full sections
- (NSInteger) returnNumberOfFullSections {
    NSInteger lResult = 0;
    
    for (NSUInteger j=0; j<[self.sectionsArray count]; j++) {
        if (((ACCrosswordSection*)[self.sectionsArray objectAtIndex:j]).isEnable == YES) {
            if ([(ACCrosswordSection*)[self.sectionsArray objectAtIndex:j] returnAnswerLetter] != nil && [[(ACCrosswordSection*)[self.sectionsArray objectAtIndex:j] returnAnswerLetter] isEqualToString:@""] == NO) {
                lResult++;
            }
        }
    }
    return lResult;
}

// method check if all sections are full
- (BOOL) checkIfSectionsFull {
    BOOL isFull = NO;
    if ([self returnNumberOfFullSections] == mMaxTagNumber+1) {
        isFull = YES;
    }
    return isFull;
}

- (NSString*) returnUserAnswerString {
    NSMutableString *lResultString = [NSMutableString stringWithFormat:@""];

    for (NSUInteger j=0; j<[self.sectionsArray count]; j++) {
        if (((ACCrosswordSection*)[self.sectionsArray objectAtIndex:j]).isEnable == YES) {
            if ([(ACCrosswordSection*)[self.sectionsArray objectAtIndex:j] returnAnswerLetter] != nil) {
                [lResultString appendString:[NSString stringWithFormat:@"%@",[[(ACCrosswordSection*)[self.sectionsArray objectAtIndex:j] returnAnswerLetter] uppercaseString]]];
            }
        }
    }
    return (NSString*)lResultString;
}

//return number of sections for current game
- (NSInteger) getAllSectionsNumber {
    NSInteger lResult = 0;
    for (NSUInteger j=0; j<[self.sectionsArray count]; j++) {
        if (((ACCrosswordSection*)[self.sectionsArray objectAtIndex:j]).isEnable == YES) {
            lResult++;
        }
    }

    return lResult;
}

#pragma mark -CrosswordSectionDelegate method-
// call when user select section
-(void) setActiveSectionWithTag:(NSInteger)tag {
    
    [self deselectAllWithoutTag:tag];
    mActiveSectionTag = tag;
    
    for (NSUInteger i=0; i<[self.sectionsArray count]; i++) {
        if (((ACCrosswordSection*)[self.sectionsArray objectAtIndex:i]).tag == mActiveSectionTag) {
            [self highlightsTheSameSectionsForCornerLetter:[(ACCrosswordSection*)[self.sectionsArray objectAtIndex:i] returnCornerLetter]];
        }
    }

    if (mDelegate && [mDelegate respondsToSelector:@selector(activeCrosswordSectionWithTag: andIsAutomaticRun:)]) {
        [mDelegate performSelector:@selector(activeCrosswordSectionWithTag: andIsAutomaticRun:) withObject:[NSNumber numberWithInteger:mActiveSectionTag+1] withObject:[NSNumber numberWithBool:NO]];
    }
}


- (void)makeHintForSectionWithTag:(NSInteger)pTag {
    for (NSUInteger i=0; i<[self.sectionsArray count]; i++) {
        if (((ACCrosswordSection*)[self.sectionsArray objectAtIndex:i]).tag == pTag-1) {
            if ([self checkIfSectionsFull] == YES) {
                if ([[(ACCrosswordSection*)[self.sectionsArray objectAtIndex:i] returnAnswerLetter] isEqualToString:[self.answerString substringWithRange:NSMakeRange(mActiveSectionTag, 1)]] == YES) {
                    BOOL isSearchInPreviousSection = NO;
                    for (NSUInteger j=i; j<[self.sectionsArray count]; j++) {
                        if (((ACCrosswordSection*)[self.sectionsArray objectAtIndex:j]).isEnable == YES) {
                            if ([[(ACCrosswordSection*)[self.sectionsArray objectAtIndex:j] returnAnswerLetter] isEqualToString:[self.answerString substringWithRange:NSMakeRange(((ACCrosswordSection*)[self.sectionsArray objectAtIndex:j]).tag, 1)]] == NO) {
                                
                                [(ACCrosswordSection*)[self.sectionsArray objectAtIndex:j] setLetter:[self.answerString substringWithRange:NSMakeRange(((ACCrosswordSection*)[self.sectionsArray objectAtIndex:j]).tag, 1)]];
                                [self setActiveSectionWithTag:((ACCrosswordSection*)[self.sectionsArray objectAtIndex:j]).tag];
                                [(ACCrosswordSection*)[self.sectionsArray objectAtIndex:j] setSectionActiveState];
                                
                                isSearchInPreviousSection = YES;
                                
                                if (mDelegate && [mDelegate respondsToSelector:@selector(makeHitWithLetter: andTag:)]) {
                                    [mDelegate performSelector:@selector(makeHitWithLetter: andTag:) withObject:[self.answerString substringWithRange:NSMakeRange(((ACCrosswordSection*)[self.sectionsArray objectAtIndex:j]).tag, 1)] withObject:[NSNumber numberWithInteger:pTag]];
                                }
                                break;
                            }
                        }
                    }
                    if (isSearchInPreviousSection == YES) {
                        break;
                    } else {
                        for (NSUInteger j=0; j<i; j++) {
                            if (((ACCrosswordSection*)[self.sectionsArray objectAtIndex:j]).isEnable == YES) {
                                if ([[(ACCrosswordSection*)[self.sectionsArray objectAtIndex:j] returnAnswerLetter] isEqualToString:[self.answerString substringWithRange:NSMakeRange(((ACCrosswordSection*)[self.sectionsArray objectAtIndex:j]).tag, 1)]] == NO) {
                                    
                                    [(ACCrosswordSection*)[self.sectionsArray objectAtIndex:j] setLetter:[self.answerString substringWithRange:NSMakeRange(((ACCrosswordSection*)[self.sectionsArray objectAtIndex:j]).tag, 1)]];
                                    [self setActiveSectionWithTag:((ACCrosswordSection*)[self.sectionsArray objectAtIndex:j]).tag];
                                    [(ACCrosswordSection*)[self.sectionsArray objectAtIndex:j] setSectionActiveState];
                                                                        
                                    if (mDelegate && [mDelegate respondsToSelector:@selector(makeHitWithLetter: andTag:)]) {
                                        [mDelegate performSelector:@selector(makeHitWithLetter: andTag:) withObject:[self.answerString substringWithRange:NSMakeRange(((ACCrosswordSection*)[self.sectionsArray objectAtIndex:j]).tag, 1)] withObject:[NSNumber numberWithInteger:pTag]];
                                    }
                                    break;
                                }
                            }
                        }
                        break;
                    }
                
                } else {
                    [(ACCrosswordSection*)[self.sectionsArray objectAtIndex:i] setLetter:[self.answerString substringWithRange:NSMakeRange(mActiveSectionTag, 1)]];
                    [self setActiveSectionWithTag:pTag-1];
                    
                    if (mDelegate && [mDelegate respondsToSelector:@selector(makeHitWithLetter: andTag:)]) {
                        [mDelegate performSelector:@selector(makeHitWithLetter: andTag:) withObject:[self.answerString substringWithRange:NSMakeRange(mActiveSectionTag, 1)] withObject:[NSNumber numberWithInteger:pTag]];
                    }
                    break;
                }
            }
            // check if this section has correct answer            
            if ([[(ACCrosswordSection*)[self.sectionsArray objectAtIndex:i] returnAnswerLetter] isEqualToString:[self.answerString substringWithRange:NSMakeRange(mActiveSectionTag, 1)]] == NO) {
                
                [(ACCrosswordSection*)[self.sectionsArray objectAtIndex:i] setLetter:[self.answerString substringWithRange:NSMakeRange(mActiveSectionTag, 1)]];
                [self setActiveSectionWithTag:pTag-1];
                
                if (mDelegate && [mDelegate respondsToSelector:@selector(makeHitWithLetter: andTag:)]) {
                    [mDelegate performSelector:@selector(makeHitWithLetter: andTag:) withObject:[self.answerString substringWithRange:NSMakeRange(mActiveSectionTag, 1)] withObject:[NSNumber numberWithInteger:pTag]];
                }
                break;
            } else {
                if ([self checkIfSectionsFull] != YES) {
                    BOOL isSearch = NO;
                    // search next empty section                    
                    for (NSUInteger j=i+1; j<[self.sectionsArray count]; j++) {
                        if (((ACCrosswordSection*)[self.sectionsArray objectAtIndex:j]).isEnable == YES) {
                            if ([(ACCrosswordSection*)[self.sectionsArray objectAtIndex:j] returnAnswerLetter] == nil || [[(ACCrosswordSection*)[self.sectionsArray objectAtIndex:j] returnAnswerLetter] isEqualToString:@""] == YES) {
                                
                                isSearch = YES;
                                
                                [(ACCrosswordSection*)[self.sectionsArray objectAtIndex:j] setLetter:[self.answerString substringWithRange:NSMakeRange(((ACCrosswordSection*)[self.sectionsArray objectAtIndex:j]).tag, 1)]];
                                [self setActiveSectionWithTag:((ACCrosswordSection*)[self.sectionsArray objectAtIndex:j]).tag];
                                [(ACCrosswordSection*)[self.sectionsArray objectAtIndex:j] setSectionActiveState];
                                
                                if (mDelegate && [mDelegate respondsToSelector:@selector(makeHitWithLetter: andTag:)]) {
                                    [mDelegate performSelector:@selector(makeHitWithLetter: andTag:) withObject:[self.answerString substringWithRange:NSMakeRange(((ACCrosswordSection*)[self.sectionsArray objectAtIndex:j]).tag, 1)] withObject:[NSNumber numberWithInteger:((ACCrosswordSection*)[self.sectionsArray objectAtIndex:j]).tag]];
                                }
                                break;
                            }
                        }
                    }
                    
                    if (isSearch == NO) {
                        for (NSInteger k=0; k<i+1; k++) {
                            if (((ACCrosswordSection*)[self.sectionsArray objectAtIndex:k]).isEnable == YES) {
                                if ([(ACCrosswordSection*)[self.sectionsArray objectAtIndex:k] returnAnswerLetter] == nil || [[(ACCrosswordSection*)[self.sectionsArray objectAtIndex:k] returnAnswerLetter] isEqualToString:@""] == YES) {
                                    
                                    [self setActiveSectionWithTag:((ACCrosswordSection*)[self.sectionsArray objectAtIndex:k]).tag];
                                    [(ACCrosswordSection*)[self.sectionsArray objectAtIndex:k] setLetter:[self.answerString substringWithRange:NSMakeRange(((ACCrosswordSection*)[self.sectionsArray objectAtIndex:k]).tag, 1)]];
                                    [(ACCrosswordSection*)[self.sectionsArray objectAtIndex:k] setSectionActiveState];
                                    
                                    if (mDelegate && [mDelegate respondsToSelector:@selector(makeHitWithLetter: andTag:)]) {
                                        [mDelegate performSelector:@selector(makeHitWithLetter: andTag:) withObject:[self.answerString substringWithRange:NSMakeRange(((ACCrosswordSection*)[self.sectionsArray objectAtIndex:k]).tag, 1)] withObject:[NSNumber numberWithInteger:((ACCrosswordSection*)[self.sectionsArray objectAtIndex:k]).tag]];
                                    }
                                    break;
                                }
                            }
                        }
                    }
                } 
            }
        }
    }
}


#pragma mark -
#pragma mark - Show Keyboard

- (void)showKeyboard {
    if (mDelegate && [mDelegate respondsToSelector:@selector(showKeyboard)]) {
        [mDelegate performSelector:@selector(showKeyboard)];
    }
}


@end
