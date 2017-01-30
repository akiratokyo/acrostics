//
//  ACClueSection.m
//  Acrostics
//
//  Created by roman.andruseiko on 11/14/12.
//  Copyright (c) 2012 A Gamz LLC. All rights reserved.
//

#import "ACClueSection.h"
#import <QuartzCore/QuartzCore.h>
#import "ACAppDelegate.h"

//#define HEADER_LABEL_SIZE 25
//#define BUTTON_WIDTH 23
//#define BUTTON_HEIGHT 23
//#define ACTIVE_BUTTON_HEIGHT 27
//#define TOP_BUTTON_HEIGHT 10
#define MARGIN 3
#define SMALL_MARGIN 2

const double ACClueSectionNumberLabelToTopLabelRation = 0.5;

@interface ACClueSection () {
    CGFloat headerLabelSize;
    CGFloat buttonWidth;
    CGFloat buttonHeight;
    CGFloat topButtonHeight;
    CGFloat topNumberLabelHeight;

    // new
    NSInteger mIndex;
    NSInteger mButtonIndex;
    
    NSInteger mButtonsCount;
}

@property (nonatomic) NSString *clue;
@property (nonatomic) NSString *answer;
@property (nonatomic) NSString *sectionTitle;
@property (nonatomic) NSArray *questionArray;
@property (nonatomic) NSMutableArray *questionLabelsArray;
@property (nonatomic) NSMutableArray *answerButtonsArray;
@property (nonatomic) NSMutableArray *backgroundsArray;
@property (nonatomic) NSMutableArray *numberButtonsArray;
@property (nonatomic) NSMutableArray *lineArray;
@property (nonatomic) UILabel *letterLabel;
@property (nonatomic) UILabel *clueLabel;

@end


@implementation ACClueSection

@synthesize buttonsCount=mButtonsCount;
@synthesize buttonIndex=mButtonIndex;
@synthesize index=mIndex;

- (id)initWithFrame:(CGRect)frame
{
    frame = CGRectIntegral(frame);
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}


