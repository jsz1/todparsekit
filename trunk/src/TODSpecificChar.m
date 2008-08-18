//
//  TODSpecificChar.m
//  TODParseKit
//
//  Created by Todd Ditchendorf on 8/14/08.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

#import <TODParseKit/TODSpecificChar.h>

@implementation TODSpecificChar

+ (id)specificCharWithChar:(NSInteger)c {
	return [[[[self class] alloc] initWithSpecificChar:c] autorelease];
}


- (id)initWithSpecificChar:(NSInteger)c {
	self = [super initWithString:[NSString stringWithFormat:@"%C", c]];
	if (self != nil) {
	}
	return self;
}


- (BOOL)qualifies:(id)obj {
	NSInteger c = [obj integerValue];
	return c == [string characterAtIndex:0];
}

@end
