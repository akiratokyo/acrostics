//
//  VKManagedObjectCloner.m
//  Resume
//
//  Created by vasyl.sadoviy on 28.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VKManagedObject.h"
#import "ACAppDelegate.h"

@implementation VKManagedObject
@synthesize isAutoSave=mIsAutoSave;
#pragma mark - Init -
- (id)init{
	self = [super init];
	if (self) {
		mManagedObjectContext = [(ACAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
		mIsAutoSave = YES;
	}
	return self;
}

#pragma mark - Create objects -
- (NSManagedObject*) createEntity:(NSString *)pEntityName {
	NSManagedObject *lNewObject = nil;
	if (mManagedObjectContext) {
		lNewObject = [NSEntityDescription insertNewObjectForEntityForName:pEntityName inManagedObjectContext:mManagedObjectContext];
		if (mIsAutoSave) {
			[self saveChanges];			
		}
	}
	return lNewObject;
}

- (NSManagedObject *)createClassEntity: (id)pClass {
	NSManagedObject *lNewObject = [self createEntity:[pClass description]];
	return lNewObject;
}

#pragma mark - Get Object -
#pragma mark --- Get List Of Objects
- (NSArray *) objectsWithEntity: (NSString *) pEntity {
	NSArray *lResult = nil;
	NSFetchRequest *lFetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *lEntity = [NSEntityDescription entityForName:pEntity inManagedObjectContext:mManagedObjectContext];
	[lFetchRequest setEntity:lEntity];
	lResult = [mManagedObjectContext executeFetchRequest:lFetchRequest error:nil];
	return lResult;
}

- (NSArray *) objectsWithClassEntity: (id) pClass {
	return [self objectsWithEntity:[pClass description]];
}

- (NSArray *) objectsWithEntity: (NSString *) pEntity andPredicate: (NSPredicate *) pPredicate {
	NSArray *lResult = nil;
	NSFetchRequest *lFetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *lEntity = [NSEntityDescription entityForName:pEntity inManagedObjectContext:mManagedObjectContext];
	[lFetchRequest setPredicate:pPredicate];
	[lFetchRequest setEntity:lEntity];
	lResult = [mManagedObjectContext executeFetchRequest:lFetchRequest error:nil];
	return lResult;
}

- (NSArray *) objectsWithClassEntity: (id) pClass andPredicate: (NSPredicate *) pPredicate {
	return [self objectsWithEntity:[pClass description] andPredicate:pPredicate];
}


- (NSArray*) objectsWithEntity: (NSString *) pEntity sortedBy: (NSString *) pSortObject {
	NSArray *lResult = nil;
	NSFetchRequest *lFetchRequest = [[NSFetchRequest alloc] init];
	NSSortDescriptor *lSortDescriptor = [[NSSortDescriptor alloc] initWithKey:pSortObject ascending:NO];
	NSArray *lSortDescriptors = [[NSArray alloc] initWithObjects:lSortDescriptor, nil];
	NSEntityDescription *lEntity = [NSEntityDescription entityForName:pEntity inManagedObjectContext:mManagedObjectContext];
	[lFetchRequest setEntity:lEntity];
	[lFetchRequest setSortDescriptors:lSortDescriptors];
	lResult = [mManagedObjectContext executeFetchRequest:lFetchRequest error:nil];
	return lResult;
}

- (NSArray*) objectsWithEntity: (NSString *) pEntity sortedByAscending: (NSString *) pSortObject {
	NSArray *lResult = nil;
	NSFetchRequest *lFetchRequest = [[NSFetchRequest alloc] init];
	NSSortDescriptor *lSortDescriptor = [[NSSortDescriptor alloc] initWithKey:pSortObject ascending:YES];
	NSArray *lSortDescriptors = [[NSArray alloc] initWithObjects:lSortDescriptor, nil];
	NSEntityDescription *lEntity = [NSEntityDescription entityForName:pEntity inManagedObjectContext:mManagedObjectContext];
	[lFetchRequest setEntity:lEntity];
	[lFetchRequest setSortDescriptors:lSortDescriptors];
	lResult = [mManagedObjectContext executeFetchRequest:lFetchRequest error:nil];
	return lResult;
}

- (NSArray*) objectsWithEntity: (NSString *) pEntity noSortedBy: (NSString *) pSortObject {
	NSArray *lResult = nil;
	NSFetchRequest *lFetchRequest = [[NSFetchRequest alloc] init];
	NSSortDescriptor *lSortDescriptor = [[NSSortDescriptor alloc] initWithKey:pSortObject ascending:NO];
	NSArray *lSortDescriptors = [[NSArray alloc] initWithObjects:lSortDescriptor, nil];
	NSEntityDescription *lEntity = [NSEntityDescription entityForName:pEntity inManagedObjectContext:mManagedObjectContext];
	[lFetchRequest setEntity:lEntity];
	[lFetchRequest setSortDescriptors:lSortDescriptors];
	lResult = [mManagedObjectContext executeFetchRequest:lFetchRequest error:nil];
	return lResult;
}

- (NSArray*) objectsWithClassEntity: (id) pClass sortedBy: (NSString *) pSortObject {
	return [self objectsWithEntity:[pClass description] sortedBy:pSortObject];
}

- (NSArray *) objectsWithClassEntity:(id)pClass sortedByAsceding:(NSString *)pSortObject {
    return [self objectsWithEntity:[pClass description] sortedByAscending:pSortObject];
}

- (NSArray*) objectsWithEntity: (NSString *) pEntity andPredicate: (NSPredicate *) pPredicate sortedByList: (NSArray *) pSortList {
	NSArray *lResult = nil;
	NSFetchRequest *lFetchRequest = [[NSFetchRequest alloc] init];
	NSMutableArray *lSortDescriptors = [[NSMutableArray alloc] init];
	for (NSInteger i = 0; i < [pSortList count]; i++) {
		NSSortDescriptor *lSortDescriptor = [[NSSortDescriptor alloc] initWithKey:[pSortList objectAtIndex:i] ascending:NO];
		[lSortDescriptors addObject:lSortDescriptor];
	}
	NSEntityDescription *lEntity = [NSEntityDescription entityForName:pEntity inManagedObjectContext:mManagedObjectContext];
	[lFetchRequest setEntity:lEntity];
	[lFetchRequest setPredicate:pPredicate];
	[lFetchRequest setSortDescriptors:lSortDescriptors];
	lResult = [mManagedObjectContext executeFetchRequest:lFetchRequest error:nil];
	return lResult;
}

- (NSArray*) objectsWithClassEntity: (id) pClass andPredicate: (NSPredicate *) pPredicate sortedByList: (NSArray *) pSortList {
	return [self objectsWithEntity:[pClass description] andPredicate:pPredicate sortedByList:pSortList];
}

- (NSArray*) objectsWithEntity: (NSString *) pEntity andPredicate: (NSPredicate *) pPredicate sortedBy: (NSString *) pSortObject {
	NSArray *lResult = nil;
	NSFetchRequest *lFetchRequest = [[NSFetchRequest alloc] init];
	NSSortDescriptor *lSortDescriptor = [[NSSortDescriptor alloc] initWithKey:pSortObject ascending:YES];
	NSArray *lSortDescriptors = [[NSArray alloc] initWithObjects:lSortDescriptor, nil];
	NSEntityDescription *lEntity = [NSEntityDescription entityForName:pEntity inManagedObjectContext:mManagedObjectContext];
	[lFetchRequest setEntity:lEntity];
	[lFetchRequest setPredicate:pPredicate];
	[lFetchRequest setSortDescriptors:lSortDescriptors];
	lResult = [mManagedObjectContext executeFetchRequest:lFetchRequest error:nil];
	return lResult;
}

- (NSArray*) objectsWithClassEntity: (id) pClass andPredicate: (NSPredicate *) pPredicate sortedBy: (NSString *) pSortObject{
	return [self objectsWithEntity:[pClass description] andPredicate:pPredicate sortedBy:pSortObject];
}

#pragma mark --- Get Single Object
- (NSManagedObject*)objectWithEntity: (NSString *) pEntity {
	NSArray *lListOfOjects = [self objectsWithEntity:pEntity];
	if ([lListOfOjects count] > 0) {
		return [lListOfOjects objectAtIndex:0];
	} else {
		return nil;
	}
}

- (NSManagedObject*)objectWithClassEntity: (id) pClass {
	return [self objectWithEntity:[pClass description]];
}

- (NSManagedObject*)objectWithEntity: (NSString *) pEntity andPredicate: (NSPredicate *) pPredicate {
	NSArray *lListOfOjects = [self objectsWithEntity:pEntity andPredicate:pPredicate];
	if ([lListOfOjects count] > 0) {
		return [lListOfOjects objectAtIndex:0];
	} else {
		return nil;
	}	
}

- (NSManagedObject*)objectWithClassEntity:(id)pClass andPredicate:(NSPredicate *)pPredicate {
	return [self objectWithEntity:[pClass description] andPredicate:pPredicate];
}

- (NSManagedObject*) objectWithEntity: (NSString *) pEntity sortedBy: (NSString *) pSortObject {
	NSArray *lListOfOjects = [self objectsWithEntity:pEntity sortedBy:pSortObject];
	if ([lListOfOjects count] > 0) {
		return [lListOfOjects objectAtIndex:0];
	} else {
		return nil;
	}
}

- (NSManagedObject*) objectWithClassEntity: (id) pClass sortedBy: (NSString *) pSortObject{
	return [self objectWithEntity:[pClass description] sortedBy:pSortObject];
}

- (NSManagedObject*) objectWithEntity: (NSString *) pEntity andPredicate: (NSPredicate *) pPredicate sortedByList: (NSArray *) pSortList {
	NSArray *lListOfOjects = [self objectsWithEntity:pEntity andPredicate:pPredicate sortedByList:pSortList];
	if ([lListOfOjects count] > 0) {
		return [lListOfOjects objectAtIndex:0];
	} else {
		return nil;
	}
}

- (NSManagedObject*) objectWithClassEntity: (id) pClass andPredicate: (NSPredicate *) pPredicate sortedByList: (NSArray *) pSortList {
	return [self objectWithEntity:[pClass description] andPredicate:pPredicate sortedByList:pSortList];
}

- (NSManagedObject*) objectWithEntity: (NSString *) pEntity andPredicate: (NSPredicate *) pPredicate sortedBy: (NSString *) pSortObject {
	NSArray *lListOfOjects = [self objectsWithEntity:pEntity andPredicate:pPredicate sortedBy:pSortObject];
	if ([lListOfOjects count] > 0) {
		return [lListOfOjects objectAtIndex:0];
	} else {
		return nil;
	}
}

- (NSManagedObject*) objectWithClassEntity: (id) pClass andPredicate: (NSPredicate *) pPredicate sortedBy: (NSString *) pSortObject{
	return [self objectWithEntity:[pClass description] andPredicate:pPredicate sortedBy:pSortObject];
}

#pragma mark - FetchedResults Controller -
- (NSFetchedResultsController*)controllerForEntity: (NSString*)pEntity andSortObject:(NSArray*)pSortArray{
	NSFetchRequest *lFetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *lEntity = [NSEntityDescription entityForName:pEntity inManagedObjectContext:mManagedObjectContext];
    [lFetchRequest setEntity:lEntity];
	
    NSArray *mSortDescriptors = [NSArray arrayWithArray:pSortArray];
    
    [lFetchRequest setSortDescriptors:mSortDescriptors];
	
    NSFetchedResultsController *lFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:lFetchRequest managedObjectContext:mManagedObjectContext sectionNameKeyPath:nil cacheName:pEntity];
    
	NSError *error = nil;
	if (![lFetchedResultsController performFetch:&error]) {
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
	return lFetchedResultsController;
}

- (NSFetchedResultsController*)controllerForEntity:(NSString*)pEntity sortedBy:(NSString *)pSortingItem isAscending:(BOOL)isAscending{
	NSSortDescriptor *lSortDescriptor = [[NSSortDescriptor alloc] initWithKey:pSortingItem ascending:isAscending];
    NSArray *lSortDescriptors = [NSArray arrayWithObjects:lSortDescriptor, nil];
	return [self controllerForEntity:pEntity andSortObject:lSortDescriptors];
}

#pragma mark - Remove Object -
- (void)deepRemoveObject:(NSManagedObject *)pEntity {
    if (pEntity) {
        NSString *lEntityName = [[pEntity entity] name];
        NSDictionary *lRelationships = [[NSEntityDescription entityForName:lEntityName inManagedObjectContext:mManagedObjectContext] relationshipsByName];
        [mManagedObjectContext deleteObject:pEntity];
        for (NSString *lRelationName in [lRelationships allKeys]){
            NSRelationshipDescription *lRerelation = [lRelationships objectForKey:lRelationName];
            
            NSString *lKeyName = lRerelation.name;
            if ([lRerelation isToMany]) {
                //get a set of all objects in the relationship
                NSMutableSet *lSourceSet = [pEntity mutableSetValueForKey:lKeyName];
                for (NSManagedObject *lCurrentObject in [lSourceSet allObjects]) {
                    [self deepRemoveObject:lCurrentObject];
                }
            } else {
                NSManagedObject *lRelatedObject = [pEntity valueForKey:lKeyName];			
                if ((lRelatedObject != nil) && (![lRelatedObject isDeleted])) {
                    [self deepRemoveObject:lRelatedObject];
                }
            }
        }
    }
}

- (void)deepRemoveToManyConnectionObject:(NSManagedObject *)pEntity {
    if (pEntity) {
        NSString *lEntityName = [[pEntity entity] name];
        NSDictionary *lRelationships = [[NSEntityDescription entityForName:lEntityName inManagedObjectContext:mManagedObjectContext] relationshipsByName];
        [mManagedObjectContext deleteObject:pEntity];
        for (NSString *lRelationName in [lRelationships allKeys]){
            NSRelationshipDescription *lRerelation = [lRelationships objectForKey:lRelationName];
            
            NSString *lKeyName = lRerelation.name;
            if ([lRerelation isToMany]) {
                //get a set of all objects in the relationship
                NSMutableSet *lSourceSet = [pEntity mutableSetValueForKey:lKeyName];
                for (NSManagedObject *lCurrentObject in [lSourceSet allObjects]) {
                    [self deepRemoveObject:lCurrentObject];
                }
            }
        }
    }
}

- (void)deepRemoveToOneObject:(NSManagedObject *)pEntity {
    if (pEntity) {
        NSString *lEntityName = [[pEntity entity] name];
        NSDictionary *lRelationships = [[NSEntityDescription entityForName:lEntityName inManagedObjectContext:mManagedObjectContext] relationshipsByName];
        [mManagedObjectContext deleteObject:pEntity];
        for (NSString *lRelationName in [lRelationships allKeys]){
            NSRelationshipDescription *lRerelation = [lRelationships objectForKey:lRelationName];
            
            NSString *lKeyName = lRerelation.name;
            if (![lRerelation isToMany]) {
                NSManagedObject *lRelatedObject = [pEntity valueForKey:lKeyName];			
                if ((lRelatedObject != nil) && (![lRelatedObject isDeleted])) {
                    [self deepRemoveObject:lRelatedObject];
                }
            }
        }
    }
}

- (void)removeObject:(NSManagedObject *)pEntity {
    if (pEntity && (![pEntity isDeleted])) {
        [mManagedObjectContext deleteObject:pEntity];
        if (mIsAutoSave) {
            [self saveChanges];			
        }        
    }
}

#pragma mark - Save -
-(void)saveChanges {
	NSError *error = nil;
    if (mManagedObjectContext != nil) {
        if ([mManagedObjectContext hasChanges] && ![mManagedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}
@end
