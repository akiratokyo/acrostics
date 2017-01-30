//  Copyright (c) 2012-2015 Egghead Games LLC. All rights reserved.

#define KEYWORD_HEIGHT      74
#define TITLE_WIDTH         240.f
#define STAR_IMAGE_WIDTH    30.f
#define MARGIN_OF_STAR      5.f
#define MARGIN              10.f

#import <QuartzCore/CALayer.h>
#import "ACGamePlayViewController.h"
#import "ACPackageViewController.h"
#import "ACGameListViewController.h"
#import "ACKeywordBoard.h"
#import "ACAppDelegate.h"
#import <AskingPoint/AskingPoint.h>
#import "MultiSelectSegmentedControl.h"
#import "Acrostics-Swift.h"

@interface ACGamePlayViewController () <MultiSelectSegmentedControlDelegate> {
    
    /*InputSourceType
     -1  - nothing
     0  - ACCluesBoard
     1  - ACKeywordsBoard
     2  - ACCrosswordBoard */
    NSInteger mInputSourceType;
    
    NSInteger mSelectedIndex;
        
    BOOL isOnlyOneUndo;
    BOOL isHintPressed;
}

@property (weak, nonatomic) IBOutlet ACCrosswordBoard *gameBoard;
@property (weak, nonatomic) IBOutlet ACCluesBoard *cluesBoard;
@property (weak, nonatomic) IBOutlet ACKeywordBoard *keywordBoard;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *tryAnotherButton;
@property (nonatomic) NSDate *startGameDate;

@property (weak, nonatomic) IBOutlet UIView* headerView;
@property (weak, nonatomic) IBOutlet UIView* titleWrapper;
@property (weak, nonatomic) IBOutlet UILabel* titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *mStateView;
@property (weak, nonatomic) IBOutlet UIView* sheetView;
@property (weak, nonatomic) IBOutlet UIButton* sourceView;
@property (weak, nonatomic) IBOutlet UIView* keywordBoardWrapper;
@property (weak, nonatomic) IBOutlet UIVisualEffectView* visualBackView;
@property (weak, nonatomic) IBOutlet UIView* borderView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint* gameBoardTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* gameBoardHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* keywordBoardTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* cluesBoardTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* cluesBoardBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* gameControlCenterConstraint;

@property (weak, nonatomic) IBOutlet MultiSelectSegmentedControl *gameControl;

@property (nonatomic) CGFloat orgWidth;
@property (nonatomic) int orgCount;
@property (nonatomic) int cluesOrgCount;
@property (nonatomic) int orgGridDiffCount;

@property (nonatomic) BOOL didAppeared;

@property (nonatomic) NSInteger puzzleNum;

@property (nonatomic) CGRect keyboardFrame;

- (void)setCorrectFrames:(UIInterfaceOrientation)pOrientation;

@end


@implementation ACGamePlayViewController

- (void)dealloc
{
    _keywordBoard.delegate = nil;
    _gameBoard.delegate = nil;
    [_level removeObserver:self forKeyPath:@"undo"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    setVal(QUIT_PUZZLE, [NSNumber numberWithBool:YES]);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    setVal(QUIT_PUZZLE, @NO);
    
    self.puzzleNum = [ACAppDelegate puzzleNumForDbid:self.level.dbId];
    [self initHeader];
    [self initGameControl];
    
    [self setComponentsVisible:NO];
    [self setComponentsHiden:YES];
    
    UISwipeGestureRecognizer *lSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] init];
    [lSwipeGestureRecognizer addTarget:self action:@selector(backPressed)];
    [lSwipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:lSwipeGestureRecognizer];
    
    [self.level addObserver:self forKeyPath:@"undo" options:1 context:NULL];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationBecameActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationBecameInActive:) name:UIApplicationWillResignActiveNotification object:nil];
    
    if ([self.level.dbStatus integerValue] == 1) {
		self.startGameDate = [NSDate date];
	}
    
    [self.gameBoard setAutoresizingMask:0];
    [self.keywordBoard setAutoresizingMask:0];

    if ([self.level.dbStatus intValue] == ACGameState_Solved) {
        [self showCongratulationVC];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    if (self.level.dbId) {
        [ASKPManager addEventWithName:@"solve" andData:@{@"puzzleID": [self getPuzzleId]}];
        [ASKPManager requestCommandsWithTag:@"solve"];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.didAppeared) {
        [self refreshUI];
    } else {
        [self initGameData];
    }
    self.didAppeared = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)initHeader {
    self.titleLabel.text = [NSString stringWithFormat:@"Puzzle %ld", (long) self.puzzleNum];
    self.title = [NSString stringWithFormat:@"Puzzle %ld", (long) self.puzzleNum];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
    self.mStateView.image = [ACAppDelegate getPuzzleStateImage:self.level];
}

- (void)initGameControl {
    
    self.gameControl.delegate = self;
    
    if (CGRectGetWidth(self.view.frame) < 420.f) {
        NSMutableIndexSet* indexSet = [NSMutableIndexSet indexSet];
        [indexSet addIndex:0];
        [indexSet addIndex:2];
        [self.gameControl setSelectedSegmentIndexes:indexSet];
        
        self.keywordBoardTopConstraint.constant = -CGRectGetHeight(self.keywordBoard.frame);
        self.keywordBoard.userInteractionEnabled = NO;
    }
    else {
        NSMutableIndexSet* indexSet = [NSMutableIndexSet indexSet];
        [indexSet addIndex:0];
        [indexSet addIndex:1];
        [indexSet addIndex:2];
        [self.gameControl setSelectedSegmentIndexes:indexSet];
        
        self.keywordBoardTopConstraint.constant = 0.f;
        self.keywordBoard.userInteractionEnabled = YES;
    }
}

