//
//  TODLetter.m
//  TODParseKit
//
//  Created by Todd Ditchendorf on 8/14/08.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

#import <TODParseKit/TODLetter.h>

@implementation TODLetter

+ (id)letter {
	return [[[[self class] alloc] initWithString:nil] autorelease];
}


- (BOOL)qualifies:(id)obj {
	NSInteger c = [obj integerValue];
	return ('a' <= c && c <= 'z') || ('A' <= c && c <= 'Z') ;
}

@end
