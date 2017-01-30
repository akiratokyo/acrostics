//
//  VKManagedObjectCloner.h
//  Resume
//
//  Created by vasyl.sadoviy on 28.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VKManagedObject : NSObject {
	NSManagedObjectContext *mManagedObjectContext;
	BOOL mIsAutoSave;
}
@property (nonatomic, readwrite) BOOL isAutoSave;

//create
- (NSManagedObject*)createEntity: (NSString *)pEntityName;
- (NSManagedObject*)createClassEntity: (id)pClass;

//get
- (NSArray*) objectsWithEntity: (NSString *) pEntity;
- (NSArray*) objectsWithClassEntity: (id) pClass;

- (NSArray*) objectsWithEntity: (NSString *) pEntity andPredicate: (NSPredicate *) pPredicate;
- (NSArray*) objectsWithClassEntity: (id) pClass andPredicate: (NSPredicate *) pPredicate;

- (NSArray*) objectsWithEntity: (NSString *) pEntity sortedBy: (NSString *) pSortObject;
- (NSArray*) objectsWithEntity: (NSString *) pEntity sortedByAscending: (NSString *) pSortObject;
- (NSArray*) objectsWithClassEntity: (id) pClass sortedBy: (NSString *) pSortObject;
- (NSArray*) objectsWithClassEntity: (id) pClass sortedByAsceding: (NSString *)pSortObject;


- (NSArray*) objectsWithEntity: (NSString *) pEntity andPredicate: (NSPredicate *) pPredicate sortedByList: (NSArray *) pSortList;

- (NSArray*) objectsWithClassEntity: (id) pClass andPredicate: (NSPredicate *) pPredicate sortedByList: (NSArray *) pSortList;
- (NSArray*) objectsWithEntity: (NSString *) pEntity noSortedBy: (NSString *) pSortObject;

- (NSArray*) objectsWithEntity: (NSString *) pEntity andPredicate: (NSPredicate *) pPredicate sortedBy: (NSString *) pSortObject;
- (NSArray*) objectsWithClassEntity: (id) pClass andPredicate: (NSPredicate *) pPredicate sortedBy: (NSString *) pSortObject;

- (NSManagedObject*)objectWithEntity: (NSString *) pEntity;
- (NSManagedObject*)objectWithClassEntity: (id) pClass;

- (NSManagedObject*)objectWithEntity: (NSString *) pEntity andPredicate: (NSPredicate *) pPredicate;
- (NSManagedObject*)objectWithClassEntity: (id) pClass andPredicate: (NSPredicate *) pPredicate;

- (NSManagedObject*) objectWithEntity: (NSString *) pEntity sortedBy: (NSString *) pSortObject;
- (NSManagedObject*) objectWithClassEntity: (id) pClass sortedBy: (NSString *) pSortObject;

- (NSManagedObject*) objectWithEntity: (NSString *) pEntity andPredicate: (NSPredicate *) pPredicate sortedByList: (NSArray *) pSortList;
- (NSManagedObject*) objectWithClassEntity: (id) pClass andPredicate: (NSPredicate *) pPredicate sortedByList: (NSArray *) pSortList;

- (NSManagedObject*) objectWithEntity: (NSString *) pEntity andPredicate: (NSPredicate *) pPredicate sortedBy: (NSString *) pSortObject;
- (NSManagedObject*) objectWithClassEntity: (id) pClass andPredicate: (NSPredicate *) pPredicate sortedBy: (NSString *) pSortObject;

//FetchedResults Controller
- (NSFetchedResultsController*)controllerForEntity:(NSString*)pEntity sortedBy:(NSString *)pSortingItem isAscending:(BOOL)isAscending;
- (NSFetchedResultsController*)controllerForEntity: (NSString*)pEntity andSortObject:(NSArray*)pSortArray;

//delete
- (void)deepRemoveObject:(NSManagedObject *)pEntity;
- (void)deepRemoveToManyConnectionObject:(NSManagedObject *)pEntity;
- (void)deepRemoveToOneObject:(NSManagedObject *)pEntity;
- (void)removeObject:(NSManagedObject*)pEntity;

//save
- (void)saveChanges;
@end
