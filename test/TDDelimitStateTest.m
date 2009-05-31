//
//  TDDelimitStateTest.m
//  TDParseKit
//
//  Created by Todd Ditchendorf on 5/21/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDDelimitStateTest.h"

@implementation TDDelimitStateTest

- (void)setUp {
    t = [[TDTokenizer alloc] init];
    delimitState = t.delimitState;
}


- (void)tearDown {
    [t release];
}


- (void)testLtFooGt {
    s = @"<foo>";
    t.string = s;
    NSCharacterSet *cs = nil;

    [t setTokenizerState:delimitState from:'<' to:'<'];
    [delimitState addStartMarker:@"<" endMarker:@">" allowedCharacterSet:cs];
    
    tok = [t nextToken];

    TDTrue(tok.isDelimitedString);
    TDEqualObjects(tok.stringValue, s);
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects(tok, [TDToken EOFToken]);
}


- (void)testLtFooGtWithFOAllowed {
    s = @"<foo>";
    t.string = s;
    NSCharacterSet *cs = [NSCharacterSet characterSetWithCharactersInString:@"fo"];
    
    [t setTokenizerState:delimitState from:'<' to:'<'];
    [delimitState addStartMarker:@"<" endMarker:@">" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(tok.stringValue, s);
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects(tok, [TDToken EOFToken]);
}


- (void)testLtFooGtWithFAllowed {
    s = @"<foo>";
    t.string = s;
    NSCharacterSet *cs = [NSCharacterSet characterSetWithCharactersInString:@"f"];
    
    [t setTokenizerState:delimitState from:'<' to:'<'];
    [delimitState addStartMarker:@"<" endMarker:@">" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"<");
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(tok.stringValue, @"foo");
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @">");
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects(tok, [TDToken EOFToken]);
}


- (void)testLtFooGtWithFAllowedAndRemove {
    s = @"<foo>";
    t.string = s;
    NSCharacterSet *cs = nil;
    
    [t setTokenizerState:delimitState from:'<' to:'<'];
    [delimitState addStartMarker:@"<" endMarker:@">" allowedCharacterSet:cs];
    [delimitState removeStartMarker:@"<"];
    
    tok = [t nextToken];
    
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"<");
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(tok.stringValue, @"foo");
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @">");
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects(tok, [TDToken EOFToken]);
}


- (void)testLtHashFooGt {
    s = @"<#foo>";
    t.string = s;
    NSCharacterSet *cs = nil;
    
    [t setTokenizerState:delimitState from:'<' to:'<'];
    [delimitState addStartMarker:@"<#" endMarker:@">" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(tok.stringValue, s);
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects(tok, [TDToken EOFToken]);
}


- (void)testLtHashFooGtWithFOAllowed {
    s = @"<#foo>";
    t.string = s;
    NSCharacterSet *cs = [NSCharacterSet characterSetWithCharactersInString:@"fo"];
    
    [t setTokenizerState:delimitState from:'<' to:'<'];
    [delimitState addStartMarker:@"<#" endMarker:@">" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(tok.stringValue, s);
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects(tok, [TDToken EOFToken]);
}


- (void)testLtHashFooGtWithFAllowed {
    s = @"<#foo>";
    t.string = s;
    NSCharacterSet *cs = [NSCharacterSet characterSetWithCharactersInString:@"f"];
    
    [t setTokenizerState:delimitState from:'<' to:'<'];
    [delimitState addStartMarker:@"<#" endMarker:@">" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"<");
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"#");
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(tok.stringValue, @"foo");
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @">");
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects(tok, [TDToken EOFToken]);
}


- (void)testLtHashFooGtWithFAllowedAndMultiCharSymbol {
    s = @"<#foo>";
    t.string = s;
    NSCharacterSet *cs = [NSCharacterSet characterSetWithCharactersInString:@"f"];
    
    [t setTokenizerState:delimitState from:'<' to:'<'];
    [delimitState addStartMarker:@"<#" endMarker:@">" allowedCharacterSet:cs];
    
    [t.symbolState add:@"<#"];
    
    tok = [t nextToken];
    
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"<#");
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(tok.stringValue, @"foo");
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @">");
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects(tok, [TDToken EOFToken]);
}


- (void)testLtHashFooHashGt {
    s = @"=#foo#=";
    t.string = s;
    NSCharacterSet *cs = nil;
    
    [t setTokenizerState:delimitState from:'=' to:'='];
    [delimitState addStartMarker:@"=#" endMarker:@"#=" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(tok.stringValue, s);
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects(tok, [TDToken EOFToken]);
}


- (void)testLtHashFooHashGtWithFOAllowed {
    s = @"=#foo#=";
    t.string = s;
    NSCharacterSet *cs = [NSCharacterSet characterSetWithCharactersInString:@"fo"];
    
    [t setTokenizerState:delimitState from:'=' to:'='];
    [delimitState addStartMarker:@"=#" endMarker:@"#=" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(tok.stringValue, s);
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects(tok, [TDToken EOFToken]);
}


- (void)testLtHashFooHashGtWithFAllowed {
    s = @"=#foo#=";
    t.string = s;
    NSCharacterSet *cs = [NSCharacterSet characterSetWithCharactersInString:@"f"];
    
    [t setTokenizerState:delimitState from:'=' to:'='];
    [delimitState addStartMarker:@"=#" endMarker:@"#=" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"=");
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"#");
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(tok.stringValue, @"foo");
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"#");
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"=");
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects(tok, [TDToken EOFToken]);
}


