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
#import <TDParseKit/TDTypes.h>

@interface TDTokenizerState ()
- (void)resetWithReader:(TDReader *)r;
- (void)append:(TDUniChar)c;
- (NSString *)bufferedString;
@end

@implementation TDToken (TDSignificantWhitespaceStateAdditions)

- (BOOL)isWhitespace {
    return self.tokenType == TDTokenTypeWhitespace;
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


- (TDToken *)nextTokenFromReader:(TDReader *)r startingWith:(TDUniChar)cin tokenizer:(TDTokenizer *)t {
    NSParameterAssert(r);
    [self resetWithReader:r];
    
    c = cin;
    while ([self isWhitespaceChar:c]) {
        [self append:c];
        c = [r read];
    }
    if (c != -1) {
        [r unread];
    }
    
    return [TDToken tokenWithTokenType:TDTokenTypeWhitespace stringValue:[self bufferedString] floatValue:0.0];
}

@end