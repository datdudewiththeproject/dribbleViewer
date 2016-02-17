//
//  ShotsAPI.h
//  dribbleViewer
//
//  Created by admin on 17/02/16.
//  Copyright © 2016 sevrikov. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ShotsAPIDelegate <NSObject>

- (void)shotsAPIdidGetShots:(NSArray*)shots;

@end

@interface ShotsAPI : NSObject

- (void)getStaticShots;

@property (nonatomic, weak) id <ShotsAPIDelegate> APIDelegate;

@end