- (void)initGameData{
    [self.gameBoard initLevelDataWithQuestion:self.level.dbQuotation
                               lettersNumbers:self.level.dbLettersArray
                                    andAnswer:self.level.dbFinalQuotation];
    self.gameBoard.delegate = self;
    self.orgGridDiffCount = self.gameBoard.maxSectionCount - self.gameBoard.sectionCount;
    
    NSArray *lCluesArrayDB = [[ACDatabaseWrapper initialize] readLevelClues:self.level.dbId];
    NSMutableArray *lClues = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *lAnswers = [NSMutableArray arrayWithCapacity:0];
    for (NSInteger i = 0; i < lCluesArrayDB.count; i++) {
        DBClues *lClue = (DBClues *)[lCluesArrayDB objectAtIndex:i];
        [lClues addObject:lClue.dbClue];
        [lAnswers addObject:lClue.dbAnswer];
    }
    
    NSArray *lKeyWordsDB = [[ACDatabaseWrapper initialize] readLevelKeyWords:self.level.dbId];
    NSMutableDictionary *lQuestions = [NSMutableDictionary dictionaryWithCapacity:0];
    NSInteger firstButtonIndex = 0;
    for (NSInteger i = 0; i < lKeyWordsDB.count; i++) {
        DBKeyWords *lKeyWords = [lKeyWordsDB objectAtIndex:i];
        NSArray *components = [lKeyWords.dbKeyWord componentsSeparatedByString:@","];
        if (i == 0) {
            firstButtonIndex = [components[0] integerValue];
        }
        [lQuestions setObject:components
                       forKey:[NSString stringWithFormat:@"%@", @(i + 1)]];
    }
    
    DLog(@"self.level.dbQuotation   - %@", self.level.dbQuotation);
    
    [self.cluesBoard initBoardWithClues:lClues questions:lQuestions andAnswers:lAnswers maxWidth:CGRectGetWidth(self.view.frame)];
    self.cluesBoard.mDelegate = self;
    mInputSourceType = 0;
  
    NSMutableArray *lKeywordArray = [NSMutableArray arrayWithCapacity:0];
    for (NSInteger i = 0; i < [lClues count]; i++) {
        [lKeywordArray addObject:[[lQuestions objectForKey:[NSString stringWithFormat:@"%@", @(i+1)]]  objectAtIndex:0]];
    }

    [self.keywordBoard initWithIndexArray:lKeywordArray andKeytype:self.level.dbKeyType];
    self.keywordBoard.delegate = self;
    self.keywordBoard.answer = self.level.dbKey;

    if ([self.level.dbStatus intValue] == ACGameState_Solved) {
        [self.view bringSubviewToFront:self.visualBackView];
    }
    
    [self restorePreviousStateWithFirstButtonIndex:firstButtonIndex];
    mInputSourceType = 0;
    
    if ([self.level.dbStatus intValue] != ACGameState_Solved) {
        [self performSelector:@selector(showKeyboard) withObject:nil];
    }
}

- (void)clearGame {
    [self initHeader];
    [self.gameBoard clearBoard];
    [self.keywordBoard clearBoard];
    [self.cluesBoard clearBoard];
}

- (void)setComponentsVisible:(BOOL)pActive {
    CGFloat lAlpha = 0.0f;
    if (pActive) {
        lAlpha = 1.0f;
    }
    self.gameBoard.alpha = lAlpha;
    self.cluesBoard.alpha = lAlpha;
    self.keywordBoard.alpha = lAlpha;
    self.borderView.alpha = lAlpha;
}

- (void)setComponentsHiden:(BOOL)pHiden {
    self.gameBoard.hidden = pHiden;
    self.cluesBoard.hidden = pHiden;
    self.keywordBoard.hidden = pHiden;
    self.borderView.hidden = pHiden;
}

- (void)removeGameListVC {
    NSMutableArray* viewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    for (UIViewController* vc in viewControllers) {
        if (!vc)
            continue;
        
        if ([vc isKindOfClass:[ACGameListViewController class]]) {
            [viewControllers removeObject:vc];
            break;
        }
        
        if ([vc isKindOfClass:[ACPackageViewController class]]) {
            vc.navigationItem.backBarButtonItem.title = [NSString stringWithFormat:@"Volume %ld", (long) [ACAppDelegate getCurrentPackage] + 1];
        }
    }
    self.navigationController.viewControllers = viewControllers;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self refreshHeader];
    
    if (!self.didAppeared) {
        return;
    } else {
        CGFloat maxWidth = CGRectGetWidth(self.view.frame);
        if (maxWidth != self.orgWidth) {
            self.orgWidth = maxWidth;
            [self refreshUI];
        }
    }
}

- (void)refreshBackTitle {
    if (CGRectGetWidth(self.view.frame) < 420.f) {
        self.navigationController.navigationBar.backItem.backBarButtonItem.title = @"";
    }
    else {
        NSString* volumeTitle = [self.level.package.dbName hasPrefix:@"Acrostics: "] ? [self.level.package.dbName substringFromIndex:@"Acrostics: ".length] : self.level.package.dbName;
        self.navigationController.navigationBar.backItem.backBarButtonItem.title = volumeTitle;
    }
}

- (void)refreshHeader {
    [self refreshBackTitle];
    
    CGFloat menuButtonWidth = 80.f;
    CGFloat titleWrapperWidth = CGRectGetWidth(self.titleWrapper.frame);
    CGFloat gameControlwidth = CGRectGetWidth(self.gameControl.frame);
    CGFloat width = CGRectGetWidth(self.view.frame);
    
    if ((width - titleWrapperWidth) / 2 - menuButtonWidth < gameControlwidth) {
        CGFloat backButtonWidth = CGRectGetMinX(self.headerView.frame);
        self.headerView.frame = CGRectMake(backButtonWidth,
                                           self.headerView.frame.origin.y,
                                           width - backButtonWidth * 2,
                                           self.headerView.frame.size.height);
        self.gameControlCenterConstraint.constant = 0.f;
        
        self.titleWrapper.alpha = 0.f;
    }
    else {
        CGFloat backButtonWidth = MIN(CGRectGetMinX(self.headerView.frame), 110.f);
        self.headerView.frame = CGRectMake(backButtonWidth,
                                           self.headerView.frame.origin.y,
                                           width - backButtonWidth * 2,
                                           self.headerView.frame.size.height);
        self.gameControlCenterConstraint.constant = (width / 2 - menuButtonWidth - titleWrapperWidth / 2) / 2 + titleWrapperWidth / 2;
        
        self.titleWrapper.alpha = 1.f;
    }
}

- (void)refreshUI {
    
    CGFloat maxWidth = CGRectGetWidth(self.view.frame);
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    self.gameBoard.maxWidth = maxWidth;
    [self.gameBoard resetGridParams:0];
    [self.gameBoard drawGridForOrientation:orientation completion:^(BOOL finished) {
        [self updateConstraints];
    }];
    
    
    [self.keywordBoard setFrame:CGRectMake(0.0f, CGRectGetMaxY(self.gameBoard.frame), self.view.frame.size.width, KEYWORD_HEIGHT)];
    [self.keywordBoard moveToCenter:maxWidth];
    
    
    self.cluesBoard.maxWidth = maxWidth;
    [self.cluesBoard resetCluesParams:0];
    [self.cluesBoard drawBoardWithCompletion:^{
        [self.cluesBoard setActiveButtonForSection:self.cluesBoard.selectedSection forButtonIndex:self.cluesBoard.selectedButton];
        
        if (self.cluesBoard.alpha != 1.f) {
            [self setComponentsHiden:NO];
            [UIView animateWithDuration:0.15f animations:^{
                NSIndexSet* selectedSegmentIndexes = self.gameControl.selectedSegmentIndexes;
                [self showGridBoard:[selectedSegmentIndexes containsIndex:ACGameControlButton_Grid]];
                [self showKeywordBoard:[selectedSegmentIndexes containsIndex:ACGameControlButton_Key]];
                [self showCluesBoard:[selectedSegmentIndexes containsIndex:ACGameControlButton_Clues]];
                self.borderView.alpha = 1.f;
            } completion:^(BOOL finished) {
            }];
        }
    }];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString*)getPuzzleId {
    NSString *resultString = [NSString stringWithFormat:@"%02ld%02ld", (long) ([ACAppDelegate getCurrentPackage] + 1), (long) self.puzzleNum];
    return [resultString copy];
}

