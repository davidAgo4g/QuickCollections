//
//  NSImageDictionary.m
//  QuickCollections
//
//  Created by Davide Agostinelli on 27/02/13.
//  Copyright (c) 2013 MyCompanyName. All rights reserved.
//

#import "NSImageContainerDictionary.h"
#import "QuickImageContainer.h"

static inline void NSUnimplementedMethod()  {return;}

@interface NSImageContainerDictionary ()   {
    NSOperationQueue *_queue;
}
+(NSMutableDictionary *)sharedDictionary;
@end

// #########

@interface NSStoreImageOperation : NSOperation
@property (nonatomic, retain) id key;
@property (nonatomic, retain) UIImage *object;
@end

@implementation NSStoreImageOperation
@synthesize key;
@synthesize object;

-(void)main {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    if(key && object)  {
        QuickImageContainer *container = [[[QuickImageContainer alloc] init] autorelease];
        [container setImage:object];
        [[NSImageContainerDictionary sharedDictionary] setObject:container forKey:key];
    }
    
    [pool release];
}

-(void)dealloc  {
    [key release];
    [object release];
    [super dealloc];
}

@end

// ##########

// ##########

@interface NSLoadImageOperation : NSOperation
@property (nonatomic, retain) id key;
@property (nonatomic, retain) UIImage *object;
@end

@implementation NSLoadImageOperation
@synthesize key;
@synthesize object;

-(void)main {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    if(key)  {
        QuickImageContainer *container = [[NSImageContainerDictionary sharedDictionary] objectForKey:key];
        self.object = [container imageInContainer];
    }
    
    [pool release];
}

-(void)dealloc  {
    [key release];
    [object release];
    [super dealloc];
}

@end

// ##########

// ##########

@interface NSSaveDictionaryOperation : NSOperation
@property (nonatomic, copy) NSString *path;
@end

@implementation NSSaveDictionaryOperation
@synthesize path;

-(void)main  {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    if (nil != self.path)  {
        NSString *itemFilePath;
        NSMutableDictionary *d = [NSImageContainerDictionary sharedDictionary];
        
        for(id key in d)  {
            if([key isKindOfClass:[NSString class]])
                itemFilePath = [path stringByAppendingPathComponent:(NSString *)key];
            else
                itemFilePath = [path stringByAppendingPathComponent:[key description]];
            
            QuickImageContainer *container = [d objectForKey:key];
            [container saveToFile:itemFilePath];
        }
    }
    
    [pool release];
}

-(void)dealloc {
    [path release];
    [super dealloc];
}

@end

// ##########

// ##########

@interface NSLoadDictionaryOperation : NSOperation
@property (nonatomic, copy) NSString *path;
@end

@implementation NSLoadDictionaryOperation
@synthesize path;

-(void)main {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if (nil != self.path)  {
        NSArray *objectsDirectories = [[NSFileManager defaultManager] 
                        contentsOfDirectoryAtPath:self.path error:NULL];
        for (NSString *p in objectsDirectories) {
            QuickImageContainer *c = [[[QuickImageContainer alloc] init] autorelease];
            [c loadFromFile:p];
            [[NSImageContainerDictionary sharedDictionary] setObject:c forKey:[p lastPathComponent]];
        }
    }
    [pool release];
}

-(void)dealloc  {
    [path release];
    [super dealloc];
}

@end

// ##########

@implementation NSImageContainerDictionary

+(NSMutableDictionary *)sharedDictionary  {    
    static NSMutableDictionary* volatile _dictionary = nil;
    if(nil == _dictionary)  {
        NSMutableDictionary *m_dictionary = [[NSMutableDictionary alloc] init];
        if (OSAtomicCompareAndSwapPtrBarrier(nil, m_dictionary, (void* volatile*)&_dictionary) == NO)
            [m_dictionary release];
    }
    return _dictionary;
}

-(id)init  {
    if((self = [super init]))  {
        _queue = [[NSOperationQueue alloc] init];
    }
    return self;
}

-(void)setImage:(UIImage *)img ForKey:(id)key  {
    [self setImageInBackground:img ForKey:key];
    [_queue waitUntilAllOperationsAreFinished];
}

-(void)setImageInBackground:(UIImage *)img ForKey:(id)key  {
    NSStoreImageOperation *operation = [[[NSStoreImageOperation alloc] init] autorelease];
    operation.key = key;
    operation.object = img;
    [_queue addOperation:operation];
}

-(UIImage *)imageForKey:(id)key  {
    NSLoadImageOperation *operation = [[[NSLoadImageOperation alloc] init] autorelease];
    operation.key = key;
    [_queue addOperation:operation];
    [_queue waitUntilAllOperationsAreFinished];
    
    UIImage *outputImage = [operation isFinished] ? operation.object : nil;
    
    return outputImage;
}

-(void)clear  {
    [[NSImageContainerDictionary sharedDictionary] removeAllObjects];
}

/*

-(void)saveObjectForKey:(id)key AtPath:(NSString *)aPath    {
    QuickImageContainer *container = [[NSImageContainerDictionary sharedDictionary] objectForKey:key];
    
    NSString *itemFilePath;
    if ([key isKindOfClass:[NSString class]])
        itemFilePath = [aPath stringByAppendingPathComponent:(NSString *)key];
    else
        itemFilePath = [aPath stringByAppendingPathComponent:[key description]];
    
    [container saveToFile:itemFilePath];
}

-(void)saveAtPath:(NSString *)aPath  {
    NSSaveDictionaryOperation *operation = [[[NSSaveDictionaryOperation alloc] init] autorelease];
    operation.path = aPath;
    [_queue addOperation:operation];
    [_queue waitUntilAllOperationsAreFinished];
}

-(void)loadFromPath:(NSString *)aPath  {
    NSLoadDictionaryOperation *operation = [[[NSLoadDictionaryOperation alloc] init] autorelease];
    operation.path = aPath;
    [_queue addOperation:operation];
    [_queue waitUntilAllOperationsAreFinished];
}
 
 */

-(void) dealloc  {
    [_queue release];
    [super dealloc];
}

@end
