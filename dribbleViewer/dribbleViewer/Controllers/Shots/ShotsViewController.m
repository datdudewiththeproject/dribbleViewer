//
//  ShotsViewController.m
//  dribbleViewer
//
//  Created by admin on 16/02/16.
//  Copyright © 2016 sevrikov. All rights reserved.
//

#import "ShotsViewController.h"
#import "Shot.h"
#import "ShotsAPI.h"
#import "ShotsViewCell.h"

//#import <AFNetworking/UIImageView+AFNetworking.h>
#import <RestKit/CoreData.h>
#import <RestKit/RestKit.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface ShotsViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, ShotsAPIDelegate>

@property (nonatomic) NSArray *shots;
@property (nonatomic) ShotsAPI *shotsAPI;

@end

@implementation ShotsViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.shotsAPI = [[ShotsAPI alloc] init];
    self.shotsAPI.APIDelegate = self;
    [self.shotsAPI getStaticShots];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}

-(void)shotsAPIdidGetShots:(NSArray *)shots
{
    for (Shot *iteratedShot in shots)
    {
        
        NSLog(@"shot: %d %d %@\n", iteratedShot.page.integerValue, iteratedShot.order.integerValue, iteratedShot.highResImageURL);
    }
    
//    self.shots = [shots subarrayWithRange:NSMakeRange(0, 5)];
    self.shots = shots;
    
    [self.collectionView reloadData];
}

#pragma mark - UICollectionView

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.shots count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ShotsViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCell" forIndexPath:indexPath];
    Shot *shot = self.shots[indexPath.row];
    
    NSURL *url = [NSURL URLWithString:shot.imageURL];
    if (shot.highResImageURL) {
        url = [NSURL URLWithString:shot.highResImageURL];
    }
    [cell.imageView sd_setImageWithURL:url];

    cell.backgroundColor = [UIColor grayColor];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Shot *shot = self.shots[indexPath.row];
    CGSize imageSize = CGSizeMake(shot.width.floatValue, shot.height.floatValue);
    float proportions = imageSize.height / imageSize.width;
    CGSize constraintedSize = CGSizeMake(self.view.frame.size.width*0.5, self.view.frame.size.height*0.5);
    
    if (imageSize.width>constraintedSize.width) {
        imageSize = CGSizeMake(constraintedSize.width, constraintedSize.width * proportions);
    }
    if (imageSize.height>constraintedSize.height) {
        imageSize = CGSizeMake(constraintedSize.height / proportions, constraintedSize.height);
    }
    
//    NSLog(@"SIZE %f %f", constraintedSize.width, constraintedSize.height);
//    imageSize = CGSizeMake(500.0/(indexPath.row+1), 500.0/(indexPath.row+1));
    
    return imageSize;
}

//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
//{
//    return UIEdgeInsetsMake(0, 0, 0, 0);
//}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

@end
