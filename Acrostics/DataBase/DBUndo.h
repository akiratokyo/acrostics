//
//  DBUndo.h
//  Acrostics
//
//  Created by Ivan Podibka on 11/19/12.
//  Copyright (c) 2012 A Gamz LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DBUndo : NSManagedObject

@property (nonatomic, retain) NSNumber * dbId;
@property (nonatomic, retain) NSNumber * dbSelectedIndex;
@property (nonatomic, retain) NSNumber * dbState;
@property (nonatomic, retain) NSString * dbAnswer;
@property (nonatomic, retain) DBLevel *level;

@end
