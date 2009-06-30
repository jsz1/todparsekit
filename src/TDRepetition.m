//
//  TDRepetition.m
//  TDParseKit
//
//  Created by Todd Ditchendorf on 7/13/08.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/TDRepetition.h>
#import <ParseKit/PKAssembly.h>

@interface TDParser ()
- (NSSet *)matchAndAssemble:(NSSet *)inAssemblies;
@end

@interface TDRepetition ()
@property (nonatomic, readwrite, retain) TDParser *subparser;
@end

@implementation TDRepetition

+ (id)repetitionWithSubparser:(TDParser *)p {
    return [[[self alloc] initWithSubparser:p] autorelease];
}


- (id)init {
    return [self initWithSubparser:nil];
}


- (id)initWithSubparser:(TDParser *)p {
    //NSParameterAssert(p);
    if (self = [super init]) {
        self.subparser = p;
    }
    return self;
}


- (void)dealloc {
    self.subparser = nil;
    self.preassembler = nil;
    self.preassemblerSelector = nil;
    [super dealloc];
}


- (void)setPreassembler:(id)a selector:(SEL)sel {
    self.preassembler = a;
    self.preassemblerSelector = sel;
}


- (TDParser *)parserNamed:(NSString *)s {
    if ([name isEqualToString:s]) {
        return self;
    } else {
        return [subparser parserNamed:s];
    }
}


- (NSSet *)allMatchesFor:(NSSet *)inAssemblies {
    NSParameterAssert(inAssemblies);
    if (preassembler) {
        NSAssert2([preassembler respondsToSelector:preassemblerSelector], @"provided preassembler %@ should respond to %s", preassembler, preassemblerSelector);
        for (PKAssembly *a in inAssemblies) {
            [preassembler performSelector:preassemblerSelector withObject:a];
        }
    }
    
    //NSMutableSet *outAssemblies = [[[NSMutableSet alloc] initWithSet:inAssemblies copyItems:YES] autorelease];
    NSMutableSet *outAssemblies = [[inAssemblies mutableCopy] autorelease];
    
    NSSet *s = inAssemblies;
    while (s.count) {
        s = [subparser matchAndAssemble:s];
        [outAssemblies unionSet:s];
    }
    
    return outAssemblies;
}

@synthesize subparser;
@synthesize preassembler;
@synthesize preassemblerSelector;
@end
