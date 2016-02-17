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

#import <RestKit/CoreData.h>
#import <RestKit/RestKit.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <JTSImageViewController/JTSImageViewController.h>

const float kInterItemSpacing = 2;

@interface ShotsViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, ShotsAPIDelegate>

@property (nonatomic) NSArray *shots;
@property (nonatomic) ShotsAPI *shotsAPI;

@property (nonatomic) UIRefreshControl *refreshControl;

@end

@implementation ShotsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.shotsAPI = [[ShotsAPI alloc] init];
    self.shotsAPI.APIDelegate = self;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(loadShots)
                  forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    self.collectionView.alwaysBounceVertical = YES;
    
    [self loadShots];
    

}

-(void)loadShots {
    [self.shotsAPI getStaticShots];
}

#pragma mark - UICollectionView delegate methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.shots count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ShotsViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCell" forIndexPath:indexPath];
    Shot *shot = self.shots[indexPath.row];
    
    cell.nameLabel.text = shot.title;
    cell.descriptionLabel.text = shot.shotDescriptionPlain;
    
    NSURL *url = [NSURL URLWithString:shot.imageURL];
    if (shot.highResImageURL) {
        url = [NSURL URLWithString:shot.highResImageURL];
    }
    
    [cell.imageView sd_setImageWithURL:url];
    cell.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Shot *shot = self.shots[indexPath.row];
    CGSize imageSize = CGSizeMake(shot.width.floatValue, shot.height.floatValue);
    imageSize = [self constraintSize:imageSize];

    // TODO: use cell self-sizing
    float verticalSpaceCorrector = 80;
    
    if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular) {
        verticalSpaceCorrector = -60;
    }
    
    CGSize cellSize = CGSizeMake(imageSize.width, imageSize.height + verticalSpaceCorrector);
    
    return cellSize;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return kInterItemSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return kInterItemSpacing;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    Shot *shot = self.shots[indexPath.row];
    
    NSString *imageKey = shot.imageURL;
    if (shot.highResImageURL) {
        imageKey = shot.highResImageURL;
    }
    
    UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imageKey];
    
    if (!image) {
        return;
    }
    
    JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
    imageInfo.image = image;
    imageInfo.referenceView = self.view;
    
    JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
                                           initWithImageInfo:imageInfo
                                           mode:JTSImageViewControllerMode_Image
                                           backgroundStyle:JTSImageViewControllerBackgroundOption_Blurred];

    [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOffscreen];
}

#pragma mark - API delegate methods

- (void)shotsAPIdidGetShots:(NSArray *)shots
{
    [self.refreshControl endRefreshing];
    self.shots = shots;
    
    [self.collectionView reloadData];
}

#pragma mark - Helpers

- (CGSize)constraintSize:(CGSize)size {
    CGSize constraintedSize = CGSizeMake(self.view.frame.size.width*0.5-kInterItemSpacing, self.view.frame.size.height*0.5-kInterItemSpacing);
    CGSize resultSize = size;
    float proportions = resultSize.height / resultSize.width;
    
    if (resultSize.width>constraintedSize.width) {
        resultSize = CGSizeMake(constraintedSize.width, constraintedSize.width * proportions);
    }
    if (resultSize.height>constraintedSize.height) {
        resultSize = CGSizeMake(constraintedSize.height / proportions, constraintedSize.height);
    }
    
    return resultSize;
}

@end
