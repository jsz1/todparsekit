//
//  DebugAppDelegate.m
//  TDParseKit
//
//  Created by Todd Ditchendorf on 8/12/08.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

#import "DebugAppDelegate.h"
#import <ParseKit/ParseKit.h>
#import "TDParserFactory.h"
#import "TDJsonParser.h"
#import "TDFastJsonParser.h"
#import "TDRegularParser.h"
#import "EBNFParser.h"
#import "TDPlistParser.h"
#import "TDXmlNameState.h"
#import "TDXmlToken.h"
#import "TDHtmlSyntaxHighlighter.h"
#import "JSONAssembler.h"
#import "TDMiniCSSAssembler.h"
#import "TDGenericAssembler.h"
#import "NSArray+TDParseKitAdditions.h"
#import "TDSyntaxHighlighter.h"
#import "TDJavaScriptParser.h"
#import "TDNSPredicateEvaluator.h"
#import <OCMock/OCMock.h>

@protocol TDMockAssember
- (void)workOnFoo:(PKAssembly *)a;
- (void)workOnBaz:(PKAssembly *)a;
- (void)workOnStart:(PKAssembly *)a;
- (void)workOnStart:(PKAssembly *)a;
- (void)workOn_Start:(PKAssembly *)a;
@end

@interface TDParserFactory ()
- (TDSequence *)parserFromExpression:(NSString *)s;
@property (retain) TDCollectionParser *expressionParser;
@end

@implementation DebugAppDelegate

- (void)dealloc {
    self.displayString = nil;
    [super dealloc];
}


- (void)doPlistParser {
    NSString *s = nil;
    TDTokenAssembly *a = nil;
    PKAssembly *res = nil;
    TDPlistParser *p = nil;
    
    p = [[[TDPlistParser alloc] init] autorelease];
    
    s = @"{"
    @"    0 = 0;"
    @"    dictKey =     {"
    @"        bar = foo;"
    @"    };"
    @"    47 = 0;"
    @"    IntegerKey = 1;"
    @"    47.7 = 0;"
    @"    <null> = <null>;"
    @"    ArrayKey =     ("
    @"                    \"one one\","
    @"                    two,"
    @"                    three"
    @"                    );"
    @"    \"Null Key\" = <null>;"
    @"    emptyDictKey =     {"
    @"    };"
    @"    StringKey = String;"
    @"    \"1.0\" = 1;"
    @"    YESKey = 1;"
    @"   \"NO Key\" = 0;"
    @"}";
    
    p.tokenizer.string = s;
    a = [TDTokenAssembly assemblyWithTokenizer:p.tokenizer];
    res = [p.dictParser completeMatchFor:a];
    
    id attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                [NSColor whiteColor], NSForegroundColorAttributeName,
                [NSFont fontWithName:@"Monaco" size:12.], NSFontAttributeName,
                nil];
    id dict = [res pop];
    
    p.tokenizer.string = [[[dict description] copy] autorelease];
    a = [TDTokenAssembly assemblyWithTokenizer:p.tokenizer];
    res = [p.dictParser bestMatchFor:a];
    dict = [res pop];

    p.tokenizer.string = nil; // prevent retain cycle leak
    s = [[[dict description] copy] autorelease];
    
    self.displayString = [[[NSAttributedString alloc] initWithString:s attributes:attrs] autorelease];
}


- (void)doHtmlSyntaxHighlighter {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"nyt" ofType:@"html"];
    NSString *s = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    //NSString *s = @"ア";
    
    TDHtmlSyntaxHighlighter *highlighter = [[TDHtmlSyntaxHighlighter alloc] initWithAttributesForDarkBackground:YES];
    NSAttributedString *o = [highlighter attributedStringForString:s];
    //NSLog(@"o: %@", [o string]);
    self.displayString = o;
    [highlighter release];    
}


- (void)doJsonParser {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"yahoo" ofType:@"json"];
    NSString *s = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    TDJsonParser *p = [[[TDJsonParser alloc] init] autorelease];
