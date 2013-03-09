//
//  QuickImageContainer.h
//  QuickCollections
//
//  Created by Davide Agostinelli on 27/02/13.
//  Copyright (c) 2013 MyCompanyName. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>
#import <libkern/OSAtomic.h>

@interface QuickImageContainer : NSObject  <NSCoding>

-(void)setImage:(UIImage *)anImage;
-(UIImage *)imageInContainer;
-(void)saveToFile:(NSString *)aPath;
-(void)loadFromFile:(NSString *)aPath;

@end
