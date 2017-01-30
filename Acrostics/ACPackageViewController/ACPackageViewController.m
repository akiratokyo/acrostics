//  Copyright (c) 2015 Egghead Games LLC. All rights reserved.

#import "ACAppDelegate.h"
#import "ACPackageViewController.h"
#import "ACGameListViewController.h"
#import "ACGamePlayViewController.h"
#import "ACPackageCell.h"
#import "Reachability.h"
#import <AskingPoint/AskingPoint.h>
#import "BBBadgeBarButtonItem.h"

#define TABLE_CELL_HEIGHT   200.f

#define SHADOW_WIDTH            120.f
#define PLAYBUTTON_WIDTH        80.f
#define LISTBUTTON_WIDTH        32.f
#define VOLUMETITLE_HEIGHT      25.f
#define VOLUMEINFO_HEIGHT       25.f
#define MARGIN_WIDTH            15.f

typedef NS_ENUM(NSUInteger, HomeSection) {s_playable = 0, s_unPurchased = 1 };
NSInteger const HomeSectionCount = 2;

@interface ACPackageViewController ()

@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property (weak, nonatomic) IBOutlet UIView *mTopWrapper;
@property (weak, nonatomic) IBOutlet UIImageView *mImageView;
@property (weak, nonatomic) IBOutlet UIImageView *mShadowView;
@property (weak, nonatomic) IBOutlet UILabel *mVolumeTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *mVolumeInfoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *mStateView;
@property (weak, nonatomic) IBOutlet UIButton *mPlayButton;
@property (weak, nonatomic) IBOutlet UIButton *mListButton;
@property (weak, nonatomic) IBOutlet UIToolbar *bottomToolbar;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint* topWrapperHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* volumeTitleWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* volumeTitleHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* volumeInfoHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* shadowViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* shadowViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* shadowViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* playButtonWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* playButtonLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* listButtonWidthConstraint;


@property (weak, nonatomic) IBOutlet UIView* tourWrapper;
@property (weak, nonatomic) IBOutlet UIButton* moreButton;
@property (weak, nonatomic) IBOutlet UIImageView* firstTour;
@property (weak, nonatomic) IBOutlet UIImageView* secondTour;
@property (weak, nonatomic) IBOutlet UIImageView* thirdTour;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint* firstTourWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* secondTourWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* thirdTourWidth;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint* firstTourLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* secondTourTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* thirdTourTrailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* thirdTourTop;


@property (strong, nonatomic) ACGameListViewController* gameListVC;

@property (nonatomic) DBPackage* curPackage;
@property (nonatomic) NSArray<DBPackage *> *packageList;
@property (nonatomic) NSArray<DBPackage *> *playable;
@property (nonatomic) NSArray<DBPackage *> *unPurchased;

@property (nonatomic) NSInteger supportReplies;


- (IBAction)playButtonPressed:(UIButton*)sender;
- (IBAction)listButtonPressed:(UIButton*)sender;
- (IBAction)moreButtonPressed:(UIButton*)sender;
- (void)playOrBuyGame:(NSNumber*)packageIdNumber;
- (IBAction)unwindToPackageViewController:(UIStoryboardSegue*)segue;

@end


@implementation ACPackageViewController