- (IBAction)didDismissStatsVC:(UIStoryboardSegue*)segue {
    [self showVisualBackView:NO];
}

#pragma mark - InterfaceOrientation methods-
- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

#pragma mark - private methods-
- (void)setCorrectFrames:(UIInterfaceOrientation)pOrientation {
    
    [self.gameBoard drawGridForOrientation:pOrientation completion:^(BOOL finished) {
        if (self.gameBoard.frame.size.height != 0)
            self.gameBoardHeightConstraint.constant = self.gameBoard.frame.size.height;
    }];
    
    
    CGSize lSelfSize = self.view.frame.size;
    if (UIInterfaceOrientationIsLandscape(pOrientation)) {
        lSelfSize = CGSizeMake(lSelfSize.height, lSelfSize.width);
    }
    
    
    [self.keywordBoard setFrame:CGRectMake(0.0f, CGRectGetMaxY(self.gameBoard.frame), lSelfSize.width, KEYWORD_HEIGHT)];
    [self.keywordBoard moveToCenter:lSelfSize.width];
    
    
    [self.cluesBoard setFrame:CGRectMake(0, CGRectGetMaxY(self.keywordBoard.frame), lSelfSize.width, lSelfSize.height - 0.f - CGRectGetMaxY(self.keywordBoard.frame))];
    self.cluesBoardBottomConstraint.constant = 0.f;
    
    [self.cluesBoard drawBoardWithCompletion:^{
        [self.cluesBoard setActiveButtonForSection:self.cluesBoard.selectedSection forButtonIndex:self.cluesBoard.selectedButton];
    }];
    
}

- (IBAction)backPressed {
    [self performSegueWithIdentifier:Segue_UnwindToPackageViewController sender:self];
    setVal(QUIT_PUZZLE, @YES);
}

- (IBAction)optionsButtonPressed:(id)pSender {
    
    if ([self.textField isFirstResponder])
        [self.textField resignFirstResponder];
    
    UIAlertController* lActionSheet = [UIAlertController alertControllerWithTitle:@"Menu" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    if ([self.level.dbStatus intValue] == ACGameState_Solved) {
        [lActionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if ([self.level.dbStatus intValue] != ACGameState_Solved) {
                [self showKeyboard];
            }
        }]];
        [lActionSheet addAction:[UIAlertAction actionWithTitle:@"Results" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self showCongratulationVC];
        }]];
        [lActionSheet addAction:[UIAlertAction actionWithTitle:@"Clear this puzzle" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self showClearAlert];
        }]];
    }
    else {
        
        [lActionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if ([self.level.dbStatus intValue] != ACGameState_Solved) {
                [self showKeyboard];
            }
        }]];
        [lActionSheet addAction:[UIAlertAction actionWithTitle:@"Undo\t@" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //Guide
            [self undoPressed];
        }]];
        [lActionSheet addAction:[UIAlertAction actionWithTitle:@"Guide" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //Guide
            [self howToPlay];
        }]];
        [lActionSheet addAction:[UIAlertAction actionWithTitle:@"Get a Hint" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //Get a Hint
            [self makeHint];
            
            [self showKeyboard];
        }]];
        [lActionSheet addAction:[UIAlertAction actionWithTitle:@"Erase Errors" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //Erase Errors
            [self eraseErrors];
            
            [self showKeyboard];
        }]];
        [lActionSheet addAction:[UIAlertAction actionWithTitle:@"Restart this Puzzle" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //Restart this Puzzle
            UIAlertController* solveAlert = [UIAlertController alertControllerWithTitle:@"" message:@"Do you really want to completely clear the puzzle? This cannot be undone!" preferredStyle:UIAlertControllerStyleAlert];
            [solveAlert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [self showKeyboard];
            }]];
            [solveAlert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                // restart
                [self restartPuzzle];
                [self showKeyboard];
            }]];
            [self presentViewController:solveAlert animated:YES completion:^{
            }];
        }]];
        [lActionSheet addAction:[UIAlertAction actionWithTitle:@"Solve this Puzzle" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //Solve this Puzzle
            UIAlertController* lSolveAlert = [UIAlertController alertControllerWithTitle:@"" message:@"Are you sure you want to solve the puzzle? You will be able to see the complete solution, but your current work will be lost. The puzzle will appear as unstarted in the menu." preferredStyle:UIAlertControllerStyleAlert];
            [lSolveAlert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [self showKeyboard];
            }]];
            [lSolveAlert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                // solve
                [self solveCryptogram];
                [self showKeyboard];
            }]];
            [self presentViewController:lSolveAlert animated:YES completion:nil];
        }]];
        [lActionSheet addAction:[UIAlertAction actionWithTitle:[ACAppDelegate getMenuSoundTitle] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //Sound Effects
            
            ACAppDelegate.soundsEnabled = !ACAppDelegate.soundsEnabled;
            [ASKPManager requestCommandsWithTag:ACAppDelegate.soundsEnabled ? @"soundOn" : @"soundOff"];
            
            [self showKeyboard];
        }]];
    }
    
    // remove the arrow from action sheet
    lActionSheet.popoverPresentationController.permittedArrowDirections = 0;
    lActionSheet.popoverPresentationController.sourceView = self.sourceView;
    
    [self presentViewController:lActionSheet animated:YES completion:^{
    }];
}

- (void)showKeyboard {
    if ([self.level.dbStatus intValue] == ACGameState_Solved) {
        if ([self.textField isFirstResponder]) {
            [self.textField resignFirstResponder];
        }
    }
    else {
        if (![self.textField isFirstResponder]) {
            [self.textField becomeFirstResponder];
        }
    }
}

- (IBAction)tryAnotherPressed {
    [self.navigationController popViewControllerAnimated:YES];
    [ACAppDelegate clearCurrentPuzzle];
}

#pragma mark - Menu methods

- (void)showClearAlert {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil message:@"Are you sure you want to start this puzzle over?" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self showKeyboard];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[ACDatabaseWrapper initialize] resetLevelWithId:self.level.dbId];
        [ACAppDelegate clearCurrentPuzzle];
        [self clearGame];
        [self showKeyboard];
    }]];
    
    [self presentViewController:alert animated:YES completion:^{
        
    }];
}

- (void)eraseErrors {
    NSInteger lErraseCount = [self.gameBoard eraseErrors];
    
    if (lErraseCount == 0) {
        UIAlertController* lErrorAlert = [UIAlertController alertControllerWithTitle:@"" message:@"It doesn't look like you need any help!" preferredStyle:UIAlertControllerStyleAlert];
        [lErrorAlert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:lErrorAlert animated:YES completion:nil];
    } else {
        [[ACDatabaseWrapper initialize] addUndo:[NSNumber numberWithInteger:mInputSourceType] index:mSelectedIndex answer:[self.gameBoard getAnswerString] levelId:self.level.dbId];
        [[ACDatabaseWrapper initialize] addHints:1+lErraseCount withLevelId:self.level.dbId];
    }
    [ASKPManager addEventWithName:@"solve" andData:@{@"eraseErrors": [self getPuzzleId]}];
    [ASKPManager requestCommandsWithTag:@"solve"];
}

