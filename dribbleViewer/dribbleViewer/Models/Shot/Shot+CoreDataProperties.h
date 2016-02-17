//
//  Shot+CoreDataProperties.h
//  dribbleViewer
//
//  Created by admin on 17/02/16.
//  Copyright © 2016 sevrikov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Shot.h"

NS_ASSUME_NONNULL_BEGIN

@interface Shot (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *animated;
@property (nullable, nonatomic, retain) NSString *highResImageURL;
@property (nullable, nonatomic, retain) NSString *imageURL;
@property (nullable, nonatomic, retain) NSNumber *isNew;
@property (nullable, nonatomic, retain) NSNumber *order;
@property (nullable, nonatomic, retain) NSString *shotDescription;
@property (nullable, nonatomic, retain) NSNumber *shotID;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSNumber *page;

@end

NS_ASSUME_NONNULL_END