@synthesize isRestorePurchases;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myUnReadResponseHandler:)
                                                 name:ASKPFeedbackUnreadCountChangedNotification object:nil];
    
    self.supportReplies = [ASKPManager unreadFeedbackCount];
    
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    NSMutableArray *temp = [NSMutableArray arrayWithArray:[[ACDatabaseWrapper initialize] getPackages]];
    [temp sortUsingComparator:^NSComparisonResult(DBPackage*  _Nonnull obj1, DBPackage*  _Nonnull obj2) {
        return [obj2.dbIsEnable compare:obj1.dbIsEnable];
    }];
    self.packageList = [temp copy];

    mProductIds = [NSMutableArray new];
    for (NSInteger i = 1; i < self.packageList.count; i++) {
        DBPackage *lPackage = self.packageList[i];
        [mProductIds addObject:lPackage.dbIAPKey];
    }
    
    NSInteger packageId = [ACAppDelegate getCurrentPackage];
    self.curPackage = [self getPackageWithId:packageId];

    if (![self.curPackage.dbIsEnable boolValue]) {
        packageId = 0;
        self.curPackage = [self getPackageWithId:packageId];
    }

    if (![getValDef(QUIT_PUZZLE, @YES) boolValue]) {
        [self playOrBuyGame:@(packageId)];
        [self playButtonPressed:nil];
    }

    [self initHeaderView];
    
    
    [self configureFeedbackButton];
    [self updateFeedbackButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [self refreshHeaderView];
    [self refreshTourWrapper];
    
    [self.mTableView reloadData];
    
    if ([SKPaymentQueue canMakePayments]) {
        
        if (self.isRestorePurchases == YES) {
            
            mRealPurchasedCount = 0;
            [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
            [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
            self.isRestorePurchases = NO;
        }
        
        SKProductsRequest *lRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:mProductIds]];
        lRequest.delegate = self;
        [lRequest start];
    } else {
        [self showAlertViewWithText:@"Purchases are disabled. Please check your settings for General -> Restrictions -> In-App Purchases and try again." andTitle:@"Warning"];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self refreshHeaderView];
    [self refreshTourWrapper];
    
    self.popOverContentSize = CGSizeMake(self.view.frame.size.width * 0.7f, self.view.frame.size.height * 0.7f);
    if (self.gameListVC) {
        self.gameListVC.preferredContentSize = self.popOverContentSize;
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (DBLevel*)getCurrentLevel {
    DBLevel* curLevel = nil;
    NSArray<DBLevel*> *levels = [[ACDatabaseWrapper initialize] readAllLevels:self.curPackage.dbId];

    NSInteger puzzleId = [ACAppDelegate getCurrentPuzzle];
    if (puzzleId != -1) {
        if (levels && levels.count > puzzleId) {
            curLevel = levels[puzzleId];
        }
    }
    else {
        ACLevelSortOrder sortOrder = [ACAppDelegate getSortOrder];
        NSArray<DBLevel*> *sortedLevels = [ACAppDelegate sortedLevels:levels withSortOrder:sortOrder];
        for (int i = 0; i < sortedLevels.count; i ++) {
            DBLevel *lLevel = sortedLevels[i];
            if (lLevel && lLevel.dbStatus.integerValue < ACGameState_Solved) {
                curLevel = lLevel;
                break;
            }
        }
    }
    if (curLevel == nil) {
        if (levels.count == 0) { // things are really messed up if this happens - we have no puzzles for this volume
            levels = [[ACDatabaseWrapper initialize] readAllLevels:@(0)];
            [ASKPManager addEventWithName:@"getCurrentLevelAllNil"];
        }
        curLevel = levels[0];
        [ASKPManager addEventWithName:@"getCurrentLevelNil"];
    }
    return curLevel;
}

- (void)initHeaderView {
    self.mShadowView.layer.shadowColor = [[UIColor lightGrayColor] CGColor];
    self.mShadowView.layer.shadowOffset = CGSizeMake(-2.f, -2.f);
    self.mShadowView.layer.shadowOpacity = 1.f;
    self.mShadowView.layer.shadowRadius = 3.f;
    self.mShadowView.clipsToBounds = NO;
    
    self.mImageView.layer.shadowColor = [[UIColor lightGrayColor] CGColor];
    self.mImageView.layer.shadowOffset = CGSizeMake(2.f, 2.f);
    self.mImageView.layer.shadowOpacity = 1.f;
    self.mImageView.layer.shadowRadius = 3.f;
    self.mImageView.clipsToBounds = NO;
    
    [self refreshHeaderView];
}

- (void)refreshHeaderView {
    
    if (self.curPackage)
        self.mVolumeTitleLabel.text = [self.curPackage.dbName hasPrefix:@"Acrostics: "] ? [self.curPackage.dbName substringFromIndex:@"Acrostics: ".length] : self.curPackage.dbName;
    
    DBLevel *lLevel = [self getCurrentLevel];
    NSInteger puzzleNum = [ACAppDelegate puzzleNumForDbid:lLevel.dbId];
    self.mVolumeInfoLabel.text = [NSString stringWithFormat:@"# %ld", (long)puzzleNum];
    self.mStateView.image = [ACAppDelegate getPuzzleStateImage:lLevel];
    
    CGSize expectedSize = [self.mVolumeTitleLabel.text boundingRectWithSize:CGSizeMake(100.f, self.mVolumeTitleLabel.frame.size.height)
                                               options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                            attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:20.f]}
                                               context:nil].size;
    
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat minTopWrapperWidth = expectedSize.width + 300.f;
    CGFloat normalTopWrapperWidth = expectedSize.width + 390.f;
    CGFloat rate = MIN((width * 1.f - MARGIN_WIDTH * 4) / (minTopWrapperWidth - MARGIN_WIDTH * 4), 1.f);
    
    self.volumeTitleWidthConstraint.constant = expectedSize.width * rate;
    self.volumeTitleHeightConstraint.constant = VOLUMETITLE_HEIGHT * rate;
    self.volumeInfoHeightConstraint.constant = VOLUMEINFO_HEIGHT * rate;
    self.topWrapperHeightConstraint.constant = SHADOW_WIDTH * rate + 2 * MARGIN_WIDTH;
    self.listButtonWidthConstraint.constant = LISTBUTTON_WIDTH * rate;
    self.playButtonWidthConstraint.constant = PLAYBUTTON_WIDTH * rate;
    
    self.mVolumeTitleLabel.font = [UIFont boldSystemFontOfSize:20.f];
    self.mVolumeInfoLabel.font = [UIFont systemFontOfSize:20.f];
    
    if (width < minTopWrapperWidth) {
        self.shadowViewTrailingConstraint.constant = MIN(width / 2 - expectedSize.width * rate / 2 - SHADOW_WIDTH * rate - MARGIN_WIDTH, 60.f);
        self.mVolumeTitleLabel.font = [UIFont boldSystemFontOfSize:18.f];
        self.mVolumeInfoLabel.font = [UIFont systemFontOfSize:18.f];
    }
    else if (width < normalTopWrapperWidth) {
        self.shadowViewTrailingConstraint.constant = width / 2 - expectedSize.width * rate / 2 - SHADOW_WIDTH - MARGIN_WIDTH;
    }
    else {
        self.shadowViewTrailingConstraint.constant = 60.f;
    }
    self.playButtonLeadingConstraint.constant = MIN(width / 2 - expectedSize.width * rate / 2 - PLAYBUTTON_WIDTH * rate - MARGIN_WIDTH, 60.f);
}

