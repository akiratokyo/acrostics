//  Copyright (c) 2012-2015 Egghead Games LLC. All rights reserved.

#import "ACAppDelegate.h"
#import "Appirater.h"
#import <AskingPoint/AskingPoint.h>


@implementation UINavigationController (override)

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskAll;
    }
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    }
    return NO;
}

@end

NSString *const ACAppDelegateCachedFontsKey = @"ACAppDelegateCachedFonts";

@interface ACAppDelegate ()

@property (nonatomic) NSDictionary *fontCacheDict;

@end

@implementation ACAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize isPlay;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Fabric with:@[[Crashlytics class]]];

    NSString *askingPointId = @"-wDjAFUIVjScIpAqWqrKEuG9UHkYdfF1rl5xhYdwu4o";
    [ASKPManager startup:askingPointId];

    self.fontCacheDict = @{};
    
    [self configureFontCache];

    if (![[NSUserDefaults standardUserDefaults] objectForKey:SOUND]) {
        [[NSUserDefaults standardUserDefaults] setObject:SOUND_ON forKey:SOUND];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [Appirater appEnteredForeground:YES];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self saveContext];
    [self saveFontCache];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Acrostics" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Acrostics.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


#pragma mark - Sound method

- (void)playSoundWithStyle:(StylesOfSond)pStyle {
    
    if ([getVal(SOUND) isEqualToString:SOUND_ON]) {
        
        CFBundleRef lMainBundle = CFBundleGetMainBundle();
        CFURLRef lSoundFileUrlRef;
        
        switch (pStyle) {
            case ErrorSound:{
                lSoundFileUrlRef = CFBundleCopyResourceURL(lMainBundle, (CFStringRef) @"error", CFSTR ("mp3"), NULL);
                break;
            }
            case EnterLetterSound:{
                lSoundFileUrlRef = CFBundleCopyResourceURL(lMainBundle, (CFStringRef) @"enter_letter", CFSTR ("wav"), NULL);
                break;
            }
            case SelectCategorySound:{
                lSoundFileUrlRef = CFBundleCopyResourceURL(lMainBundle, (CFStringRef) @"select_category_or_puzzle", CFSTR ("mp3"), NULL);
                break;
            }
            case SelectSquareSound:{
                if (isPlay == YES) {
                    lSoundFileUrlRef = CFBundleCopyResourceURL(lMainBundle, (CFStringRef) @"select_square", CFSTR ("wav"), NULL);
                } else {
                    lSoundFileUrlRef = nil;
                    isPlay = YES;
                }
                break;
            }
            case SuccessSound:{
                lSoundFileUrlRef = CFBundleCopyResourceURL(lMainBundle, (CFStringRef) @"success", CFSTR ("mp3"), NULL);
                break;
            }
            case UndoButtonSound:{
                lSoundFileUrlRef = CFBundleCopyResourceURL(lMainBundle, (CFStringRef) @"undo", CFSTR ("mp3"), NULL);
                break;
            }
            case ClearSquareSound:{
                lSoundFileUrlRef = CFBundleCopyResourceURL(lMainBundle, (CFStringRef) @"clear_square", CFSTR ("wav"), NULL);
                break;
            }
        }
        
        if (lSoundFileUrlRef != nil) {
            UInt32 lSoundID;
            AudioServicesCreateSystemSoundID(lSoundFileUrlRef, &lSoundID);
            AudioServicesPlaySystemSound(lSoundID);
            CFRelease(lSoundFileUrlRef);
        }
    }
}

#pragma mark - Fonts

- (void)configureFontCache {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *fontCacheDict = [defaults objectForKey:ACAppDelegateCachedFontsKey];
    if (!fontCacheDict) {
        self.fontCacheDict = [self generateFontCacheDict];
    } else {
        self.fontCacheDict = fontCacheDict;
    }
}


+ (CGFloat)fontSizeForString:(NSString*)string
                       frame:(CGRect)frame
                  isBoldFont:(BOOL)isBoldFont
{
    ACAppDelegate *appDelegate = (ACAppDelegate *)[[UIApplication sharedApplication] delegate];
    return [appDelegate fontSizeForString:string frame:frame isBoldFont:isBoldFont];
}

