//
//  TODAssembly.m
//  TODParseKit
//
//  Created by Todd Ditchendorf on 7/13/08.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

#import <TODParseKit/TODAssembly.h>

@interface TODAssembly ()
@property (nonatomic, readwrite, retain) NSMutableArray *stack;
@property NSInteger index;
@property (nonatomic, copy) NSString *string;
@property (nonatomic, readwrite, copy) NSString *defaultDelimiter;
@end

@implementation TODAssembly

+ (id)assemblyWithString:(NSString *)s {
	return [[[[self class] alloc] initWithString:s] autorelease];
}


- (id)init {
	return [self initWithString:nil];
}


- (id)initWithString:(NSString *)s {
	self = [super init];
	if (self != nil) {
		self.stack = [NSMutableArray array];
		self.defaultDelimiter = @"/";
		self.string = s;
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
	TODAssembly *a = [[[self class] allocWithZone:zone] initWithString:string];
	[a->stack release];
	a->stack = [stack mutableCopy];
	a->target = [target copy];
	a->index = index;
	[a->defaultDelimiter release];
	a->defaultDelimiter = [defaultDelimiter copy];
    return a;
}


- (id)next {
	NSAssert1(0, @"-[TODAssembly %s] must be overriden", _cmd);
	return nil;
}


- (BOOL)hasMore {
	NSAssert1(0, @"-[TODAssembly %s] must be overriden", _cmd);
	return NO;
}


- (NSString *)consumed:(NSString *)delimiter {
	NSAssert1(0, @"-[TODAssembly %s] must be overriden", _cmd);
	return nil;
}


- (NSString *)remainder:(NSString *)delimiter {
	NSAssert1(0, @"-[TODAssembly %s] must be overriden", _cmd);
	return nil;
}


- (NSInteger)length {
	NSAssert1(0, @"-[TODAssembly %s] must be overriden", _cmd);
	return 0;
}


- (NSInteger)objectsConsumed {
	NSAssert1(0, @"-[TODAssembly %s] must be overriden", _cmd);
	return 0;
}


- (NSInteger)objectsRemaining {
	NSAssert1(0, @"-[TODAssembly %s] must be overriden", _cmd);
	return 0;
}


- (id)peek {
	NSAssert1(0, @"-[TODAssembly %s] must be overriden", _cmd);
	return nil;
}


- (id)pop {
	id result = nil;
	if (stack.count) {
		result = [[stack.lastObject retain] autorelease];
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
	
	NSInteger i = 0;
	NSInteger len = stack.count;
	
	for (id obj in self.stack) {
		[s appendString:[obj description]];
		if (i != len - 1) {
			[s appendString:@", "];
		}
		i++;
	}
	
	[s appendString:@"]"];
	
	[s appendString:[self consumed:self.defaultDelimiter]];
	[s appendString:@"^"];
	[s appendString:[self remainder:self.defaultDelimiter]];
	
	return [[s copy] autorelease];
}

@synthesize stack;
@synthesize target;
@synthesize index;
@synthesize string;
@synthesize defaultDelimiter;
@end