- (void)refreshTourWrapper {
    
    CGRect viewFrame = self.view.frame;
    CGRect tourFrame = self.tourWrapper.frame;
    
    if (viewFrame.size.width < 600.f) {
        CGFloat tourWidth = viewFrame.size.width * 0.6f;
        CGFloat tourHeight = tourWidth * 5 / 4;
        
        self.firstTourLeading.constant = (viewFrame.size.width - tourWidth) / 2.f;
        self.firstTourWidth.constant = tourWidth;
        
        self.secondTourTop.constant = 70.f + tourHeight + MARGIN_WIDTH;
        self.secondTourWidth.constant = tourWidth;
        
        self.thirdTourTop.constant = 70.f + (tourHeight + MARGIN_WIDTH) * 2;
        self.thirdTourTrailing.constant = (viewFrame.size.width - tourWidth) / 2.f;
        self.thirdTourWidth.constant = tourWidth;
        
        
        tourFrame.size.height = 70.f + (tourHeight + MARGIN_WIDTH) * 3;
    }
    else {
        CGFloat tourWidth = viewFrame.size.width / 3 - 30.f;
        
        self.firstTourLeading.constant = 25.f;
        self.firstTourWidth.constant = tourWidth;
        
        self.secondTourTop.constant = 70.f;
        self.secondTourWidth.constant = tourWidth;
        
        self.thirdTourTop.constant = 70.f;
        self.thirdTourTrailing.constant = 25.f;
        self.thirdTourWidth.constant = tourWidth;
        
        
        tourFrame.size.height = CGRectGetMaxY(self.firstTour.frame) + MARGIN_WIDTH;
    }
    
    self.tourWrapper.frame = tourFrame;

    NSInteger rowCount = self.playable.count + (self.moreButton.selected ? self.unPurchased.count : 1);
    CGSize contentSize = CGSizeMake(self.mTableView.contentSize.width, 60.f * rowCount + tourFrame.size.height);
    
    self.mTableView.contentSize = contentSize;
}


#pragma mark - Autorotations methods -
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self.mTableView reloadData];
    [self refreshTourWrapper];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