- (void)restartPuzzle {
    DLog(@"restartPuzzle");
    
    if (self.level.dbId) {
        [ASKPManager addEventWithName:@"restartPuzzle" andData:@{@"puzzleID": [self getPuzzleId]}];
        [ASKPManager requestCommandsWithTag:@"restartPuzzle"];
    }
    
    mInputSourceType = 1;
    [self.cluesBoard clearBoard];
    [self.keywordBoard clearBoard];
    [self.gameBoard clearBoard];

    NSDate *lTempDate = self.startGameDate;
    [[ACDatabaseWrapper initialize] resetLevelWithId:self.level.dbId];
    self.startGameDate = lTempDate;
}

- (void)makeHint {
    [self.gameBoard makeHintForSectionWithTag:mSelectedIndex];
    [[ACDatabaseWrapper initialize] addHints:1 withLevelId:self.level.dbId];
    [[ACDatabaseWrapper initialize] addUndo:[NSNumber numberWithInteger:mInputSourceType] index:mSelectedIndex answer:[self.gameBoard getAnswerString] levelId:self.level.dbId];
    [self checkForWin];
    isHintPressed = NO;
}

- (void)solveCryptogram {
    DLog(@"solveCryptogram");
    
    if (self.level.dbId) {
        [ASKPManager addEventWithName:@"autoSolve" andData:@{@"puzzleID": [self getPuzzleId]}];
        [ASKPManager requestCommandsWithTag:@"autoSolve"];
    }
    
    self.tryAnotherButton.hidden = NO;
    [[ACDatabaseWrapper initialize] resetLevelWithId:self.level.dbId];
    
    [self.gameBoard solveGame];
    [self.keywordBoard solveGame];
    [self.cluesBoard solveBoard];
}

- (void)howToPlay {
    DLog(@"howToPlay");
    [ASKPManager requestCommandsWithTag:@"showHelp"];
    [self performSegueWithIdentifier:Segue_ShowHelpViewController sender:self];
}

#pragma mark -KeyboardDelegate methods-
- (void)deletePressed {
    DLog(@"Delete pressed");
    
    if (mInputSourceType == 2) {
        [self.gameBoard clearSectionWithIndex:mSelectedIndex andGoToPreviousSection:YES];
        [self.keywordBoard clearSectionWithTag:mSelectedIndex andRunToPrevious:NO];
        
        [self.cluesBoard removeTitleForIndex:mSelectedIndex needActivePrevious:NO];
    }
    else if (mInputSourceType == 1) {
        [self.keywordBoard clearSectionWithTag:mSelectedIndex andRunToPrevious:YES];
        [self.gameBoard clearSectionWithIndex:mSelectedIndex andGoToPreviousSection:NO];
        [self.cluesBoard removeTitleForIndex:mSelectedIndex needActivePrevious:NO];
    }
    else if (mInputSourceType == 0){
        [self.cluesBoard removeTitleForIndex:mSelectedIndex needActivePrevious:YES];
        [self.gameBoard clearSectionWithIndex:mSelectedIndex andGoToPreviousSection:NO];
        [self.keywordBoard clearSectionWithTag:mSelectedIndex andRunToPrevious:NO];
    }

    
    DLog(@"%@",[self.gameBoard getAnswerString]);
    [[ACDatabaseWrapper initialize] addUndo:[NSNumber numberWithInteger:mInputSourceType] index:mSelectedIndex answer:[self.gameBoard getAnswerString] levelId:self.level.dbId];
}

- (NSString*)puzzleStringFromString:(NSString*)string {
    NSCharacterSet* alphabetSet = [[NSCharacterSet letterCharacterSet] invertedSet];
    NSString* puzzleString = [string stringByTrimmingCharactersInSet:alphabetSet];
    if (puzzleString)
        puzzleString = [puzzleString uppercaseString];
    
    return puzzleString;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ([string isEqualToString:@"@"]) {
        [self undoPressed];
        return NO;
    }
    
    if ([string isEqualToString:@" "]) {
        [self deletePressed];
        return NO;
    }
    
    if ([string isEqualToString:@""]) {
        [self deletePressed];
        return NO;
    }
    
    NSString* puzzleString = [self puzzleStringFromString:string];
    if (puzzleString && puzzleString.length > 0) {
        [self buttonPressed:puzzleString];
        return YES;
    }
    
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([textField respondsToSelector:@selector(inputAssistantItem)]) {
        UITextInputAssistantItem* item = [textField inputAssistantItem];
        item.leadingBarButtonGroups = @[];
        item.trailingBarButtonGroups = @[];
    }
}

- (void)undoPressed {
    DLog(@"Undo pressed");

    DBUndo *lUndo = [[ACDatabaseWrapper initialize] removeUndoOperation:self.level.dbId];
    if (lUndo != nil) {
        mInputSourceType = [lUndo.dbState integerValue];
        
        [self.gameBoard removeAllLetters];
        [self.cluesBoard clearBoardWithoutSelectionFirstSection];
        [self.keywordBoard clearBoard];

        DLog(@"%@",lUndo.dbAnswer);
        for (NSInteger i=0; i<[lUndo.dbAnswer length]; i++) {
            [self.gameBoard setLetter:[lUndo.dbAnswer substringWithRange:NSMakeRange(i, 1)] forSectionWithTag:i];
            [self.cluesBoard setTitle:[lUndo.dbAnswer substringWithRange:NSMakeRange(i, 1)] forNumber:[NSString stringWithFormat:@"%@", @(i+1)]];
            [self.keywordBoard setLetter:[lUndo.dbAnswer substringWithRange:NSMakeRange(i, 1)] toSectionWithTagIfPossible:i+1];
        }
        
        DLog(@"SelectedIndex:%@", @([lUndo.dbSelectedIndex integerValue]));
        NSInteger lSelectedIndex = [lUndo.dbSelectedIndex integerValue];
        [self.gameBoard highlightSectionForTag:lSelectedIndex];
        
        if (mInputSourceType == 0) {
            [self.cluesBoard setActiveButtonForNumber:[NSString stringWithFormat:@"%@", @(lSelectedIndex)] andDrawGrid:YES];
        }
        else {
            [self.cluesBoard setActiveButtonForNumber:[NSString stringWithFormat:@"%@", @(lSelectedIndex)] andDrawGrid:NO];
        }
        [self.keywordBoard deselectSection];
        [self.keywordBoard setHighlightSection:self.cluesBoard.selectedSection];
        if (mInputSourceType == 1) {
            [self.keywordBoard setActiveSectionIfPossibleForCurrentTag:lSelectedIndex andDrawBorder:YES];
        }
        else {
            [self.keywordBoard setActiveSectionIfPossibleForCurrentTag:lSelectedIndex andDrawBorder:NO];
        }
        mSelectedIndex = lSelectedIndex;
    }
    else if (isOnlyOneUndo == NO) {
        
        isOnlyOneUndo = YES;
        
        if (mInputSourceType == 2) {
            if (isHintPressed == NO) {
                mSelectedIndex--;
            }
            else {
                isHintPressed = NO;
            }
        }
        else {
            mSelectedIndex = 1;
            mInputSourceType = 2;
        }
        
        if ([self.gameBoard returnIndexWithFirstLetter] != -1) {
            mSelectedIndex = [self.gameBoard returnIndexWithFirstLetter];
        }
        
        NSInteger lSelectedIndex = mSelectedIndex;
        DLog(@"lSelectedIndex:%@",@(lSelectedIndex));
        
        [self.gameBoard removeAllLetters];
        [self.cluesBoard clearBoardWithoutSelectionFirstSection];
        [self.keywordBoard clearBoard];

        
        if (mInputSourceType != 2) {
            lSelectedIndex++;
        }
        
        [self.gameBoard highlightSectionForTag:lSelectedIndex];
        mSelectedIndex = lSelectedIndex;
        self.gameBoard.activeSectionTag = lSelectedIndex-1;
        
        if (self.gameBoard.activeSectionTag < 0) {
            self.gameBoard.activeSectionTag = 0;
        }

        if (mInputSourceType == 0) {
            [self.cluesBoard setActiveButtonForNumber:[NSString stringWithFormat:@"%@", @(lSelectedIndex)] andDrawGrid:YES];
        }
        else {
            [self.cluesBoard setActiveButtonForNumber:[NSString stringWithFormat:@"%@", @(lSelectedIndex)] andDrawGrid:NO];
        }
        [self.keywordBoard deselectSection];
        [self.keywordBoard setHighlightSection:self.cluesBoard.selectedSection];
        
        if (mInputSourceType == 1) {
            [self.keywordBoard setActiveSectionIfPossibleForCurrentTag:lSelectedIndex andDrawBorder:YES];
        }
        else {
            [self.keywordBoard setActiveSectionIfPossibleForCurrentTag:lSelectedIndex andDrawBorder:NO];
        }

    }
}

