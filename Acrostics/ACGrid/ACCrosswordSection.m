//
//  ACCrosswordSection.m
//  Acrostics
//
//  Created by Oleg.Sehelin on 13.11.12.
//  Copyright (c) 2012 A Gamz LLC. All rights reserved.
//

#import "ACCrosswordSection.h"
#import "ACAppDelegate.h"

#define LABEL_SIZE 17.0f
#define LABEL_SIZE_LANDSCAPE 15.0f

@interface ACCrosswordSection ()

@property (nonatomic) UILabel *answerLetterLabel;
@property (nonatomic) UILabel *numberLabel;
@property (nonatomic) UILabel *letterLabel;
@property (nonatomic) UIButton *button;

@end

@implementation ACCrosswordSection

@synthesize isActive;

- (id)initWithFrame:(CGRect)frame
{
    frame = CGRectIntegral(frame);
    self = [super initWithFrame:frame];
    return self;
}

- (id)initWithTitleNumber:(NSInteger)pNumber andTitleLetter:(NSString*)pLetter {
    self = [super initWithFrame:CGRectMake(0, 0, 50, 50)];
    self.clipsToBounds = YES;
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        CGFloat width = MIN(self.frame.size.width / 3.5f, LABEL_SIZE_LANDSCAPE);
        
        _answerLetterLabel = [[UILabel alloc] initWithFrame:CGRectMake(width * 0.5f, width, width * 2.5f, width * 2.5f)];
        _answerLetterLabel.frame  = CGRectIntegral(_answerLetterLabel.frame);
        _answerLetterLabel.backgroundColor = [UIColor whiteColor];
        _answerLetterLabel.font = [UIFont boldSystemFontOfSize:32.f];
        _answerLetterLabel.textAlignment = NSTextAlignmentCenter;
        _answerLetterLabel.textColor = BLUE_COLOR;
        _answerLetterLabel.userInteractionEnabled = NO;
        [self addSubview:_answerLetterLabel];
        
        _numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(1.f, 0.f, width * 2.f, width)];
        _numberLabel.frame  = CGRectIntegral(_numberLabel.frame);
        _numberLabel.backgroundColor = [UIColor whiteColor];
        _numberLabel.font = [UIFont systemFontOfSize:32.f];
        _numberLabel.text = [NSString stringWithFormat:@"%@",@(pNumber)];
        _numberLabel.textColor = [UIColor blackColor];
        _numberLabel.userInteractionEnabled = NO;
        [self addSubview:_numberLabel];
        
        _letterLabel = [[UILabel alloc] initWithFrame:CGRectMake(width * 2.5f - 1.f, 0.f, width, width)];
        _letterLabel.frame  = CGRectIntegral(_letterLabel.frame);
        _letterLabel.backgroundColor = [UIColor whiteColor];
        _letterLabel.font = [UIFont systemFontOfSize:32.f];
        _letterLabel.textAlignment = NSTextAlignmentRight;
        _letterLabel.text = pLetter;
        _letterLabel.textColor = [UIColor blackColor];
        _letterLabel.userInteractionEnabled = NO;
        [self addSubview:_letterLabel];
        
        _button = [[UIButton alloc] initWithFrame:self.frame];
        [_button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        _button.backgroundColor = [UIColor clearColor];
        _button.frame  = CGRectIntegral(_button.frame);
        _button.center = CGPointMake(round(_button.center.x), round(_button.center.y));
        [self addSubview:_button];
        
        CGFloat fontSize = [ACAppDelegate fontSizeForString:@"000" frame:_numberLabel.frame isBoldFont:NO];
        fontSize = MIN(fontSize, [ACAppDelegate fontSizeForString:@"W" frame:_letterLabel.frame isBoldFont:NO]);
        
        _numberLabel.font = [UIFont systemFontOfSize:fontSize];
        _letterLabel.font = [UIFont systemFontOfSize:fontSize];
        
        fontSize = [ACAppDelegate fontSizeForString:@"W" frame:_answerLetterLabel.frame isBoldFont:YES];
        _answerLetterLabel.font = [UIFont boldSystemFontOfSize:fontSize];
        
        
        _isEnable = YES;
    }
    
    return self;
}

- (void)setColor:(UIColor *)color
{
    self.backgroundColor = color;
    self.letterLabel.backgroundColor = color;
    self.numberLabel.backgroundColor = color;
    self.answerLetterLabel.backgroundColor = color;
}