#pragma mark - Table view methods -
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch ((HomeSection) indexPath.section) {
        case s_playable: {
            DBPackage *mPackage = self.playable[indexPath.row];
            UITableViewCell *lCell = [tableView dequeueReusableCellWithIdentifier:@"ACPlayCell" forIndexPath:indexPath];
            lCell.tag = mPackage.dbId.integerValue;
            lCell.textLabel.text = [mPackage.dbName hasPrefix:@"Acrostics: "] ? [mPackage.dbName substringFromIndex:@"Acrostics: ".length] : mPackage.dbName;
            lCell.detailTextLabel.text = @"PLAY";
            lCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

            return lCell;
        }
        case s_unPurchased: {
            ACPackageCell *lCell = (ACPackageCell*)[tableView dequeueReusableCellWithIdentifier:@"ACPackageCell" forIndexPath:indexPath];
            if (self.unPurchased.count > 0) {
                DBPackage *mPackage = self.unPurchased[indexPath.row];
                lCell.tag = mPackage.dbId.integerValue;
                if (0 < lCell.tag && lCell.tag <= [mPriceArray count]) {
                    SKProduct *product = [self getProductWithIAPKey:mPackage.dbIAPKey];
                    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
                    [formatter setLocale:product.priceLocale];
                    lCell.price = [formatter stringFromNumber:product.price];
                }
                [lCell setPackageInfo:mPackage indexPath:indexPath];
            }
            return lCell;
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.unPurchased.count > 0 ? HomeSectionCount : HomeSectionCount - 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    self.playable = [self getPlayableVolumes];
    self.unPurchased = [self getUnPurchasedVolumes];

    switch ((HomeSection) section) {
        case  s_playable:
            return self.playable.count;
        case s_unPurchased:
            return self.moreButton.selected ? self.unPurchased.count : 1;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DBPackage *package;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    switch ((HomeSection) indexPath.section) {
        case s_playable:
            package = self.playable[indexPath.row];
            break;
        case s_unPurchased:
            package = self.unPurchased[indexPath.row];
            break;
    }

    [ACAppDelegate setCurrentPackage:package.dbId];
    [self playOrBuyGame:package.dbId];
}

- (IBAction)tapPlayOrBuyButton:(UIButton*)sender {
    DBPackage *package = self.unPurchased[sender.tag];
    
    [ACAppDelegate setCurrentPackage:package.dbId];
    [self playOrBuyGame:package.dbId];
}

#pragma mark - Purchase delegates -

#pragma mark - SKProductsRequestDelegate method
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    if (mPriceArray != nil) {
        mPriceArray = nil;
    }
    mPriceArray = [NSMutableArray arrayWithCapacity:0];
    
    for (NSString *iAP in mProductIds) {
        for (SKProduct *product in response.products) {
            if ([product.productIdentifier isEqualToString:iAP]) {
                [mPriceArray addObject:product];
            }
        }
    }
    [self.mTableView reloadData];
}

#pragma mark - SKPaymentTransactionObserver method

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction * lTransaction in transactions) {
        switch (lTransaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completedTransaction:lTransaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:lTransaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:lTransaction];
                break;
            default:
                break;
        }
    };
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray *)downloads {
    for (SKDownload *download in downloads)
    {
        switch (download.downloadState) {
            case SKDownloadStateActive:
                DLog(@"Download progress = %f",
                     download.progress);
                DLog(@"Download time = %f",
                     download.timeRemaining);
                break;
            case SKDownloadStateFinished:
                if (mCurrentCellTag != -1) {
                    [[ACDatabaseWrapper initialize] parseBoughtPackageWithId:mCurrentCellTag];
                    mCurrentCellTag = -1;
                    [self.mTableView reloadData];
                }
                break;
            default:
                break;
        }
    }
    
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    if (queue.transactions.count == 0) {
        [self showAlertViewWithText:@"No previous purchases were found." andTitle:@"Warning"];
    } else {
        if (mRealPurchasedCount == 0) {
            [self showAlertViewWithText:[NSString stringWithFormat:@"Your %@ purchased volumes are already available. No new volumes were found to restore.",@(queue.transactions.count)] andTitle:@"Message"];
        } else {
            [self showAlertViewWithText:[NSString stringWithFormat:@"Your %@ previously purchased volumes have been restored.", @(mRealPurchasedCount)] andTitle:@"Message"];
        }
    }
}

