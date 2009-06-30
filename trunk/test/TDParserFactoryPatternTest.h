//
//  PKParserFactoryPatternTest.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 6/6/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDTestScaffold.h"
#import "TDParserFactory.h"

@interface TDParserFactoryPatternTest : SenTestCase {
    NSString *g;
    NSString *s;
    PKTokenAssembly *a;
    TDParserFactory *factory;
    PKAssembly *res;
    PKParser *lp; // language parser
    PKTokenizer *t;
}

@end
