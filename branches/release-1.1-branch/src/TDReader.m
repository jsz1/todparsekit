//
//  TDReader.m
//  TDParseKit
//
//  Created by Todd Ditchendorf on 1/21/06.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

#import <TDParseKit/TDReader.h>

@implementation TDReader

- (id)init {
    return [self initWithString:nil];
}


- (id)initWithString:(NSString *)s {
    self = [super init];
    if (self) {
        self.string = s;
    }
    return self;
}


- (void)dealloc {
    self.string = nil;
    [super dealloc];
}


- (NSString *)string {
    return [[string retain] autorelease];
}


- (void)setString:(NSString *)s {
    if (string != s) {
        [self willChangeValueForKey:@"string"];
        [string autorelease];
        string = [s copy];
        length = string.length;
        [self didChangeValueForKey:@"string"];
    }
    // reset cursor
    cursor = 0;
}


- (NSInteger)read {
    if (0 == length || cursor > length - 1) {
        return -1;
    }
    return [string characterAtIndex:cursor++];
}


- (void)unread {
    cursor = (0 == cursor) ? 0 : cursor - 1;
}

@end
