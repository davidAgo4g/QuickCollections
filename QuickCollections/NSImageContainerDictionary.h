//
//  NSImageDictionary.h
//  QuickCollections
//
//  Created by Davide Agostinelli on 27/02/13.
//  Copyright (c) 2013 MyCompanyName. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <libkern/OSAtomic.h>

@class QuickImageContainer;

@interface NSImageContainerDictionary : NSObject

-(void)clear;
-(void)setImage:(UIImage *)img ForKey:(id)key;
-(void)setImageInBackground:(UIImage *)img ForKey:(id)key;
-(UIImage *)imageForKey:(id)key;
// -(void)saveObjectForKey:(id)key AtPath:(NSString *)aPath;

// -(void)saveAtPath:(NSString *)aPath;
// -(void)loadFromPath:(NSString *)aPath;

@end
