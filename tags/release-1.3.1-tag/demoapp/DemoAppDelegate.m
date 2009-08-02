//
//  DemoAppDelegate.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 7/12/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "DemoAppDelegate.h"
#import <ParseKit/ParseKit.h>

@interface DemoAppDelegate ()
- (void)doParse;
- (void)done:(NSArray *)toks;
@end

@implementation DemoAppDelegate

- (id)init {
    if (self = [super init]) {
        self.tokenizer = [[[PKTokenizer alloc] init] autorelease];
        
        [tokenizer.symbolState add:@"::"];
        [tokenizer.symbolState add:@"<="];
        [tokenizer.symbolState add:@">="];
        [tokenizer.symbolState add:@"=="];
        [tokenizer.symbolState add:@"!="];
        [tokenizer.symbolState add:@"+="];
        [tokenizer.symbolState add:@"-="];
        [tokenizer.symbolState add:@"*="];
        [tokenizer.symbolState add:@"/="];
        [tokenizer.symbolState add:@":="];
        [tokenizer.symbolState add:@"++"];
        [tokenizer.symbolState add:@"--"];
        [tokenizer.symbolState add:@"<>"];
        [tokenizer.symbolState add:@"=:="];
    }
    return self;
}


- (void)dealloc {
    self.tokenizer = nil;
    self.inString = nil;
    self.outString = nil;
    self.tokString = nil;
    [super dealloc];
}


- (void)awakeFromNib {
    NSString *s = [NSString stringWithFormat:@"%C", 0xab];
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:s];
    [tokenField setTokenizingCharacterSet:set];
}


- (IBAction)parse:(id)sender {
    if (!self.inString.length) {
        NSBeep();
        return;
    }
    
    self.busy = YES;
    
    //[self doParse];
    [NSThread detachNewThreadSelector:@selector(doParse) toTarget:self withObject:nil];
}


- (void)doParse {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    //self.tokenizer = [[[PKTokenizer alloc] init] autorelease];
    self.tokenizer.string = self.inString;
    
    
    NSMutableArray *toks = [[NSMutableArray alloc] init];
    PKToken *tok = nil;
    PKToken *eofTok = [PKToken EOFToken];
    while (tok = [tokenizer nextToken]) {
        if (eofTok == tok) {
            break;
        }
        
        [toks addObject:tok];
    }
    
    //[self done:toks];
    [self performSelectorOnMainThread:@selector(done:) withObject:toks waitUntilDone:NO];
    
    [pool drain];
}


- (void)done:(NSArray *)toks {
    NSMutableString *s = [NSMutableString string];
    for (PKToken *tok in toks) {
        [s appendFormat:@"%@ %C", tok.stringValue, 0xab];
    }
    self.tokString = [[s copy] autorelease];
    
    s = [NSMutableString string];
    for (PKToken *tok in toks) {
        [s appendFormat:@"%@\n", [tok debugDescription]];
    }
    self.outString = [[s copy] autorelease];
    self.busy = NO;
    
    [toks release];
}



@synthesize tokenizer;
@synthesize inString;
@synthesize outString;
@synthesize tokString;
@synthesize busy;
@end