// section initialization
- (void)initWithClue:(NSString*)pClue
              answer:(NSString*)pAnswer
         andQuestion:(NSArray*)pQuestion
            andTitle:(NSString*)pTitle
          andMaxClue:(NSString*)maxClue
   andMaxButtonCount:(NSInteger)maxButtonCount
{
    self.buttonIndex = 0;
    _clue = pClue;
    _answer = pAnswer;
    _questionArray = pQuestion;
    _sectionTitle = pTitle;
    
    _maxClue = maxClue;
    _maxButtonCount = maxButtonCount;
    
    //
    headerLabelSize = 25.f;
    buttonWidth = 23.f;
    buttonHeight = 23.f;
    topButtonHeight = 10.f;
    topNumberLabelHeight = 1.0f * ACClueSectionNumberLabelToTopLabelRation;
    
    
    _questionLabelsArray = [[NSMutableArray alloc] init];
    _answerButtonsArray = [[NSMutableArray alloc] init];
    _backgroundsArray = [[NSMutableArray alloc] init];
    _numberButtonsArray = [[NSMutableArray alloc] init];
    _lineArray = [[NSMutableArray alloc] init];
        
    mButtonsCount = [_questionArray count];
    
    [self setBackgroundColor:[UIColor clearColor]];
    NSInteger lStartPoint = headerLabelSize + MARGIN * 2;
    for (NSInteger i = 0; i < [_questionArray count]; i++) {
        
        UIView *lBackgoundView = [[UIView alloc] initWithFrame:CGRectMake(lStartPoint,
                                                                          MARGIN - 3,
                                                                          buttonWidth,
                                                                          topButtonHeight + SMALL_MARGIN + buttonHeight + 6)];
        lBackgoundView.backgroundColor = [UIColor whiteColor];
        lBackgoundView.frame  = CGRectIntegral(lBackgoundView.frame);
        lBackgoundView.center = CGPointMake(round(lBackgoundView.center.x), round(lBackgoundView.center.y));
        [self addSubview:lBackgoundView];
        [_backgroundsArray addObject:lBackgoundView];
        
        
        //number label
        UILabel *lQuestionLabel = [[UILabel alloc] initWithFrame:CGRectMake(lStartPoint,
                                                                            MARGIN,
                                                                            buttonWidth,
                                                                            topNumberLabelHeight)];
        lQuestionLabel.backgroundColor = [UIColor clearColor];
        lQuestionLabel.text = [_questionArray objectAtIndex:i];
        lQuestionLabel.font = [UIFont systemFontOfSize:8.0f];
        [lQuestionLabel setTextColor:[UIColor darkGrayColor]];
        [lQuestionLabel setTextAlignment:NSTextAlignmentRight];
        lQuestionLabel.frame  = CGRectIntegral(lQuestionLabel.frame);
        lQuestionLabel.adjustsFontSizeToFitWidth = YES;
        //lQuestionLabel.center = CGPointMake(round(lQuestionLabel.center.x), round(lQuestionLabel.center.y));
        [self addSubview:lQuestionLabel];
        [_questionLabelsArray addObject:lQuestionLabel];

        // button
        UIButton *lButton = [[UIButton alloc] initWithFrame:CGRectMake(lStartPoint,
                                                                       MARGIN + topButtonHeight + SMALL_MARGIN,
                                                                       buttonWidth,
                                                                       buttonHeight)];
        lButton.backgroundColor = [UIColor clearColor];
        [lButton setTitle:@"" forState:UIControlStateNormal];
        lButton.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        [lButton setTitleColor:BLUE_COLOR forState:UIControlStateNormal];
        [lButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [lButton.titleLabel setBaselineAdjustment:UIBaselineAdjustmentAlignCenters];
        [lButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        lButton.tag = i + 1;
        lButton.frame  = CGRectIntegral(lButton.frame);
        //lButton.center = CGPointMake(round(lButton.center.x), round(lButton.center.y));
        [self addSubview:lButton];
        [_answerButtonsArray addObject:lButton];

        // number button
        UIButton *lNumberButton = [[UIButton alloc] initWithFrame:CGRectMake(lStartPoint,
                                                                             MARGIN,
                                                                             buttonWidth,
                                                                             topButtonHeight)];
        lNumberButton.backgroundColor = [UIColor clearColor];
        [lNumberButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        lNumberButton.tag = i + 1;
        lNumberButton.frame  = CGRectIntegral(lNumberButton.frame);
        [self addSubview:lNumberButton];
        [_numberButtonsArray addObject:lNumberButton];

        UIView *lLineView = [[UIView alloc] initWithFrame:CGRectMake(lStartPoint + 1.0f,
                                                                     MARGIN + topButtonHeight + SMALL_MARGIN * 2 + buttonHeight,
                                                                     buttonWidth - 1.0f,
                                                                     1)];
        [lLineView setBackgroundColor:[UIColor lightGrayColor]];
        [self addSubview:lLineView];
        [_lineArray addObject:lLineView];
        
        
        lStartPoint = lStartPoint + buttonWidth + MARGIN;
    }
    
    //section letter label
    _letterLabel = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN,
                                                             MARGIN + 15.f,
                                                             headerLabelSize,
                                                             headerLabelSize)];
    _letterLabel.backgroundColor = [UIColor clearColor];
    _letterLabel.text = _sectionTitle;
    _letterLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    [_letterLabel setTextColor:[UIColor darkGrayColor]];
    [_letterLabel setTextAlignment:NSTextAlignmentCenter];
    _letterLabel.frame  = CGRectIntegral(_letterLabel.frame);
    //_letterLabel.center = CGPointMake(round(_letterLabel.center.x), round(_letterLabel.center.y));
    [self addSubview:_letterLabel];
 
    
    CGSize lFrameSize = [self getCurrentSize];
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, lFrameSize.width, lFrameSize.height)];
    
    
    //clue label
    _clueLabel = [[UILabel alloc] initWithFrame:CGRectMake(headerLabelSize + MARGIN * 2,
                                                           MARGIN * 2 + topButtonHeight + SMALL_MARGIN * 2 + buttonHeight,
                                                           lFrameSize.width - headerLabelSize - MARGIN * 2 - 3,
                                                           buttonHeight)];
    _clueLabel.numberOfLines = 10;
    _clueLabel.backgroundColor = [UIColor clearColor];
    _clueLabel.text = _clue;
    _clueLabel.font = [UIFont systemFontOfSize:12.0f];
    [_clueLabel setTextColor:[UIColor darkGrayColor]];
    [_clueLabel setTextAlignment:NSTextAlignmentLeft];
    _clueLabel.frame = [self sizeForLabel:_clueLabel withText:_clue maxWidth:_clueLabel.frame.size.width];
    _clueLabel.frame  = CGRectIntegral(_clueLabel.frame);
    //_clueLabel.center = CGPointMake(round(_clueLabel.center.x), round(_clueLabel.center.y));
    [self addSubview:_clueLabel];
}

