//
//  ACDatabaseWrapper.m
//  Acrostics
//
//  Created by Ivan Podibka on 11/14/12.
//  Copyright (c) 2012 A Gamz LLC. All rights reserved.
//

#import "ACDatabaseWrapper.h"
#import "VKManagedObject.h"

#define IS_DATA_LOADED @"isDataLoaded"
#define ALPHABET_ARRAY [NSArray arrayWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G",	@"H", @"I",	@"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R",	@"S",@"T",@"U",	@"V",@"W",@"X",	@"Y", @"Z", nil]

static ACDatabaseWrapper *sSingleObject;

@interface ACDatabaseWrapper()
- (void)parseGames;
@end

@implementation ACDatabaseWrapper

+ (id)initialize {
    if (sSingleObject == nil) {
        sSingleObject = [[ACDatabaseWrapper alloc] init];
    }
    return sSingleObject;
}

+ (void)release {
    sSingleObject = nil;
}

- (id)init {
    self = [super init];
    if (self) {
        mDatabaseManager = [[VKManagedObject alloc] init];
        [self parseBasicPackagesInfo];
    }
    
    return self;
}

- (void)saveChanges {
    @synchronized(self) {
        [mDatabaseManager saveChanges];
    }
}

- (void)saveBuyState:(NSInteger)pIdentifier {
    @synchronized(self) {
        DBPackage *lPackage = [[self getPackages] objectAtIndex:pIdentifier];
        lPackage.dbIsEnable = [NSNumber numberWithBool:YES];
        [mDatabaseManager saveChanges];
    }
}

- (NSArray *)getPackages {
    @synchronized(self) {
        NSArray *lPackages = [mDatabaseManager objectsWithClassEntity:[DBPackage class] sortedByAsceding:@"dbId"];
        return lPackages;
    }
}


- (NSArray *)readAllLevels:(NSNumber *)pPackageId {
    @synchronized(self) {
        NSArray *lArray = [mDatabaseManager objectsWithClassEntity:[DBLevel class] andPredicate:[NSPredicate predicateWithFormat:@"package.dbId == %@", pPackageId] sortedBy:@"dbId"];
        return lArray; 
    }
}

- (DBLevel *)readLevelById:(NSNumber *)pLevelId {
    @synchronized(self) {
        DBLevel *lLevel = (DBLevel *)[mDatabaseManager objectWithClassEntity:[DBLevel class] andPredicate:[NSPredicate predicateWithFormat:@"dbId == %@", pLevelId]];
        return lLevel;
    }
}

- (NSArray *)readLevelKeyWords:(NSNumber *)pLevelId {
    @synchronized(self) {
        NSArray *lKeyWords = [mDatabaseManager objectsWithClassEntity:[DBKeyWords class] andPredicate:[NSPredicate predicateWithFormat:@"level.dbId == %@", pLevelId] sortedBy:@"dbId"];
        return lKeyWords;
    }
}

- (NSArray *)readLevelClues:(NSNumber *)pLevelId {
    @synchronized(self) {
        NSArray *lClues = [mDatabaseManager objectsWithClassEntity:[DBClues class] andPredicate:[NSPredicate predicateWithFormat:@"level.dbId == %@", pLevelId] sortedBy:@"dbId"];
        return lClues;
    }
}

- (void)addUndo:(NSNumber *)pState index:(NSInteger)pIndex answer:(NSString *)pAnswer levelId:(NSNumber *)pLevelId {
    @synchronized(self) {
        DBLevel *lLevel = [self readLevelById:pLevelId];
        
        DBUndo *lUndo = (DBUndo *)[mDatabaseManager createClassEntity:[DBUndo class]];
        lUndo.dbId = [NSNumber numberWithInteger:[[lLevel.undo allObjects] count]];
        lUndo.dbState = pState;
        lUndo.dbSelectedIndex = [NSNumber numberWithInteger:pIndex];
        lUndo.dbAnswer = pAnswer;
        [lLevel addUndoObject:lUndo];
        
        [mDatabaseManager saveChanges];
    }
}

