//
//  TDAlternationTest.m
//  TDParseKit
//
//  Created by Todd Ditchendorf on 7/13/08.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

#import "TDAlternationTest.h"


@implementation TDAlternationTest

- (void)tearDown {
    [a release];
}


- (void)testTrueLiteralBestMatchForFooSpaceBarSpaceBaz {
    s = @"foo baz bar";
    a = [[TDTokenAssembly alloc] initWithString:s];
    
    p = [TDAlternation alternation];
    [p add:[TDLiteral literalWithString:@"foo"]];
    [p add:[TDLiteral literalWithString:@"bar"]];
    [p add:[TDLiteral literalWithString:@"baz"]];
    
    TDAssembly *result = [p bestMatchFor:a];
    
    STAssertNotNil(result, @"");
    STAssertEqualObjects(@"[foo]foo^baz/bar", [result description], @"");
}


- (void)testTrueLiteralBestMatchForFooSpaceBarSpaceBaz1 {
    s = @"123 baz bar";
    a = [[TDTokenAssembly alloc] initWithString:s];
    
    p = [TDAlternation alternation];
    [p add:[TDLiteral literalWithString:@"bar"]];
    [p add:[TDLiteral literalWithString:@"baz"]];
    [p add:[TDNum num]];
    
    TDAssembly *result = [p bestMatchFor:a];
    
    STAssertNotNil(result, @"");
    STAssertEqualObjects(@"[123]123^baz/bar", [result description], @"");
}


- (void)testTrueLiteralBestMatchForFooSpaceBarSpaceBaz2 {
    s = @"123 baz bar";
    a = [[TDTokenAssembly alloc] initWithString:s];
    
    p = [TDAlternation alternation];
    [p add:[TDWord word]];
    [p add:[TDLiteral literalWithString:@"baz"]];
    [p add:[TDNum num]];
    
    TDAssembly *result = [p bestMatchFor:a];
    
    STAssertNotNil(result, @"");
    STAssertEqualObjects(@"[123]123^baz/bar", [result description], @"");
}


- (void)testTrueLiteralBestMatchForFooSpaceBarSpaceBaz3 {
    s = @"123 baz bar";
    a = [[TDTokenAssembly alloc] initWithString:s];
    
    p = [TDAlternation alternation];
    [p add:[TDWord word]];
    [p add:[TDLiteral literalWithString:@"foo"]];
    [p add:[TDNum num]];
    
    TDAssembly *result = [p bestMatchFor:a];
    
    STAssertNotNil(result, @"");
    STAssertEqualObjects(@"[123]123^baz/bar", [result description], @"");
}


- (void)testTrueLiteralBestMatchForFooSpaceBarSpaceBaz4 {
    s = @"123 baz bar";
    a = [[TDTokenAssembly alloc] initWithString:s];
    
    p = [TDAlternation alternation];
    [p add:[TDLiteral literalWithString:@"foo"]];
    [p add:[TDLiteral literalWithString:@"baz"]];
    [p add:[TDNum num]];
    
    TDAssembly *result = [p bestMatchFor:a];
    
    STAssertNotNil(result, @"");
    STAssertEqualObjects(@"[123]123^baz/bar", [result description], @"");
}

@end