- (void)testLtDollar123Dollar {
    s = @"$123$";
    t.string = s;
    NSCharacterSet *cs = nil;
    
    [t setTokenizerState:delimitState from:'$' to:'$'];
    [delimitState addStartMarker:@"$" endMarker:@"$" allowedCharacterSet:cs];
    
    tok = [t nextToken];

    TDTrue(tok.isDelimitedString);
    TDEqualObjects(tok.stringValue, s);
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects(tok, [TDToken EOFToken]);
}


- (void)testLtDollarDollar123DollarDollar {
    s = @"$$123$$";
    t.string = s;
    NSCharacterSet *cs = nil;
    
    [t setTokenizerState:delimitState from:'$' to:'$'];
    [delimitState addStartMarker:@"$$" endMarker:@"$$" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(tok.stringValue, s);
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects(tok, [TDToken EOFToken]);
}


- (void)testLtDollarDollar123DollarHash {
    s = @"$$123$#";
    t.string = s;
    NSCharacterSet *cs = nil;
    
    [t setTokenizerState:delimitState from:'$' to:'$'];
    [delimitState addStartMarker:@"$$" endMarker:@"$#" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(tok.stringValue, s);
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects(tok, [TDToken EOFToken]);
}


- (void)testLtDollarDollar123DollarHashDecimalDigitAllowed {
    s = @"$$123$#";
    t.string = s;
    NSCharacterSet *cs = [NSCharacterSet decimalDigitCharacterSet];
    
    [t setTokenizerState:delimitState from:'$' to:'$'];
    [delimitState addStartMarker:@"$$" endMarker:@"$#" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(tok.stringValue, s);
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects(tok, [TDToken EOFToken]);
}


- (void)testLtDollarDollar123DollarHashAlphanumericAllowed {
    s = @"$$123$#";
    t.string = s;
    NSCharacterSet *cs = [NSCharacterSet alphanumericCharacterSet];
    
    [t setTokenizerState:delimitState from:'$' to:'$'];
    [delimitState addStartMarker:@"$$" endMarker:@"$#" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(tok.stringValue, s);
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects(tok, [TDToken EOFToken]);
}


- (void)testLtDollarDollar123DollarHashAlphanumericAndWhitespaceAndNewlineAllowed {
    s = @"$$123 456\t789\n0$#";
    t.string = s;
    NSMutableCharacterSet *cs = [[[NSCharacterSet alphanumericCharacterSet] mutableCopy] autorelease];
    [cs formUnionWithCharacterSet:[NSCharacterSet whitespaceCharacterSet]];
    [cs formUnionWithCharacterSet:[NSCharacterSet newlineCharacterSet]];
    
    [t setTokenizerState:delimitState from:'$' to:'$'];
    [delimitState addStartMarker:@"$$" endMarker:@"$#" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(tok.stringValue, s);
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects(tok, [TDToken EOFToken]);
}


- (void)testLtDollarDollar123DollarHashWhitespaceAllowed {
    s = @"$$123$#";
    t.string = s;
    NSCharacterSet *cs = [NSCharacterSet whitespaceCharacterSet];
    
    [t setTokenizerState:delimitState from:'$' to:'$'];
    [delimitState addStartMarker:@"$$" endMarker:@"$#" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"$");
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"$");
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isNumber);
    TDEqualObjects(tok.stringValue, @"123");
    TDEquals(tok.floatValue, (CGFloat)123.0);
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"$");
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"#");
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects(tok, [TDToken EOFToken]);
}


- (void)testLtDollarDollarDollarHash {
    s = @"$$$#";
    t.string = s;
    NSCharacterSet *cs = nil;
    
    [t setTokenizerState:delimitState from:'$' to:'$'];
    [delimitState addStartMarker:@"$$" endMarker:@"$#" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(tok.stringValue, s);
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects(tok, [TDToken EOFToken]);
}


- (void)testLtDollarDollarDollar {
    s = @"$$$";
    t.string = s;
    NSCharacterSet *cs = nil;
    
    [t setTokenizerState:delimitState from:'$' to:'$'];
    [delimitState addStartMarker:@"$$" endMarker:@"$#" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(tok.stringValue, s);
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects(tok, [TDToken EOFToken]);
}


- (void)testLtDollarDollarDollarBalanceEOFStrings {
    s = @"$$$";
    t.string = s;
    NSCharacterSet *cs = nil;
    
    delimitState.balancesEOFTerminatedStrings = YES;
    [t setTokenizerState:delimitState from:'$' to:'$'];
    [delimitState addStartMarker:@"$$" endMarker:@"$#" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(tok.stringValue, @"$$$$#");
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects(tok, [TDToken EOFToken]);
}


- (void)testPHPPrint {
    s = @"<?= 'foo' ?>";
    t.string = s;
    NSCharacterSet *cs = nil;
    
    [t setTokenizerState:delimitState from:'<' to:'<'];
    [delimitState addStartMarker:@"<?=" endMarker:@"?>" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(tok.stringValue, s);
    TDEquals(tok.floatValue, (CGFloat)0.0);

    tok = [t nextToken];
    TDEqualObjects(tok, [TDToken EOFToken]);
}


- (void)testPHP {
    s = @"<?php echo 'foo'; ?>";
    t.string = s;
    NSCharacterSet *cs = nil;
    
    [t setTokenizerState:delimitState from:'<' to:'<'];
    [delimitState addStartMarker:@"<?php" endMarker:@"?>" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(tok.stringValue, s);
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects(tok, [TDToken EOFToken]);
}


- (void)testEnvVars {
    s = @"${PRODUCT_NAME} or ${EXECUTABLE_NAME}";
    t.string = s;
    NSCharacterSet *cs = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZ_"];
    
    [t setTokenizerState:delimitState from:'$' to:'$'];
    [delimitState addStartMarker:@"${" endMarker:@"}" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(tok.stringValue,  @"${PRODUCT_NAME}");
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(tok.stringValue,  @"or");
    
    tok = [t nextToken];
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(tok.stringValue,  @"${EXECUTABLE_NAME}");
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects(tok, [TDToken EOFToken]);
}


- (void)testCocoaString {
    s = @"@\"foo\"";
    t.string = s;
    NSCharacterSet *cs = nil;
    
    [t setTokenizerState:delimitState from:'@' to:'@'];
    [delimitState addStartMarker:@"@\"" endMarker:@"\"" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(tok.stringValue,  s);
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects(tok, [TDToken EOFToken]);
}


- (void)testAlphaMarkerXX {
    s = @"XXfooXX";
    t.string = s;
    NSCharacterSet *cs = nil;
    
    [t setTokenizerState:delimitState from:'X' to:'X'];
    [delimitState addStartMarker:@"XX" endMarker:@"XX" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(tok.stringValue,  s);
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects(tok, [TDToken EOFToken]);
}


- (void)testAlphaMarkerXXAndXXX {
    s = @"XXfooXXX";
    t.string = s;
    NSCharacterSet *cs = nil;
    
    [t setTokenizerState:delimitState from:'X' to:'X'];
    [delimitState addStartMarker:@"XX" endMarker:@"XXX" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(tok.stringValue,  s);
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects(tok, [TDToken EOFToken]);
}


- (void)testAlphaMarkerXXFails {
    s = @"XXfooXX";
    t.string = s;
    NSCharacterSet *cs = [NSCharacterSet whitespaceCharacterSet];
    
    [t setTokenizerState:delimitState from:'X' to:'X'];
    [delimitState addStartMarker:@"XX" endMarker:@"XX" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(tok.stringValue,  s);
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects(tok, [TDToken EOFToken]);
}


- (void)testAlphaMarkerXXFalseStartMarker {
    s = @"XfooXX";
    t.string = s;
    NSCharacterSet *cs = [NSCharacterSet whitespaceCharacterSet];
    
    [t setTokenizerState:delimitState from:'X' to:'X'];
    [delimitState addStartMarker:@"XX" endMarker:@"XX" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(tok.stringValue,  s);
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects(tok, [TDToken EOFToken]);
}


- (void)testAtStartMarkerNilEndMarker {
    s = @"@foo";
    t.string = s;
    NSCharacterSet *cs = [NSCharacterSet alphanumericCharacterSet];
    
    [t setTokenizerState:delimitState from:'@' to:'@'];
    [delimitState addStartMarker:@"@" endMarker:nil allowedCharacterSet:cs];
    
    tok = [t nextToken];
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(tok.stringValue,  s);
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects(tok, [TDToken EOFToken]);
}


- (void)testAtStartMarkerNilEndMarker2 {
    s = @"@foo bar @ @baz ";
    t.string = s;
    NSCharacterSet *cs = [NSCharacterSet alphanumericCharacterSet];
    
    [t setTokenizerState:delimitState from:'@' to:'@'];
    [delimitState addStartMarker:@"@" endMarker:nil allowedCharacterSet:cs];
    
    tok = [t nextToken];
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(tok.stringValue,  @"@foo");
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(tok.stringValue,  @"bar");
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue,  @"@");
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(tok.stringValue,  @"@baz");
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects(tok, [TDToken EOFToken]);
}

@end