- (DBUndo *)getLastUndo:(NSNumber *)pLeveId {
    @synchronized(self) {
        DBUndo *lLastUndo = (DBUndo *)[[mDatabaseManager objectsWithClassEntity:[DBUndo class] andPredicate:[NSPredicate predicateWithFormat:@"level.dbId == %@", pLeveId] sortedBy:@"dbId"] lastObject];
        return lLastUndo;
    }
}

- (void) addNewIndex:(NSInteger)pIndex andNewState:(NSInteger)pState forLevelId:(NSNumber*)pLevelId {
    @synchronized(self) {
        DBUndo *lLastUndo = [self getLastUndo:pLevelId];
        lLastUndo.dbState = [NSNumber numberWithInteger:pState];
        lLastUndo.dbSelectedIndex = [NSNumber numberWithInteger:pIndex];
        DLog(@"lLastUndo.dbSelectedIndex  - %@", @([lLastUndo.dbSelectedIndex integerValue]));
        [mDatabaseManager saveChanges];
    }
}

- (DBUndo *)removeUndoOperation:(NSNumber *)pLevelId {
    @synchronized(self) {
        DBUndo *lLastUndo = nil;
        DBUndo *lUndoToRemove = (DBUndo *)[[mDatabaseManager objectsWithClassEntity:[DBUndo class] andPredicate:[NSPredicate predicateWithFormat:@"level.dbId == %@", pLevelId]] lastObject];
        
        if (lUndoToRemove) {
            DBLevel *lLevel = [self readLevelById:pLevelId];
            [lLevel removeUndoObject:lUndoToRemove];
            [mDatabaseManager saveChanges];
            
            //get last undo
            lLastUndo = [self getLastUndo:pLevelId];
        }
        
        return lLastUndo;
    }
}

- (void)removeAllUndoOperations:(NSNumber *)pLevelId {
    @synchronized(self) {
        DBLevel *lLevel = [self readLevelById:pLevelId];
        [lLevel removeUndo:lLevel.undo];
        [mDatabaseManager saveChanges];
    }
}

- (void)addHints:(NSInteger)pNumberOfHints withLevelId:(NSNumber *)pLevelId {
    @synchronized(self) {       
        DBLevel *lLevel = [self readLevelById:pLevelId];
        lLevel.dbHints = [NSNumber numberWithInt:[lLevel.dbHints intValue] + (int) pNumberOfHints];
        [mDatabaseManager saveChanges];
    }
}

- (void)resetLevelWithId:(NSNumber *)pLevelId {
    @synchronized(self) {
        DBLevel *lLevel = [self readLevelById:pLevelId];
        lLevel.dbStatus = [NSNumber numberWithInteger:0];
        lLevel.dbHints = [NSNumber numberWithInteger:0];
        lLevel.dbCurrentTime = [NSNumber numberWithFloat:0.0f];
        [lLevel removeUndo:lLevel.undo];
        [mDatabaseManager saveChanges];
    }
}

- (void)resetAllGamesInPackage:(NSNumber *)pPackageId {
    @synchronized(self) {
        NSArray *lLevels = [self readAllLevels:pPackageId];
        for (DBLevel *lLevel in lLevels) {
            lLevel.dbStatus = [NSNumber numberWithInteger:0];
            lLevel.dbHints = [NSNumber numberWithInteger:0];
            lLevel.dbCurrentTime = [NSNumber numberWithFloat:0.0f];
            [lLevel removeUndo:lLevel.undo];
        }
        [mDatabaseManager saveChanges];
    }
}

- (NSString *)createLettersString:(NSDictionary *)pArray {
    NSString *lResult = @"";
    if (pArray) {
        NSArray *lAllKeys = [[pArray allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSInteger lFirst = [(NSNumber *)obj1 integerValue];
            NSInteger lSecond = [(NSNumber *)obj2 integerValue];
            if (lFirst < lSecond) {
                return NSOrderedAscending;
            } else {
                return NSOrderedDescending;
            }
        }];
        NSArray *lAlphabet = ALPHABET_ARRAY;
        for (NSInteger i = 0; i < lAllKeys.count; i++) {
            NSInteger lLetterPos = [[pArray objectForKey:[lAllKeys objectAtIndex:i]] integerValue];
            lResult = [NSString stringWithFormat:@"%@%@", lResult, [lAlphabet objectAtIndex:lLetterPos]];
        }
    }
    return lResult;
}

