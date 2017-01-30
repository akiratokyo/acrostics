//  Copyright (c) 2012-2015 EggheadGames LLC. All rights reserved.

#import <QuartzCore/QuartzCore.h>
#import "ACPackageViewController.h"
#import "ACGameListViewController.h"
#import "ACGamePlayViewController.h"
#import "Reachability.h"
#import "ACAppDelegate.h"
#import "Acrostics-Swift.h"
#import <AskingPoint/AskingPoint.h>

#define CELL_HEIGHT 130
#define GAME_ITEM_WIDTH_PORTRAIT 155
#define GAME_ITEM_WIDTH_LANDSCAPE 147
#define MAX_ITEMS_COUNT_PORTRAIT 5
#define MAX_ITEMS_COUNT_LANDSCAPE 10

#define MAX_COUNT 35


@interface ACGameListViewController ()

@property (weak, nonatomic) IBOutlet UILabel* titleLabel;
@property (weak, nonatomic) IBOutlet UILabel* orderLabel;
@property (weak, nonatomic) IBOutlet UIButton* arrowButton;
@property (weak, nonatomic) IBOutlet UIButton* doneButton;
@property (weak, nonatomic) IBOutlet UIPickerView* orderPickerView;
@property (weak, nonatomic) IBOutlet UICollectionView* mGameCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *mCompletedGamesCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *mTotalGamesCountLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* orderPickerTop;

@property (nonatomic) BOOL isUnwindToPackageVC;
@property (nonatomic) CGFloat orgWidth;
@property (nonatomic) ACLevelSortOrder origOrder;
@property (nonatomic) NSArray* orderList;

- (void)initData;
- (IBAction)tapGameItem:(UIButton *)sender;
- (IBAction)tapOrderButton:(UIButton*)sender;
- (IBAction)tapDoneButton:(UIButton*)sender;

@end


@implementation ACGameListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    
    self.title = [self.package.dbName hasPrefix:@"Acrostics: "] ? [self.package.dbName substringFromIndex:@"Acrostics: ".length] : self.package.dbName;

    NSInteger currentPuzzle = [ACAppDelegate getCurrentPuzzle];
    if (!self.isFromList && currentPuzzle != -1) {
        [self gameItemPressed:currentPuzzle];
    }

    // set flowlayout of collectionView
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.sectionInset = UIEdgeInsetsMake(0.f, 0.f, 0.f, 0.f);
    flowLayout.minimumLineSpacing = 0.f;
    flowLayout.minimumInteritemSpacing = 0.f;
    self.mGameCollectionView.collectionViewLayout = flowLayout;
    self.mGameCollectionView.backgroundColor = [UIColor whiteColor];
}

- (void)initData {
    self.orderList = @[@"sequential", @"easier first", @"harder first", @"middle first"];
    self.origOrder = [ACAppDelegate getSortOrder];
    mLevelsDataSource = [NSMutableArray arrayWithArray:[[ACDatabaseWrapper initialize] readAllLevels:self.package.dbId]];
    [self sortLevels:self.origOrder];
    
    NSInteger lCountOfSolvedGames = 0;
    for (NSInteger i = 0; i < mLevelsDataSource.count; i++) {
        DBLevel *lLevel = [mLevelsDataSource objectAtIndex:i];
        if ([lLevel.dbStatus integerValue] == 2)
            lCountOfSolvedGames++;
    }
    
    self.titleLabel.text = self.orderList[self.origOrder];

    self.mTotalGamesCountLabel.text = [NSString stringWithFormat:@"out of %@", @(mLevelsDataSource.count)];
    self.mCompletedGamesCountLabel.text = [NSString stringWithFormat:@"%@", @(lCountOfSolvedGames)];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [ASKPManager requestCommandsWithTag:@"TOC1"];

    [self initData];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self reloadCollectionView];
    [self.mGameCollectionView flashScrollIndicators];
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.isUnwindToPackageVC) {
        [super viewWillDisappear:animated];
    }
    else {
        if (self.origOrder != [ACAppDelegate getSortOrder]) {
            [ACAppDelegate clearCurrentPuzzle];
        }
        [self backToPackageVC];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (self.view.frame.size.width < 375.f) {
        self.orderLabel.text = @"Order";
    }
    else {
        self.orderLabel.text = @"Play order";
    }
    
    self.doneButton.hidden = ([UIScreen mainScreen].bounds.size.height > self.view.frame.size.height);
    
    [self reloadCollectionView];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (CGSize)preferredContentSize {
    return self.parentVC.popOverContentSize;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Autorotations methods -
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self reloadCollectionView];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self reloadCollectionView];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (void)reloadCollectionView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mGameCollectionView reloadData];
    });
}

#pragma mark - Game item delegate - 

- (IBAction)tapGameItem:(UIButton *)sender {
    [self gameItemPressed:sender.tag];
}

- (void)gameItemPressed:(NSInteger)puzzleNum {
    if (mLevelsDataSource && mLevelsDataSource.count > puzzleNum) {
        self.level = [mLevelsDataSource objectAtIndex:puzzleNum];
        if ([self.level.dbStatus intValue] != ACGameState_Solved) {
            [ACAppDelegate setCurrentPuzzle:self.level.dbId];
            [AppDelegate playSoundWithStyle:SelectCategorySound];
            [AppDelegate setIsPlay:NO];
        }
        
        self.isUnwindToPackageVC = YES;
        [self performSegueWithIdentifier:Segue_UnwindToPackageViewController sender:self.level];
    }
}

