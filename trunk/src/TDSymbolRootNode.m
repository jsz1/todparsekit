//
//  TDSymbolRootNode.m
//  TDParseKit
//
//  Created by Todd Ditchendorf on 1/20/06.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

#import <TDParseKit/TDSymbolRootNode.h>
#import <TDParseKit/TDReader.h>

@interface TDSymbolRootNode ()
- (void)addWithFirst:(NSInteger)c rest:(NSString *)s parent:(TDSymbolNode *)p;
- (NSString *)nextWithFirst:(NSInteger)c rest:(TDReader *)r parent:(TDSymbolNode *)p;
@end

@implementation TDSymbolRootNode

- (void)add:(NSString *)s {
	if (s.length < 2) return;
	
	[self addWithFirst:[s characterAtIndex:0] rest:[s substringFromIndex:1] parent:self];
}


- (void)addWithFirst:(NSInteger)c rest:(NSString *)s parent:(TDSymbolNode *)p {
	NSNumber *key = [NSNumber numberWithInteger:c];
	TDSymbolNode *child = [p.children objectForKey:key];
	if (!child) {
		child = [[[TDSymbolNode alloc] initWithParent:p character:c] autorelease];
		[p.children setObject:child forKey:key];
	}

	NSString *rest = nil;
	
	if (0 == s.length) {
		return;
	} else if (s.length > 1) {
		rest = [s substringFromIndex:1];
	}
	
	[self addWithFirst:[s characterAtIndex:0] rest:rest parent:child];
}

 
- (NSString *)nextSymbol:(TDReader *)r startingWith:(NSInteger)cin {
	return [self nextWithFirst:cin rest:r parent:self];
}


- (NSString *)nextWithFirst:(NSInteger)c rest:(TDReader *)r parent:(TDSymbolNode *)p {
	NSString *result = [[[NSString alloc] initWithCharacters:(const unichar *)&c length:1] autorelease];
	//NSString *result = [[[NSString alloc] initWithBytes:&c length:1 encoding:NSUTF8StringEncoding] autorelease];

//	NSLog(@"c: %d", c);
//	NSLog(@"string for c: %@", result);
//	NSString *chars = [[[NSString alloc] initWithCharacters:(const unichar *)&c length:1] autorelease];
//	NSString *utfs  = [[[NSString alloc] initWithUTF8String:(const char *)&c] autorelease];
//	NSString *utf8  = [[[NSString alloc] initWithBytes:&c length:1 encoding:NSUTF8StringEncoding] autorelease];
//	NSString *utf16 = [[[NSString alloc] initWithBytes:&c length:1 encoding:NSUTF16StringEncoding] autorelease];
//	NSString *ascii = [[[NSString alloc] initWithBytes:&c length:1 encoding:NSASCIIStringEncoding] autorelease];
//	NSString *iso   = [[[NSString alloc] initWithBytes:&c length:1 encoding:NSISOLatin1StringEncoding] autorelease];
//
//	NSLog(@"chars: '%@'", chars);
//	NSLog(@"utfs: '%@'", utfs);
//	NSLog(@"utf8: '%@'", utf8);
//	NSLog(@"utf16: '%@'", utf16);
//	NSLog(@"ascii: '%@'", ascii);
//	NSLog(@"iso: '%@'", iso);
	
	NSNumber *key = [NSNumber numberWithInteger:c];
	TDSymbolNode *child = [p.children objectForKey:key];
	
	if (!child) {
		if (p == self) {
			return result;
		} else {
			[r unread];
			return @"";
		}
	} 
	
	c = [r read];
	if (-1 == c) {
		return result;
	}
	
	return [result stringByAppendingString:[self nextWithFirst:c rest:r parent:child]];
}


- (NSString *)description {
	return @"<TDSymbolRootNode>";
}

@end