- (void)restorePreviousStateWithFirstButtonIndex:(NSInteger)firstButtonIndex
{
    DBUndo *lUndo = [[ACDatabaseWrapper initialize] getLastUndo:self.level.dbId];
    
    if (lUndo != nil) {
        NSInteger lInputSource = [lUndo.dbState integerValue];
        mInputSourceType = [lUndo.dbState integerValue];
        DLog(@"mInputSourceType  - %@", @(mInputSourceType));
        [self.gameBoard removeAllLetters];
        [self.cluesBoard clearBoardWithoutSelectionFirstSection];
        [self.keywordBoard clearBoard];
        
        DLog(@"%@",lUndo.dbAnswer);
        for (NSInteger i=0; i<[lUndo.dbAnswer length]; i++) {
            [self.gameBoard setLetter:[lUndo.dbAnswer substringWithRange:NSMakeRange(i, 1)] forSectionWithTag:i];
            [self.cluesBoard setTitle:[lUndo.dbAnswer substringWithRange:NSMakeRange(i, 1)] forNumber:[NSString stringWithFormat:@"%@", @(i+1)]];
            [self.keywordBoard setLetter:[lUndo.dbAnswer substringWithRange:NSMakeRange(i, 1)] toSectionWithTagIfPossible:i+1];
        }
        
        NSInteger lSelectedIndex = [lUndo.dbSelectedIndex integerValue];
        DLog(@"lSelectedIndex - %@", @(lSelectedIndex));

        if (lSelectedIndex == 0) {
            lSelectedIndex = [self.gameBoard getAllSectionsNumber];
        }
        [self.gameBoard highlightSectionForTag:lSelectedIndex];
        [self activeCrosswordSectionWithTag:[NSNumber numberWithInteger:lSelectedIndex] andIsAutomaticRun:NO];
        mInputSourceType = lInputSource;
        if (lInputSource == 0) {
            [self.cluesBoard setActiveButtonForNumber:[NSString stringWithFormat:@"%@", @(lSelectedIndex)] andDrawGrid:YES];
        }
        else {
            [self.cluesBoard setActiveButtonForNumber:[NSString stringWithFormat:@"%@", @(lSelectedIndex)] andDrawGrid:NO];
        }
        [self.keywordBoard deselectSection];
        [self.keywordBoard setHighlightSection:self.cluesBoard.selectedSection];
        if (lInputSource == 1) {
            [self.keywordBoard setActiveSectionIfPossibleForCurrentTag:lSelectedIndex andDrawBorder:YES];
        }
        else {
            [self.keywordBoard setActiveSectionIfPossibleForCurrentTag:lSelectedIndex andDrawBorder:NO];
        }
    }
    else {
        [self.gameBoard highlightSectionForTag:firstButtonIndex];
        [self activeCrosswordSectionWithTag:@(firstButtonIndex)
                          andIsAutomaticRun:@NO];
    }
}

- (void)buttonPressed:(NSString *)pTitle {
//    DLog(@"letter pressed %@",pTitle);
    
    [AppDelegate setIsPlay:NO];
    
    if (mInputSourceType == 0) {
        [self.gameBoard setLetter:pTitle andRunToNextSection:NO];
        self.keywordBoard.activeSection = mSelectedIndex;
        [self.keywordBoard setLetter:pTitle andNeedActivateNext:NO];
        self.keywordBoard.activeSection = -1;
        [self.cluesBoard setLetter:pTitle needActiveNext:YES];
    }
    else if (mInputSourceType == 1) {
        [self.gameBoard setLetter:pTitle andRunToNextSection:NO];
        [self.cluesBoard setLetter:pTitle needActiveNext:NO];
        [self.keywordBoard setLetter:pTitle andNeedActivateNext:YES];
    }
    else if (mInputSourceType == 2) {
        [self.cluesBoard setLetter:pTitle needActiveNext:NO];
        self.keywordBoard.activeSection = mSelectedIndex;
        [self.keywordBoard setLetter:pTitle andNeedActivateNext:NO];
        self.keywordBoard.activeSection = -1;
        [self.gameBoard setLetter:pTitle andRunToNextSection:YES];
    }
    
//    DLog(@"string:%@",[self.gameBoard getAnswerString]);
    
    [[ACDatabaseWrapper initialize] addUndo:[NSNumber numberWithInteger:mInputSourceType] index:mSelectedIndex answer:[self.gameBoard getAnswerString] levelId:self.level.dbId];
    isOnlyOneUndo = NO;
    [self checkForWin];
}

