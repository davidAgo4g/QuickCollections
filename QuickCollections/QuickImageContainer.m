//
//  QuickImageContainer.m
//  QuickCollections
//
//  Created by Davide Agostinelli on 27/02/13.
//  Copyright (c) 2013 MyCompanyName. All rights reserved.
//

#include <stdlib.h>
#include <string.h>
#import "QuickImageContainer.h"

static NSString* const kImageWidthKey = @"kImageWidthKey";
static NSString* const kImageHeightKey = @"kImageHeightKey";
static NSString* const kImageInfoKey = @"kImageInfoKey";
static NSString* const kImageBytesPerRowKey = @"kImageBytesPerRowKey";
static NSString* const kImageBytesKey = @"kImageBytesKey";

// private - class extension

@interface QuickImageContainer ()   {
    _GSImagePixelData    *_data;
    BOOL                  _compressed;
    UIImage              *_privateImage;
}

-(void)setImageData:(_GSImagePixelData *)some_data;
@end

@implementation QuickImageContainer
@synthesize image;

-(id) init  {
    return [self initWithImage:nil];
}

-(id)initWithImage:(UIImage *)anImage  {
    if ((self = [super init])) {
        _data = (_GSImagePixelData *)malloc(sizeof(_GSImagePixelData));
        self.image = anImage;
    }
    return self;
}

-(void)compress  {
    
    CGImageRef inImage = self.image.CGImage;
    
    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    size_t bpr = CGImageGetBytesPerRow(inImage);
    size_t length = bpr * h;
    CGBitmapInfo info = CGImageGetBitmapInfo(inImage);
    
    _GSImagePixelData *img_data = (_GSImagePixelData *)malloc(sizeof(_GSImagePixelData));
    img_data->_bytesPerRow = bpr;
    img_data->_width = w;
    img_data->_height = h;
    img_data->_info = (unsigned)info;
    img_data->_bytes = (uint8_t *)malloc(length);
    
    CFDataRef inData = CGDataProviderCopyData(CGImageGetDataProvider(inImage));
    const UInt8 *bytes = CFDataGetBytePtr(inData);
    memcpy(img_data->_bytes, bytes, length);
    
    self.image = nil;
    
    [self setImageData:img_data];
    free(img_data);
    img_data = NULL;
}

-(void)uncompress  {
    
    size_t w, h, bpr;
    if (_data == NULL) {
        return;
    }
    
    w = _data->_width;
    h = _data->_height;
    bpr = _data->_bytesPerRow;
    size_t length = bpr * h;
    
    CFDataRef data = CFDataCreate(kCFAllocatorDefault, _data->_bytes, length);
	CGDataProviderRef provider = CGDataProviderCreateWithCFData(data);
    CFRelease(data);
    
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGImageRef cgImage = CGImageCreate(w, h, 8, 32, bpr, colorSpace,
                                       (CGBitmapInfo)_data->_info, provider, NULL, NO, kCGRenderingIntentDefault);
    CGDataProviderRelease(provider);
	CGColorSpaceRelease(colorSpace);
    
	self.image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
}


-(id)initWithCoder:(NSCoder *)aDecoder  {
    if ((self = [super init])) {
        _data = (_GSImagePixelData *)malloc(sizeof(_GSImagePixelData));
        
        size_t w = [aDecoder decodeIntForKey:kImageWidthKey];
        size_t h = [aDecoder decodeIntForKey:kImageHeightKey];
        size_t bpr = [aDecoder decodeIntForKey:kImageBytesPerRowKey];
        size_t info = [aDecoder decodeIntForKey:kImageInfoKey];
        NSUInteger length = bpr * h;
        
        _GSImagePixelData *img_data = (_GSImagePixelData *)malloc(sizeof(_GSImagePixelData));
        img_data->_bytesPerRow = bpr;
        img_data->_width = w;
        img_data->_height = h;
        img_data->_info = (unsigned)info;
        img_data->_bytes = (uint8_t *)malloc(length);
        const uint8_t *bytes = [aDecoder decodeBytesForKey:kImageBytesKey returnedLength:&length];
        memcpy(img_data->_bytes, bytes, length);
        
        [self setImageData:img_data];
        
        free(img_data);
        img_data = NULL;
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder  {
    
    [aCoder encodeInt:_data->_width forKey:kImageWidthKey];
    [aCoder encodeInt:_data->_height forKey:kImageHeightKey];
    [aCoder encodeInt:_data->_bytesPerRow forKey:kImageBytesPerRowKey];
    [aCoder encodeInt:_data->_info forKey:kImageInfoKey];
    NSUInteger length = _data->_bytesPerRow * _data->_height;
    [aCoder encodeBytes:_data->_bytes length:length forKey:kImageBytesKey];
}



-(void)setImage:(UIImage *)anImage  {
    if (anImage != _privateImage) {
        [anImage retain];
        [_privateImage release];
        _privateImage = anImage;
    }
    _compressed = NO;
}

-(UIImage *)image  {
    
    if (_compressed)
        [self uncompress];
    return _privateImage;
}

-(void)setImageData:(_GSImagePixelData *)some_data  {
    *_data = *some_data;
    _compressed = YES;
}

-(NSData *)data  {
    if (!_compressed)
        [self compress];
    return [NSData dataWithBytes:_data length:sizeof(_GSImagePixelData)];
}

-(void)saveToFile:(NSString *)aPath  {
    
    if(aPath == nil)   return;
    [self.data writeToFile:aPath atomically:YES];
}

-(void)loadFromFile:(NSString *)aPath  {
    
    if(aPath == nil)  return;
    
    NSData *data = [NSData dataWithContentsOfFile:aPath];
    _GSImagePixelData *img_data = (_GSImagePixelData *)malloc(sizeof(_GSImagePixelData));
    [data getBytes:img_data length:sizeof(_GSImagePixelData)];
    
    [self setImageData:img_data];
    
    free(img_data);
    img_data = NULL;
}

-(void)dealloc  {
    
    free(_data->_bytes);
    _data->_bytes = NULL;
    // freeing our struct
    free(_data);
    _data = NULL;
    
    if (!_compressed) 
        self.image = nil;
    
    [super dealloc];
}

@end