- (void)parseBasicPackagesInfo {
    NSError *lError = nil;
    NSString *lJSONString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"manifest" ofType:@"json"]
                                                      encoding:NSUTF8StringEncoding
                                                         error:&lError];
    if (!lError) {
        NSArray *lBasicPackagesInfo = [NSJSONSerialization JSONObjectWithData:[lJSONString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&lError];
        
        [mDatabaseManager setIsAutoSave:NO];
        for (NSInteger i = 0; i < lBasicPackagesInfo.count; i++) {
            NSDictionary *lPackageData = [lBasicPackagesInfo objectAtIndex:i];
            NSInteger lDBId = [[lPackageData objectForKey:@"id"] integerValue] - 1;
//            DLog(@"dbid : %@", @(lDBId));
            
            DBPackage *lPackage = (DBPackage *)[mDatabaseManager objectWithClassEntity:[DBPackage class] andPredicate:[NSPredicate predicateWithFormat:@"dbId == %i", lDBId]];
            if (!lPackage) {
                lPackage = (DBPackage *)[mDatabaseManager createClassEntity:[DBPackage class]];
                lPackage.dbId = [NSNumber numberWithInteger:lDBId];
                lPackage.dbName = [lPackageData objectForKey:@"title"];
                lPackage.dbDescription = [lPackageData objectForKey:@"description"];
                lPackage.dbImageName = [lPackageData objectForKey:@"icon"];
                lPackage.dbBanner = [lPackageData objectForKey:@"banner"];
                lPackage.dbFileName = [lPackageData objectForKey:@"file"];
                lPackage.dbIAPKey = [lPackageData objectForKey:@"iapkey"];
                
                if (i == 0) {
                    lPackage.dbIsEnable = [NSNumber numberWithBool:YES];
                    [mDatabaseManager saveChanges];
                    [self parseBoughtPackageWithId:0];
                } else {
                    lPackage.dbIsEnable = [NSNumber numberWithBool:NO];
                }
            }
        }
        
        [mDatabaseManager saveChanges];
        [mDatabaseManager setIsAutoSave:YES];
    }
}

