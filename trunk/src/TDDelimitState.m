//
//  TDDelimitState.m
//  TDParseKit
//
//  Created by Todd Ditchendorf on 5/21/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <TDParseKit/TDDelimitState.h>
#import <TDParseKit/TDReader.h>
#import <TDParseKit/TDTokenizer.h>
#import <TDParseKit/TDToken.h>
#import <TDParseKit/TDSymbolRootNode.h>
#import <TDParseKit/TDTypes.h>

@interface TDTokenizerState ()
- (void)reset;
- (void)append:(TDUniChar)c;
- (void)appendString:(NSString *)s;
- (NSString *)bufferedString;
@end

@interface TDDelimitState ()
@property (nonatomic, retain) TDSymbolRootNode *rootNode;
@property (nonatomic, retain) NSMutableArray *startSymbols;
@property (nonatomic, retain) NSMutableArray *endSymbols;
@property (nonatomic, retain) NSMutableArray *characterSets;
@end

@implementation TDDelimitState

- (id)init {
    if (self = [super init]) {
        self.rootNode = [[[TDSymbolRootNode alloc] init] autorelease];
        self.startSymbols = [NSMutableArray array];
        self.endSymbols = [NSMutableArray array];
        self.characterSets = [NSMutableArray array];
    }
    return self;
}


- (void)dealloc {
    self.rootNode = nil;
    self.startSymbols = nil;
    self.endSymbols = nil;
    self.characterSets = nil;
    [super dealloc];
}


- (void)addStartSymbol:(NSString *)start endSymbol:(NSString *)end allowedCharacterSet:(NSCharacterSet *)cs {
    NSParameterAssert(start.length);
    NSParameterAssert(end.length);
    [rootNode add:start];
    [rootNode add:end];
    [startSymbols addObject:start];
    [endSymbols addObject:end];
    [characterSets addObject:cs ? cs : (id)[NSNull null]];
}


- (void)removeStartSymbol:(NSString *)start {
    NSParameterAssert(start.length);
    [rootNode remove:start];
    NSUInteger i = [startSymbols indexOfObject:start];
    if (NSNotFound != i) {
        [startSymbols removeObject:start];
        [endSymbols removeObjectAtIndex:i]; // this should always be in range.
    }
}


- (void)unreadSymbol:(NSString *)s fromReader:(TDReader *)r {
    NSUInteger len = s.length;
    NSUInteger i = 0;
    for ( ; i < len - 1; i++) {
        [r unread];
    }
}


- (TDToken *)nextTokenFromReader:(TDReader *)r startingWith:(TDUniChar)cin tokenizer:(TDTokenizer *)t {
    NSParameterAssert(r);
    NSParameterAssert(t);
    
    NSString *startSymbol = [rootNode nextSymbol:r startingWith:cin];
    if (!startSymbol.length || ![startSymbols containsObject:startSymbol]) {
        NSUInteger i = 0;
        for ( ; i < startSymbol.length - 1; i++) {
            [r unread];
        }
        return [TDToken tokenWithTokenType:TDTokenTypeSymbol stringValue:[NSString stringWithFormat:@"%C", cin] floatValue:0.0];
    }
    
    [self reset];
    [self appendString:startSymbol];
    
    NSUInteger i = [startSymbols indexOfObject:startSymbol];
    NSString *endSymbol = [endSymbols objectAtIndex:i];
    TDUniChar e = [endSymbol characterAtIndex:0];
    NSCharacterSet *characterSet = nil;
    id csOrNull = [characterSets objectAtIndex:i];
    if ([NSNull null] != csOrNull) {
        characterSet = csOrNull;
    }
    
    TDUniChar c;
    while (1) {
        c = [r read];
        if (TDEOF == c) {
            if (balancesEOFTerminatedStrings) {
                [self appendString:endSymbol];
            }
            break;
        }
        
        if (characterSet) {
            if (![characterSet characterIsMember:c]) {
                // TODO unwind
            }
        }
        
        if (e == c) {
            NSString *peek = [rootNode nextSymbol:r startingWith:e];
            if ([endSymbol isEqualToString:peek]) {
                [self appendString:endSymbol];
                c = [r read];
                break;
            } else {
                [self unreadSymbol:peek fromReader:r];
                if (e != [peek characterAtIndex:0]) {
                    [self append:c];
                    c = [r read];
                }
            }
        }
        [self append:c];
    }
    
    if (TDEOF != c) {
        [r unread];
    }
    
    return [TDToken tokenWithTokenType:TDTokenTypeDelimitedString stringValue:[self bufferedString] floatValue:0.0];
}

@synthesize rootNode;
@synthesize balancesEOFTerminatedStrings;
@synthesize startSymbols;
@synthesize endSymbols;
@synthesize characterSets;
@end