//change size and font
- (void)changeFontAndSizeForMaxWidth:(CGFloat)maxWidth
                        sectionCount:(NSInteger)sectionCount
                      maxButtonCount:(NSInteger)maxButtonCount
                        decreaseFont:(BOOL)decreaseFont {
    
    buttonWidth = maxWidth / (sectionCount * (maxButtonCount + 1)) - MARGIN;
    if (decreaseFont) {
        buttonWidth = buttonWidth * 0.9f;
    }
    buttonHeight = buttonWidth;
    topButtonHeight = MIN(30.f - 5.f * sectionCount, buttonWidth * 0.5f);
    topNumberLabelHeight = topButtonHeight;
    headerLabelSize = buttonWidth + MARGIN * 2;
    
    
    CGFloat buttonFontSize = 7.f;
    
    NSInteger lStartPoint = headerLabelSize + MARGIN;
    for (NSInteger i = 0; i < [self.questionArray count]; i++) {
        UIView* lBackgoundView = self.backgroundsArray[i];
        lBackgoundView.frame = CGRectMake(lStartPoint,
                                          buttonWidth,
                                          buttonWidth,
                                          buttonWidth * 2.f);
        lBackgoundView.frame  = CGRectIntegral(lBackgoundView.frame);
        
        
        // question label
        UILabel* lQuestionLabel = self.questionLabelsArray[i];
        lQuestionLabel.frame = CGRectMake(lStartPoint,
                                          buttonWidth,
                                          buttonWidth - SMALL_MARGIN,
                                          topNumberLabelHeight);
        lQuestionLabel.frame  = CGRectIntegral(lQuestionLabel.frame);
        CGFloat lQuestionLabelFontSize = [ACAppDelegate fontSizeForString:@"88888" frame:lQuestionLabel.frame isBoldFont:NO];
        if (decreaseFont) {
            lQuestionLabelFontSize = lQuestionLabelFontSize - 1.f;
        }
        lQuestionLabel.font = [UIFont systemFontOfSize:lQuestionLabelFontSize];
        lQuestionLabel.hidden = (maxWidth < 420.f);
        
        
        // answer button
        UIButton* lButton = self.answerButtonsArray[i];
        lButton.frame = CGRectMake(lStartPoint,
                                   buttonWidth + buttonWidth,
                                   buttonWidth,
                                   buttonWidth);
        lButton.frame = CGRectIntegral(lButton.frame);
        buttonFontSize = lButton.frame.size.width;
        if (lButton.frame.size.width < 11.f)
            buttonFontSize = lButton.frame.size.width - 1.f;
        lButton.titleLabel.font = [UIFont boldSystemFontOfSize:buttonFontSize];
        lButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        
        
        // number button
        UIButton* lNumberButton = self.numberButtonsArray[i];
        lNumberButton.frame = CGRectMake(lStartPoint,
                                         buttonWidth,
                                         buttonWidth,
                                         topButtonHeight);
        lNumberButton.frame  = CGRectIntegral(lNumberButton.frame);
        
        
        // line
        UIView* lLineView = self.lineArray[i];
        lLineView.frame = CGRectMake(lStartPoint + 1.f,
                                     buttonWidth + buttonWidth * 2.f,
                                     buttonWidth - 1.f,
                                     1.f);
        
        
        lStartPoint = lStartPoint + buttonWidth + MARGIN;
    }
    
    
    //section letter label
    self.letterLabel.frame = CGRectMake(0.f,
                                        buttonWidth,
                                        headerLabelSize,
                                        headerLabelSize);
    self.letterLabel.frame  = CGRectIntegral(self.letterLabel.frame);
    CGFloat letterLabelFontSize = buttonFontSize * 0.9f;
    self.letterLabel.font = [UIFont boldSystemFontOfSize:letterLabelFontSize];
    
    
    CGSize lFrameSize = [self getCurrentSize];
    
    //clue label
    self.clueLabel.frame = CGRectMake(headerLabelSize + MARGIN,
                                      buttonWidth + buttonWidth * 2.5f,
                                      lFrameSize.width - headerLabelSize - MARGIN,
                                      buttonWidth);
    CGFloat clueLabelFontSize = buttonFontSize * 0.7f;
    if (sectionCount < 2)
        clueLabelFontSize = buttonFontSize * 0.6f;
    self.clueLabel.font = [UIFont systemFontOfSize:clueLabelFontSize];
    self.clueLabel.frame = [self sizeForLabel:self.clueLabel withText:self.clue maxWidth:self.clueLabel.frame.size.width];
    self.clueLabel.frame  = CGRectIntegral(self.clueLabel.frame);
    
    
    // self
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, lFrameSize.width, CGRectGetMaxY(self.clueLabel.frame))];
}

