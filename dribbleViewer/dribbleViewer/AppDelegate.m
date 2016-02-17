//
//  AppDelegate.m
//  dribbleViewer
//
//  Created by admin on 16/02/16.
//  Copyright © 2016 sevrikov. All rights reserved.
//

#import "AppDelegate.h"

#import <RestKit/CoreData.h>
#import <RestKit/RestKit.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSURL *baseURL = [NSURL URLWithString:@"https://api.dribbble.com/"];
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:baseURL];
//    [objectManager.HTTPClient setDefaultHeader:@"Authorization" value:@"3b126b5a5b770316ad3a609806b1b629bacd1dbf928dd39442406bd3d888cf20"];
    
    // Core Data stack initialization
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    objectManager.managedObjectStore = managedObjectStore;
    
    [managedObjectStore createPersistentStoreCoordinator];
    NSString *storePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"dribbleDB.sqlite"];
    NSString *seedPath = [[NSBundle mainBundle] pathForResource:@"RKSeedDatabase" ofType:@"sqlite"];
    NSError *error;
    NSPersistentStore *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:storePath fromSeedDatabaseAtPath:seedPath withConfiguration:nil options:nil error:&error];
    NSAssert(persistentStore, @"Failed to add persistent store with error: %@", error);
    
    [managedObjectStore createManagedObjectContexts];
    
    managedObjectStore.managedObjectCache = [[RKInMemoryManagedObjectCache alloc] initWithManagedObjectContext:managedObjectStore.persistentStoreManagedObjectContext];
    
    // Map entities
    RKEntityMapping *shotMapping = [RKEntityMapping mappingForEntityForName:@"Shot" inManagedObjectStore:managedObjectStore];
    shotMapping.identificationAttributes = @[@"shotID"];
    [shotMapping addAttributeMappingsFromDictionary:@{ @"id" : @"shotID",
                                                       @"title" : @"title",
                                                       @"description" : @"shotDescription",
                                                       @"images.hidpi" : @"imageURL",
                                                       @"images.normal" : @"highResImageURL"}];
    
    RKResponseDescriptor *shotsResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:shotMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:nil
                                                keyPath:nil
                                            statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)
     ];
    
    [objectManager addResponseDescriptor:shotsResponseDescriptor];
    
    // Enable Activity Indicator Spinner
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    return YES;
}

@end