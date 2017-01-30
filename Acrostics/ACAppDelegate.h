//  Copyright (c) 2012-2015 Egghead Games LLC. All rights reserved.

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

#define AppDelegate (ACAppDelegate*)[[UIApplication sharedApplication] delegate]

typedef enum {
    ErrorSound = 0,
    EnterLetterSound,
    SelectCategorySound,
    SelectSquareSound,
    SuccessSound,
    UndoButtonSound,
    ClearSquareSound,
} StylesOfSond;

@interface ACAppDelegate : UIResponder <UIApplicationDelegate> {
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) BOOL isPlay;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)playSoundWithStyle:(StylesOfSond)pStyle;

+ (CGFloat)fontSizeForString:(NSString*)string frame:(CGRect)frame isBoldFont:(BOOL)isBoldFont;
+ (UIImage*)getPuzzleStateImage:(DBLevel*)lLevel;
+ (NSArray*)sortedLevels:(NSArray*)levels withSortOrder:(ACLevelSortOrder)sortOrder;
+ (NSInteger)puzzleNumForDbid:(NSNumber*)dbid;

+ (NSInteger)getCurrentPackage;
+ (void)setCurrentPackage:(NSNumber*)packageId;
+ (NSInteger)getCurrentPuzzle;
+ (void)setCurrentPuzzle:(NSNumber*)dbid;
+ (void)clearCurrentPuzzle;
+ (void)setSortOrder:(ACLevelSortOrder)order;
+ (ACLevelSortOrder)getSortOrder;
+ (BOOL)soundsEnabled;
+ (void)setSoundsEnabled:(BOOL)soundsEnabled;
+ (NSString *)getMenuSoundTitle;

@end
