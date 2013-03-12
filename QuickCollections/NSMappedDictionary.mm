//
//  NSMappedDictionary.m
//  QuickCollections
//
//  Created by Davide Agostinelli on 11/03/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "NSMappedDictionary.h"
#import "NSMap.mm"

@interface NSMappedDictionary ()  {
    UnorderedMap<void const*, id> *_dictionary;
}

@end

@implementation NSMappedDictionary

-(id)init  {
    if ((self = [super init])) {
        _dictionary = new UnorderedMap<void const*, id> ();
    }
    return self;
}

- (NSUInteger)count  {
    return _dictionary->size();
}

- (BOOL)isEmpty  {
    return _dictionary->empty();
}

-(void)setObject:(id)anObject forKey:(id)aKey  {
    _dictionary->insert((void const*)aKey, anObject);
}

-(id)objectForKey:(id)aKey  {
    return _dictionary->get((void const *)aKey);
}

- (void)removeAllObjects  {
    _dictionary->clear();
}

- (void)removeObjectForKey:(id)aKey  {
    _dictionary->erase((void const *)aKey);
}

-(void)dealloc  {
    delete _dictionary;
    [super dealloc];
}

@end


@implementation NSMappedDictionary (Images)

-(void)setImage:(UIImage *)anImage forKey:(id)aKey  {
    _dictionary->insertImage((void const*)aKey, anImage);
}

-(UIImage *)imageForKey:(id)aKey  {
    return _dictionary->getImage((void const*)aKey);
}

@end