// return section size
- (CGSize)getCurrentSize {
    NSInteger lWidth = headerLabelSize;
    
    for (NSInteger i = 0; i < self.maxButtonCount; i++) {
        lWidth = lWidth + buttonWidth + MARGIN;
    }
    
    CGFloat lHeight = MARGIN*2 + topButtonHeight + SMALL_MARGIN * 2 + buttonHeight * 2 + MARGIN;
    return CGSizeMake(lWidth, lHeight);
}

//size for label
- (CGRect)sizeForLabel:(UILabel *)pLabel withText:(NSString *)pText maxWidth:(CGFloat)pMaxWidth {
    CGRect lResultRect = CGRectZero;
    CGSize lMaximumSize = CGSizeMake(pMaxWidth, 9999999);
    CGSize lExpectedSize = [pText boundingRectWithSize:lMaximumSize options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:pLabel.font} context:nil].size;
    lResultRect = CGRectMake(pLabel.frame.origin.x, pLabel.frame.origin.y, pMaxWidth, lExpectedSize.height);
    return lResultRect;
}

// pressed section button
- (void)buttonPressed:(id)sender{
    if ([sender isKindOfClass:[UIButton class]]) {
        [self setHighlightForSection];
        UIButton *lButton = (UIButton *)sender;
        self.buttonIndex = lButton.tag;
        
        if ([self.delegate respondsToSelector:@selector(setClueSectionActive:)]) {
            [self.delegate setClueSectionActive:self];
        }
        // send button number
        if ([self.delegate respondsToSelector:@selector(setNeedSelectNumber:)]) {
            [self.delegate setNeedSelectNumber:((UILabel*)[self.questionLabelsArray objectAtIndex:self.buttonIndex-1]).text];
        }
        if ([self.delegate respondsToSelector:@selector(scrollToSection:)]) {
            [self.delegate scrollToSection:self];
        }
        if ([self.delegate respondsToSelector:@selector(showKeyboardForSection:)]) {
            [self.delegate showKeyboardForSection:self];
        }
        [self setActiveStateForButton:lButton];
    }
}

- (void)activateButton:(id)sender{
    if ([sender isKindOfClass:[UIButton class]]) {
        [self setHighlightForSection];
        UIButton *lButton = (UIButton *)sender;
        self.buttonIndex = lButton.tag;
        if (self.delegate != nil) {
            if ([self.delegate respondsToSelector:@selector(setClueSectionActive:)]) {
                [self.delegate performSelector:@selector(setClueSectionActive:) withObject:self];
            }
            if ([self.delegate respondsToSelector:@selector(scrollToSection:)]) {
                [self.delegate performSelector:@selector(scrollToSection:) withObject:self];
            }
        }
		[self setActiveStateForButton:lButton];
    }
}

// set deselcted state for section
- (void)deselectSection{
    for (NSInteger i = 0; i < [self.answerButtonsArray count]; i++) {
        UIButton *lButton = [self.answerButtonsArray objectAtIndex:i];
        [self setUnactiveStateForButton:lButton];
    }
    self.buttonIndex = 0;
}

