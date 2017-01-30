//
//  DBKeyWords.h
//  Acrostics
//
//  Created by Ivan Podibka on 11/14/12.
//  Copyright (c) 2012 A Gamz LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DBKeyWords : NSManagedObject

@property (nonatomic, retain) NSNumber * dbId;
@property (nonatomic, retain) NSString * dbKeyWord;
@property (nonatomic, retain) DBLevel *level;

@end