- (void)checkForWin {
    if ([self.gameBoard checkIfSectionsFull] == YES) {
        if ([self.gameBoard checkGame] == YES) {
            NSString *lDisplayMode = @"";
            if ([UIApplication sharedApplication].statusBarOrientation == 1 || [UIApplication sharedApplication].statusBarOrientation == 2) {
                lDisplayMode = @"portrait";
            } else if ([UIApplication sharedApplication].statusBarOrientation == 3 || [UIApplication sharedApplication].statusBarOrientation == 4) {
                lDisplayMode = @"landscape";
            }
            
            [ACAppDelegate clearCurrentPuzzle];

            [self saveTime];
            self.level.dbStatus = [NSNumber numberWithInt:2];
            [[ACDatabaseWrapper initialize] saveChanges];

            NSDictionary *dataDict = @{@"PuzzleID" : [self getPuzzleId],
                                       @"Time" : self.level.dbCurrentTime.stringValue,
                                       @"Hints" : self.level.dbHints.stringValue,
                                       @"DisplayMode" : lDisplayMode};
            [ASKPManager addEventWithName:@"Completed" andData:dataDict];
            [ASKPManager requestCommandsWithTag:@"Completed"];

            
            [AppDelegate playSoundWithStyle:SuccessSound];
            
            [self showCongratulationVC];
            
        } else {
            [self showErrorMessage];
            [AppDelegate playSoundWithStyle:ErrorSound];
        }
    }
}

- (void)showCongratulationVC {
    [self initHeader];
    [self showVisualBackView:YES];
    
    [self performSelector:@selector(goToCongratulationVC) withObject:nil afterDelay:0.25f];
}

- (void)goToCongratulationVC {
    [self performSegueWithIdentifier:Segue_ShowCongratulationViewController sender:self];
}

- (void)showVisualBackView:(BOOL)show {
    if (show) {
        if ([self.textField isFirstResponder])
            [self.textField resignFirstResponder];
        
        [UIView animateWithDuration:0.25f animations:^{
            self.visualBackView.alpha = 1.f;
        } completion:^(BOOL finished) {
            [self.view bringSubviewToFront:self.visualBackView];
        }];
    }
    else {
        [UIView animateWithDuration:0.25f animations:^{
        } completion:^(BOOL finished) {
            [self.view sendSubviewToBack:self.visualBackView];
        }];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:Segue_ShowCongratulationViewController]) {
        CongratulationViewController *lCongratulations = segue.destinationViewController;
        lCongratulations.level = self.level;
    }
    else if ([segue.identifier isEqualToString:Segue_ShowHelpViewController]) {
        NSString* backButtonTitle = [NSString stringWithFormat:@"Puzzle %ld", (long) self.puzzleNum];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:backButtonTitle style:UIBarButtonItemStylePlain target:nil action:nil];
    }
}

#pragma mark - check level status and time

- (void)checkLevelStatus {
	if ([self.level.dbStatus integerValue] != 2) {
		if ([[self.level.undo allObjects] count] == 0) {
            if ([self.level.dbStatus integerValue] != 0) {
                //change only when values is false
                self.level.dbStatus = [NSNumber numberWithInteger:0];
                [[ACDatabaseWrapper initialize] saveChanges];
            }
            if (self.startGameDate)
                self.startGameDate = nil;
		} else {
			if ([self.level.dbStatus integerValue] != 1) {
				//change onlywhen values is false
				self.level.dbStatus = [NSNumber numberWithInteger:1];
				[[ACDatabaseWrapper initialize] saveChanges];
			}
            if (!self.startGameDate) {
                self.startGameDate = [NSDate date];
            }
		}
	}
}

//save time to database object
- (void)saveTime {
	if (self.startGameDate) {
		float oldTime = [self.level.dbCurrentTime floatValue];
		float newTime = oldTime + [[NSDate date] timeIntervalSinceDate:self.startGameDate];
		self.level.dbCurrentTime = [NSNumber numberWithFloat:newTime];
		[[ACDatabaseWrapper initialize] saveChanges];
	}
    
    if (self.startGameDate)
        self.startGameDate = nil;
}

#pragma mark - KVO & Notification
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
	[self checkLevelStatus];
}

- (void)applicationBecameActive:(NSNotification*)pNotification {
	if ([self.level.dbStatus integerValue] == 1) {
        if (self.startGameDate)
            self.startGameDate = nil;
		self.startGameDate = [NSDate date];
	}
}

- (void)applicationBecameInActive:(NSNotification*)pNotification {
	[self saveTime];
}

#pragma mark - ACCluesBoardDelegate
//call when selected button into clues board
- (void)setCluesBoardSelected:(NSString*)pNumber {
    
    if (mInputSourceType != 0) {
        if ([[ACDatabaseWrapper initialize]getLastUndo:self.level.dbId] == nil) {
            [[ACDatabaseWrapper initialize] addUndo:[NSNumber numberWithInteger:0] index:[pNumber integerValue] answer:[self.gameBoard getAnswerString] levelId:self.level.dbId];
        } else {
            [[ACDatabaseWrapper initialize] addNewIndex:[pNumber integerValue] andNewState:0 forLevelId:self.level.dbId];
        }
    } else {
        [[ACDatabaseWrapper initialize] addNewIndex:mSelectedIndex andNewState:0 forLevelId:self.level.dbId];
    }
    mInputSourceType = 0;
    [self.gameBoard highlightSectionForTag:[pNumber integerValue]];
    [self.keywordBoard deselectSection];
    [self.keywordBoard setHighlightSection:self.cluesBoard.selectedSection];
    [self.keywordBoard setActiveSectionIfPossibleForCurrentTag:[pNumber integerValue] andDrawBorder:NO];
    self.keywordBoard.activeSection = -1;
    mSelectedIndex = [pNumber integerValue];
}

#pragma mark - GameBoardDelegate methods-
// method call when user activate section
- (void)activeCrosswordSectionWithTag:(NSNumber*)pSectionTag andIsAutomaticRun:(NSNumber*)pIsRun {
    
    [self.cluesBoard setActiveButtonForNumber:[NSString stringWithFormat:@"%@", @([pSectionTag integerValue])] andDrawGrid:NO];
    [self.keywordBoard deselectSection];
    [self.keywordBoard setHighlightSection:self.cluesBoard.selectedSection];
    [self.keywordBoard setActiveSectionIfPossibleForCurrentTag:[pSectionTag integerValue] andDrawBorder:NO];
    self.keywordBoard.activeSection = -1;
    mInputSourceType = 2;
    mSelectedIndex = [pSectionTag integerValue];
    if ([[ACDatabaseWrapper initialize] getLastUndo:self.level.dbId] != nil && [NSNumber numberWithBool:NO] == pIsRun) {
        [[ACDatabaseWrapper initialize] addNewIndex:mSelectedIndex andNewState:mInputSourceType forLevelId:self.level.dbId];
    }
}

- (void) erraseCallForTag:(NSNumber*)pTag {
    [self.keywordBoard clearSectionWithTag:[pTag integerValue]];
    [self.cluesBoard removeTitleForIndex:[pTag integerValue] needActivePrevious:NO];
}

- (void) makeHitWithLetter:(NSString*)pString andTag:(NSNumber *)pTag {
    [self.cluesBoard setLetter:pString needActiveNext:NO];
    self.keywordBoard.activeSection = mSelectedIndex;
    [self.keywordBoard setLetter:pString andNeedActivateNext:NO];
    self.keywordBoard.activeSection = -1;
    isOnlyOneUndo = NO;
    isHintPressed = YES;
}