#pragma mark - Transactions methods
- (void)completedTransaction:(SKPaymentTransaction *)pTransaction {
    DLog(@"transaction completed");

    if (pTransaction.payment && pTransaction.payment.productIdentifier) {
        [ASKPManager addEventWithName:@"purchase" andData:@{@"Product_name" : pTransaction.payment.productIdentifier}];
        [ASKPManager requestCommandsWithTag:@"purchase"];
    }
    if ([pTransaction respondsToSelector:@selector(downloads)]) {
        if([pTransaction.downloads count] > 0) {
            [[SKPaymentQueue defaultQueue] startDownloads:pTransaction.downloads];
        }
    }
    if (mCurrentCellTag != -1) {
        [[ACDatabaseWrapper initialize] parseBoughtPackageWithId:mCurrentCellTag];
        [ACAppDelegate clearCurrentPuzzle];
        [self playOrBuyGame:[NSNumber numberWithInteger:mCurrentCellTag]];
        [self.mTableView reloadData];
        mCurrentCellTag = -1;
    }
    [[SKPaymentQueue defaultQueue] finishTransaction:pTransaction];
}


- (void)restoreTransaction:(SKPaymentTransaction *)pTransaction {
    DLog(@"restoreTransaction...");
    if (pTransaction.payment && pTransaction.payment.productIdentifier) {
         [ASKPManager addEventWithName:@"purchaseRestored" andData:@{@"Product_name" : pTransaction.payment.productIdentifier}];
        [ASKPManager requestCommandsWithTag:@"purchaseRestored"];
        
        for (NSUInteger i = 0; i < [mProductIds count]; i++) {
            if ([pTransaction.payment.productIdentifier isEqualToString:[NSString stringWithFormat:@"%@", mProductIds[i]]]) {
                if (![((DBPackage *)[[ACDatabaseWrapper initialize] getPackages][i + 1]).dbIsEnable boolValue]) {
                    [[ACDatabaseWrapper initialize] parseBoughtPackageWithId:i + 1];
                    mRealPurchasedCount++;
                }
                [self.mTableView reloadData];
                break;
            }
        }
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction:pTransaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)pTransaction {
    DLog(@"failedTransaction...");
    
    if (pTransaction.payment && pTransaction.payment.productIdentifier && pTransaction.error.localizedDescription)
    {
        [ASKPManager addEventWithName:@"purchaseFailed"
                              andData:@{@"Product_name": pTransaction.payment.productIdentifier,
                                        @"Error" : pTransaction.error.localizedDescription}];
        [ASKPManager requestCommandsWithTag:@"purchaseFailed"];
    }
    
    if (pTransaction.error && pTransaction.error.code != SKErrorPaymentCancelled) {
        DLog(@"Transaction error: %@", pTransaction.error.localizedDescription);
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction: pTransaction];
}

#pragma mark - Activity view -
- (void)showActivityView:(NSNumber *)pValue {
}

- (NSArray<DBPackage *> *)getPlayableVolumes {
    NSMutableArray<DBPackage *> *result = [NSMutableArray arrayWithCapacity:0];
    for (DBPackage* package in self.packageList) {
        if (package.dbIsEnable.boolValue && package.dbId.integerValue != self.curPackage.dbId.integerValue)
            [result addObject:package];
    }
    return [result copy];
}

- (NSArray <DBPackage *> *)getUnPurchasedVolumes {
    NSMutableArray<DBPackage *> *result = [NSMutableArray arrayWithCapacity:0];
    for (DBPackage* package in self.packageList) {
        if (!package.dbIsEnable.boolValue)
            [result addObject:package];
    }
    return [result copy];
}

- (DBPackage*)getPackageWithId:(NSInteger)packageId {
    for (DBPackage* package in self.packageList) {
        if (package && package.dbId.integerValue == packageId)
            return package;
    }
    return nil;
}

- (SKProduct*)getProductWithIAPKey:(NSString*)IAPKey {
    SKProduct *product = nil;

    if (mPriceArray && mPriceArray.count > 0 && IAPKey) {
        for (SKProduct *temp in mPriceArray) {
            if ([temp.productIdentifier isEqualToString:IAPKey]) {
                product = temp;
                break;
            }
        }
    }
    return product;
}

#pragma mark - Actions for selected cell -

- (void)playOrBuyGame:(NSNumber*)packageIdNumber {
    NSInteger packageId = packageIdNumber.integerValue;
    DBPackage* package = [self getPackageWithId:packageId];
    if ([package.dbIsEnable boolValue]) {
        [AppDelegate playSoundWithStyle:SelectCategorySound];
        [ACAppDelegate setCurrentPackage:packageIdNumber];
        self.curPackage = package;
        self.isFromList = NO;
        [self refreshHeaderView];
        [self.mTableView reloadData];
    } else {
        Reachability *lReachability = [Reachability reachabilityForInternetConnection];
        NetworkStatus lCurrentNetworkStatus = [lReachability currentReachabilityStatus];
        if (lCurrentNetworkStatus != NotReachable) {
            if ([SKPaymentQueue canMakePayments]) {
                mCurrentCellTag = packageId;
                SKProduct *product = [self getProductWithIAPKey:package.dbIAPKey];
                if (product) {
                    SKPayment *lPayment = [SKPayment paymentWithProduct:product];
                    [[SKPaymentQueue defaultQueue] addPayment:lPayment];
                    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
                }
            } else {
                mCurrentCellTag = -1;
                [self showAlertViewWithText:@"Purchases are disabled. Please check your settings for General -> Restrictions -> In-App Purchases and try again." andTitle:@"Warning"];
            }
        } else {
            [self showAlertViewWithText:@"Cannot connect to the iTunes Store. Please check that your internet is on and try again." andTitle:@"Warning"];
        }
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:Segue_ShowListViewController]) {
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        
        self.gameListVC = (ACGameListViewController*)segue.destinationViewController;
        self.gameListVC.package = (DBPackage *)sender;
        self.gameListVC.isFromList = self.isFromList;
        self.gameListVC.parentVC = self;
    }
    else if ([segue.identifier isEqualToString:Segue_ShowGamePlayViewController]) {
        NSString* volumeTitle = [self.curPackage.dbName hasPrefix:@"Acrostics: "] ? [self.curPackage.dbName substringFromIndex:@"Acrostics: ".length] : self.curPackage.dbName;
        if (CGRectGetWidth(self.view.frame) < 420.f) {
            volumeTitle = @"";
        }
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:volumeTitle style:UIBarButtonItemStylePlain target:nil action:nil];
        
        ACGamePlayViewController *lView = (ACGamePlayViewController*)segue.destinationViewController;
        if (sender && [sender isKindOfClass:[DBLevel class]]) {
            lView.level = sender;
        }
        else {
            DBLevel *lLevel = [self getCurrentLevel];
            lView.level = lLevel;
        }
    }
    else if ([segue.identifier isEqualToString:Segue_ShowHelpViewController]) {
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:self.mVolumeTitleLabel.text style:UIBarButtonItemStylePlain target:nil action:nil];
    }
}

