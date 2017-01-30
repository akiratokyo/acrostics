//
//  DBPackage.h
//  Acrostics
//
//  Created by Ivan Podibka on 11/28/12.
//  Copyright (c) 2012 A Gamz LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DBLevel;

@interface DBPackage : NSManagedObject

@property (nonatomic, retain) NSString * dbDescription;
@property (nonatomic, retain) NSNumber * dbId;
@property (nonatomic, retain) NSString * dbImageName;
@property (nonatomic, retain) NSNumber * dbIsEnable;
@property (nonatomic, retain) NSString * dbName;
@property (nonatomic, retain) NSString * dbFileName;
@property (nonatomic, retain) NSString * dbBanner;
@property (nonatomic, retain) NSString * dbIAPKey;
@property (nonatomic, retain) NSSet *level;
@end

@interface DBPackage (CoreDataGeneratedAccessors)

- (void)addLevelObject:(DBLevel *)value;
- (void)removeLevelObject:(DBLevel *)value;
- (void)addLevel:(NSSet *)values;
- (void)removeLevel:(NSSet *)values;
@end