- (CGFloat)fontSizeForString:(NSString*)string frame:(CGRect)frame isBoldFont:(BOOL)isBoldFont
{
    NSString *cachedFontKey = [NSString stringWithFormat:@"%@-{%.0f, %.0f}-%@", string, frame.size.width, frame.size.height, @(isBoldFont)];
    NSNumber *cachedNumber = self.fontCacheDict[cachedFontKey];
    if (cachedNumber) {
        return cachedNumber.floatValue;
    }
    
    CGFloat fontSize = (int)frame.size.height;
    UIFont *font = isBoldFont ? [UIFont boldSystemFontOfSize:fontSize] : [UIFont systemFontOfSize:fontSize];
    NSDictionary *attributes = @{NSFontAttributeName: font};
    CGSize expectedSize = [string boundingRectWithSize:CGSizeMake(frame.size.width, 9999999)
                                               options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                            attributes:attributes
                                               context:nil].size;
    if (expectedSize.height >= frame.size.height || fontSize >= 5.f) {
        fontSize = fontSize - 1;
    }
    NSMutableDictionary *dict = [self.fontCacheDict mutableCopy];
    [dict setObject:@(fontSize) forKey:cachedFontKey];
    self.fontCacheDict = [dict copy];
    return fontSize;
}

- (void)saveFontCache
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.fontCacheDict forKey:ACAppDelegateCachedFontsKey];
    [userDefaults synchronize];
}

#pragma mark -

+ (UIImage*)getPuzzleStateImage:(DBLevel*)lLevel {
    
    NSInteger state = [lLevel.dbStatus integerValue];
    NSInteger difficulty = [lLevel.dbDifficulty integerValue];
    // TODO: This code is also in ACGameListViewController
    BOOL isPerfect = (lLevel.dbStatus.integerValue == ACGameState_Solved && lLevel.dbCurrentTime.integerValue < lLevel.dbAverageTime.integerValue);
    
    UIImage* stateImage = nil;
    switch (state) {
        case ACGameState_NotStarted:
        {
            switch (difficulty) {
                case ACGameDifficulty_Easy:
                    stateImage = [UIImage imageNamed:@"puzzle_difficulty_easy"];
                    break;
                case ACGameDifficulty_Medium:
                    stateImage = [UIImage imageNamed:@"puzzle_difficulty_medium"];
                    break;
                case ACGameDifficulty_Hard:
                    stateImage = [UIImage imageNamed:@"puzzle_difficulty_hard"];
                    break;
            }
        }
            break;
        case ACGameState_Started:
            switch (difficulty) {
                case ACGameDifficulty_Easy:
                    stateImage = [UIImage imageNamed:@"puzzle_state_processing_easy"];
                    break;
                case ACGameDifficulty_Medium:
                    stateImage = [UIImage imageNamed:@"puzzle_state_processing_medium"];
                    break;
                case ACGameDifficulty_Hard:
                    stateImage = [UIImage imageNamed:@"puzzle_state_processing_hard"];
                    break;
            }
            break;
        case ACGameState_Solved:
        {
            stateImage = [UIImage imageNamed:@"puzzle_state_solved"];
            if (isPerfect)
                stateImage = [UIImage imageNamed:@"puzzle_state_perfect"];
        }
            break;
        default:
            break;
    }
    
    return stateImage;
}

+ (NSArray*)sortedLevels:(NSArray*)levels withSortOrder:(ACLevelSortOrder)sortOrder {
    if (!levels || levels.count < 1)
        return @[];
    
    NSArray* sortedLevels = [levels sortedArrayUsingComparator:^NSComparisonResult(DBLevel* obj1, DBLevel* obj2) {
        switch (sortOrder) {
            case ACLevelSortOrder_Sequential:
            {
                return [obj1.dbId compare:obj2.dbId];
            }
                break;
            case ACLevelSortOrder_Easier:
            {
                return [obj1.dbDifficulty compare:obj2.dbDifficulty];
            }
                break;
            case ACLevelSortOrder_Harder:
            {
                return [obj2.dbDifficulty compare:obj1.dbDifficulty];
            }
                break;
            case ACLevelSortOrder_Middle:
            {
                if (obj1.dbDifficulty.integerValue == ACGameDifficulty_Medium) {
                    if (obj2.dbDifficulty.integerValue == ACGameDifficulty_Medium) {
                        return [obj1.dbId compare:obj2.dbId];
                    }
                    else
                        return NSOrderedAscending;
                }
                else {
                    if (obj2.dbDifficulty.integerValue == ACGameDifficulty_Medium) {
                        return NSOrderedDescending;
                    }
                    else {
                        return [obj1.dbDifficulty compare:obj2.dbDifficulty];
                    }
                }
            }
                break;
                
            default:
                break;
        }
        return NSOrderedAscending;
    }];
    
    return sortedLevels;
}