- (void)buttonPressed:(id)pSender {
    [self setSectionActiveState];
    if ([self.delegate respondsToSelector:@selector(setActiveSectionWithTag:)]) {
        [self.delegate setActiveSectionWithTag:self.tag];
    }
    if ([self.delegate respondsToSelector:@selector(showKeyboard)]) {
        [self.delegate showKeyboard];
    }
}

//change size and font for different portrait orientations
- (void)changeFontAndSizeForAnotherPortrait {
    self.numberLabel.frame = CGRectMake(1.0f, 0.0f, LABEL_SIZE+5.0f, LABEL_SIZE);
    self.numberLabel.frame  = CGRectIntegral(self.numberLabel.frame);
    //mself.numberLabel.center = CGPointMake(round(mself.numberLabel.center.x), round(mself.numberLabel.center.y));
    self.numberLabel.font = [UIFont systemFontOfSize:10];
    
    self.letterLabel.frame = CGRectMake(self.frame.size.width-LABEL_SIZE, 0.0f, LABEL_SIZE, LABEL_SIZE);
    self.letterLabel.frame  = CGRectIntegral(self.letterLabel.frame);
    //mLetterLabel.center = CGPointMake(round(mLetterLabel.center.x), round(mLetterLabel.center.y));
    self.letterLabel.font = [UIFont systemFontOfSize:10];
    
    self.answerLetterLabel.frame = CGRectMake(8.0f, self.numberLabel.frame.size.height,self.frame.size.width- LABEL_SIZE, self.frame.size.height - LABEL_SIZE-2.0f);
    self.answerLetterLabel.font = [UIFont boldSystemFontOfSize:20];

}

//change size and font for different orientations
- (void)changeFontAndSizeForLandscape:(BOOL)pValue sectionCount:(int)sectionCount {
    if (pValue == NO) {
        self.numberLabel.frame = CGRectMake(1.0f, 0.0f, LABEL_SIZE+5.0f, LABEL_SIZE);
        self.numberLabel.frame  = CGRectIntegral(self.numberLabel.frame);
        //mself.numberLabel.center = CGPointMake(round(mself.numberLabel.center.x), round(mself.numberLabel.center.y));
        self.numberLabel.font = [UIFont systemFontOfSize:12];
        
        self.letterLabel.frame = CGRectMake(self.frame.size.width-LABEL_SIZE, 0.0f, LABEL_SIZE, LABEL_SIZE);
        self.letterLabel.frame  = CGRectIntegral(self.letterLabel.frame);
        //mLetterLabel.center = CGPointMake(round(mLetterLabel.center.x), round(mLetterLabel.center.y));
        self.letterLabel.font = [UIFont systemFontOfSize:12];

        self.answerLetterLabel.frame = CGRectMake(8.0f, self.numberLabel.frame.size.height,self.frame.size.width- LABEL_SIZE, self.frame.size.height - LABEL_SIZE-2.0f);
        self.answerLetterLabel.font = [UIFont boldSystemFontOfSize:32 - 2 * (sectionCount - GridSectionCount_Portrait_Min)];
    } else {
        self.numberLabel.frame = CGRectMake(1.0f, 0.0f, LABEL_SIZE_LANDSCAPE+5.0f, LABEL_SIZE_LANDSCAPE);
        self.numberLabel.frame  = CGRectIntegral(self.numberLabel.frame);
        //mself.numberLabel.center = CGPointMake(round(mself.numberLabel.center.x), round(mself.numberLabel.center.y));
        self.numberLabel.font = [UIFont systemFontOfSize:10];
        
        self.letterLabel.frame = CGRectMake(self.frame.size.width-(LABEL_SIZE_LANDSCAPE-2.0f), 0.0f, LABEL_SIZE_LANDSCAPE-3.0f, LABEL_SIZE_LANDSCAPE);
        self.letterLabel.frame  = CGRectIntegral(self.letterLabel.frame);
        //mLetterLabel.center = CGPointMake(round(mLetterLabel.center.x), round(mLetterLabel.center.y));
        self.letterLabel.font = [UIFont systemFontOfSize:10];
        
        self.answerLetterLabel.frame = CGRectMake(7.0f, self.numberLabel.frame.size.height,self.frame.size.width- LABEL_SIZE_LANDSCAPE, self.frame.size.height - LABEL_SIZE_LANDSCAPE-2.0f);
        self.answerLetterLabel.font = [UIFont boldSystemFontOfSize:28 - (sectionCount - GridSectionCount_Landscape_Min)];

    }
}