//    TDFastJsonParser *p = [[[TDFastJsonParser alloc] init] autorelease];
    
    id result = nil;
    
    @try {
        result = [p parse:s];
    } @catch (NSException *e) {
        NSLog(@"\n\n\nexception:\n\n %@", [e reason]);
    }
    NSLog(@"result %@", result);
}


- (void)doEBNFParser {
    //NSString *s = @"foo (bar|baz)*;";
    NSString *s = @"$baz = bar; ($baz|foo)*;";
    //NSString *s = @"foo;";
    EBNFParser *p = [[[EBNFParser alloc] init] autorelease];
    
    //    PKAssembly *a = [p bestMatchFor:[TDTokenAssembly assemblyWithString:s]];
    //    NSLog(@"a: %@", a);
    //    NSLog(@"a.target: %@", a.target);
    
    TDParser *res = [p parse:s];
    //    NSLog(@"res: %@", res);
    //    NSLog(@"res: %@", res.string);
    //    NSLog(@"res.subparsers: %@", res.subparsers);
    //    NSLog(@"res.subparsers 0: %@", [[res.subparsers objectAtIndex:0] string]);
    //    NSLog(@"res.subparsers 1: %@", [[res.subparsers objectAtIndex:1] string]);
    
    s = @"bar foo bar foo";
    PKAssembly *a = [res completeMatchFor:[TDTokenAssembly assemblyWithString:s]];
    NSLog(@"\n\na: %@\n\n", a);
}


- (void)doGrammarParser {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"json" ofType:@"grammar"];
    NSString *s = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
//    s = @"@start = openCurly closeCurly; openCurly = '{'; closeCurly = '}';";
//    s = @"@start = start*; start = 'bar';";
    
    TDParserFactory *factory = [TDParserFactory factory];
    
    JSONAssembler *ass = [[[JSONAssembler alloc] init] autorelease];
    TDParser *lp = [factory parserFromGrammar:s assembler:ass];
    
    path = [[NSBundle bundleForClass:[self class]] pathForResource:@"yahoo" ofType:@"json"];
    s = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
   
//    s = @"bar bar";
    TDTokenizer *t = [TDTokenizer tokenizerWithString:s];
    t.whitespaceState.reportsWhitespaceTokens = YES;
    TDTokenAssembly *a = [TDTokenAssembly assemblyWithTokenizer:t];
    a.preservesWhitespaceTokens = YES;
    //PKAssembly *res = 
    [lp completeMatchFor:a];
    
    self.displayString = ass.displayString;
}


- (void)doJavaScriptGrammarParser {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"javascript" ofType:@"grammar"];
    NSString *s = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    TDParser *p = [[TDParserFactory factory] parserFromGrammar:s assembler:nil];
    //TDParser *plus = [p parserNamed:@"plus"];
    
    s = @";";
    p.tokenizer.string = s;
    //PKAssembly *a = [TDTokenAssembly assemblyWithTokenizer:p.tokenizer];
    //PKAssembly *res = [p bestMatchFor:a];
    //    TDEqualObjects(@"[var, foo, =, 'bar', ;]var/foo/=/bar/;^", [res description]);
}


