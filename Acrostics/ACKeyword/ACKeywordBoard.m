//
//  ACKeywordBoard.m
//  Acrostics
//
//  Created by Oleg.Sehelin on 15.11.12.
//  Copyright (c) 2012 A Gamz LLC. All rights reserved.
//

#import "ACKeywordBoard.h"
#import "ACAppDelegate.h"
#import <QuartzCore/QuartzCore.h>

#define MAX_BUTTON_HEIGHT 23
#define BUTTON_HEIGHT 27
#define MARGIN 7
#define BUTTON_NEW_HEIGHT 27
#define BORDER_HEIGHT 5.f

@interface ACKeywordBoard ()

@property (nonatomic) NSMutableArray *keywordButtonsArray;
@property (nonatomic) NSMutableArray *linesArray;
@property (nonatomic) UIView *containerView;
@property (nonatomic) UILabel *keytypeLabel;

//check if all sections full
- (BOOL) checkIsAllSectionsFull;

//run to next free section
- (void) runToNextSectionWithTag:(NSInteger)pTag;

@end

@implementation ACKeywordBoard

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    self.backgroundColor = [UIColor whiteColor];
    
}

#pragma mark -Public methods-

// init method
- (void) initWithIndexArray:(NSArray*)pIndexArray andKeytype:(NSString*)pKeytype {
    
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    UIView* topBorder = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                 0.f,
                                                                 self.frame.size.width,
                                                                 BORDER_HEIGHT)];
    [topBorder setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin];
    topBorder.backgroundColor = BLUE_COLOR;
    [self addSubview:topBorder];
    
    UIView* bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                    self.frame.size.height - BORDER_HEIGHT,
                                                                    self.frame.size.width,
                                                                    BORDER_HEIGHT)];
    [bottomBorder setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin];
    bottomBorder.backgroundColor = BLUE_COLOR;
    [self addSubview:bottomBorder];
    
    
    _keywordButtonsArray = [[NSMutableArray alloc] init];
    _linesArray = [[NSMutableArray alloc] init];
    
    _activeSection = -1;
    
    self.buttonWidth = MAX_BUTTON_HEIGHT;
    
    NSInteger lStartPoint = MARGIN;
    
    // container view    
    _containerView = [[UIView alloc] init];
    _containerView.backgroundColor = [UIColor clearColor];
    _containerView.frame = CGRectMake(0.f, 0.f, [pIndexArray count] * (self.buttonWidth + MARGIN) - MARGIN, self.frame.size.height);
    [self addSubview:_containerView];
    
    // keytype label
    _keytypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0,
                                                              MARGIN + BUTTON_HEIGHT + BORDER_HEIGHT,
                                                              _containerView.frame.size.width,
                                                              _containerView.frame.size.height - (MARGIN + BUTTON_HEIGHT + 2 * BORDER_HEIGHT))];
    _keytypeLabel.backgroundColor = [UIColor clearColor];
    _keytypeLabel.numberOfLines = 0;
    _keytypeLabel.textAlignment = NSTextAlignmentCenter;
    _keytypeLabel.textColor = [UIColor darkGrayColor];
    _keytypeLabel.font = [UIFont boldSystemFontOfSize:13];
    _keytypeLabel.text = [NSString stringWithFormat:@"Keywords: %@", pKeytype];
    [_keytypeLabel sizeToFit];
    [_containerView addSubview:_keytypeLabel];
    _keytypeLabel.frame  = CGRectIntegral(_keytypeLabel.frame);
    _keytypeLabel.center = CGPointMake(round(_keytypeLabel.center.x), round(_keytypeLabel.center.y));

    for (NSInteger i = 0; i < [pIndexArray count]; i++) {
        
        // button
        UIButton *lButton = [[UIButton alloc] initWithFrame:CGRectMake(lStartPoint,
                                                                       MARGIN + BORDER_HEIGHT,
                                                                       self.buttonWidth,
                                                                       BUTTON_HEIGHT + 1.f)];
        lButton.backgroundColor = [UIColor whiteColor];
        [lButton setTitle:@"" forState:UIControlStateNormal];
        lButton.titleLabel.font = [UIFont boldSystemFontOfSize:20.0f];
        [lButton setTitleColor:BLUE_COLOR forState:UIControlStateNormal];
        [lButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [lButton.titleLabel setBaselineAdjustment:UIBaselineAdjustmentNone];
        [lButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        lButton.tag = [[pIndexArray objectAtIndex:i] integerValue];
        lButton.frame  = CGRectIntegral(lButton.frame);
        
        [_containerView addSubview:lButton];
        [_keywordButtonsArray addObject:lButton];
        
        UIView *lLineView = [[UIView alloc] initWithFrame:CGRectMake(lStartPoint + 1.f,
                                                                     MARGIN + BORDER_HEIGHT + BUTTON_HEIGHT,
                                                                     self.buttonWidth - 1.f,
                                                                     1.f)];
        [lLineView setBackgroundColor:[UIColor lightGrayColor]];
        [_containerView addSubview:lLineView];
        [_linesArray addObject:lLineView];

        lStartPoint = lStartPoint + self.buttonWidth + MARGIN;
    }
}

// draw conteiner label in center
- (void) moveToCenter:(CGFloat)width {
    
    NSInteger buttonCount = [self.keywordButtonsArray count];
    if (buttonCount == 0)
        return;
    
    CGFloat defaultContainerWidth = buttonCount * (MAX_BUTTON_HEIGHT + MARGIN) - MARGIN;
    CGFloat containerWidth = MIN(width * 4 / 5, defaultContainerWidth);
    CGFloat rate = containerWidth * 1.f / defaultContainerWidth;
    CGFloat newButtonWidth = MAX_BUTTON_HEIGHT * rate;
    
    if (self.buttonWidth == newButtonWidth) {
        self.containerView.frame = CGRectMake(self.center.x - containerWidth / 2,
                                          self.containerView.frame.origin.y,
                                          containerWidth,
                                          self.containerView.frame.size.height);
        
        self.keytypeLabel.frame = CGRectMake(0.0,
                                         MARGIN + BUTTON_HEIGHT + BORDER_HEIGHT,
                                         containerWidth,
                                         self.containerView.frame.size.height - (MARGIN + BUTTON_HEIGHT + 2 * BORDER_HEIGHT));
        self.keytypeLabel.frame  = CGRectIntegral(self.keytypeLabel.frame);
        self.keytypeLabel.center = CGPointMake(round(self.keytypeLabel.center.x), round(self.keytypeLabel.center.y));
    }
    else {
        self.buttonWidth = newButtonWidth;
        
        CGFloat fontSize = [ACAppDelegate fontSizeForString:@"W" frame:CGRectMake(0.f, 0.f, self.buttonWidth, self.buttonWidth) isBoldFont:YES];
        fontSize = MIN(fontSize, 20.f);
        
        NSInteger lStartPoint = 0.f;
        for (NSInteger i = 0; i < buttonCount; i++) {
            
            // button
            UIButton *lButton = [self.keywordButtonsArray objectAtIndex:i];
            lButton.frame = CGRectMake(lStartPoint,
                                       MARGIN + BORDER_HEIGHT,
                                       self.buttonWidth,
                                       BUTTON_HEIGHT + 1.f);
            lButton.frame  = CGRectIntegral(lButton.frame);
            lButton.titleLabel.font = [UIFont boldSystemFontOfSize:fontSize];
            
            UIView *lLineView = [self.linesArray objectAtIndex:i];
            lLineView.frame = CGRectMake(lStartPoint + 1.f,
                                         MARGIN + BORDER_HEIGHT + BUTTON_HEIGHT,
                                         self.buttonWidth - 1.f,
                                         1.f);
            
            lStartPoint = lStartPoint + self.buttonWidth + MARGIN * rate;
        }
        
        self.containerView.frame = CGRectMake(self.center.x - containerWidth / 2,
                                          self.containerView.frame.origin.y,
                                          containerWidth,
                                          self.containerView.frame.size.height);
        
        self.keytypeLabel.frame = CGRectMake(0.0,
                                         MARGIN + BUTTON_HEIGHT + BORDER_HEIGHT,
                                         containerWidth,
                                         self.containerView.frame.size.height - (MARGIN + BUTTON_HEIGHT + 2 * BORDER_HEIGHT));
        self.keytypeLabel.frame  = CGRectIntegral(self.keytypeLabel.frame);
        self.keytypeLabel.center = CGPointMake(round(self.keytypeLabel.center.x), round(self.keytypeLabel.center.y));
        
        
    }
}

// set active section if it has corect tag
- (void)setActiveSectionIfPossibleForCurrentTag:(NSInteger)pTag andDrawBorder:(BOOL)pValue{
    for (NSUInteger i = 0; i < [self.keywordButtonsArray count]; i++) {
        UIButton *button = self.keywordButtonsArray[i];
        if ([button isMemberOfClass:[UIButton class]] && button.tag == pTag) {
            self.activeSection = i;
            button.backgroundColor = MAIN_SELECTION_COLOR;
            if (pValue) {
                button.layer.borderWidth = 2.0;
                button.layer.borderColor = [UIColor blackColor].CGColor;
                [self.containerView bringSubviewToFront:button];
            }
        }
    }
}

// set highlight section if user select another letter than first from glue
- (void) setHighlightSection:(NSInteger)pTag {
    [self deselectSection];
    [self.containerView sendSubviewToBack:(UIButton*)[self.keywordButtonsArray objectAtIndex:pTag]];
    ((UIButton*)[self.keywordButtonsArray objectAtIndex:pTag]).backgroundColor = SECONDARY_SELECTION_COLOR;
}

// deselect active section
- (void) deselectSection {
    for (NSUInteger i=0; i<[self.keywordButtonsArray count]; i++) {
        if ([[self.keywordButtonsArray objectAtIndex:i] class] == [UIButton class]) {
            [self.containerView sendSubviewToBack:(UIButton*)[self.keywordButtonsArray objectAtIndex:i]];
            ((UIButton*)[self.keywordButtonsArray objectAtIndex:i]).backgroundColor = [UIColor whiteColor];
            [[(UIButton*)[self.keywordButtonsArray objectAtIndex:i] layer] setBorderWidth:0.0f];
        }
    }
}

//set letter in active section
- (void) setLetter:(NSString*)pLetter andNeedActivateNext:(BOOL)pValue {
    if (pValue) {
        if (self.activeSection != -1) {
            [((UIButton*)[self.keywordButtonsArray objectAtIndex:self.activeSection]) setTitle:pLetter forState:UIControlStateNormal];
            
            if (pValue == YES) {
                [self deselectSection];
                [self runToNextSectionWithTag:self.activeSection];
            } else {
                self.activeSection = -1;
            }
        }
    } else {
        for (NSUInteger i=0; i<[self.keywordButtonsArray count]; i++) {
            if (((UIButton*)[self.keywordButtonsArray objectAtIndex:i]).tag == self.activeSection) {
                [((UIButton*)[self.keywordButtonsArray objectAtIndex:i]) setTitle:pLetter forState:UIControlStateNormal];
                break;
            }
        }
    }
}

- (void) clearSectionWithTag:(NSInteger)pTag {
    for (NSUInteger i=0; i<[self.keywordButtonsArray count]; i++) {
        if (((UIButton*)[self.keywordButtonsArray objectAtIndex:i]).tag == pTag) {
            [((UIButton*)[self.keywordButtonsArray objectAtIndex:i]) setTitle:@"" forState:UIControlStateNormal];
        }
    }
}

//clear section at index
- (void) clearSectionWithTag:(NSInteger)pTag andRunToPrevious:(BOOL)pValue{
    for (NSUInteger i=0; i<[self.keywordButtonsArray count]; i++) {
        if (((UIButton*)[self.keywordButtonsArray objectAtIndex:i]).tag == pTag) {
            if ([[(UIButton*)[self.keywordButtonsArray objectAtIndex:i] titleForState:UIControlStateNormal] isEqualToString:@""] == NO  && [[(UIButton*)[self.keywordButtonsArray objectAtIndex:i] titleForState:UIControlStateNormal] isEqualToString:@" "] == NO) {
                [((UIButton*)[self.keywordButtonsArray objectAtIndex:i]) setTitle:@"" forState:UIControlStateNormal];
            } else {
                if (pValue == YES) {
                    self.activeSection--;
                    if (self.activeSection < 0) {
                        self.activeSection = [self.keywordButtonsArray count]-1;
                    }
                    
                    [self deselectSection];
                    [self setActiveSectionIfPossibleForCurrentTag:((UIButton*)[self.keywordButtonsArray objectAtIndex:self.activeSection]).tag andDrawBorder:YES];
                    [(UIButton*)[self.keywordButtonsArray objectAtIndex:self.activeSection] setTitle:@"" forState:UIControlStateNormal];
                    
                    if ([self.delegate respondsToSelector:@selector(setKeywordBoardActive:)]) {
                        [self.delegate setKeywordBoardActive:((UIButton*)[self.keywordButtonsArray objectAtIndex:self.activeSection]).tag];
                    }
                }
            }
        }
    }
}

// set letter for current cell if possible
- (void) setLetter:(NSString*)pLetter toSectionWithTagIfPossible:(NSInteger)pTag {
    for (NSUInteger i=0; i<[self.keywordButtonsArray count]; i++) {
        if (((UIButton*)[self.keywordButtonsArray objectAtIndex:i]).tag == pTag) {
            [(UIButton*)[self.keywordButtonsArray objectAtIndex:i] setTitle:pLetter forState:UIControlStateNormal];
        }
    }
}

//solve game
- (void) solveGame {
    [self deselectSection];
    for (NSUInteger i=0; i<[self.keywordButtonsArray count]; i++) {
        [(UIButton*)[self.keywordButtonsArray objectAtIndex:i] setTitle:[self.answer substringWithRange:NSMakeRange(i, 1)] forState:UIControlStateNormal];
        ((UIButton*)[self.keywordButtonsArray objectAtIndex:i]).enabled = NO;
    }
}

#pragma mark -Private methods-
//check if all sections full
- (BOOL) checkIsAllSectionsFull {
    BOOL isFull = NO;
    for (NSUInteger i=0; i<[self.keywordButtonsArray count]; i++) {
        if ([[(UIButton*)[self.keywordButtonsArray objectAtIndex:i] titleForState:UIControlStateNormal] isEqualToString:@""] == NO && [[(UIButton*)[self.keywordButtonsArray objectAtIndex:i] titleForState:UIControlStateNormal] isEqualToString:@" "] == NO) {
            isFull = YES;
        } else {
            isFull = NO;
            break;
        }
    }
    return isFull;
}

// button pressed method
-(void) buttonPressed:(id)pSender {
    for (NSUInteger i=0; i<[self.keywordButtonsArray count]; i++) {
        if (((UIButton*)[self.keywordButtonsArray objectAtIndex:i]).tag == ((UIButton*)pSender).tag) {
            self.activeSection = i;
            [self deselectSection];
            [self setActiveSectionIfPossibleForCurrentTag:((UIButton*)pSender).tag andDrawBorder:YES];
            
            if ([self.delegate respondsToSelector:@selector(setKeywordBoardActive:)]) {
                [self.delegate setKeywordBoardActive:((UIButton*)pSender).tag];
            }
            if ([self.delegate respondsToSelector:@selector(showKeyboard)]) {
                [self.delegate showKeyboard];
            }
        }
    }
}

//run to next free section
- (void) runToNextSectionWithTag:(NSInteger)pTag {
    pTag++;
    if (pTag > [self.keywordButtonsArray count]-1) {
        pTag = 0;
    }
    
    [self setActiveSectionIfPossibleForCurrentTag:((UIButton*)[self.keywordButtonsArray objectAtIndex:pTag]).tag andDrawBorder:YES];
    if ([self.delegate respondsToSelector:@selector(setKeywordBoardActive:)]) {
        [self.delegate setKeywordBoardActive:((UIButton*)[self.keywordButtonsArray objectAtIndex:pTag]).tag];
    }
}

- (void)clearBoard {
    for (NSUInteger i=0; i<[self.keywordButtonsArray count]; i++) {
        [((UIButton*)[self.keywordButtonsArray objectAtIndex:i]) setTitle:@"" forState:UIControlStateNormal];
    }
    [self deselectSection];
}

@end