- (void)changeFontAndSizeForMaxWidth:(CGFloat)maxWidth numberFontSize:(CGFloat)numberFontSize answerFontSize:(CGFloat)answerFontSize {
    
    CGFloat width = MIN(self.frame.size.width / 3.5f, LABEL_SIZE_LANDSCAPE);
    
    self.numberLabel.frame = CGRectMake(2.5f, 1.f, width * 2.f, width);
    self.numberLabel.frame  = CGRectIntegral(self.numberLabel.frame);
    self.numberLabel.adjustsFontSizeToFitWidth = YES;
    self.numberLabel.minimumScaleFactor = 0.1f;
    self.numberLabel.font = [UIFont systemFontOfSize:numberFontSize];
    
    self.letterLabel.frame = CGRectMake(width * 2.5f - 2.5f, 1.f, width, width);
    self.letterLabel.frame  = CGRectIntegral(self.letterLabel.frame);
    self.letterLabel.adjustsFontSizeToFitWidth = YES;
    self.letterLabel.minimumScaleFactor = 0.1f;
    self.letterLabel.font = [UIFont systemFontOfSize:numberFontSize];
    
    if (maxWidth < 420.f) {
        self.numberLabel.alpha = 0.f;
        self.letterLabel.alpha = 0.f;
        
        self.answerLetterLabel.frame = CGRectMake(width * 0.25f, width * 0.5f, width * 3.f, width * 3.f);
        self.answerLetterLabel.frame  = CGRectIntegral(self.answerLetterLabel.frame);
        self.answerLetterLabel.adjustsFontSizeToFitWidth = YES;
        self.answerLetterLabel.minimumScaleFactor = 0.1f;
        self.answerLetterLabel.font = [UIFont boldSystemFontOfSize:answerFontSize];
    }
    else {
        self.numberLabel.alpha = 1.f;
        self.letterLabel.alpha = 1.f;
        
        self.answerLetterLabel.frame = CGRectMake(width * 0.5f, width, width * 2.5f, width * 2.5f);
        self.answerLetterLabel.frame  = CGRectIntegral(self.answerLetterLabel.frame);
        self.answerLetterLabel.adjustsFontSizeToFitWidth = YES;
        self.answerLetterLabel.minimumScaleFactor = 0.1f;
        self.answerLetterLabel.font = [UIFont boldSystemFontOfSize:answerFontSize];
    }
}

#pragma mark -Button method-
- (void)setSectionActiveState {
//    self.backgroundColor = MAIN_SELECTION_COLOR;
    [self setColor:MAIN_SELECTION_COLOR];
    self.isActive = YES;
}

#pragma mark -Public methods-
- (void)setSameSectionSate {
//    self.backgroundColor = SECONDARY_SELECTION_COLOR;
    [self setColor:SECONDARY_SELECTION_COLOR];
}

- (void)deselectSection {
//    self.backgroundColor = [UIColor whiteColor];
    [self setColor:[UIColor whiteColor]];
    self.isActive = NO;
}

//disable selection for current section
- (void)unactiveSection {
    [self deselectSection];
    self.button.enabled = NO;
}

- (void)setLetter:(NSString*)pLetter {
    self.answerLetterLabel.text = pLetter;
}

- (void)setPunctuation:(NSString*)pPunctuation {
    self.backgroundColor = GRID_BACKGROUND_COLOR;
    self.letterLabel.hidden = YES;
    self.numberLabel.hidden = YES;
    self.answerLetterLabel.textColor = [UIColor whiteColor];
    self.answerLetterLabel.backgroundColor = [UIColor clearColor];
    self.answerLetterLabel.text = pPunctuation;
    
    for (NSUInteger i=0; i<[[self subviews] count]; i++) {
        if ([[[self subviews] objectAtIndex:i] class] == [UIButton class]) {
            ((UIButton*)[[self subviews] objectAtIndex:i]).enabled = NO;
            break;
        }
    }
    self.isEnable = NO;
}

- (void)setGap {
    self.backgroundColor = [UIColor clearColor];
    self.letterLabel.hidden = YES;
    self.numberLabel.hidden = YES;
    self.answerLetterLabel.hidden = YES;
    
    for (NSUInteger i=0; i<[[self subviews] count]; i++) {
        if ([[[self subviews] objectAtIndex:i] class] == [UIButton class]) {
            ((UIButton*)[[self subviews] objectAtIndex:i]).enabled = NO;
            break;
        }
    }
    self.isEnable = NO;
}

- (NSString *)returnCornerLetter {
    return self.letterLabel.text;
}

- (NSString *)returnAnswerLetter {
    return self.answerLetterLabel.text;
}

@end