- (void)doProf {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"json_with_discards" ofType:@"grammar"];
    NSString *s = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    TDTokenizer *t = [TDTokenizer tokenizerWithString:s];
    TDToken *eof = [TDToken EOFToken];
    TDToken *tok = nil;
    NSDate *start = [NSDate date];
    while ((tok = [t nextToken]) != eof) ;
    CGFloat ms4tok = -([start timeIntervalSinceNow]);
    
    TDParserFactory *factory = [TDParserFactory factory];
    TDJsonParser *p = nil;
    
    p = [[[TDJsonParser alloc] initWithIntentToAssemble:NO] autorelease];
    
    //JSONAssembler *assembler = [[[JSONAssembler alloc] init] autorelease];
    start = [NSDate date];
    TDParser *lp = [factory parserFromGrammar:s assembler:p];
    CGFloat ms4grammar = -([start timeIntervalSinceNow]);
    
    path = [[NSBundle bundleForClass:[self class]] pathForResource:@"yahoo" ofType:@"json"];
    s = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    start = [NSDate date];
    PKAssembly *a = [TDTokenAssembly assemblyWithString:s];
    a = [lp completeMatchFor:a];
    CGFloat ms4json = -([start timeIntervalSinceNow]);

    p = [[TDJsonParser alloc] initWithIntentToAssemble:NO];
    start = [NSDate date];
    id res = [p parse:s];
    CGFloat ms4json2 = -([start timeIntervalSinceNow]);
    [p release];
    
    p = [[TDJsonParser alloc] initWithIntentToAssemble:YES];
    start = [NSDate date];
    res = [p parse:s];
    CGFloat ms4json3 = -([start timeIntervalSinceNow]);
    [p release];
    
    id fp = [[[TDFastJsonParser alloc] init] autorelease];
    start = [NSDate date];
    res = [fp parse:s];
    CGFloat ms4json4 = -([start timeIntervalSinceNow]);
    
    id attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                [NSFont fontWithName:@"Monaco" size:14.], NSFontAttributeName,
                [NSColor whiteColor], NSForegroundColorAttributeName,
                nil];

    s = [NSString stringWithFormat:@"tokenization: %f \n\ngrammar parse: %f sec\n\nlp json parse: %f sec\n\np json parse (not assembled): %f sec\n\np json parse (assembled): %f sec\n\nfast json parse (assembled): %f sec\n\n %f", ms4tok, ms4grammar, ms4json, ms4json2, ms4json3, ms4json4, (ms4json3/ms4json4)];
    self.displayString = [[[NSMutableAttributedString alloc] initWithString:s attributes:attrs] autorelease];
}


- (void)doTokenize {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"yahoo" ofType:@"json"];
    NSString *s = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    TDTokenizer *t = [TDTokenizer tokenizerWithString:s];
    TDToken *eof = [TDToken EOFToken];
    TDToken *tok = nil;

    NSDate *start = [NSDate date];    
    while ((tok = [t nextToken]) != eof) ;
    CGFloat secs = -([start timeIntervalSinceNow]);
    
    id attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                [NSFont fontWithName:@"Monaco" size:14.], NSFontAttributeName,
                [NSColor whiteColor], NSForegroundColorAttributeName,
                nil];

    s = [NSString stringWithFormat:@"tokenize: %f", secs];
    self.displayString = [[[NSMutableAttributedString alloc] initWithString:s attributes:attrs] autorelease];
}


- (void)doSimpleCSS {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"mini_css" ofType:@"grammar"];
    NSString *s = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    TDParserFactory *factory = [TDParserFactory factory];
    
    TDMiniCSSAssembler *assembler = [[[TDMiniCSSAssembler alloc] init] autorelease];
    TDParser *lp = [factory parserFromGrammar:s assembler:assembler];
    s = @"foo { color:rgb(111.0, 99.0, 255.0); }";
    PKAssembly *a = [TDTokenAssembly assemblyWithString:s];
    a = [lp completeMatchFor:a];
    
}


