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

typedef struct _GSImagePixelData {
    
    uint8_t    *_bytes;
    size_t      _width;
    size_t      _height;
    size_t      _bytesPerRow;
    unsigned    _info;
    
} _GSImagePixelData;

@interface QuickImageContainer : NSObject  <NSCoding>

-(void)setImage:(UIImage *)anImage;
-(UIImage *)imageInContainer;
-(void)saveToFile:(NSString *)aPath;
-(void)loadFromFile:(NSString *)aPath;

@end