+ (NSInteger)puzzleNumForDbid:(NSNumber*) dbid {
    NSInteger result = (dbid.integerValue % 50) + 1;
    return result;
}

static NSString *const kSCREEN1 = @"SCREEN1";
static NSString *const kSCREEN2 = @"SCREEN2";

+ (void)setCurrentPackage:(NSNumber*)packageId {
    setVal(kSCREEN1, packageId);
}

+ (NSInteger)getCurrentPackage {
    NSNumber *result = [[NSUserDefaults standardUserDefaults] objectForKey:kSCREEN1];
    if (result == nil) {
        result = @(0);
        [self setCurrentPackage:result];
    }
    return result.integerValue;
}

+ (void)setCurrentPuzzle:(NSNumber*)dbid {
    setVal(kSCREEN2, dbid);
}

+ (NSInteger)getCurrentPuzzle {
    NSNumber *result = [[NSUserDefaults standardUserDefaults] objectForKey:kSCREEN2];
    if (result == nil) {
        result = @(-1);
        [self setCurrentPuzzle:result];
    }
    return result.integerValue;
}

+ (void)clearCurrentPuzzle {
    [self setCurrentPuzzle:@-1];
}

static NSString *const kSORT_ORDER = @"SORT_ORDER";

+ (void)setSortOrder:(ACLevelSortOrder)order {
    setVal(kSORT_ORDER, @(order));
}

+ (ACLevelSortOrder) getSortOrder {
    ACLevelSortOrder result = ACLevelSortOrder_Sequential;

    NSNumber *stored = [[NSUserDefaults standardUserDefaults] objectForKey:kSORT_ORDER];
    if (stored == nil) {
        [self setSortOrder:result];
    } else if (stored.integerValue >= ACLevelSortOrder_Sequential && stored.integerValue <= ACLevelSortOrder_Middle) {
        result = stored.integerValue;
    }
    return result;
}

+ (BOOL)soundsEnabled {
    return [getVal(SOUND) isEqualToString:SOUND_ON];
}

+ (void)setSoundsEnabled:(BOOL)soundsEnabled {
    setVal(SOUND, soundsEnabled ? SOUND_ON : SOUND_OFF);
}

+ (NSString *)getMenuSoundTitle {
    return ((ACAppDelegate.soundsEnabled) ? @"Mute Sounds" : @"Play Sounds");
}

