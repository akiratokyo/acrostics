//
//  ACCluesBoard.m
//  Acrostics
//
//  Created by roman.andruseiko on 11/14/12.
//  Copyright (c) 2012 A Gamz LLC. All rights reserved.
//

#import "ACCluesBoard.h"
#define MARGIN_BETWEEN_SECTIONS 2
#define MARGIN_BETWEEN_SECTIONS_HORIZONTAL 5.f

@interface ACCluesBoard () {
    NSInteger mSelectedSection;
    NSInteger mSelectedButtonIndex;
}

@property (nonatomic) NSMutableArray *cluesArray;
@property (nonatomic) NSMutableArray *answersArray;
@property (nonatomic) NSDictionary *questionsDictionary;
@property (nonatomic) NSMutableArray *sectionsArray;

@end

@implementation ACCluesBoard

@synthesize selectedSection=mSelectedSection;
@synthesize selectedButton=mSelectedButtonIndex;

#pragma mark - initialization
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// init board data
- (void)initBoardWithClues:(NSArray*)pClues questions:(NSDictionary *)pQuestions andAnswers:(NSArray*)pAnswers maxWidth:(CGFloat)width {
    
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    NSArray *lAphabet = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",
                @"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",nil];
    _cluesArray = [[NSMutableArray alloc] initWithArray:pClues];
    _answersArray = [[NSMutableArray alloc] initWithArray:pAnswers];
    _questionsDictionary = [[NSMutableDictionary alloc] initWithDictionary:pQuestions];
    
    _sectionsArray = [[NSMutableArray alloc] init];
    
    
    _maxWidth = width;
    _minSectionCount = CluesSectionCount_Min;
    _maxSectionCount = CluesSectionCount_Max;
    _sectionCount = [getValDef(CLUES_SECTION_COUNT, @(2)) intValue];
    if (self.maxWidth > 0.f && self.maxWidth < 420.f) {
        _maxSectionCount = CluesSectionCount_Max - 1;
        _sectionCount = [getValDef(CLUES_SECTION_COUNT, @(1)) intValue];
    }
    setVal(CLUES_SECTION_COUNT, @(_sectionCount));
    
    _decreaseForRegularMode = _maxSectionCount - _sectionCount;
    

//    DLog(@"_cluesArray  - %@  %@", _cluesArray, @([_cluesArray count]));
//    DLog(@"_answersArray  - %@  %@", _answersArray, @([_answersArray count]));
//    DLog(@"mQuestions  - %@  %@", _questionsDictionary, @([_questionsDictionary count]));
    
    
    _maxClue = @"";
    for (NSInteger i = 0; i < [_cluesArray count]; i++) {
        NSString *clueString = [_cluesArray objectAtIndex:i];
        if (clueString.length > _maxClue.length) {
            _maxClue = clueString;
        }
    }
    
    _maxButtonCount = 0;
    for (NSInteger i = 0; i < [_questionsDictionary count]; i++) {
        NSArray* questions = [_questionsDictionary objectForKey:[NSString stringWithFormat:@"%@", @(i + 1)]];
        if (questions.count > _maxButtonCount) {
            _maxButtonCount = questions.count;
        }
    }
    
    
    for (NSInteger i = 0; i < [_cluesArray count]; i++) {
        ACClueSection *lSection = [[ACClueSection alloc] init];
        [lSection initWithClue:[_cluesArray objectAtIndex:i]
                        answer:[_answersArray objectAtIndex:i]
                   andQuestion:[_questionsDictionary objectForKey:[NSString stringWithFormat:@"%@", @(i + 1)]]
                      andTitle:[lAphabet objectAtIndex:i]
                    andMaxClue:_maxClue
             andMaxButtonCount:_maxButtonCount];
        lSection.delegate = self;
        lSection.index = i;
        [_sectionsArray addObject:lSection];
        [self addSubview:lSection];
    } 
}

- (void)resetSectionCounts {
    
    self.minSectionCount = CluesSectionCount_Min;
    self.maxSectionCount = CluesSectionCount_Max;
    if (self.maxWidth > 0.f && self.maxWidth < 420.f) {
        _maxSectionCount = CluesSectionCount_Max - 1;
    }
    self.sectionCount = self.maxSectionCount - self.decreaseForRegularMode;
    if (self.sectionCount < self.minSectionCount)
        self.sectionCount = self.minSectionCount;
    setVal(CLUES_SECTION_COUNT, @(_sectionCount));
}

- (void)resetCluesParams:(int)diffCount {
    
    self.decreaseForRegularMode += diffCount;
    [self resetSectionCounts];
}