- (void)doSimpleCSS2 {
    TDParserFactory *factory = [TDParserFactory factory];

    // create CSS parser
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"mini_css" ofType:@"grammar"];
    NSString *grammarString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    TDMiniCSSAssembler *cssAssembler = [[[TDMiniCSSAssembler alloc] init] autorelease];
    TDParser *cssParser = [factory parserFromGrammar:grammarString assembler:cssAssembler];
    
    // parse CSS
    path = [[NSBundle bundleForClass:[self class]] pathForResource:@"json" ofType:@"css"];
    NSString *s = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    PKAssembly *a = [TDTokenAssembly assemblyWithString:s];
    a = [cssParser bestMatchFor:a];
    
    // get attributes from css
    id attrs = cssAssembler.attributes;
    
    // create JSON Parser
    path = [[NSBundle bundleForClass:[self class]] pathForResource:@"json" ofType:@"grammar"];
    grammarString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    TDGenericAssembler *genericAssembler = [[[TDGenericAssembler alloc] init] autorelease];

    // give it the attrs from CSS
    genericAssembler.attributes = attrs;
    TDParser *jsonParser = [factory parserFromGrammar:grammarString assembler:genericAssembler];
    
    // parse JSON
    path = [[NSBundle bundleForClass:[self class]] pathForResource:@"yahoo" ofType:@"json"];
    s = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];

    // take care to preseve the whitespace in the JSON
    TDTokenizer *t = [TDTokenizer tokenizerWithString:s];
    t.whitespaceState.reportsWhitespaceTokens = YES;
    TDTokenAssembly *a1 = [TDTokenAssembly assemblyWithTokenizer:t];
    a1.preservesWhitespaceTokens = YES;
    [jsonParser completeMatchFor:a1];
    
    self.displayString = genericAssembler.displayString;
}


- (void)doJSONHighlighting {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"yahoo" ofType:@"json"];
    NSString *s = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    TDSyntaxHighlighter *shc = [[[TDSyntaxHighlighter alloc] init] autorelease];
    self.displayString = [shc highlightedStringForString:s ofGrammar:@"json"];
}


- (void)doCSSHighlighting {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"example" ofType:@"css"];
    NSString *s = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    TDSyntaxHighlighter *shc = [[[TDSyntaxHighlighter alloc] init] autorelease];
    self.displayString = [shc highlightedStringForString:s ofGrammar:@"css"];
}


- (void)doHTMLHighlighting {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"example" ofType:@"html"];
    NSString *s = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    TDSyntaxHighlighter *shc = [[[TDSyntaxHighlighter alloc] init] autorelease];
    self.displayString = [shc highlightedStringForString:s ofGrammar:@"html"];
}


- (void)doMultiLineComment {
    NSString *s = @"/* foo */ ";
    TDTokenizer *t = [TDTokenizer tokenizerWithString:s];
    t.commentState.reportsCommentTokens = YES;
    //TDToken *tok = 
    [t nextToken];
}


- (void)doRubyHashParser {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"rubyhash" ofType:@"grammar"];
    NSString *s = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    TDParser *lp = [[TDParserFactory factory] parserFromGrammar:s assembler:nil];
    
    s = @"{\"brand\"=>{\"name\"=>\"something\","
    @"\"logo\"=>#<File:/var/folders/RK/RK1vsZigGhijmL6ObznDJk+++TI/-Tmp-/CGI66145-4>,"
    @"\"summary\"=>\"wee\", \"content\"=>\"woopy doo\"}, \"commit\"=>\"Save\","
    @"\"authenticity_token\"=>\"43a94d60304a7fb13a4ff61a5960461ce714e92b\","
    @"\"action\"=>\"create\", \"controller\"=>\"admin/brands\"}";
    
    NSLog(@"%@", [lp parse:s]);
}



