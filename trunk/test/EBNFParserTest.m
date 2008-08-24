//
//  EBNFParserTest.m
//  TDParseKit
//
//  Created by Todd Ditchendorf on 8/15/08.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

#import "EBNFParserTest.h"
#import "EBNFParser.h"

@implementation EBNFParserTest

- (void)test {
	//NSString *s = @"foo (bar|baz)*;";
	NSString *s = @"$baz = bar; ($baz|foo)*;";
	//NSString *s = @"foo;";
	EBNFParser *p = [[[EBNFParser alloc] init] autorelease];
	
	//	TDAssembly *a = [p bestMatchFor:[TDTokenAssembly assemblyWithString:s]];
	//	NSLog(@"a: %@", a);
	//	NSLog(@"a.target: %@", a.target);
	
	TDParser *res = [p parse:s];
	//	NSLog(@"res: %@", res);
	//	NSLog(@"res: %@", res.string);
	//	NSLog(@"res.subparsers: %@", res.subparsers);
	//	NSLog(@"res.subparsers 0: %@", [[res.subparsers objectAtIndex:0] string]);
	//	NSLog(@"res.subparsers 1: %@", [[res.subparsers objectAtIndex:1] string]);
	
	s = @"bar foo bar foo";
	TDAssembly *a = [res completeMatchFor:[TDTokenAssembly assemblyWithString:s]];
	NSLog(@"\n\na: %@\n\n", a);
	
}

@end