#pragma mark - Show alert view -
- (void) showAlertViewWithText:(NSString*)pText andTitle:(NSString*)pTitle{
    UIAlertController* lAlert = [UIAlertController alertControllerWithTitle:pTitle message:pText preferredStyle:UIAlertControllerStyleAlert];
    [lAlert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    
    [self presentViewController:lAlert animated:YES completion:nil];
}

#pragma mark - Guide -

- (IBAction)playButtonPressed:(UIButton*)sender {
    if ([self.curPackage.dbIsEnable boolValue]) {
        [AppDelegate playSoundWithStyle:SelectCategorySound];
        [ACAppDelegate setCurrentPackage:self.curPackage.dbId];
        self.isFromList = NO;
        [self performSegueWithIdentifier:Segue_ShowGamePlayViewController sender:self.curPackage];
    }
}

- (IBAction)listButtonPressed:(UIButton*)sender {
    if ([self.curPackage.dbIsEnable boolValue]) {
        [AppDelegate playSoundWithStyle:SelectCategorySound];
        [ACAppDelegate setCurrentPackage:self.curPackage.dbId];
        self.isFromList = YES;
        [self performSegueWithIdentifier:Segue_ShowListViewController sender:self.curPackage];
    }
}

- (IBAction)moreButtonPressed:(UIButton*)sender {
    sender.selected = !sender.selected;
    [self.mTableView reloadData];
}

- (IBAction)menuButtonPressed:(id)sender {
    UIActionSheet *lActionSheet = [[UIActionSheet alloc] initWithTitle:@"Menu" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:[ACAppDelegate getMenuSoundTitle], @"Erase all Player Records", @"Restore Purchases", nil];
    [lActionSheet showInView:self.view];
}

- (IBAction)feedbackButtonPressed:(id)sender {
    self.supportReplies = 0;
    [self updateFeedbackButton];
        
    ASKPCustomerSupportViewController *fbController = [ASKPCustomerSupportViewController new];
    [self presentViewController:fbController animated:YES completion:NULL];
}

- (IBAction)guideButtonPressed:(id)sender {
    
}

- (IBAction)didDismissGameListVC:(UIStoryboardSegue*)segue {
    [self refreshHeaderView];
}

- (IBAction)unwindToPackageViewController:(UIStoryboardSegue*)segue {
    ACGameListViewController* sourceViewController = segue.sourceViewController;
    if ([sourceViewController isKindOfClass:[ACGameListViewController class]]) {
        [self refreshHeaderView];
        
        [self performSelector:@selector(goToGamePlayVC:) withObject:sourceViewController.level afterDelay:0.5f];
    }
    self.gameListVC = nil;
}

- (void)goToGamePlayVC:(DBLevel*)level {
    [self performSegueWithIdentifier:Segue_ShowGamePlayViewController sender:level];
}

- (void)viewDidUnload {
    self.mTableView = nil;
    [super viewDidUnload];
}

- (void)configureFeedbackButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(0, 0, 100, 44);
    button.titleLabel.font = [UIFont systemFontOfSize:17.0];
    [button setTitle:@"Feedback" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(feedbackButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    BBBadgeBarButtonItem *feedbackBarButtonItem = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:button];
    feedbackBarButtonItem.badgeOriginX = 83;
    feedbackBarButtonItem.badgeOriginY = 2;
    
    NSMutableArray *toolbarItems = [self.bottomToolbar.items mutableCopy];
    [toolbarItems insertObject:feedbackBarButtonItem atIndex:2];
    self.bottomToolbar.items = [toolbarItems copy];
}

- (void)updateFeedbackButton {
    BBBadgeBarButtonItem *button = (BBBadgeBarButtonItem*)self.bottomToolbar.items[2];
    NSString *badgeValue = [NSString stringWithFormat:@"%d", (int)self.supportReplies];
    button.badgeValue = badgeValue;
}

- (void)myUnReadResponseHandler:(NSNotification*)note {
    NSDictionary *data = note.userInfo;
    self.supportReplies = [data[ASKPFeedbackUnreadCountUserInfoKey] unsignedIntegerValue];
    [self updateFeedbackButton];
}


#pragma mark -
#pragma mark - Actions sheet delegate

- (void)restorePurchasedPressed {
    if ([SKPaymentQueue canMakePayments]) {
        
        mRealPurchasedCount = 0;
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
        self.isRestorePurchases = NO;
        
        SKProductsRequest *lRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:mProductIds]];
        lRequest.delegate = self;
        [lRequest start];
    } else {
        [self showAlertViewWithText:@"Purchases are disabled. Please check your settings for General -> Restrictions -> In-App Purchases and try again." andTitle:@"Warning"];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    DLog(@"actions sheet - pressed button: %@", @(buttonIndex));
    switch (buttonIndex) {
        case 0: {
            //sound
            ACAppDelegate.soundsEnabled = !ACAppDelegate.soundsEnabled;
            [ASKPManager requestCommandsWithTag:ACAppDelegate.soundsEnabled ? @"soundOn" : @"soundOff"];
            break;
        }
        case 1: {
            //remove all player records
            UIAlertController* lEraseAlert = [UIAlertController alertControllerWithTitle:@"" message:@"Are you sure you want to erase all records? Doing so will return every puzzle to its original, blank state. Once done, this cannot be undone." preferredStyle:UIAlertControllerStyleAlert];
            [lEraseAlert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
            [lEraseAlert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [ASKPManager requestCommandsWithTag:@"EraseAll"];
                for (DBPackage* package in self.packageList) {
                    if (!package)
                        continue;
                    [[ACDatabaseWrapper initialize] resetAllGamesInPackage:package.dbId];
                }
            }]];
            [self presentViewController:lEraseAlert animated:YES completion:nil];
            break;
        }
        case 2: {
            [self restorePurchasedPressed];
            break;
        }
        default:
            break;
    }
}


@end
