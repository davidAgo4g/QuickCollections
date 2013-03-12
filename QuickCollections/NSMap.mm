//
//  NSMap.mm
//  QuickCollections
//
//  Created by Davide Agostinelli on 11/03/13.
//  Copyright (c) 2013 MyCompanyName. All rights reserved.
//

#import <tr1/unordered_map>
#import  <tr1/functional>
#import <tr1/hashtable>
#import "QuickImageContainer.h"

class ObjCPtr {
protected:
    id object_;
public:
    ObjCPtr(id object) { object_ = [object retain]; }
    ObjCPtr(ObjCPtr const &other) { object_ = [other.object_ retain]; }
    ~ObjCPtr() {
        [object_ release];
        object_ = nil;
    }
    ObjCPtr & operator=(ObjCPtr const & other) {
        id old = object_; object_ = [other.object_ retain]; [old release];
        return *this;
    }
    id get() const { return object_; }
    bool operator==(id that) const { return object_ == that; }
    bool operator!=(id that) const { return object_ != that; }
    operator id() const { return object_; }
    id operator* () const { return object_; }
};

class _GSImageContainer  {
protected:
    _GSImagePixelData *_data;
public:
    _GSImageContainer(UIImage *image);
    _GSImageContainer()  { _GSImageContainer(nil); };
    ~_GSImageContainer();
    
    void set_image(UIImage *anImage);
    id get_image() const;
    
    bool operator==(id that) const { return get_image()==that; }
    bool operator!=(id that) const { return get_image()!=that; }
    operator id() const { return get_image(); }
    id operator* () const { return get_image(); }
};

_GSImageContainer::_GSImageContainer(UIImage *image)  {
    _data = new _GSImagePixelData();
    _data->_bytes = 0x00000000;
    set_image(image);
}

void _GSImageContainer::set_image(UIImage *anImage)  {
    CGImageRef inImage = anImage.CGImage;
    
    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    size_t bpr = CGImageGetBytesPerRow(inImage);
    size_t length = bpr * h;
    CGBitmapInfo info = CGImageGetBitmapInfo(inImage);
    
    _data->_bytesPerRow = bpr;
    _data->_width = w;
    _data->_height = h;
    _data->_info = (unsigned)info;
    _data->_bytes = new uint8_t[length];
    
    CFDataRef inData = CGDataProviderCopyData(CGImageGetDataProvider(inImage));
    const UInt8 *bytes = CFDataGetBytePtr(inData);
    memcpy(_data->_bytes, bytes, length);
}

id _GSImageContainer::get_image() const  {
    size_t w, h, bpr;
    if (_data->_bytes == NULL) {
        return nil;
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
    
	UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    return image;
}

_GSImageContainer::~_GSImageContainer()  {
    delete [] _data->_bytes;
    delete _data;
    
    _data->_bytes = NULL;
    _data = NULL;
}

template<typename K, typename T>
class UnorderedMap {
public:
    typedef typename std::tr1::unordered_map<K, T> map_type;
    typedef typename map_type::value_type entry_type;
    typedef typename map_type::const_iterator const_iterator;
    typedef typename map_type::iterator iterator;
    
protected:
    map_type map_;
    
public:
    
    UnorderedMap(size_t nbuckets=0) : map_(nbuckets) { }
    
    virtual ~UnorderedMap() { }
    
    // reference to the underlying tr1 unordered_map
    inline map_type &map() { return map_; }
    
    // adding entries
    inline void insert(K key, T value) { map_.insert(entry_type(key, ObjCPtr(value))); }
    inline void insertImage(K key, T value) { map_.insert(entry_type(key, _GSImageContainer(value))); }
    
    // locating entries
    inline iterator find(K key) { return map_.find(key); }
    inline const_iterator find(K key) const { return map_.find(key); }
    
    // removing specific entries
    inline iterator erase(iterator where) { return map_.erase(where); }
    inline iterator erase(iterator first, iterator last) {
        return map_.erase(first, last);
    }
    inline size_t erase(const K& key) { return map_.erase(key); }
    
    inline id get(K key) {
        iterator it = this->map_.find(key);
        return (it != this->map_.end()) ? ((ObjCPtr)it->second).get() : nil;
    }
    
    inline T getImage(K key) {
        iterator it = this->map_.find(key);
        return (it != this->map_.end()) ? ((_GSImageContainer)it->second).get_image() : NULL;
    }
    
    // removing all entries
    void clear() { map_.clear(); }
    
    // swapping this map with another map
    inline void swap(map_type& other) { map_.swap(other.map_); }
    
    // counting entries
    inline size_t size() const { return map_.size(); }
    
    // testing for empty-ness
    bool empty() const { return size() == 0; }
};