#pragma mark - KeywordBoardDelegate method-
- (void)setKeywordBoardActive:(NSInteger)tag {
    
    if (mInputSourceType != 1) {
        if ([[ACDatabaseWrapper initialize]getLastUndo:self.level.dbId] == nil) {
            [[ACDatabaseWrapper initialize] addUndo:[NSNumber numberWithInteger:1] index:tag answer:[self.gameBoard getAnswerString] levelId:self.level.dbId];
        } else {
            [[ACDatabaseWrapper initialize] addNewIndex:tag andNewState:1 forLevelId:self.level.dbId];
        }
    } else {
        [[ACDatabaseWrapper initialize] addNewIndex:mSelectedIndex andNewState:1 forLevelId:self.level.dbId];
    }

    
    mInputSourceType = 1;
//    [[ACDatabaseWrapper initialize] addNewIndex:[pNumber integerValue] andNewState:mInputSourceType forLevelId:self.level.dbId];
    DLog(@"pNumber  - %@", @(tag));
    [self.cluesBoard setActiveButtonForNumber:[NSString stringWithFormat:@"%@", @(tag)] andDrawGrid:NO];
    [self.gameBoard highlightSectionForTag:tag];
    mSelectedIndex = tag;
}


#pragma mark - UITapGestureRecognizer

- (IBAction)handleTaps:(UITapGestureRecognizer *)recognizer {
    if ([self.textField isFirstResponder])
        [self.textField resignFirstResponder];
}

#pragma mark - UIPinchGestureRecognizer

- (CGFloat)getKeywordBoardBottom {
    BOOL isKeywordBoardShown = ([self getGameStatus] / 10) % 2 == 1;
    CGFloat keywordBoardBottom = CGRectGetHeight(self.gameBoard.frame) + (isKeywordBoardShown ? CGRectGetHeight(self.keywordBoard.frame) : 0.f);
    return keywordBoardBottom;
}

- (void)updateConstraints {
    
    CGFloat keywordBoardBottom = [self getKeywordBoardBottom];
    
    CGFloat cluesBoardHeight = CGRectGetHeight(self.view.frame) - keywordBoardBottom - ([self.textField isFirstResponder] ? CGRectGetHeight(self.keyboardFrame) : 0.f);
    if (cluesBoardHeight > 0) {
        CGFloat cluesBoardBottom = [self.textField isFirstResponder] ? CGRectGetHeight(self.keyboardFrame) : 0.0f;
        self.cluesBoardBottomConstraint.constant = cluesBoardBottom;
    }
    else {
        self.cluesBoardBottomConstraint.constant = cluesBoardHeight - CGRectGetHeight(self.cluesBoard.frame);
    }
    
    
    if (self.gameBoard.frame.size.height != 0)
        self.gameBoardHeightConstraint.constant = self.gameBoard.frame.size.height;
}

- (IBAction)handlePinch:(UIPinchGestureRecognizer *)recognizer {
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    int diffCount = ((recognizer.scale - 1.f) / 0.08f);
    if (diffCount == 0) {
        self.orgCount = self.gameBoard.sectionCount;
    }
    else {
        recognizer.scale = 1.f;
        
        diffCount = diffCount / abs(diffCount);
    }
    
    int sectionCount = self.orgCount - diffCount;
    if (self.gameBoard.sectionCount == sectionCount)
        return;
    if (sectionCount < self.gameBoard.minSectionCount)
        return;
    if (sectionCount > self.gameBoard.maxSectionCount)
        return;
    
    
    [self.gameBoard resetGridParams:diffCount];
    [self.gameBoard drawGridForOrientation:orientation completion:^(BOOL finished) {
        
        [self updateConstraints];
        
        recognizer.scale = 1.f;
        
        self.orgGridDiffCount = self.gameBoard.maxSectionCount - self.gameBoard.sectionCount;
    }];
}

- (IBAction)handleCluesPinch:(UIPinchGestureRecognizer *)recognizer {
    
    int diffCount = ((recognizer.scale - 1.f) / 0.3f);
    if (diffCount == 0) {
        self.cluesOrgCount = self.cluesBoard.sectionCount;
    }
    else {
        recognizer.scale = 1.f;
        
        diffCount = diffCount / abs(diffCount);
    }
    
    int sectionCount = self.cluesOrgCount - diffCount;
    if (self.cluesBoard.sectionCount == sectionCount)
        return;
    if (sectionCount < self.cluesBoard.minSectionCount)
        return;
    if (sectionCount > self.cluesBoard.maxSectionCount)
        return;
    
    
    [self.cluesBoard resetCluesParams:diffCount];
    [self.cluesBoard drawBoardWithCompletion:^{
        [self.cluesBoard setActiveButtonForSection:self.cluesBoard.selectedSection forButtonIndex:self.cluesBoard.selectedButton];
    }];
}


#pragma mark - Default Keyboard delegate

- (void)keyboardWillShow:(NSNotification*)notif
{
    [self animateKeyboardUp:YES userInfo:notif.userInfo];
}

- (void)keyboardWillHide:(NSNotification*)notif
{
    [self animateKeyboardUp:NO userInfo:notif.userInfo];
}

//TODO: use -[self.cluesBoard setContentOffset:animated:] instead
- (void)animateKeyboardUp:(BOOL)up userInfo:(NSDictionary *)userInfo
{
    self.keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    double animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = (UIViewAnimationCurve) [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    UIViewAnimationOptions options = (UIViewAnimationOptions) ((curve << 16) | UIViewAnimationOptionBeginFromCurrentState);
    
    CGFloat cluesBoardBottom = 0.0f;
    CGFloat keywordBoardBottom = [self getKeywordBoardBottom];
    CGFloat cluesBoardHeight = CGRectGetHeight(self.view.frame) - keywordBoardBottom - (up ? CGRectGetHeight(self.keyboardFrame) : 0.f);
    if (cluesBoardHeight > 0) {
        cluesBoardBottom = up ? CGRectGetHeight(self.keyboardFrame) : 0.0f;
    }
    else {
        cluesBoardBottom = cluesBoardHeight - CGRectGetHeight(self.cluesBoard.frame);
    }
    
    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:options
                     animations:^{
                         self.cluesBoardBottomConstraint.constant = cluesBoardBottom;
                         [self.view layoutIfNeeded];
                     } completion:nil];
}

- (void)animateTextFieldUp:(BOOL)up duration:(CGFloat)duration keyboardBounds:(CGRect)keyboardBounds {
    [UIView animateWithDuration:duration
                     animations:^{
                         self.cluesBoardBottomConstraint.constant = up ? keyboardBounds.size.height : 0.f;
                         [self.view layoutIfNeeded];
                     } completion:nil];
}

#pragma mark - error message

