//
//  DBLevel.h
//  Acrostics
//
//  Created by Ivan Podibka on 11/19/12.
//  Copyright (c) 2012 A Gamz LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DBClues, DBKeyWords, DBUndo;

@interface DBLevel : NSManagedObject

@property (nonatomic, retain) NSString * dbAuthor;
@property (nonatomic, retain) NSNumber * dbAverageTime;
@property (nonatomic, retain) NSNumber * dbCurrentTime;
@property (nonatomic, retain) NSNumber * dbDifficulty;
@property (nonatomic, retain) NSString * dbFinalQuotation;
@property (nonatomic, retain) NSNumber * dbHints;
@property (nonatomic, retain) NSNumber * dbId;
@property (nonatomic, retain) NSString * dbKey;
@property (nonatomic, retain) NSString * dbKeyType;
@property (nonatomic, retain) NSString * dbLettersArray;
@property (nonatomic, retain) NSNumber * dbPercentage;
@property (nonatomic, retain) NSString * dbQuotation;
@property (nonatomic, retain) NSString * dbSource;
@property (nonatomic, retain) NSNumber * dbStatus;
@property (nonatomic, retain) NSSet *clues;
@property (nonatomic, retain) NSSet *keyWords;
@property (nonatomic, retain) DBPackage *package;
@property (nonatomic, retain) NSSet *undo;
@end

@interface DBLevel (CoreDataGeneratedAccessors)

- (void)addCluesObject:(DBClues *)value;
- (void)removeCluesObject:(DBClues *)value;
- (void)addClues:(NSSet *)values;
- (void)removeClues:(NSSet *)values;
- (void)addKeyWordsObject:(DBKeyWords *)value;
- (void)removeKeyWordsObject:(DBKeyWords *)value;
- (void)addKeyWords:(NSSet *)values;
- (void)removeKeyWords:(NSSet *)values;
- (void)addUndoObject:(DBUndo *)value;
- (void)removeUndoObject:(DBUndo *)value;
- (void)addUndo:(NSSet *)values;
- (void)removeUndo:(NSSet *)values;
@end
