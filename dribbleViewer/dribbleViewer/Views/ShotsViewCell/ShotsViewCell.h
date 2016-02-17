//
//  ShotsViewCell.h
//  dribbleViewer
//
//  Created by admin on 17/02/16.
//  Copyright © 2016 sevrikov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShotsViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end
