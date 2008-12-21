//
//  TDAssembly.m
//  TDParseKit
//
//  Created by Todd Ditchendorf on 7/13/08.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

#import <TDParseKit/TDAssembly.h>

@interface TDAssembly ()
- (id)initWithString:(NSString *)s defaultDelimiter:(NSString *)d stack:(NSMutableArray *)a;

@property (nonatomic, readwrite, retain) NSMutableArray *stack;
@property (nonatomic) NSInteger index;
@property (nonatomic, copy) NSString *string;
@property (nonatomic, readwrite, copy) NSString *defaultDelimiter;
@end

@implementation TDAssembly

+ (id)assemblyWithString:(NSString *)s {
    return [[[self alloc] initWithString:s] autorelease];
}


- (id)init {
    return [self initWithString:nil];
}


- (id)initWithString:(NSString *)s {
    return [self initWithString:s defaultDelimiter:@"/" stack:[NSMutableArray array]];
}


// designated initializer. 
// this exists simply to improve the performance of the -copyWithZone: method.
// this is private so as not to complicate the public API with a not-particularly-useful constructor
- (id)initWithString:(NSString *)s defaultDelimiter:(NSString *)d stack:(NSMutableArray *)a {
    self = [super init];
    if (self) {
        self.stack = a;
        self.string = s;
        self.defaultDelimiter = d;
    }
    return self;
}


- (void)dealloc {
    self.stack = nil;
    self.target = nil;
    self.string = nil;
    self.defaultDelimiter = nil;
    [super dealloc];
}


- (id)copyWithZone:(NSZone *)zone {
    TDAssembly *a = [[[self class] allocWithZone:zone] initWithString:string defaultDelimiter:defaultDelimiter stack:[[stack mutableCopy] autorelease]];
    a->target = [target mutableCopy];
    a->index = index;
    return a;
}


- (id)next {
    NSAssert1(0, @"-[TDAssembly %s] must be overriden", _cmd);
    return nil;
}


- (BOOL)hasMore {
    NSAssert1(0, @"-[TDAssembly %s] must be overriden", _cmd);
    return NO;
}


- (NSString *)consumedObjectsSeparatedBy:(NSString *)delimiter {
    NSAssert1(0, @"-[TDAssembly %s] must be overriden", _cmd);
    return nil;
}


- (NSString *)remainingObjectsSeparatedBy:(NSString *)delimiter {
    NSAssert1(0, @"-[TDAssembly %s] must be overriden", _cmd);
    return nil;
}


- (NSInteger)length {
    NSAssert1(0, @"-[TDAssembly %s] must be overriden", _cmd);
    return 0;
}


- (NSInteger)objectsConsumed {
    NSAssert1(0, @"-[TDAssembly %s] must be overriden", _cmd);
    return 0;
}


- (NSInteger)objectsRemaining {
    NSAssert1(0, @"-[TDAssembly %s] must be overriden", _cmd);
    return 0;
}


- (id)peek {
    NSAssert1(0, @"-[TDAssembly %s] must be overriden", _cmd);
    return nil;
}


- (id)pop {
    id result = nil;
    if (stack.count) {
        result = [[[stack lastObject] retain] autorelease];
        [stack removeLastObject];
    }
    return result;
}


- (void)push:(id)object {
    if (object) {
        [stack addObject:object];
    }
}


- (BOOL)isStackEmpty {
    return 0 == stack.count;
}


- (NSArray *)objectsAbove:(id)fence {
    NSMutableArray *result = [NSMutableArray array];
    
    while (stack.count) {        
        id obj = [self pop];
        
        if ([obj isEqual:fence]) {
            [self push:obj];
            break;
        } else {
            [result addObject:obj];
        }
    }
    
    return result;
}


- (NSString *)description {
    NSMutableString *s = [NSMutableString string];
    [s appendString:@"["];
    
    NSUInteger i = 0;
    NSUInteger len = stack.count;
    
    for (id obj in stack) {
        [s appendString:[obj description]];
        if (len - 1 != i++) {
            [s appendString:@", "];
        }
    }
    
    [s appendString:@"]"];
    
    [s appendString:[self consumedObjectsSeparatedBy:self.defaultDelimiter]];
    [s appendString:@"^"];
    [s appendString:[self remainingObjectsSeparatedBy:self.defaultDelimiter]];
    
    return [[s copy] autorelease];
}

@synthesize stack;
@synthesize target;
@synthesize index;
@synthesize string;
@synthesize defaultDelimiter;
@end
