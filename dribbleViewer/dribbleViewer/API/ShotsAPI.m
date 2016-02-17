//
//  ShotsAPI.m
//  dribbleViewer
//
//  Created by admin on 17/02/16.
//  Copyright © 2016 sevrikov. All rights reserved.
//

#import "ShotsAPI.h"
#include "Shot.h"

#import <RestKit/CoreData.h>
#import <RestKit/RestKit.h>

@implementation ShotsAPI

-(void)getStaticShots;
{
    [self requestData];
}

- (void)requestData {
    
    NSString *requestPath = @"/v1/shots";
    
    [[RKObjectManager sharedManager]
     getObjectsAtPath:requestPath
     parameters:@{@"access_token" : @"3b126b5a5b770316ad3a609806b1b629bacd1dbf928dd39442406bd3d888cf20",
                  @"per_page":@"25"}
     //     parameters:nil
     success: ^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
         //articles have been saved in core data by now
         [self fetchShotsFromContext];
     }
     failure: ^(RKObjectRequestOperation *operation, NSError *error) {
         RKLogError(@"Load failed with error: %@", error);
         [self fetchShotsFromContext];
     }
     ];
    
}

- (void)fetchShotsFromContext {
    
    NSManagedObjectContext *context = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Shot"];
    
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    fetchRequest.sortDescriptors = @[descriptor];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    //    Shot *shot = [fetchedObjects firstObject];
    
//    self.shots = [fetchedObjects subarrayWithRange:NSMakeRange(0, 5)];
    
//    for (Shot *shot in fetchedObjects) {
//        //
//        if (!shot.image) {
//            shot.image = [NSData dataWithContentsOfURL:[NSURL URLWithString:shot.imageURL]];
//        }
//        
//    }
    
    if ([self.APIDelegate respondsToSelector:@selector(shotsAPIdidGetShots:)]) {
        [self.APIDelegate shotsAPIdidGetShots:fetchedObjects];
    }
    
    //    NSLog(@"shot: %@", shot);
}

@end