- (void)doFactory {
//    id mock = [OCMockObject mockForProtocol:@protocol(TDMockAssember)];
//    TDParserFactory *factory = [TDParserFactory factory];
//    NSString *s = nil;
//    s = @"@start = foo|baz; foo (workOnFooAssembly:) = 'bar'; baz (workOnBazAssembly:) = 'bat'";
//    factory.assemblerSettingBehavior = TDParserFactoryAssemblerSettingBehaviorOnExplicit;
//    TDParser *lp = [factory parserFromGrammar:s assembler:mock];
//    
////    [[mock expect] workOnBazAssembly:OCMOCK_ANY];
////    NSString *s = @"bar bat";
////    a = [TDTokenAssembly assemblyWithString:s];
////    res = [lp completeMatchFor:a];
////    TDEqualObjects(@"[bar, bat]bar/bat^", [res description]);
////    [mock verify];
    
//    NSString *g = @"@delimitState = '$'; @delimitedString = '$' '%' nil; @start = DelimitedString('$', '%');";
//    TDParser *lp = [[TDParserFactory factory] parserFromGrammar:g assembler:nil];
//
//    NSString *s = @"$foo%";
//    TDTokenizer *t = lp.tokenizer;
//    t.string = s;
//    PKAssembly *res = [lp bestMatchFor:[TDTokenAssembly assemblyWithTokenizer:t]];
    
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"xpath1_0" ofType:@"grammar"];
    NSString *g = [NSString stringWithContentsOfFile:path];
    TDParser *p = [[TDParserFactory factory] parserFromGrammar:g assembler:nil];
    TDTokenizer *t = p.tokenizer;
    t.string = @"foo";
    PKAssembly *res = [p completeMatchFor:[TDTokenAssembly assemblyWithTokenizer:t]];
    
}


- (void)doParenStuff {
    NSString *s = @"-(ab+5)";
    TDTokenizer *t = [TDTokenizer tokenizerWithString:s];

    TDToken *tok = [t nextToken];
    
//    TDTrue(tok.isSymbol);
//    TDEqualObjects(tok.stringValue, @"-");    
//    TDEquals((CGFloat)0.0, tok.floatValue);
    
    tok = [t nextToken];
//    TDTrue(tok.isSymbol);
//    TDEqualObjects(tok.stringValue, @"(");
//    TDEquals((CGFloat)0.0, tok.floatValue);
}


- (void)doDelimitedString {
    NSString *s = @"<?= 'foo' ?>";

    TDTokenizer *t = [TDTokenizer tokenizerWithString:s];
    NSCharacterSet *cs = nil;
    
    [t setTokenizerState:t.delimitState from:'<' to:'<'];
    [t.delimitState addStartMarker:@"<?=" endMarker:@"?>" allowedCharacterSet:cs];
    
//    TDToken *tok = [t nextToken];
    
    //TDTrue(tok.isDelimitedString);
    
}


- (void)doJSParser {
    TDJavaScriptParser *jsp = [TDJavaScriptParser parser];
    NSString *s = @"for( ; true; true) {}";
    jsp.tokenizer.string = s;
//    TDTokenAssembly *a = [TDTokenAssembly assemblyWithTokenizer:jsp.tokenizer];
//    id res = [jsp bestMatchFor:a];
    //TDEqualObjects([res description], @"['foo']'foo'^");
    
    //TDEqualObjects([res description], @"[for, (, ;, true, ;, true, ), {, }]for/(/;/true/;/true/)/{/}^");
}


- (void)doNSPredicateEvaluator {
    TDNSPredicateEvaluator *eval = [[[TDNSPredicateEvaluator alloc] initWithKeyPathResolver:nil] autorelease];
}


- (void)doXMLParser {
	NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"xml" ofType:@"grammar"];
	NSString *g = [NSString stringWithContentsOfFile:path];
    TDParser *p = [[TDParserFactory factory] parserFromGrammar:g assembler:self];
    TDTokenizer *t = p.tokenizer;	
}




- (IBAction)run:(id)sender {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
//    [self doPlistParser];
//    [self doHtmlSyntaxHighlighter];
//    [self doJsonParser];
//    [self doRubyHashParser];

//    [self doJSParser];
    
//    [self doProf];

    //[self doJavaScriptGrammarParser];
    
    //    [self doTokenize];
//    [self doGrammarParser];
//    [self doSimpleCSS];
//    [self doSimpleCSS2];
//    [self doParenStuff];
    
//    [self doJSONHighlighting];
//    [self doCSSHighlighting];
//    [self doHTMLHighlighting];
    
//    [self doMultiLineComment];
//    [self doDelimitedString];
    
    [self doFactory];
    
//	[self doXMLParser];
//    [self doNSPredicateEvaluator];
    
    [pool drain];
}

@synthesize displayString;
@end