// set highlighted state for section
- (void)setHighlightForSection{
    for (NSInteger i = 0; i < [self.answerButtonsArray count]; i++) {
        UIButton *lButton = [self.answerButtonsArray objectAtIndex:i];
        [self setHighlitedStateForButton:lButton];
    }
    self.buttonIndex = 0;
}

// solve section
- (void)solveSection{
    for (NSInteger i = 0; i < [self.answerButtonsArray count]; i++) {
        UIButton *lButton = [self.answerButtonsArray objectAtIndex:i];
        [self setUnactiveStateForButton:lButton];
        lButton.enabled = NO;
        [lButton setTitle:[[NSString stringWithFormat:@"%C", [self.answer characterAtIndex:i]] uppercaseString] forState:UIControlStateNormal];
    }
}

// clear section
- (void)clearSection{
    for (NSInteger i = 0; i < [self.answerButtonsArray count]; i++) {
        UIButton *lButton = [self.answerButtonsArray objectAtIndex:i];
        [self setUnactiveStateForButton:lButton];
        [lButton setTitle:@"" forState:UIControlStateNormal];
    }
    self.buttonIndex = 0;
}

// get title for button with index
- (NSString *)getButtonTitleForIndex:(NSInteger)pIndex{
    NSString *lTitle = @"";
    for (NSInteger i = 0; i < [self.answerButtonsArray count]; i++) {
        UIButton *lButton = [self.answerButtonsArray objectAtIndex:i];
        if (lButton.tag == pIndex) {
            lTitle = [lButton titleForState:UIControlStateNormal];
        }
    }
    return lTitle;
}

// set highlighted state for button
- (void)setHighlitedStateForButton:(UIButton*)pButton{
    UIView *lView = [self.backgroundsArray objectAtIndex:pButton.tag - 1];
    [lView setBackgroundColor:SECONDARY_SELECTION_COLOR];
    [self bringSubviewToFront:[self.lineArray objectAtIndex:pButton.tag - 1]];
    [[lView layer] setBorderWidth:0.0f];
    [lView setClipsToBounds:YES];
}

// set active state for button
- (void)setActiveStateForButton:(UIButton *)pButton{
    UIView *lView = [self.backgroundsArray objectAtIndex:pButton.tag - 1];
    [self sendSubviewToBack:[self.lineArray objectAtIndex:pButton.tag - 1]];
    [lView setBackgroundColor:MAIN_SELECTION_COLOR];
    [[lView layer] setBorderWidth:0.0f];
    [[lView layer] setBorderColor:[UIColor blackColor].CGColor];
    [lView setClipsToBounds:YES];
}

// set unactive state for button
- (void)setUnactiveStateForButton:(UIButton *)pButton{
	if (pButton.isEnabled) {
        UIView *lView = [self.backgroundsArray objectAtIndex:pButton.tag - 1];        
        [self bringSubviewToFront:[self.lineArray objectAtIndex:pButton.tag - 1]];
		[lView setBackgroundColor:[UIColor whiteColor]];
		[[lView layer] setBorderWidth:0.0f];
	}
}

// select button with tag (like it pressed)
- (void)setSelectedButtonWithTag:(NSInteger)pButtonTag{
    for (NSInteger i = 0; i < [self.answerButtonsArray count]; i++) {
        UIButton *lButton = [self.answerButtonsArray objectAtIndex:i];
        if (pButtonTag != 0 && lButton.tag == pButtonTag) {
            [self buttonPressed:lButton];
        }
    }
}

// set letter for active button
- (void)setLetter:(NSString*)pLetter{
    for (NSInteger i = 0; i < [self.answerButtonsArray count]; i++) {
        UIButton *lButton = [self.answerButtonsArray objectAtIndex:i];
        if (lButton.tag == mButtonIndex){
            [lButton setTitle:pLetter forState:UIControlStateNormal];
        }
    }
}

// set active next button
- (BOOL)setActiveNextFreeButton:(BOOL)pFromStart{
    NSInteger lStartPoint = 0;
    if (!pFromStart) {
        lStartPoint = mButtonIndex;
    }
    
    if (lStartPoint < [self.answerButtonsArray count]) {
        UIButton *lButton = [self.answerButtonsArray objectAtIndex:lStartPoint];
        [self buttonPressed:lButton];
        return YES;
    }else{
        return NO;
    }
}