#pragma mark - drawing
// board drawing for different nterface orientations
- (void)drawBoardWithCompletion:(void (^)())completion {
    
    if (!self.sectionCount)
        return;
    
    
    NSInteger countOfGroup = 0;
    if ([self.sectionsArray count] % self.sectionCount == 0) {
        countOfGroup = [self.sectionsArray count] / self.sectionCount;
    }
    else {
        countOfGroup = (NSInteger)[self.sectionsArray count] / self.sectionCount + 1;
    }
    
    CGFloat groupWidth = self.maxWidth / self.sectionCount;
    CGFloat startYPos = MARGIN_BETWEEN_SECTIONS_HORIZONTAL;
    CGFloat groupOffset = 0.f;
    CGFloat maxGroupHeight = 0.f;
    
    BOOL decreaseFont = (self.sectionCount < 4 && (self.maxWidth == [UIScreen mainScreen].bounds.size.width || self.maxWidth == [UIScreen mainScreen].bounds.size.height));
    
    for (NSInteger i = 0; i < [self.sectionsArray count]; i++) {
        int groupIndex = (int)(i / countOfGroup);
        if (i % countOfGroup == 0) {
            CGFloat groupHeight = startYPos - groupOffset;
            maxGroupHeight = MAX(maxGroupHeight, groupHeight);
            
            groupOffset = startYPos - MARGIN_BETWEEN_SECTIONS_HORIZONTAL;
        }
        
        ACClueSection *lSection = [self.sectionsArray objectAtIndex:i];
        [lSection changeFontAndSizeForMaxWidth:self.maxWidth sectionCount:self.sectionCount maxButtonCount:self.maxButtonCount decreaseFont:decreaseFont];
        
        
        [lSection setFrame:CGRectMake(groupIndex * groupWidth,
                                      startYPos - groupOffset,
                                      lSection.frame.size.width,
                                      lSection.frame.size.height)];
        
        NSInteger offset = 0;
        if (lSection.buttonsCount > 12) {
            offset += - 45;
        }
        if (lSection.buttonsCount > 13) {
            offset += - 25;
        }
        if (lSection.buttonsCount > 14) {
            offset += - 25;
        }
        
        if (i < countOfGroup)
            offset = 0.f;
        
        [lSection setFrame:CGRectMake(lSection.frame.origin.x + offset,
                                      lSection.frame.origin.y,
                                      lSection.frame.size.width,
                                      lSection.frame.size.height)];
        lSection.frame  = CGRectIntegral(lSection.frame);
        
        
        startYPos += CGRectGetHeight(lSection.frame);
    }
    
    CGFloat groupHeight = startYPos - groupOffset;
    maxGroupHeight = MAX(maxGroupHeight, groupHeight);
    
    [self setContentSize:CGSizeMake(self.maxWidth, maxGroupHeight + 15)];
    [self setContentOffset:CGPointMake(0, 0)];
    
    completion();
}


#pragma mark - board behavior
// clear board
- (void)clearBoardWithoutSelectionFirstSection {
    for (NSInteger i = 0; i < [self.sectionsArray count]; i++) {
        ACClueSection *lSection = [self.sectionsArray objectAtIndex:i];
        [lSection clearSection];
    }
}

// clear board and set selected first button in first section
- (void)clearBoard {
    for (NSInteger i = 0; i < [self.sectionsArray count]; i++) {
        ACClueSection *lSection = [self.sectionsArray objectAtIndex:i];
        [lSection clearSection];
    }
    [(ACClueSection*)[self.sectionsArray objectAtIndex:0] setSelectedButtonWithTag:1];
}

// set selected section with index and button with index
- (void)setSelectedSection:(NSInteger)pSection andPosition:(NSInteger)pPosition{
    for (NSInteger i = 0; i < [self.sectionsArray count]; i++) {
        ACClueSection *lSection = [self.sectionsArray objectAtIndex:i];
        [lSection deselectSection];
    }
    [(ACClueSection*)[self.sectionsArray objectAtIndex:pSection] setSelectedButtonWithTag:pPosition];
}

// set letter for button with index and set active next(if needed) 
- (void)setLetter:(NSString*)pLetter needActiveNext:(BOOL)pNeedActive
{
    for (NSInteger i = 0; i < [self.sectionsArray count]; i++) {
        ACClueSection *lSection = [self.sectionsArray objectAtIndex:i];
        if (lSection.index == mSelectedSection){
            [lSection setLetter:pLetter];
        }
    }
    if (pNeedActive) {
        BOOL isFound = NO;
        for (NSInteger i = mSelectedSection; i < [self.sectionsArray count]; i++) {
            ACClueSection *lSection = [self.sectionsArray objectAtIndex:i];
            if (i == mSelectedSection) {
                if ([lSection setActiveNextFreeButton:NO]) {
                    isFound = YES;
                    break;
                }
            }else{
                if ([lSection setActiveNextFreeButton:YES]) {
                    isFound = YES;
                    break;
                }
            }
        }
        while (!isFound) {
            for (NSInteger i = 0; i < [self.sectionsArray count]; i++) {
                ACClueSection *lSection = [self.sectionsArray objectAtIndex:i];
                if ([lSection setActiveNextFreeButton:YES]) {
                    isFound = YES;
                    break;
                }
                isFound = YES;
            }
        }        
    }
}

