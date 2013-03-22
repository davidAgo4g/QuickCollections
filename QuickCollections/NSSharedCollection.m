//
//  NSImageDictionary.m
//  QuickCollections
//
//  Created by Davide Agostinelli on 27/02/13.
//  Copyright (c) 2013 MyCompanyName. All rights reserved.
//

#import "NSSharedCollection.h"
#import "QuickImageContainer.h"

static inline void NSUnimplementedMethod()  {return;}


@implementation NSDictionary (Images)

-(void)setImage:(UIImage *)anImage forKey:(id)aKey  {
    QuickImageContainer *c = [[[QuickImageContainer alloc] init] autorelease];
    [c setImage:anImage];
    [c compress];
    
    if ([aKey isKindOfClass:[NSString class]])
        [self setValue:c forKey:(NSString *)aKey];
    if([self isKindOfClass:[NSMutableDictionary class]])
        [(NSMutableDictionary *)self setObject:c forKey:aKey];
}

-(UIImage *)imageForKey:(id)aKey  {
    
    QuickImageContainer *c;
    if ([aKey isKindOfClass:[NSString class]])
        c = [self valueForKey:(NSString *)aKey];
    else if([self isKindOfClass:[NSMutableDictionary class]])
        c = [(NSMutableDictionary *)self objectForKey:aKey];
    else c = nil;
    return c.image;
}

@end


// #########

@interface NSStoreImageOperation : NSOperation
@property (nonatomic, retain) id key;
@property (nonatomic, assign) NSMutableDictionary *delegate;
@property (nonatomic, retain) UIImage *object;
@end

@implementation NSStoreImageOperation
@synthesize key;
@synthesize object;
@synthesize delegate;

-(void)main {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if(key && object && delegate)  {
        [delegate setImage:object forKey:key];
    }
    [pool release];
}

-(void)dealloc  {
    [key release]; key = nil;
    [object release]; object = nil;
    delegate = nil;
    [super dealloc];
}

@end


@interface NSGetImageOperation : NSOperation
@property (nonatomic, retain) id key;
@property (nonatomic, assign) NSMutableDictionary *delegate;
@property (nonatomic, retain) UIImage *object;

@end

@implementation NSGetImageOperation
@synthesize key;
@synthesize object;
@synthesize delegate;

-(void)main {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if(key)  {
        self.object = [delegate imageForKey:key];
    }
    [pool release];
}

-(void)dealloc  {
    [key release]; key = nil;
    [object release]; object = nil;
    delegate = nil;
    [super dealloc];
}

@end

// ##########

@interface NSSharedCollection ()   {
    NSOperationQueue *_queue;
    NSMutableDictionary *_dictionary;
}
@end

// ##########

@implementation NSSharedCollection

+(NSSharedCollection *)sharedCollection  {
    static NSSharedCollection *_collection = nil;
    if (nil==_collection) {
        NSSharedCollection *c = [[NSSharedCollection alloc] init];
        if(OSAtomicCompareAndSwapPtrBarrier(nil, c, (void* volatile*)&_collection) == NO)
            [c release];
    }
    return _collection;
}

-(id)init  {
    if((self = [super init]))  {
        _queue = [[NSOperationQueue alloc] init];
        _dictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void)setImage:(UIImage *)img ForKey:(id)key  {
    [_dictionary setImage:img forKey:key];
}

-(void)setImageInBackground:(UIImage *)img ForKey:(id)key  {
    NSStoreImageOperation *operation = [[[NSStoreImageOperation alloc] init] autorelease];
    operation.key = key;
    operation.delegate = _dictionary;
    operation.object = img;
    [_queue addOperation:operation];
}

-(UIImage *)imageForKey:(id)key  {
    return [_dictionary imageForKey:key];
}

-(void)endUpInsertingImages  {
    [_queue waitUntilAllOperationsAreFinished];
}

-(void)removeAllObjects  {
    [_dictionary removeAllObjects];
}

-(void) dealloc  {
    [_queue release];
    [_dictionary release];
    [super dealloc];
}

@end