- (IBAction)tapDoneButton:(UIButton*)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)backToPackageVC {
    [self performSegueWithIdentifier:Segue_DismissGameListViewController sender:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:Segue_ShowGamePlayViewController]) {
        ACGamePlayViewController *lView = (ACGamePlayViewController*)segue.destinationViewController;
        lView.level = (DBLevel*)sender;
        
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:self.title style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    else if ([segue.identifier isEqualToString:Segue_UnwindToPackageViewController]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}



- (NSInteger)getSectionCount {
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat height = CGRectGetHeight(self.view.frame);
    if (width > height)
        return MAX_ITEMS_COUNT_LANDSCAPE;
    return MAX_ITEMS_COUNT_PORTRAIT;
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSInteger sectionCount = [self getSectionCount];
    NSUInteger lCount = 0;
    if (mLevelsDataSource && mLevelsDataSource.count > 0) {
        lCount = (mLevelsDataSource.count + sectionCount - 1) / sectionCount;
    }
    return lCount;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self getSectionCount];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ACPuzzleCell *cell = (ACPuzzleCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"ACPuzzleCell" forIndexPath:indexPath];
    
    // Configure the cell
    
    NSInteger sectionCount = [self getSectionCount];
    NSInteger index = indexPath.section * sectionCount + indexPath.row;
    if (index < mLevelsDataSource.count) {
        DBLevel *lLevel = [mLevelsDataSource objectAtIndex:index];
        cell.mItemButton.tag = index;
        
        NSInteger state = [lLevel.dbStatus integerValue];
        NSInteger difficulty = [lLevel.dbDifficulty integerValue];
        NSInteger puzzleNum = [ACAppDelegate puzzleNumForDbid:lLevel.dbId];
        // TODO: This code is also in ACAppDelegate
        BOOL isPerfect = (lLevel.dbStatus.integerValue == ACGameState_Solved && lLevel.dbCurrentTime.integerValue < lLevel.dbAverageTime.integerValue);
        [cell setGameItemState:state difficulty:difficulty number:puzzleNum isPerfect:isPerfect];
        
        
        CGFloat maxWidth = CGRectGetWidth(self.view.frame);
        CGFloat labelWidth = ((maxWidth - 10.f) / sectionCount - 10.f) * 3 / 10;
        
        CGFloat fontSize = [ACAppDelegate fontSizeForString:@"888" frame:CGRectMake(0.f, 0.f, labelWidth, labelWidth * 2 / 3) isBoldFont:NO];
        fontSize = MIN(fontSize, 20.f);
        cell.mNumberLabel.font = [UIFont systemFontOfSize:fontSize];
    }
    
    return cell;
}


#pragma mark -
#pragma mark - <UICollectionViewDelegateFlowLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger sectionCount = [self getSectionCount];
    
    CGFloat maxWidth = CGRectGetWidth(self.view.frame);
    int width = (int)(maxWidth - 10.f) / sectionCount;
    
    return CGSizeMake(width, width);
}


#pragma mark -
#pragma mark - UIPickerView delegate

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.orderList.count;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.orderList[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [ACAppDelegate setSortOrder:row];

    [self showOrderPicker:NO completion:^{
        self.titleLabel.text = self.orderList[row];
        [self sortLevels:(ACLevelSortOrder)row];
    }];
}

#pragma mark -
#pragma mark - Order

- (IBAction)tapOrderButton:(UIButton*)sender {
    self.arrowButton.selected = !self.arrowButton.selected;
    [self showOrderPicker:self.arrowButton.selected completion:^{
        
    }];
}

- (void)showOrderPicker:(BOOL)show completion:(void (^ __nullable)())completion {
    if (show) {
        self.orderPickerView.layer.shadowColor = [[UIColor grayColor] CGColor];
        self.orderPickerView.layer.shadowOffset = CGSizeMake(0.f, 2.f);
        self.orderPickerView.layer.shadowOpacity = 0.5f;
        self.orderPickerView.layer.shadowRadius = 3.f;
        self.orderPickerView.clipsToBounds = NO;
        
        ACLevelSortOrder sortOder = [ACAppDelegate getSortOrder];
        self.titleLabel.text = self.orderList[sortOder];
        [self.orderPickerView selectRow:sortOder inComponent:0 animated:NO];
        
        self.orderPickerView.alpha = 1.f;
    }
    
    [UIView animateWithDuration:0.25f animations:^{
        self.orderPickerView.center = show ? CGPointMake(self.orderPickerView.center.x, 44.f + self.orderPickerView.frame.size.height / 2) : CGPointMake(self.orderPickerView.center.x, 44.f - self.orderPickerView.frame.size.height / 2);
    } completion:^(BOOL finished) {
        self.arrowButton.selected = show;
        self.orderPickerTop.constant = show ? 0.f : -self.orderPickerView.frame.size.height;
        
        if (!show) {
            self.orderPickerView.layer.shadowColor = [[UIColor clearColor] CGColor];
            self.orderPickerView.layer.shadowOffset = CGSizeMake(-2.f, -2.f);
            self.orderPickerView.layer.shadowOpacity = 1.f;
            self.orderPickerView.layer.shadowRadius = 3.f;
            self.orderPickerView.clipsToBounds = NO;
            
            self.orderPickerView.alpha = 0.f;
        }
        
        completion();
    }];
}

- (void)sortLevels:(ACLevelSortOrder)sortOrder {
    mLevelsDataSource = [NSMutableArray arrayWithArray:[ACAppDelegate sortedLevels:mLevelsDataSource withSortOrder:sortOrder]];
    [self.mGameCollectionView reloadData];
}


@end
