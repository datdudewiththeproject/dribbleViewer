//
//  ShotsViewController.m
//  dribbleViewer
//
//  Created by admin on 16/02/16.
//  Copyright © 2016 sevrikov. All rights reserved.
//

#import "ShotsViewController.h"
#include "Shot.h"

#import <AFNetworking/UIImageView+AFNetworking.h>
#import <RestKit/CoreData.h>
#import <RestKit/RestKit.h>

@interface ShotsViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic) NSArray *shots;

@end

@implementation ShotsViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [self requestData];
    
}

- (void)requestData {
    
    NSString *requestPath = @"/v1/shots";
    
    [[RKObjectManager sharedManager]
     getObjectsAtPath:requestPath
     parameters:@{@"access_token" : @"3b126b5a5b770316ad3a609806b1b629bacd1dbf928dd39442406bd3d888cf20",
                  @"per_page":@"5"}
//     parameters:nil
     success: ^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
         //articles have been saved in core data by now
         [self fetchShotsFromContext];
     }
     failure: ^(RKObjectRequestOperation *operation, NSError *error) {
         RKLogError(@"Load failed with error: %@", error);
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
    
    for (Shot *iteratedShot in fetchedObjects)
    {
        
        NSLog(@"shot: %@\n", iteratedShot.highResImageURL);
    }
    
    self.shots = [fetchedObjects subarrayWithRange:NSMakeRange(0, 5)];
    
    [self.collectionView reloadData];
    
//    NSLog(@"shot: %@", shot);
}

#pragma mark - UICOllectionView

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.shots count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCell" forIndexPath:indexPath];
    Shot *shot = self.shots[indexPath.row];
    UIImageView *image = [[UIImageView alloc] init];
    [image setImageWithURL:[NSURL URLWithString:shot.imageURL]];
    
    
    
    [cell.contentView addSubview:image];
    return cell;
}

@end