- (void)showErrorMessage{
    CGFloat width = MIN(357.f, CGRectGetWidth(self.view.frame) * 0.9f);
    
    UILabel *lLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, width, 30.f)];
    lLabel.backgroundColor = [UIColor yellowColor];
    lLabel.text = @" Sorry, your answer is not yet correct... ";
    lLabel.textColor = [UIColor blackColor];
    lLabel.textAlignment = NSTextAlignmentCenter;
    lLabel.font = [UIFont systemFontOfSize:20.0f];
    lLabel.adjustsFontSizeToFitWidth = YES;
    lLabel.minimumScaleFactor = 0.5f;
    [lLabel setCenter:CGPointMake(self.view.frame.size.width / 2, CGRectGetMaxY(self.cluesBoard.frame) - 15.f)];
    lLabel.frame  = CGRectIntegral(lLabel.frame);
    lLabel.center = CGPointMake(round(lLabel.center.x), round(lLabel.center.y));
    
    [self.view addSubview:lLabel];
    [self performSelector:@selector(hideErrorMessage:) withObject:lLabel afterDelay:1.5f];
}

- (void)hideErrorMessage:(UILabel *)pLabel{
    [UIView beginAnimations:@"HideMessage" context:nil];
    [UIView setAnimationDuration:1.0f];
    pLabel.alpha = 0.0f;
    [UIView commitAnimations];
    [pLabel performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1.1f];
}


#pragma mark -
#pragma mark - MultiSelectSegmentedControl delegate

- (void)multiSelect:(MultiSelectSegmentedControl *)multiSelecSegmendedControl didChangeValue:(BOOL)value atIndex:(NSUInteger)index {
    
    NSInteger newGameStatus = [self getGameStatus];
    
    if (newGameStatus == 100) {
        [self autoFitGrid];
    }
    else {
        [self reverseGridToOrgState];
    }
    
    if (value) {
        switch (index) {
            case ACGameControlButton_Grid:
                [self showGridBoard:value];
                break;
            case ACGameControlButton_Key:
                [self showKeywordBoard:value];
                break;
            case ACGameControlButton_Clues:
                [self showCluesBoard:value];
                break;
                
            default:
                break;
        }
    }
    else {
        switch (index) {
            case ACGameControlButton_Grid:
            {
                [self showGridBoard:value];
                if (newGameStatus == 0) {
                    [self showCluesBoard:YES];
                    [self setGameStatus:1];
                }
                else if (newGameStatus == 10) {
                    [self showCluesBoard:YES];
                    [self setGameStatus:11];
                }
            }
                break;
            case ACGameControlButton_Key:
            {
                [self showKeywordBoard:value];
            }
                break;
            case ACGameControlButton_Clues:
            {
                [self showCluesBoard:value];
                if (newGameStatus == 0) {
                    [self showGridBoard:YES];
                    [self setGameStatus:100];
                }
                else if (newGameStatus == 10) {
                    [self showGridBoard:YES];
                    [self setGameStatus:110];
                }
            }
                break;
                
            default:
                break;
        }
    }
    
    newGameStatus = [self getGameStatus];
    mInputSourceType = [self getNewInputSourceType:newGameStatus];
}

- (NSInteger)getNewInputSourceType:(NSInteger)gameStatus {
    NSInteger newInputSourceType = 0;
    
    if (gameStatus / 100 == 0) {
        newInputSourceType = 0;
    }
    else if (gameStatus % 2 == 0) {
        newInputSourceType = 2;
    }
    else {
        newInputSourceType = mInputSourceType;
    }
    
    return newInputSourceType;
}

- (BOOL)isInvalidGameStatus {
    NSInteger newGameStatus = [self getGameStatus];
    return (newGameStatus == 0 || newGameStatus == 10);
}

- (NSInteger)getGameStatus {
    NSInteger gameStatus = 0;
    
    NSIndexSet* selectedSegmentIndexes = self.gameControl.selectedSegmentIndexes;
    if ([selectedSegmentIndexes containsIndex:ACGameControlButton_Grid]) {
        gameStatus += pow(10, 2);
    }
    if ([selectedSegmentIndexes containsIndex:ACGameControlButton_Key]) {
        gameStatus += pow(10, 1);
    }
    if ([selectedSegmentIndexes containsIndex:ACGameControlButton_Clues]) {
        gameStatus += pow(10, 0);
    }
    
    return gameStatus;
}

- (void)setGameStatus:(NSInteger)status {
    NSMutableIndexSet* newIndexSet = [NSMutableIndexSet indexSet];
    if (status >= 100)
        [newIndexSet addIndex:0];
    if (((status / 10) % 2) == 1)
        [newIndexSet addIndex:ACGameControlButton_Key];
    if ((status % 2) == 1)
        [newIndexSet addIndex:ACGameControlButton_Clues];
    [self.gameControl setSelectedSegmentIndexes:newIndexSet];
    
    
    if (status == 100) {
        [self autoFitGrid];
    }
}

- (void)showGridBoard:(BOOL)show {
    self.gameBoardTopConstraint.constant = show ? 0.f : -CGRectGetHeight(self.gameBoard.frame);
    self.gameBoard.alpha = show;
    self.gameBoard.userInteractionEnabled = show;
}

- (void)showKeywordBoard:(BOOL)show {
    if (show)
        [self updateConstraints];
    
    self.keywordBoardTopConstraint.constant = show ? 0.f : -CGRectGetHeight(self.keywordBoard.frame);
    self.keywordBoard.alpha = show;
    self.keywordBoard.userInteractionEnabled = show;
}

- (void)showCluesBoard:(BOOL)show {
    self.cluesBoard.alpha = show;
    self.cluesBoard.userInteractionEnabled = show;
}

- (void)autoFitGrid {
    if (!self.gameBoard.sectionCount) {
        return;
    }
    
    self.orgGridDiffCount = self.gameBoard.maxSectionCount - self.gameBoard.sectionCount;
    
    int diffCount = 0;
    
    while (1) {
        
        NSInteger sectionCount = self.gameBoard.sectionCount - diffCount;
        
        if (sectionCount < self.gameBoard.minSectionCount) {
            diffCount --;
            if (diffCount < 0)
                diffCount = 0;
            break;
        }
        
        CGFloat sectionSize = CGRectGetWidth(self.view.frame) / sectionCount;
        NSInteger rowCount = 0;
        if ([self.level.dbQuotation length] % sectionCount == 0) {
            rowCount = [self.level.dbQuotation length] / sectionCount;
        } else {
            rowCount = [self.level.dbQuotation length] / sectionCount + 1;
        }
        
        if (rowCount * sectionSize + 4.f + self.keyboardFrame.size.height > CGRectGetHeight(self.view.frame)) {
            diffCount --;
            if (diffCount < 0)
                diffCount = 0;
            
            break;
        }
        
        diffCount ++;
    }
    
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    [self.gameBoard resetGridParams:diffCount];
    [self.gameBoard drawGridForOrientation:orientation completion:^(BOOL finished) {
        [self updateConstraints];
    }];
}

- (void)reverseGridToOrgState {
    
    int diffCount = self.gameBoard.maxSectionCount - self.gameBoard.sectionCount;
    if (diffCount == self.orgGridDiffCount)
        return;
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    [self.gameBoard resetGridParams:self.orgGridDiffCount - diffCount];
    [self.gameBoard drawGridForOrientation:orientation completion:^(BOOL finished) {
        [self updateConstraints];
    }];
}


@end
