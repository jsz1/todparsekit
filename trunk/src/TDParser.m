//
//  TDParser.m
//  TDParseKit
//
//  Created by Todd Ditchendorf on 1/20/06.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

#import <TDParseKit/TDParser.h>
#import <TDParseKit/TDAssembly.h>

@interface TDParser ()
- (NSSet *)matchAndAssemble:(NSSet *)inAssemblies;
- (TDAssembly *)best:(NSSet *)inAssemblies;
@end

@implementation TDParser

+ (id)parser {
	return [[[self alloc] init] autorelease];
}


- (id)init {
	self = [super init];
	if (self != nil) {
	}
	return self;
}


- (void)dealloc {
	self.assembler = nil;
	self.selector = nil;
	self.name = nil;
	[super dealloc];
}


- (void)setAssembler:(id)a selector:(SEL)sel {
	self.assembler = a;
	self.selector = sel;
}


- (NSSet *)allMatchesFor:(NSSet *)inAssemblies {
	NSAssert1(0, @"-[TDParser %s] must be overriden", _cmd);
	return nil;
}


- (TDAssembly *)bestMatchFor:(TDAssembly *)a {
	NSSet *initialState = [NSSet setWithObject:a];
	NSSet *finalState = [self matchAndAssemble:initialState];
	return [self best:finalState];
}


- (TDAssembly *)completeMatchFor:(TDAssembly *)a {
	TDAssembly *best = [self bestMatchFor:a];
	if (best && ![best hasMore]) {
		return best;
	}
	return nil;
}


- (NSSet *)matchAndAssemble:(NSSet *)inAssemblies {
	NSSet *outAssemblies = [self allMatchesFor:inAssemblies];
	if (assembler) {
	//if (assembler && [assembler respondsToSelector:selector]) {
		for (TDAssembly *a in outAssemblies) {
			[assembler performSelector:selector withObject:a];
		}
	}
	return outAssemblies;
}


- (TDAssembly *)best:(NSSet *)inAssemblies {
	TDAssembly *best = nil;
	
	for (TDAssembly *a in inAssemblies) {
		if (![a hasMore]) {
			best = a;
			break;
		}
		if (!best) {
			best = a;
		} else if ([a objectsConsumed] > [best objectsConsumed]) {
			best = a;
		}
	}
	
	return best;
}


- (NSString *)description {
	if (name.length) {
		return [NSString stringWithFormat:@"%@ (%@)", [[self className] substringFromIndex:2], name];
	} else {
		return [NSString stringWithFormat:@"%@", [[self className] substringFromIndex:2]];
	}
}

@synthesize assembler;
@synthesize selector;
@synthesize name;
@end
