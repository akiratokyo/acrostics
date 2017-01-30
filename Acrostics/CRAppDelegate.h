//
//  CRAppDelegate.h
//  Cryptograms
//
//  Created by roman.andruseiko on 10/30/12.
//  Copyright (c) 2012 Vakoms. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

typedef enum {
    ErrorSound = 0,
    EnterLetterSound,
    SelectCategorySound,
    SelectSquareSound,
    SuccessSound,
    UndoButtonSound,
    ClearSquareSound,
} StylesOfSond;

@class CRPackageViewController;
@interface CRAppDelegate : UIResponder <UIApplicationDelegate>{
    UINavigationController *mNavigationController;
    CRPackageViewController *mRootViewController;
}

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic) BOOL isPlay;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)playSoundWithStyle:(StylesOfSond)pStyle;
@end
