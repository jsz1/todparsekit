//
//  TDGenericAssembler.m
//  TDParseKit
//
//  Created by Todd Ditchendorf on 12/22/08.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

#import "TDGenericAssembler.h"
#import "NSArray+TDParseKitAdditions.h"
#import <TDParseKit/TDParseKit.h>

@interface TDGenericAssembler ()
- (void)workOnTerminalNamed:(NSString *)name withAssembly:(TDAssembly *)a;
- (void)appendAttributedStringForObjects:(NSArray *)objs withAttrs:(id)attrs;
- (void)appendAttributedStringForObject:(id)obj withAttrs:(id)attrs;
- (NSMutableArray *)popWhitespaceTokensFrom:(TDAssembly *)a;
- (void)consumeWhitespaceTokens:(NSArray *)whitespaceToks;
- (void)consumeWhitespaceToken:(TDToken *)whitespaceTok;
- (void)consumeWhitespaceFrom:(TDAssembly *)a;
    
@property (nonatomic, retain) NSString *prefix;
@property (nonatomic, retain) NSString *suffix;
@end

@implementation TDGenericAssembler

- (id)init {
    self = [super init];
    if (self) {
        self.displayString = [[[NSMutableAttributedString alloc] initWithString:@"" attributes:nil] autorelease];
        self.productionNames = [NSMutableDictionary dictionary];
        self.defaultProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSColor blackColor], NSForegroundColorAttributeName,
                                  [NSColor whiteColor], NSBackgroundColorAttributeName,
                                  [NSFont fontWithName:@"Monaco" size:11.0], NSFontAttributeName,
                                  nil];
        self.prefix = @"workOn";
        self.suffix = @"Assembly:";
    }
    return self;
}


- (void)dealloc {
    self.attributes = nil;
    self.defaultProperties = nil;
    self.productionNames = nil;
    self.displayString = nil;
    self.prefix = nil;
    self.suffix = nil;
    [super dealloc];
}


- (BOOL)respondsToSelector:(SEL)sel {
    return YES;
}


- (id)performSelector:(SEL)sel withObject:(id)obj {
    NSString *selName = NSStringFromSelector(sel);
    
    NSString *productionName = [productionNames objectForKey:selName];
    
    if (!productionName) {
        NSUInteger prefixLen = prefix.length;
        NSInteger c = ((NSInteger)[selName characterAtIndex:prefixLen]) + 32; // lowercase
        NSRange r = NSMakeRange(prefixLen + 1, selName.length - (prefixLen + suffix.length + 1 /*:*/));
        productionName = [NSString stringWithFormat:@"%C%@", c, [selName substringWithRange:r]];
        [productionNames setObject:productionName forKey:selName];
    }
    
    [self workOnTerminalNamed:productionName withAssembly:obj];
    
    return nil;
}


- (void)workOnTerminalNamed:(NSString *)name withAssembly:(TDAssembly *)a {
    //NSLog(@"%@ : %@", name, a);
    NSMutableArray *whitespaceToks = [self popWhitespaceTokensFrom:a];

    id props = [attributes objectForKey:name];
    if (!props) props = defaultProperties;
    
    NSMutableArray *toks = nil;
    TDToken *tok = nil;
    while (tok = [a pop]) {
        if (TDTokenTypeWhitespace != tok.tokenType) {
            if (!toks) toks = [NSMutableArray array];
            [toks addObject:tok];
        } else {
            [self consumeWhitespaceToken:tok];
            break;
        }
    }
    
    [self consumeWhitespaceFrom:a];
    [self appendAttributedStringForObjects:toks withAttrs:props];
    [self consumeWhitespaceTokens:whitespaceToks];
}


- (void)appendAttributedStringForObjects:(NSArray *)objs withAttrs:(id)attrs {
    for (id obj in objs) {
        [self appendAttributedStringForObject:obj withAttrs:attrs];
    }
}


- (void)appendAttributedStringForObject:(id)obj withAttrs:(id)attrs {
    NSAttributedString *as = [[NSAttributedString alloc] initWithString:[obj stringValue] attributes:attrs];
    [displayString appendAttributedString:as];
    [as release];
}


- (NSMutableArray *)popWhitespaceTokensFrom:(TDAssembly *)a {
    NSMutableArray *whitespaceToks = nil;
    TDToken *tok = nil;
    while (tok = [a pop]) {
        if (TDTokenTypeWhitespace == tok.tokenType) {
            if (!whitespaceToks) {
                whitespaceToks = [NSMutableArray array];
            }
            [whitespaceToks addObject:tok];
        } else {
            [a push:tok];
            break;
        }
    }
    if (whitespaceToks) {
        whitespaceToks = [whitespaceToks reversedMutableArray];
    }
    return whitespaceToks;
}


- (void)consumeWhitespaceTokens:(NSArray *)whitespaceToks {
    [self appendAttributedStringForObjects:whitespaceToks withAttrs:nil];
}


- (void)consumeWhitespaceToken:(TDToken *)whitespaceTok {
    [self appendAttributedStringForObject:whitespaceTok withAttrs:nil];
}


- (void)consumeWhitespaceFrom:(TDAssembly *)a {
    NSMutableArray *whitespaceToks = [self popWhitespaceTokensFrom:a];
    if (whitespaceToks) {
        [self consumeWhitespaceTokens:whitespaceToks];
    }
}

@synthesize attributes;
@synthesize defaultProperties;
@synthesize productionNames;
@synthesize displayString;
@synthesize prefix;
@synthesize suffix;
@end