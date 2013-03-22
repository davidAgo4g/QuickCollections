//
//  NSSharedCollection.h
//  QuickCollections
//
//  Created by Davide Agostinelli on 27/02/13.
//  Copyright (c) 2013 MyCompanyName. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <libkern/OSAtomic.h>

@interface NSDictionary (Images)
-(void)setImage:(UIImage *)anImage forKey:(id)aKey;
-(UIImage *)imageForKey:(id)aKey;
@end

@class QuickImageContainer;

@interface NSSharedCollection : NSObject

+(NSSharedCollection *)sharedCollection;
-(void)removeAllObjects;
-(void)setImage:(UIImage *)img ForKey:(id)key;
-(void)setImageInBackground:(UIImage *)img ForKey:(id)key;
-(UIImage *)imageForKey:(id)key;
-(void)endUpInsertingImages;
// -(void)saveObjectForKey:(id)key AtPath:(NSString *)aPath;

// -(void)saveAtPath:(NSString *)aPath;
// -(void)loadFromPath:(NSString *)aPath;

@end