- (void)parseBoughtPackageWithId:(NSInteger)pValue {
    @synchronized(self) {
        DBPackage *lPackage = (DBPackage *)[mDatabaseManager objectWithClassEntity:[DBPackage class] andPredicate:[NSPredicate predicateWithFormat:@"dbId == %i", pValue]];
        lPackage.dbIsEnable = [NSNumber numberWithBool:YES];
        
        NSError *lError = nil;
        NSString *lFileName = [[[lPackage dbFileName] componentsSeparatedByString:@"."] objectAtIndex:0];
        NSString *lJSONString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:lFileName ofType:@"json"] encoding:NSUTF8StringEncoding error:&lError];
        
        if (!lError) {
            NSArray *lPackagesGames = [NSJSONSerialization JSONObjectWithData:[lJSONString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&lError];
    
            NSInteger lLevelId = [[mDatabaseManager objectsWithClassEntity:[DBLevel class]] count];
            [mDatabaseManager setIsAutoSave:NO];
            for (NSInteger lGamesIndex = 0; lGamesIndex < lPackagesGames.count; lGamesIndex++) {
                NSDictionary *lSingleGame = [lPackagesGames objectAtIndex:lGamesIndex];
                
                DBLevel *lLevel = (DBLevel *)[mDatabaseManager createClassEntity:[DBLevel class]];
                lLevel.dbId = [NSNumber numberWithInteger:lLevelId];
                lLevel.dbDifficulty = [lSingleGame objectForKey:@"difficulty"];
                lLevel.dbAverageTime = [lSingleGame objectForKey:@"avtime"];
                lLevel.dbPercentage = [lSingleGame objectForKey:@"perc"];
                lLevel.dbAuthor = [lSingleGame objectForKey:@"author"];
                lLevel.dbSource = [lSingleGame objectForKey:@"source"];
                lLevel.dbQuotation = [lSingleGame objectForKey:@"quotation"];
                lLevel.dbStatus = [NSNumber numberWithInteger:0];
                lLevel.dbCurrentTime = [NSNumber numberWithFloat:0.0f];
                
                NSDictionary *lQuoDict = [lSingleGame objectForKey:@"final_ary"];
                NSString *lFinalQuotation = @"";
                for (NSInteger i = 0; i < lQuoDict.count; i++) {
                    lFinalQuotation = [NSString stringWithFormat:@"%@%@", lFinalQuotation, [lQuoDict objectForKey:[NSString stringWithFormat:@"%@", @(i + 1)]]];
                }
                lLevel.dbFinalQuotation = lFinalQuotation;
                
                lLevel.dbKey = [lSingleGame objectForKey:@"key"];
                lLevel.dbKeyType = [lSingleGame objectForKey:@"keytype"];
                lLevel.dbLettersArray = [self createLettersString:[lSingleGame objectForKey:@"final_word_ary"]];
                lLevel.dbHints = [NSNumber numberWithInteger:0];
                
                NSArray *lWordsArray = [lSingleGame objectForKey:@"word_ary"];
                for (NSInteger i = 0; i < lWordsArray.count; i++) {
                    NSMutableString *lSingleWord = [[NSMutableString alloc] init];
                    NSArray *lSingleWordArray = [lWordsArray objectAtIndex:i];
                    
                    DBKeyWords *lKeyWords = (DBKeyWords *)[mDatabaseManager createClassEntity:[DBKeyWords class]];
                    lKeyWords.dbId = [NSNumber numberWithInteger:i];
                    for (NSInteger j = 0; j < lSingleWordArray.count; j++)
                        [lSingleWord appendString:[NSString stringWithFormat:@"%@ ", [lSingleWordArray objectAtIndex:j]]];
                    lKeyWords.dbKeyWord = [[lSingleWord stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] stringByReplacingOccurrencesOfString:@" " withString:@","];
                    
                    [lLevel addKeyWordsObject:lKeyWords];
                    
                }
                
                NSDictionary *lCluesDictionary = [lSingleGame objectForKey:@"clues"];
                NSArray *lAnswers = [lSingleGame objectForKey:@"ana_ary"];
                for (NSInteger j = 0; j < lAnswers.count; j++) {
                    NSString *lAnswer = [lAnswers objectAtIndex:j];
                    DBClues *lClue = (DBClues *)[mDatabaseManager createClassEntity:[DBClues class]];
                    lClue.dbId = [NSNumber numberWithInteger:j];
                    lClue.dbClue = [lCluesDictionary objectForKey:lAnswer];
                    lClue.dbAnswer = lAnswer;
                    
                    [lLevel addCluesObject:lClue];
                }
                
                lLevelId++;
                
                [lPackage addLevelObject:lLevel];
            }
            
            [mDatabaseManager saveChanges];
            [mDatabaseManager setIsAutoSave:NO];
        }
        
    }
}

