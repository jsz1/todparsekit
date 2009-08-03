//
//  TDParseTreeTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/1/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDParseTreeTest.h"

@implementation TDParseTreeTest

- (void)setUp {
    factory = [PKParserFactory factory];
    as = [[[PKParseTreeAssembler alloc] init] autorelease];
}


- (void)testFoo {
    g = @"@start = expr;"
        @"expr = addExpr;"
        @"addExpr = atom (('+'|'-') atom)*;"
        @"atom = Number;";
    lp = [factory parserFromGrammar:g assembler:as preassembler:as];
    
    lp.tokenizer.string = @"1 + 2";
    a = [PKTokenAssembly assemblyWithTokenizer:lp.tokenizer];
    res = [lp completeMatchFor:a];
    TDNotNil(res);
    TDEqualObjects([res description], @"[]1/+/2^");
    
    PKParseTree *tr = res.target;
    TDEqualObjects([tr class], [PKParseTree class]);
    TDEquals([[tr children] count], (NSUInteger)1);
    
    PKRuleNode *expr = [[tr children] objectAtIndex:0];
    TDEqualObjects([expr class], [PKRuleNode class]);
    TDEquals([[expr children] count], (NSUInteger)1);
    
    PKRuleNode *addExpr = [[expr children] objectAtIndex:0];
    TDEqualObjects([addExpr class], [PKRuleNode class]);
    TDEquals([[addExpr children] count], (NSUInteger)3);

    PKRuleNode *atom1 = [[addExpr children] objectAtIndex:0];
    TDEqualObjects([atom1 class], [PKRuleNode class]);
    TDEqualObjects([atom1 name], @"atom");
    TDEquals([[atom1 children] count], (NSUInteger)1);

    PKTokenNode *one = [[atom1 children] objectAtIndex:0];
    TDEqualObjects([one class], [PKTokenNode class]);
    TDEqualObjects([one token], [PKToken tokenWithTokenType:PKTokenTypeNumber stringValue:@"1" floatValue:1.0]);

    PKTokenNode *plus = [[addExpr children] objectAtIndex:1];
    TDEqualObjects([plus class], [PKTokenNode class]);
    TDEqualObjects([plus token], [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"+" floatValue:0]);

    PKRuleNode *atom2 = [[addExpr children] objectAtIndex:2];
    TDEqualObjects([atom2 class], [PKRuleNode class]);
    TDEqualObjects([atom2 name], @"atom");
    TDEquals([[atom2 children] count], (NSUInteger)1);

    PKTokenNode *two = [[atom2 children] objectAtIndex:0];
    TDEqualObjects([two class], [PKTokenNode class]);
    TDEqualObjects([two token], [PKToken tokenWithTokenType:PKTokenTypeNumber stringValue:@"2" floatValue:2.0]);
}

@end