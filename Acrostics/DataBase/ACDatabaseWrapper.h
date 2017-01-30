//
//  ACDatabaseWrapper.h
//  Acrostics
//
//  Created by Ivan Podibka on 11/14/12.
//  Copyright (c) 2012 A Gamz LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VKManagedObject;
@class ACUndoObject;
@interface ACDatabaseWrapper : NSObject {
    @public
    VKManagedObject *mDatabaseManager;
}

//singleton
+ (id)initialize;

//release singleton
+ (void)release;

//save changes
- (void)saveChanges;

//save buy state
- (void)saveBuyState:(NSInteger)pIdentifier;

//get packages
- (NSArray *)getPackages;

//read all levels
- (NSArray *)readAllLevels:(NSNumber *)pPackageId;

//read single level
- (DBLevel *)readLevelById:(NSNumber *)pLevelId;
 
//read keywords
- (NSArray *)readLevelKeyWords:(NSNumber *)pLevelId;

//read clues and answers
- (NSArray *)readLevelClues:(NSNumber *)pLevelId;

//adding undo item ot DB
- (void)addUndo:(NSNumber *)pState index:(NSInteger)pIndex answer:(NSString *)pAnswer levelId:(NSNumber *)pLevelId;

//get last undo
- (DBUndo *)getLastUndo:(NSNumber *)pLeveId;

//change index and state values for last undo
- (void) addNewIndex:(NSInteger)pIndex andNewState:(NSInteger)pState forLevelId:(NSNumber*)pLevelId;

//make undo operation (remove from data base) and return last undo operations
- (DBUndo *)removeUndoOperation:(NSNumber *)pLevelId;

//remove all undo opretaions from level
- (void)removeAllUndoOperations:(NSNumber *)pLevelId;

//add hints
- (void)addHints:(NSInteger)pNumberOfHints withLevelId:(NSNumber *)pLevelId;

//reset selected level
- (void)resetLevelWithId:(NSNumber *)pLevelId;

//reset all levels in package
- (void)resetAllGamesInPackage:(NSNumber *)pPackageId;

- (void)parseBoughtPackageWithId:(NSInteger)pValue;
@end
