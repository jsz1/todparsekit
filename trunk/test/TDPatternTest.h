//
//  TDPatternTest.h
//  TDParseKit
//
//  Created by Todd Ditchendorf on 5/31/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDTestScaffold.h"

@interface TDPatternTest : SenTestCase {
    PKTokenizer *t;
    TDPattern *p;
    PKIntersection *inter;
    PKAssembly *a;
    NSString *s;
}

@end
