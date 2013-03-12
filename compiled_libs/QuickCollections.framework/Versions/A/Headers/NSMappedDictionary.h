//
//  NSMappedDictionary.h
//  QuickCollections
//
//  Created by Davide Agostinelli on 11/03/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSMappedDictionary : NSObject

- (void)setObject:(id)anObject forKey:(id)aKey;
- (id)objectForKey:(id)aKey;
- (void)removeAllObjects;
- (BOOL)isEmpty;
- (NSUInteger)count;
- (void)removeObjectForKey:(id)aKey;

@end

@interface NSMappedDictionary (Images)

- (void)setImage:(UIImage *)anImage forKey:(id)aKey;
- (UIImage *)imageForKey:(id)aKey;

@end