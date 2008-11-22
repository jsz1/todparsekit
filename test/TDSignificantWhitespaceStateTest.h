//
//  TDSignificantWhitespaceStateTest.h
//  TDParseKit
//
//  Created by Todd Ditchendorf on 7/14/08.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <TDParseKit/TDParseKit.h>

@interface TDSignificantWhitespaceStateTest : SenTestCase {
    TDSignificantWhitespaceState *whitespaceState;
    TDReader *r;
    NSString *s;    
}
@end