// remove title for button with index and if needed set active previous button
- (void)removeTitleForIndex:(NSInteger)pIndex needActivePrevious:(BOOL)pNeedActive{
    
    if (!pNeedActive) {
        for (NSInteger i = 0; i < [self.sectionsArray count]; i++) {
            ACClueSection *lSection = [self.sectionsArray objectAtIndex:i];
            [lSection removeTitleForIndex:pIndex];
        }        
    }else{
        BOOL isRemoved = NO;
        for (NSInteger i = 0; i < [self.sectionsArray count]; i++) {
            ACClueSection *lSection = [self.sectionsArray objectAtIndex:i];
            if ([lSection removeTitleForIndex:pIndex]) {
                isRemoved = YES;
                break;
            }
        }
        
        if (!isRemoved) {
            for (NSInteger i = mSelectedSection; i < [self.sectionsArray count]; i++) {
                ACClueSection *lSection = [self.sectionsArray objectAtIndex:i];
                if (i == mSelectedSection) {
                    if ([lSection setActivePreviousButton:NO]) {
                        [lSection removeSelectedTitle];
                    }else{
                        if (mSelectedSection > 0) {
                            ACClueSection *lPreviousSection = [self.sectionsArray objectAtIndex:i - 1];
                            [lPreviousSection setActivePreviousButton:YES];
                            [lPreviousSection removeSelectedTitle];
                        }else{
                            ACClueSection *lPreviousSection = [self.sectionsArray objectAtIndex:[self.sectionsArray count] - 1];
                            [lPreviousSection setActivePreviousButton:YES];
                            [lPreviousSection removeSelectedTitle];
                        }
                    }
                    
                    break;
                    
                }
            }

        }
 
    }
}

#pragma mark - ACClueSectionDelegate
// set active section
- (void)setClueSectionActive:(id)pSection{
    if ([pSection isKindOfClass:[ACClueSection class]]) {
		mSelectedSection = 0;
		ACClueSection *lCurrentSection = (ACClueSection *)pSection;
		mSelectedButtonIndex = lCurrentSection.buttonIndex;
        
        for (NSInteger i = 0; i < [self.sectionsArray count]; i++) {
            ACClueSection *lSection = [self.sectionsArray objectAtIndex:i];
            
			if (lSection.index == lCurrentSection.index){
				mSelectedSection = i;
			}else{
                [lSection deselectSection];
            }
        }
//        DLog(@"section - %@, button  - %@", @(mSelectedSection), @(mSelectedButtonIndex));
    }
}

// scroll to section
- (void)scrollToSection:(id)pSection {
    if ((pSection != nil) && [pSection isKindOfClass:[ACClueSection class]]) {
		ACClueSection *lCurrentSection = (ACClueSection *)pSection;
        
        CGFloat lContentOffset = floor(lCurrentSection.center.y - self.frame.size.height / 2);
        
        if (lContentOffset < 0) {
            lContentOffset = 0.0f;
        }
        
        if (lContentOffset > (self.contentSize.height - self.frame.size.height)) {
            lContentOffset = (self.contentSize.height - self.frame.size.height);
        }
        
        if (((self.contentOffset.y > lCurrentSection.frame.origin.y) || ((self.frame.size.height + self.contentOffset.y) < (lCurrentSection.frame.origin.y + lCurrentSection.frame.size.height)))) {
            [self setContentOffset:CGPointMake(self.contentOffset.x, lContentOffset) animated:YES];
        }
    }
}

// set active state for button with index
- (void)setActiveButtonForNumber:(NSString*)pNumber andDrawGrid:(BOOL)pValue{
    for (NSInteger i = 0; i < [self.sectionsArray count]; i++) {
        ACClueSection *lSection = [self.sectionsArray objectAtIndex:i];
        if (pValue == YES) {
            [lSection setActiveButtonForNumber:pNumber];
        } else {
            [lSection setActiveButtonForNumberWithoutDraw:pNumber];
        }
    }
}

- (void)setActiveButtonForSection:(NSInteger)section forButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0)
        return;
    
    ACClueSection *lSection = [self.sectionsArray objectAtIndex:section];
    NSString* pNumber = [lSection getQuestionNumberWith:buttonIndex];
    
    [lSection setActiveButtonForNumberWithoutDraw:pNumber];
}


// set title for button with index
- (void)setTitle:(NSString*)pTitle forNumber:(NSString*)pNumber{
    for (NSInteger i = 0; i < [self.sectionsArray count]; i++) {
        ACClueSection *lSection = [self.sectionsArray objectAtIndex:i];
        [lSection setTitle:pTitle forNumber:pNumber];
    }
}

//call to delegate with selected number
- (void)setNeedSelectNumber:(NSString*)pNumber{
    if ([self.mDelegate respondsToSelector:@selector(setCluesBoardSelected:)]) {
        [self.mDelegate setCluesBoardSelected:pNumber];
    }
}

// solve clues board
- (void)solveBoard{
    for (NSInteger i = 0; i < [self.sectionsArray count]; i++) {
        ACClueSection *lSection = [self.sectionsArray objectAtIndex:i];
        [lSection solveSection];
    }
}


#pragma mark -
#pragma mark - Show Keyboard

- (void)showKeyboardForSection:(ACClueSection *)section {
    if ([self.mDelegate respondsToSelector:@selector(showKeyboard)]) {
        [self.mDelegate showKeyboard];
    }
    [self scrollToSection:section];
}

@end
