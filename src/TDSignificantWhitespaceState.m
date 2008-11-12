//
//  TDSignificantWhitespaceState.m
//  TDParseKit
//
//  Created by Todd Ditchendorf on 7/14/08.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

#import <TDParseKit/TDSignificantWhitespaceState.h>
#import <TDParseKit/TDReader.h>
#import <TDParseKit/TDTokenizer.h>
#import <TDParseKit/TDToken.h>

@interface TDTokenizerState ()
- (void)reset;
@property (nonatomic, retain) NSMutableString *stringbuf;
@end

@implementation TDToken (TDSignificantWhitespaceStateAdditions)

- (BOOL)isWhitespace {
	return self.tokenType == TDTT_WHITESPACE;
}


- (NSString *)debugDescription {
	NSString *typeString = nil;
	if (self.isNumber) {
		typeString = @"Number";
	} else if (self.isQuotedString) {
		typeString = @"Quoted String";
	} else if (self.isSymbol) {
		typeString = @"Symbol";
	} else if (self.isWord) {
		typeString = @"Word";
	} else if (self.isWhitespace) {
		typeString = @"Whitespace";
	}
	return [NSString stringWithFormat:@"<%@ %C%@%C>", typeString, 0x00ab, self.value, 0x00bb];
}

@end

@implementation TDSignificantWhitespaceState

- (void)dealloc {
	[super dealloc];
}


- (TDToken *)nextTokenFromReader:(TDReader *)r startingWith:(NSInteger)cin tokenizer:(TDTokenizer *)t {
	[self reset];
	
	c = cin;
	while ([self isWhitespaceChar:c]) {
		[stringbuf appendFormat:@"%C", c];
		c = [r read];
	}
	if (c != -1) {
		[r unread];
	}
	
	return [TDToken tokenWithTokenType:TDTT_WHITESPACE stringValue:[[stringbuf copy] autorelease] floatValue:0.0f];
}

@end
