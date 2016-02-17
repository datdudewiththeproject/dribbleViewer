//
//  ShotsAPI.m
//  dribbleViewer
//
//  Created by admin on 17/02/16.
//  Copyright © 2016 sevrikov. All rights reserved.
//

#import "ShotsAPI.h"
#import "Shot.h"
#import "AppDelegate.h"

#import <RestKit/CoreData.h>
#import <RestKit/RestKit.h>
#import <Reachability/Reachability.h>

const NSInteger kShotsAmount = 50;

@interface ShotsAPI ()

//@property (nonatomic) NSMutableArray *shots;
@property (nonatomic) NSInteger currentPage;

@end

@implementation ShotsAPI

-(void)getStaticShots;
{
//    self.shots = [NSMutableArray array];
    self.currentPage = 1;
    
    Reachability* reach = [Reachability reachabilityWithHostname:@"dribbble.com"];
    if (reach.isReachable) {
        [self removeAllOldShots];
        [self requestShots];
    } else {
        [self returnShots];
    }
}

- (void)requestShots{
    NSString *requestPath = @"/v1/shots";
    
    [[RKObjectManager sharedManager]
     getObjectsAtPath:requestPath
     parameters:@{@"access_token" : @"3b126b5a5b770316ad3a609806b1b629bacd1dbf928dd39442406bd3d888cf20",
                  @"per_page":@(kShotsAmount),
                  @"page" : @(self.currentPage)}
     success: ^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
         //shots have been saved in core data by now
         [self prepareShots];
     }
     failure: ^(RKObjectRequestOperation *operation, NSError *error) {
         RKLogError(@"Load failed with error: %@", error);
         //fetch old cached shots then
         [self returnShots];
     }
     ];
    
}

- (void)removeAllOldShots {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.coreDataContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Shot"];
    [fetchRequest setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject *object in fetchedObjects)
    {
        [context deleteObject:object];
    }
    
    error = nil;
    [context save:&error];
}

-(NSArray*)fetchShots {
    NSManagedObjectContext *context = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Shot"];
    
    NSSortDescriptor *descriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"page" ascending:YES];
    NSSortDescriptor *descriptor2 = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
//    fetchRequest.sortDescriptors = @[descriptor1, descriptor2];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    for (Shot *shot in fetchedObjects) {
        if (!shot.page || shot.page.integerValue == 0) {
            shot.page = @(self.currentPage);
        }
    }
    
    [context save:&error];
    [context saveToPersistentStore:&error];
    
    return [fetchedObjects sortedArrayUsingDescriptors:@[descriptor1, descriptor2]];
}

- (void)prepareShots {
    NSArray *filteredShots = [self filterShots:[self fetchShots]];
    
    if (filteredShots.count<kShotsAmount) {
        self.currentPage++;
        [self requestShots];
    }
    else {
        [self returnShots];
    }
}

-(NSArray*)filterShots:(NSArray*)shots {
    NSMutableArray *array = [NSMutableArray array];
    
    for (Shot *shot in shots) {
        if (!shot.animated.boolValue) {
            [array addObject:shot];
        }
    }
    
    return array;
}

-(void)returnShots {
    if ([self.APIDelegate respondsToSelector:@selector(shotsAPIdidGetShots:)]) {
        NSArray *shots = [self filterShots:[self fetchShots]];
        NSInteger count = shots.count<kShotsAmount?shots.count:kShotsAmount;
        [self.APIDelegate shotsAPIdidGetShots:[shots subarrayWithRange:NSMakeRange(0, count)]];
    }
}

@end