- (NSDictionary *)generateFontCacheDict
{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    [dict setObject:@(30) forKey:@"W-{31, 31}-1"];
    [dict setObject:@(36) forKey:@"New York county or river-{416, 43}-0"];
    [dict setObject:@(55) forKey:@"New York county or river-{627, 66}-0"];
    [dict setObject:@(73) forKey:@"W-{88, 88}-1"];
    [dict setObject:@(12) forKey:@"100-{35, 15}-0"];
    [dict setObject:@(17) forKey:@"W-{17, 18}-1"];
    [dict setObject:@(12) forKey:@"88888-{87, 13}-0"];
    [dict setObject:@(13) forKey:@"000-{27, 14}-0"];
    [dict setObject:@(12) forKey:@"100-{62, 15}-0"];
    [dict setObject:@(6) forKey:@"000-{14, 7}-0"];
    [dict setObject:@(10) forKey:@"W-{13, 12}-0"];
    [dict setObject:@(24) forKey:@"W-{29, 29}-1"];
    [dict setObject:@(11) forKey:@"W-{12, 12}-0"];
    [dict setObject:@(9) forKey:@"88888-{21, 10}-0"];
    [dict setObject:@(36) forKey:@"W-{37, 37}-1"];
    [dict setObject:@(12) forKey:@"88888-{110, 13}-0"];
    [dict setObject:@(9) forKey:@"88888-{27, 10}-0"];
    [dict setObject:@(6) forKey:@"88888-{13, 7}-0"];
    [dict setObject:@(29) forKey:@"W-{31, 30}-1"];
    [dict setObject:@(12) forKey:@"100-{111, 15}-0"];
    [dict setObject:@(51) forKey:@"W-{61, 61}-1"];
    [dict setObject:@(9) forKey:@"88888-{54, 10}-0"];
    [dict setObject:@(16) forKey:@"New York county or river-{207, 20}-0"];
    [dict setObject:@(55) forKey:@"New York county or river-{626, 66}-0"];
    [dict setObject:@(20) forKey:@"W-{25, 25}-1"];
    [dict setObject:@(7) forKey:@"88888-{35, 8}-0"];
    [dict setObject:@(74) forKey:@"New York county or river-{837, 89}-0"];
    [dict setObject:@(34) forKey:@"W-{41, 41}-1"];
    [dict setObject:@(27) forKey:@"W-{29, 28}-1"];
    [dict setObject:@(7) forKey:@"88888-{27, 8}-0"];
    [dict setObject:@(56) forKey:@"W-{67, 67}-1"];
    [dict setObject:@(6) forKey:@"000-{16, 8}-0"];
    [dict setObject:@(10) forKey:@"000-{21, 11}-0"];
    [dict setObject:@(12) forKey:@"88888-{59, 13}-0"];
    [dict setObject:@(12) forKey:@"88888-{82, 13}-0"];
    [dict setObject:@(12) forKey:@"000-{25, 13}-0"];
    [dict setObject:@(12) forKey:@"100-{82, 15}-0"];
    [dict setObject:@(13) forKey:@"W-{14, 14}-0"];
    [dict setObject:@(12) forKey:@"100-{27, 15}-0"];
    [dict setObject:@(12) forKey:@"000-{29, 15}-0"];
    [dict setObject:@(26) forKey:@"New York county or river-{306, 32}-0"];
    [dict setObject:@(16) forKey:@"New York county or river-{206, 20}-0"];
    [dict setObject:@(23) forKey:@"W-{25, 24}-1"];
    [dict setObject:@(46) forKey:@"W-{55, 55}-1"];
    [dict setObject:@(39) forKey:@"W-{46, 47}-1"];
    [dict setObject:@(36) forKey:@"New York county or river-{417, 43}-0"];
    [dict setObject:@(23) forKey:@"W-{24, 24}-1"];
    [dict setObject:@(7) forKey:@"W-{9, 9}-0"];
    [dict setObject:@(26) forKey:@"W-{32, 32}-1"];
    [dict setObject:@(7) forKey:@"88888-{26, 8}-0"];
    [dict setObject:@(33) forKey:@"W-{40, 40}-1"];
    [dict setObject:@(9) forKey:@"88888-{28, 10}-0"];
    [dict setObject:@(15) forKey:@"W-{19, 19}-1"];
    [dict setObject:@(9) forKey:@"88888-{55, 10}-0"];
    [dict setObject:@(7) forKey:@"88888-{18, 8}-0"];
    [dict setObject:@(18) forKey:@"W-{18, 19}-1"];
    [dict setObject:@(12) forKey:@"88888-{37, 13}-0"];
    [dict setObject:@(16) forKey:@"W-{20, 20}-1"];
    [dict setObject:@(9) forKey:@"000-{20, 10}-0"];
    [dict setObject:@(12) forKey:@"W-{13, 13}-0"];
    [dict setObject:@(37) forKey:@"W-{38, 38}-1"];
    [dict setObject:@(12) forKey:@"100-{40, 15}-0"];
    [dict setObject:@(11) forKey:@"000-{24, 12}-0"];
    [dict setObject:@(38) forKey:@"W-{46, 46}-1"];
    [dict setObject:@(97) forKey:@"W-{116, 116}-1"];
    [dict setObject:@(45) forKey:@"W-{54, 54}-1"];
    [dict setObject:@(13) forKey:@"000-{28, 14}-0"];
    [dict setObject:@(92) forKey:@"W-{110, 110}-1"];
    [dict setObject:@(51) forKey:@"W-{62, 62}-1"];
    [dict setObject:@(23) forKey:@"New York county or river-{277, 28}-0"];
    [dict setObject:@(12) forKey:@"88888-{56, 13}-0"];
    [dict setObject:@(7) forKey:@"000-{17, 9}-0"];
    [dict setObject:@(10) forKey:@"000-{23, 12}-0"];
    [dict setObject:@(7) forKey:@"88888-{17, 8}-0"];
    [dict setObject:@(23) forKey:@"New York county or river-{276, 27}-0"];
    [dict setObject:@(21) forKey:@"W-{26, 26}-1"];
    [dict setObject:@(18) forKey:@"W-{20, 19}-1"];
    [dict setObject:@(33) forKey:@"W-{34, 34}-1"];
    [dict setObject:@(31) forKey:@"New York county or river-{366, 38}-0"];
    [dict setObject:@(10) forKey:@"100-{19, 15}-0"];
    [dict setObject:@(12) forKey:@"88888-{44, 13}-0"];
    [dict setObject:@(9) forKey:@"88888-{29, 10}-0"];
    [dict setObject:@(21) forKey:@"W-{22, 22}-1"];
    [dict setObject:@(12) forKey:@"100-{61, 15}-0"];
    [dict setObject:@(14) forKey:@"W-{16, 15}-0"];
    [dict setObject:@(25) forKey:@"W-{30, 30}-1"];
    [dict setObject:@(12) forKey:@"W-{15, 15}-0"];
    [dict setObject:@(12) forKey:@"88888-{61, 13}-0"];
    [dict setObject:@(12) forKey:@"100-{29, 15}-0"];
    [dict setObject:@(26) forKey:@"New York county or river-{306, 31}-0"];
    [dict setObject:@(24) forKey:@"W-{26, 25}-1"];
    [dict setObject:@(6) forKey:@"W-{8, 7}-0"];
    [dict setObject:@(32) forKey:@"W-{34, 33}-1"];
    [dict setObject:@(48) forKey:@"New York county or river-{556, 58}-0"];
    [dict setObject:@(9) forKey:@"88888-{40, 10}-0"];
    [dict setObject:@(10) forKey:@"000-{22, 11}-0"];
    [dict setObject:@(9) forKey:@"88888-{42, 10}-0"];
    [dict setObject:@(12) forKey:@"000-{26, 13}-0"];
    [dict setObject:@(7) forKey:@"W-{9, 8}-0"];
    [dict setObject:@(27) forKey:@"W-{28, 28}-1"];
    [dict setObject:@(10) forKey:@"W-{11, 11}-0"];
    [dict setObject:@(30) forKey:@"W-{36, 36}-1"];
    [dict setObject:@(7) forKey:@"88888-{19, 8}-0"];
    [dict setObject:@(12) forKey:@"100-{55, 15}-0"];
    [dict setObject:@(9) forKey:@"000-{19, 10}-0"];
    [dict setObject:@(9) forKey:@"88888-{30, 10}-0"];
    [dict setObject:@(13) forKey:@"W-{15, 14}-0"];
    [dict setObject:@(50) forKey:@"W-{60, 60}-1"];
    [dict setObject:@(17) forKey:@"W-{21, 21}-1"];
    [dict setObject:@(6) forKey:@"W-{8, 8}-0"];
    [dict setObject:@(12) forKey:@"100-{54, 15}-0"];
    [dict setObject:@(5) forKey:@"88888-{12, 6}-0"];
    [dict setObject:@(12) forKey:@"100-{30, 15}-0"];
    [dict setObject:@(7) forKey:@"000-{15, 8}-0"];
    [dict setObject:@(74) forKey:@"New York county or river-{836, 89}-0"];
    [dict setObject:@(12) forKey:@"100-{26, 15}-0"];
    [dict setObject:@(9) forKey:@"W-{11, 10}-0"];
    [dict setObject:@(100) forKey:@"New York county or river-{1116, 119}-0"];
    [dict setObject:@(22) forKey:@"W-{27, 27}-1"];
    [dict setObject:@(9) forKey:@"W-{10, 10}-0"];
    [dict setObject:@(29) forKey:@"W-{35, 35}-1"];
    [dict setObject:@(68) forKey:@"W-{82, 82}-1"];
    [dict setObject:@(8) forKey:@"88888-{17, 9}-0"];
    [dict setObject:@(8) forKey:@"000-{18, 9}-0"];
    [dict setObject:@(4) forKey:@"88888-{12, 5}-0"];
    [dict setObject:@(12) forKey:@"88888-{62, 13}-0"];
    [dict setObject:@(12) forKey:@"100-{110, 15}-0"];
    [dict setObject:@(12) forKey:@"88888-{111, 13}-0"];
    [dict setObject:@(5) forKey:@"88888-{11, 6}-0"];
    [dict setObject:@(22) forKey:@"W-{24, 23}-1"];
    [dict setObject:@(14) forKey:@"W-{15, 15}-1"];
    [dict setObject:@(14) forKey:@"000-{30, 15}-0"];
    [dict setObject:@(22) forKey:@"W-{23, 23}-1"];
    [dict setObject:@(93) forKey:@"W-{111, 111}-1"];
    
    return dict;
}

/// Use to add values to generateFontCacheDict
- (void)logDictAsCode:(NSDictionary *)dict
{
    NSMutableString *debugString = [@"\n" mutableCopy];
    for (NSString *key in dict) {
        NSNumber *size = dict[key];
        NSString *newString = [NSString stringWithFormat:@"[dict setObject:@(%@) forKey:@\"%@\"];\n", size.stringValue, key];
        [debugString appendString:newString];
    }
    NSLog(@"Dict: %@", debugString);
}

@end
