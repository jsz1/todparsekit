//
//  TDJSValueHolder.m
//  TDParseKit
//
//  Created by Todd Ditchendorf on 1/2/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDJSValueHolder.h"

@implementation JSValueHolder

- (id)initWithContext:(JSContextRef)c heldValue:(JSValueRef)v {
    self = [super init];
    if (self) {
        self.context = c;
        self.heldValue = v;
    }
    return self;
}


- (void)dealloc {
    [super dealloc];
}


@synthesize context;
@synthesize heldValue;
@end