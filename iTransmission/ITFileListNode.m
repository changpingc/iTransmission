
//
//  ITFileListNode.m
//  iTransmission
//
//  Created by Mike Chen on 10/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ITFileListNode.h"

@interface ITFileListNode (Private)

- (id) initWithFolder: (BOOL) isFolder name: (NSString *) name path: (NSString *) path torrent: (ITTorrent *) torrent;

@end

@implementation ITFileListNode

@synthesize name = _name;
@synthesize path = _path;
@synthesize indexes = _indexes;
@synthesize icon = _icon;
@synthesize torrent = _torrent;
@synthesize size = _size;
@synthesize isFolder = _isFolder;
@synthesize children = _children;

- (id) initWithFolderName: (NSString *) name path: (NSString *) path torrent: (ITTorrent *) torrent
{
    if ((self = [self initWithFolder: YES name: name path: path torrent: torrent]))
    {
        self.children = [[NSMutableArray alloc] init];
        self.size = 0;
    }
    
    return self;
}

- (id) initWithFileName: (NSString *) name path: (NSString *) path size: (uint64_t) size index: (NSUInteger) index torrent: (ITTorrent *) torrent
{
    if ((self = [self initWithFolder: NO name: name path: path torrent: torrent]))
    {
        self.size = size;
        [self.indexes addIndex: index];
    }
    
    return self;
}

- (void) insertChild: (ITFileListNode *) child
{
    NSAssert(self.isFolder, @"method can only be invoked on folders");
    
    [self.children addObject:child];
}

- (void) insertIndex: (NSUInteger) index withSize: (uint64_t) size
{
    NSAssert(self.isFolder, @"method can only be invoked on folders");
    
    [self.indexes addIndex: index];
    self.size += size;
}

- (id) copyWithZone: (NSZone *) zone
{
    return self;
}

- (NSString *) description
{
    if (!self.isFolder)
        return [NSString stringWithFormat: @"%@ (%d)", self.name, [self.indexes firstIndex]];
    else
        return [NSString stringWithFormat: @"%@ (folder: %@)", self.name, self.indexes];
}

- (NSMutableArray *) children
{
    NSAssert(self.isFolder, @"method can only be invoked on folders");
    
    return _children;
}

@end

@implementation ITFileListNode (Private)

- (id) initWithFolder: (BOOL) isFolder name: (NSString *) name path: (NSString *) path torrent: (ITTorrent *) torrent
{
    if ((self = [super init]))
    {
        self.isFolder = isFolder;
        self.name = name;
        self.path = path;
        
        self.indexes = [[NSMutableIndexSet alloc] init];
        
        self.torrent = torrent;
    }
    
    return self;
}

@end
