//
//  TDSignificantWhitespaceStateTest.m
//  TDParseKit
//
//  Created by Todd Ditchendorf on 7/14/08.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

#import "TDSignificantWhitespaceStateTest.h"


@implementation TDSignificantWhitespaceStateTest

- (void)setUp {
    whitespaceState = [[TDSignificantWhitespaceState alloc] init];
}


- (void)tearDown {
    [whitespaceState release];
    [r release];
}


- (void)testSpace {
    s = @" ";
    r = [[PKReader alloc] initWithString:s];
    TDToken *t = [whitespaceState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    STAssertNotNil(t, @"");
    STAssertEqualObjects(s, t.stringValue, @"");
    STAssertEquals(TDEOF, [r read], @"");
}


- (void)testTwoSpaces {
    s = @"  ";
    r = [[PKReader alloc] initWithString:s];
    TDToken *t = [whitespaceState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    STAssertNotNil(t, @"");
    STAssertEqualObjects(s, t.stringValue, @"");
    STAssertEquals(TDEOF, [r read], @"");
}


- (void)testEmptyString {
    s = @"";
    r = [[PKReader alloc] initWithString:s];
    TDToken *t = [whitespaceState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    STAssertNotNil(t, @"");
    STAssertEqualObjects(s, t.stringValue, @"");
    STAssertEquals(TDEOF, [r read], @"");
}


- (void)testTab {
    s = @"\t";
    r = [[PKReader alloc] initWithString:s];
    TDToken *t = [whitespaceState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    STAssertNotNil(t, @"");
    STAssertEqualObjects(s, t.stringValue, @"");
    STAssertEquals(TDEOF, [r read], @"");
}


- (void)testNewLine {
    s = @"\n";
    r = [[PKReader alloc] initWithString:s];
    TDToken *t = [whitespaceState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    STAssertNotNil(t, @"");
    STAssertEqualObjects(s, t.stringValue, @"");
    STAssertEquals(TDEOF, [r read], @"");
}


- (void)testCarriageReturn {
    s = @"\r";
    r = [[PKReader alloc] initWithString:s];
    TDToken *t = [whitespaceState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    STAssertNotNil(t, @"");
    STAssertEqualObjects(s, t.stringValue, @"");
    STAssertEquals(TDEOF, [r read], @"");
}


- (void)testSpaceCarriageReturn {
    s = @" \r";
    r = [[PKReader alloc] initWithString:s];
    TDToken *t = [whitespaceState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    STAssertNotNil(t, @"");
    STAssertEqualObjects(s, t.stringValue, @"");
    STAssertEquals(TDEOF, [r read], @"");
}


- (void)testSpaceTabNewLineSpace {
    s = @" \t\n ";
    r = [[PKReader alloc] initWithString:s];
    TDToken *t = [whitespaceState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    STAssertNotNil(t, @"");
    STAssertEqualObjects(s, t.stringValue, @"");
    STAssertEquals(TDEOF, [r read], @"");
}


- (void)testSpaceA {
    s = @" a";
    r = [[PKReader alloc] initWithString:s];
    TDToken *t = [whitespaceState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    STAssertNotNil(t, @"");
    STAssertEqualObjects(@" ", t.stringValue, @"");
    STAssertEquals((TDUniChar)'a', [r read], @"");
}

- (void)testSpaceASpace {
    s = @" a ";
    r = [[PKReader alloc] initWithString:s];
    TDToken *t = [whitespaceState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    STAssertNotNil(t, @"");
    STAssertEqualObjects(@" ", t.stringValue, @"");
    STAssertEquals((TDUniChar)'a', [r read], @"");
}


- (void)testTabA {
    s = @"\ta";
    r = [[PKReader alloc] initWithString:s];
    TDToken *t = [whitespaceState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    STAssertNotNil(t, @"");
    STAssertEqualObjects(@"\t", t.stringValue, @"");
    STAssertEquals((TDUniChar)'a', [r read], @"");
}


- (void)testNewLineA {
    s = @"\na";
    r = [[PKReader alloc] initWithString:s];
    TDToken *t = [whitespaceState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    STAssertNotNil(t, @"");
    STAssertEqualObjects(@"\n", t.stringValue, @"");
    STAssertEquals((TDUniChar)'a', [r read], @"");
}


- (void)testCarriageReturnA {
    s = @"\ra";
    r = [[PKReader alloc] initWithString:s];
    TDToken *t = [whitespaceState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    STAssertNotNil(t, @"");
    STAssertEqualObjects(@"\r", t.stringValue, @"");
    STAssertEquals((TDUniChar)'a', [r read], @"");
}


- (void)testNewLineSpaceCarriageReturnA {
    s = @"\n \ra";
    r = [[PKReader alloc] initWithString:s];
    TDToken *t = [whitespaceState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    STAssertNotNil(t, @"");
    STAssertEqualObjects(@"\n \r", t.stringValue, @"");
    STAssertEquals((TDUniChar)'a', [r read], @"");
}


@end