// set previous next button
- (BOOL)setActivePreviousButton:(BOOL)pFromStart{    
    if (pFromStart) {
        UIButton *lButton = [self.answerButtonsArray objectAtIndex:[self.answerButtonsArray count] - 1];
        [self buttonPressed:lButton];
        return YES;
    }else{
        DLog(@"mButtonIndex  - %@", @(mButtonIndex));
        if (mButtonIndex >= 2) {
            UIButton *lButton = [self.answerButtonsArray objectAtIndex:mButtonIndex - 2];
            [self buttonPressed:lButton];
            return YES;
        }else{
            return NO;
        }
    }
}

// set active button with number
- (void)setActiveButtonForNumber:(NSString*)pNumber{
    for (NSInteger i = 0; i < [self.answerButtonsArray count]; i++) {
        UIButton *lButton = [self.answerButtonsArray objectAtIndex:i];
        if ([((UILabel *)[self.questionLabelsArray objectAtIndex:i]).text isEqualToString:pNumber]){
            [self activateButton:lButton];
        }
    }
}

- (void)setActiveButtonForNumberWithoutDraw:(NSString*)pNumber{
    for (NSInteger i = 0; i < [self.answerButtonsArray count]; i++) {
        UIButton *lButton = [self.answerButtonsArray objectAtIndex:i];
        if ([((UILabel *)[self.questionLabelsArray objectAtIndex:i]).text isEqualToString:pNumber]){
            [self activateButton:lButton];
            [self setHighlightForSection];
            self.buttonIndex = lButton.tag;
            if (self.delegate != nil) {
                if ([self.delegate respondsToSelector:@selector(setClueSectionActive:)]) {
                    [self.delegate performSelector:@selector(setClueSectionActive:) withObject:self];
                }
                if ([self.delegate respondsToSelector:@selector(scrollToSection:)]) {
                    [self.delegate performSelector:@selector(scrollToSection:) withObject:self];
                }
            }
            UIView *lView = [self.backgroundsArray objectAtIndex:lButton.tag - 1];
            [lView setBackgroundColor:MAIN_SELECTION_COLOR];
            [lView setClipsToBounds:YES];
        }
    }
}
// set title for button with index
- (void)setTitle:(NSString*)pTitle forNumber:(NSString*)pNumber{
    for (NSInteger i = 0; i < [self.answerButtonsArray count]; i++) {
        UIButton *lButton = [self.answerButtonsArray objectAtIndex:i];
        if ([((UILabel *)[self.questionLabelsArray objectAtIndex:i]).text isEqualToString:pNumber]){
            [lButton setTitle:pTitle forState:UIControlStateNormal];
        }
    }
}


// remove title for selected button
- (void)removeSelectedTitle{
    for (NSInteger i = 0; i < [self.answerButtonsArray count]; i++) {
        UIButton *lButton = [self.answerButtonsArray objectAtIndex:i];
        if (lButton.tag == mButtonIndex){
            [lButton setTitle:@"" forState:UIControlStateNormal];
        }
    }
}

// remove title for button with index and return success/failed
- (BOOL)removeTitleForIndex:(NSInteger)pIndex{
//    DLog(@"-------------------------");
    for (NSInteger i = 0; i < [self.answerButtonsArray count]; i++) {
        UIButton *lButton = [self.answerButtonsArray objectAtIndex:i];
//        DLog(@" titles - :%@:", [lButton titleForState:UIControlStateNormal]);
        if ([((UILabel *)[self.questionLabelsArray objectAtIndex:i]).text isEqualToString:[NSString stringWithFormat:@"%@", @(pIndex)]]){
//            DLog(@"index  -%i", pIndex);
            if (![[lButton titleForState:UIControlStateNormal] isEqualToString:@""] && ![[lButton titleForState:UIControlStateNormal] isEqualToString:@" "]) {
                [lButton setTitle:@"" forState:UIControlStateNormal];
                return YES;
            }
        }
    }
    return NO;
}

- (NSString*)getQuestionNumberWith:(NSInteger)index {
    NSString* questionNumber = ((UILabel *)[self.questionLabelsArray objectAtIndex:index - 1]).text;
    return questionNumber;
}

@end