//parsing json
- (void)parseGames {
    NSError *lError = nil;
    NSString *lJSONString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"levelsData" ofType:@"json"]
                                                      encoding:NSUTF8StringEncoding
                                                         error:&lError];
    if (!lError) {
        NSArray *lPackages = [NSJSONSerialization JSONObjectWithData:[lJSONString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&lError];
        
        NSInteger lLevelId = 0;
        [mDatabaseManager setIsAutoSave:NO];
        for (NSInteger i = 0; i < lPackages.count; i++) {
            NSDictionary *lPackageData = [lPackages objectAtIndex:i];
            
            DBPackage *lPackage = (DBPackage *)[mDatabaseManager createClassEntity:[DBPackage class]];
            lPackage.dbId = [NSNumber numberWithInt:(int)i];
            lPackage.dbName = [lPackageData objectForKey:@"title"];
            lPackage.dbDescription = [lPackageData objectForKey:@"description"];
            lPackage.dbImageName = [lPackageData objectForKey:@"image"];
            
            if (i == 0) {
                lPackage.dbIsEnable = [NSNumber numberWithBool:YES];
            } else {
                lPackage.dbIsEnable = [NSNumber numberWithBool:NO];
            }
            
            NSArray *lPackagesGames = [lPackageData objectForKey:@"puzzlePack"];
            for (NSInteger lGamesIndex = 0; lGamesIndex < lPackagesGames.count; lGamesIndex++) {
                NSDictionary *lSingleGame = [lPackagesGames objectAtIndex:lGamesIndex];
                
                DBLevel *lLevel = (DBLevel *)[mDatabaseManager createClassEntity:[DBLevel class]];
                lLevel.dbId = [NSNumber numberWithInteger:lLevelId];
                lLevel.dbDifficulty = [lSingleGame objectForKey:@"difficulty"];
                lLevel.dbAverageTime = [lSingleGame objectForKey:@"avtime"];
                lLevel.dbPercentage = [lSingleGame objectForKey:@"perc"];
                lLevel.dbAuthor = [lSingleGame objectForKey:@"author"];
                lLevel.dbSource = [lSingleGame objectForKey:@"source"];
                lLevel.dbQuotation = [lSingleGame objectForKey:@"quotation"];
                lLevel.dbStatus = [NSNumber numberWithInteger:0];
                lLevel.dbCurrentTime = [NSNumber numberWithFloat:0.0f];
                
                NSDictionary *lQuoDict = [lSingleGame objectForKey:@"final_ary"];
                NSString *lFinalQuotation = @"";
                for (NSInteger i = 0; i < lQuoDict.count; i++) {
                    lFinalQuotation = [NSString stringWithFormat:@"%@%@", lFinalQuotation, [lQuoDict objectForKey:[NSString stringWithFormat:@"%@", @(i + 1)]]];
                }
                lLevel.dbFinalQuotation = lFinalQuotation;
                
                lLevel.dbKey = [lSingleGame objectForKey:@"key"];
                lLevel.dbKeyType = [lSingleGame objectForKey:@"keytype"];
                lLevel.dbLettersArray = [self createLettersString:[lSingleGame objectForKey:@"final_word_ary"]];
                lLevel.dbHints = [NSNumber numberWithInteger:0];
                
                NSArray *lWordsArray = [lSingleGame objectForKey:@"word_ary"];
                for (NSInteger i = 0; i < lWordsArray.count; i++) {
                    NSMutableString *lSingleWord = [[NSMutableString alloc] init];
                    NSArray *lSingleWordArray = [lWordsArray objectAtIndex:i];
                    
                    DBKeyWords *lKeyWords = (DBKeyWords *)[mDatabaseManager createClassEntity:[DBKeyWords class]];
                    lKeyWords.dbId = [NSNumber numberWithInteger:i];
                    for (NSInteger j = 0; j < lSingleWordArray.count; j++)
                        [lSingleWord appendString:[NSString stringWithFormat:@"%@ ", [lSingleWordArray objectAtIndex:j]]];
                    lKeyWords.dbKeyWord = [[lSingleWord stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] stringByReplacingOccurrencesOfString:@" " withString:@","];
                    
                    [lLevel addKeyWordsObject:lKeyWords];
                    
                }
                
                NSDictionary *lCluesDictionary = [lSingleGame objectForKey:@"clues"];
                NSArray *lAnswers = [lSingleGame objectForKey:@"ana_ary"];
                for (NSInteger j = 0; j < lAnswers.count; j++) {
                    NSString *lAnswer = [lAnswers objectAtIndex:j];
                    DBClues *lClue = (DBClues *)[mDatabaseManager createClassEntity:[DBClues class]];
                    lClue.dbId = [NSNumber numberWithInteger:j];
                    lClue.dbClue = [lCluesDictionary objectForKey:lAnswer];
                    lClue.dbAnswer = lAnswer;
                    
                    [lLevel addCluesObject:lClue];
                }
                
                lLevelId++;
                
                [lPackage addLevelObject:lLevel];
            }
        }
        
        [mDatabaseManager saveChanges];
        [mDatabaseManager setIsAutoSave:YES];

    }
}

@end
