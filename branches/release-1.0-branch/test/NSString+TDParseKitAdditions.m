//
//  NSString+TDParseKitAdditions.m
//  TDParseKit
//
//  Created by Todd Ditchendorf on 11/5/08.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

#import "NSString+TDParseKitAdditions.h"

@implementation NSString (TDParseKitAdditions)

- (NSString *)stringByTrimmingQuotes {
    NSUInteger len = self.length;
    
    if (len < 2) {
        return self;
    }
    
    NSRange r = NSMakeRange(0, len);
    
    unichar c = [self characterAtIndex:0];
    if (c == '\'' || c == '"') {
        unichar quoteChar = c;
        r.location = 1;
        r.length -= 1;

        c = [self characterAtIndex:len - 1];
        if (c == quoteChar) {
            r.length -= 1;
        }
        return [self substringWithRange:r];
    } else {
        return self;
    }
}

@end
