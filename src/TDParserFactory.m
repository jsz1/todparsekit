//
//  TDParserFactory.m
//  TDParseKit
//
//  Created by Todd Ditchendorf on 12/12/08.
//  Copyright 2008 Todd Ditchendorf All rights reserved.
//

#import "TDParserFactory.h"
#import <ParseKit/ParseKit.h>
#import "NSString+TDParseKitAdditions.h"
#import "NSArray+TDParseKitAdditions.h"

@interface PKParser (TDParserFactoryAdditionsFriend)
- (void)setTokenizer:(TDTokenizer *)t;
@end

@interface PKCollectionParser ()
@property (nonatomic, readwrite, retain) NSMutableArray *subparsers;
@end

@interface PKRepetition ()
@property (nonatomic, readwrite, retain) PKParser *subparser;
@end

@interface TDPattern ()
@property (nonatomic, assign) TDTokenType tokenType;
@end

void TDReleaseSubparserTree(PKParser *p) {
    if ([p isKindOfClass:[PKCollectionParser class]]) {
        PKCollectionParser *c = (PKCollectionParser *)p;
        NSArray *subs = c.subparsers;
        if (subs) {
            [subs retain];
            c.subparsers = nil;
            for (PKParser *s in subs) {
                TDReleaseSubparserTree(s);
            }
            [subs release];
        }
    } else if ([p isMemberOfClass:[PKRepetition class]]) {
        PKRepetition *r = (PKRepetition *)p;
		PKParser *sub = r.subparser;
        if (sub) {
            [sub retain];
            r.subparser = nil;
            TDReleaseSubparserTree(sub);
            [sub release];
        }
    }
}

@interface TDParserFactory ()
- (TDTokenizer *)tokenizerForParsingGrammar;
- (BOOL)isAllWhitespace:(NSArray *)toks;
- (id)parserTokensTableFromParsingStatementsInString:(NSString *)s;
- (void)gatherParserClassNamesFromTokens;
- (NSString *)parserClassNameFromTokenArray:(NSArray *)toks;

- (TDTokenizer *)tokenizerFromGrammarSettings;
- (BOOL)boolForTokenForKey:(NSString *)key;
- (void)setTokenizerState:(TDTokenizerState *)state onTokenizer:(TDTokenizer *)t forTokensForKey:(NSString *)key;
- (void)setFallbackStateOn:(TDTokenizerState *)state withTokenizer:(TDTokenizer *)t forTokensForKey:(NSString *)key;

- (id)expandParser:(PKParser *)p fromTokenArray:(NSArray *)toks;
- (PKParser *)expandedParserForName:(NSString *)parserName;
- (void)setAssemblerForParser:(PKParser *)p;
- (NSArray *)tokens:(NSArray *)toks byRemovingTokensOfType:(TDTokenType)tt;
- (NSString *)defaultAssemblerSelectorNameForParserName:(NSString *)parserName;

// this is only for unit tests? can it go away?
- (PKSequence *)parserFromExpression:(NSString *)s;

- (PKAlternation *)zeroOrOne:(PKParser *)p;
- (PKSequence *)oneOrMore:(PKParser *)p;
    
- (void)workOnStatement:(PKAssembly *)a;
- (void)workOnCallback:(PKAssembly *)a;
- (void)workOnExpression:(PKAssembly *)a;
- (void)workOnAnd:(PKAssembly *)a;
- (void)workOnIntersection:(PKAssembly *)a;    
- (void)workOnExclusion:(PKAssembly *)a;
- (void)workOnPatternOptions:(PKAssembly *)a;
- (void)workOnPattern:(PKAssembly *)a;
- (void)workOnLiteral:(PKAssembly *)a;
- (void)workOnVariable:(PKAssembly *)a;
- (void)workOnConstant:(PKAssembly *)a;
- (void)workOnDelimitedString:(PKAssembly *)a;
- (void)workOnNum:(PKAssembly *)a;
- (void)workOnStar:(PKAssembly *)a;
- (void)workOnPlus:(PKAssembly *)a;
- (void)workOnQuestion:(PKAssembly *)a;
- (void)workOnPhraseCardinality:(PKAssembly *)a;
- (void)workOnCardinality:(PKAssembly *)a;
- (void)workOnOr:(PKAssembly *)a;

@property (nonatomic, assign) id assembler;
@property (nonatomic, retain) NSMutableDictionary *parserTokensTable;
@property (nonatomic, retain) NSMutableDictionary *parserClassTable;
@property (nonatomic, retain) NSMutableDictionary *selectorTable;
@property (nonatomic, retain) TDToken *equals;
@property (nonatomic, retain) TDToken *curly;
@property (nonatomic, retain) TDToken *paren;
@property (nonatomic, retain) TDToken *caret;
@property (nonatomic, retain) PKCollectionParser *statementParser;
@property (nonatomic, retain) PKCollectionParser *declarationParser;
@property (nonatomic, retain) PKCollectionParser *callbackParser;
@property (nonatomic, retain) PKCollectionParser *selectorParser;
@property (nonatomic, retain) PKCollectionParser *exprParser;
@property (nonatomic, retain) PKCollectionParser *termParser;
@property (nonatomic, retain) PKCollectionParser *orTermParser;
@property (nonatomic, retain) PKCollectionParser *factorParser;
@property (nonatomic, retain) PKCollectionParser *nextFactorParser;
@property (nonatomic, retain) PKCollectionParser *phraseParser;
@property (nonatomic, retain) PKCollectionParser *phraseStarParser;
@property (nonatomic, retain) PKCollectionParser *phrasePlusParser;
@property (nonatomic, retain) PKCollectionParser *phraseQuestionParser;
@property (nonatomic, retain) PKCollectionParser *phraseCardinalityParser;
@property (nonatomic, retain) PKCollectionParser *cardinalityParser;
@property (nonatomic, retain) PKCollectionParser *primaryExprParser;
@property (nonatomic, retain) PKCollectionParser *predicateParser;
@property (nonatomic, retain) PKCollectionParser *intersectionParser;
@property (nonatomic, retain) PKCollectionParser *exclusionParser;
@property (nonatomic, retain) PKCollectionParser *atomicValueParser;
@property (nonatomic, retain) PKCollectionParser *discardParser;
@property (nonatomic, retain) PKCollectionParser *patternParser;
@property (nonatomic, retain) PKCollectionParser *delimitedStringParser;
@property (nonatomic, retain) PKParser *literalParser;
@property (nonatomic, retain) PKParser *variableParser;
@property (nonatomic, retain) PKParser *constantParser;

@property (nonatomic, retain, readonly) PKParser *whitespaceParser;
@property (nonatomic, retain, readonly) PKCollectionParser *optionalWhitespaceParser;
@end

@implementation TDParserFactory

+ (id)factory {
    return [[[TDParserFactory alloc] init] autorelease];
}


- (id)init {
    if (self = [super init]) {
        self.equals  = [TDToken tokenWithTokenType:TDTokenTypeSymbol stringValue:@"=" floatValue:0.0];
        self.curly   = [TDToken tokenWithTokenType:TDTokenTypeSymbol stringValue:@"{" floatValue:0.0];
        self.paren   = [TDToken tokenWithTokenType:TDTokenTypeSymbol stringValue:@"(" floatValue:0.0];
        self.caret   = [TDToken tokenWithTokenType:TDTokenTypeSymbol stringValue:@"^" floatValue:0.0];
        self.assemblerSettingBehavior = TDParserFactoryAssemblerSettingBehaviorOnAll;
    }
    return self;
}


- (void)dealloc {
    assembler = nil; // appease clang static analyzer
    
    TDReleaseSubparserTree(statementParser);
    TDReleaseSubparserTree(exprParser);
    
    self.parserTokensTable = nil;
    self.parserClassTable = nil;
    self.selectorTable = nil;
    self.equals = nil;
    self.curly = nil;
    self.paren = nil;
    self.caret = nil;
    self.statementParser = nil;
    self.declarationParser = nil;
    self.callbackParser = nil;
    self.selectorParser = nil;
    self.exprParser = nil;
    self.termParser = nil;
    self.orTermParser = nil;
    self.factorParser = nil;
    self.nextFactorParser = nil;
    self.phraseParser = nil;
    self.phraseStarParser = nil;
    self.phrasePlusParser = nil;
    self.phraseQuestionParser = nil;
    self.phraseCardinalityParser = nil;
    self.cardinalityParser = nil;
    self.primaryExprParser = nil;
    self.predicateParser = nil;
    self.intersectionParser = nil;
    self.exclusionParser = nil;
    self.atomicValueParser = nil;
    self.discardParser = nil;
    self.patternParser = nil;
    self.delimitedStringParser = nil;
    self.literalParser = nil;
    self.variableParser = nil;
    self.constantParser = nil;
    [super dealloc];
}


- (PKParser *)parserFromGrammar:(NSString *)s assembler:(id)a {
    self.assembler = a;
    self.selectorTable = [NSMutableDictionary dictionary];
    self.parserClassTable = [NSMutableDictionary dictionary];
    self.parserTokensTable = [self parserTokensTableFromParsingStatementsInString:s];

    TDTokenizer *t = [self tokenizerFromGrammarSettings];

    [self gatherParserClassNamesFromTokens];
    
    PKParser *start = [self expandedParserForName:@"@start"];
    
    assembler = nil;
    self.selectorTable = nil;
    self.parserClassTable = nil;
    self.parserTokensTable = nil;
    
    if (start && [start isKindOfClass:[PKParser class]]) {
        start.tokenizer = t;
        return start;
    } else {
        [NSException raise:@"GrammarException" format:@"The provided language grammar was invalid"];
        return nil;
    }
}


- (TDTokenizer *)tokenizerForParsingGrammar {
    TDTokenizer *t = [TDTokenizer tokenizer];
    
    t.whitespaceState.reportsWhitespaceTokens = YES;
    
    // customize tokenizer to find tokenizer customization directives
    [t setTokenizerState:t.wordState from:'@' to:'@'];
    
    // add support for tokenizer directives like @commentState.fallbackState
    [t.wordState setWordChars:YES from:'.' to:'.'];
    [t.wordState setWordChars:NO from:'-' to:'-'];
    
    // setup comments
    [t setTokenizerState:t.commentState from:'/' to:'/'];
    [t.commentState addSingleLineStartMarker:@"//"];
    [t.commentState addMultiLineStartMarker:@"/*" endMarker:@"*/"];
    
    // comment state should fallback to delimit state to match regex delimited strings
    t.commentState.fallbackState = t.delimitState;
    
    // regex delimited strings
    [t.delimitState addStartMarker:@"/" endMarker:@"/" allowedCharacterSet:[[NSCharacterSet whitespaceCharacterSet] invertedSet]];
    
    return t;
}


- (BOOL)isAllWhitespace:(NSArray *)toks {
    for (TDToken *tok in toks) {
        if (TDTokenTypeWhitespace != tok.tokenType) {
            return NO;
        }
    }
    return YES;
}


- (id)parserTokensTableFromParsingStatementsInString:(NSString *)s {
    TDTokenizer *t = [self tokenizerForParsingGrammar];
    t.string = s;
    
    TDTokenArraySource *src = [[TDTokenArraySource alloc] initWithTokenizer:t delimiter:@";"];
    id target = [NSMutableDictionary dictionary]; // setup the variable lookup table
    
    while ([src hasMore]) {
        NSArray *toks = [src nextTokenArray];
        if (![self isAllWhitespace:toks]) {
            TDTokenAssembly *a = [TDTokenAssembly assemblyWithTokenArray:toks];
            //a.preservesWhitespaceTokens = YES;
            a.target = target;
            PKAssembly *res = [self.statementParser completeMatchFor:a];
            target = res.target;
        }
    }

    [src release];
    
    return target;
}


- (void)gatherParserClassNamesFromTokens {
    isGatheringClasses = YES;
    // discover the actual parser class types
    for (NSString *parserName in parserTokensTable) {
        NSString *className = [self parserClassNameFromTokenArray:[parserTokensTable objectForKey:parserName]];
        NSAssert1(className.length, @"Could not build ClassName from token array for parserName: %@", parserName);
        [parserClassTable setObject:className forKey:parserName];
    }
    isGatheringClasses = NO;
}


- (NSString *)parserClassNameFromTokenArray:(NSArray *)toks {
    PKAssembly *a = [TDTokenAssembly assemblyWithTokenArray:toks];
    a.target = parserTokensTable;
    a = [self.exprParser completeMatchFor:a];
    PKParser *res = [a pop];
    a.target = nil;
    return [res className];
}


- (TDTokenizer *)tokenizerFromGrammarSettings {
    TDTokenizer *t = [TDTokenizer tokenizer];
    [t.commentState removeSingleLineStartMarker:@"//"];
    [t.commentState removeMultiLineStartMarker:@"/*"];

    t.whitespaceState.reportsWhitespaceTokens = [self boolForTokenForKey:@"@reportsWhitespaceTokens"];
    t.commentState.reportsCommentTokens = [self boolForTokenForKey:@"@reportsCommentTokens"];
	t.commentState.balancesEOFTerminatedComments = [self boolForTokenForKey:@"balancesEOFTerminatedComments"];
	t.quoteState.balancesEOFTerminatedQuotes = [self boolForTokenForKey:@"@balancesEOFTerminatedQuotes"];
	t.delimitState.balancesEOFTerminatedStrings = [self boolForTokenForKey:@"@balancesEOFTerminatedStrings"];
	t.numberState.allowsTrailingDot = [self boolForTokenForKey:@"@allowsTrailingDot"];
    
    [self setTokenizerState:t.wordState onTokenizer:t forTokensForKey:@"@wordState"];
    [self setTokenizerState:t.numberState onTokenizer:t forTokensForKey:@"@numberState"];
    [self setTokenizerState:t.quoteState onTokenizer:t forTokensForKey:@"@quoteState"];
    [self setTokenizerState:t.delimitState onTokenizer:t forTokensForKey:@"@delimitState"];
    [self setTokenizerState:t.symbolState onTokenizer:t forTokensForKey:@"@symbolState"];
    [self setTokenizerState:t.commentState onTokenizer:t forTokensForKey:@"@commentState"];
    [self setTokenizerState:t.whitespaceState onTokenizer:t forTokensForKey:@"@whitespaceState"];
    
    [self setFallbackStateOn:t.commentState withTokenizer:t forTokensForKey:@"@commentState.fallbackState"];
    [self setFallbackStateOn:t.delimitState withTokenizer:t forTokensForKey:@"@delimitState.fallbackState"];
    
    NSArray *toks = nil;
    
    // muli-char symbols
    toks = [NSArray arrayWithArray:[parserTokensTable objectForKey:@"@symbol"]];
    toks = [toks arrayByAddingObjectsFromArray:[parserTokensTable objectForKey:@"@symbols"]];
    [parserTokensTable removeObjectForKey:@"@symbol"];
    [parserTokensTable removeObjectForKey:@"@symbols"];
    for (TDToken *tok in toks) {
        if (tok.isQuotedString) {
            [t.symbolState add:[tok.stringValue stringByTrimmingQuotes]];
        }
    }
    
    // wordChars
    toks = [NSArray arrayWithArray:[parserTokensTable objectForKey:@"@wordChar"]];
    toks = [toks arrayByAddingObjectsFromArray:[parserTokensTable objectForKey:@"@wordChars"]];
    [parserTokensTable removeObjectForKey:@"@wordChar"];
    [parserTokensTable removeObjectForKey:@"@wordChars"];
    for (TDToken *tok in toks) {
        if (tok.isQuotedString) {
			NSString *s = [tok.stringValue stringByTrimmingQuotes];
			if (s.length) {
				NSInteger c = [s characterAtIndex:0];
				[t.wordState setWordChars:YES from:c to:c];
			}
        }
    }
    
    // whitespaceChars
    toks = [NSArray arrayWithArray:[parserTokensTable objectForKey:@"@whitespaceChar"]];
    toks = [toks arrayByAddingObjectsFromArray:[parserTokensTable objectForKey:@"@whitespaceChars"]];
    [parserTokensTable removeObjectForKey:@"@whitespaceChar"];
    [parserTokensTable removeObjectForKey:@"@whitespaceChars"];
    for (TDToken *tok in toks) {
        if (tok.isQuotedString) {
			NSString *s = [tok.stringValue stringByTrimmingQuotes];
			if (s.length) {
                NSInteger c = 0;
                if ([s hasPrefix:@"#x"]) {
                    c = [s integerValue];
                } else {
                    c = [s characterAtIndex:0];
                }
                [t.whitespaceState setWhitespaceChars:YES from:c to:c];
			}
        }
    }
    
    // single-line comments
    toks = [NSArray arrayWithArray:[parserTokensTable objectForKey:@"@singleLineComment"]];
    toks = [toks arrayByAddingObjectsFromArray:[parserTokensTable objectForKey:@"@singleLineComments"]];
    [parserTokensTable removeObjectForKey:@"@singleLineComment"];
    [parserTokensTable removeObjectForKey:@"@singleLineComments"];
    for (TDToken *tok in toks) {
        if (tok.isQuotedString) {
            NSString *s = [tok.stringValue stringByTrimmingQuotes];
            [t.commentState addSingleLineStartMarker:s];
        }
    }
    
    // multi-line comments
    toks = [NSArray arrayWithArray:[parserTokensTable objectForKey:@"@multiLineComment"]];
    toks = [toks arrayByAddingObjectsFromArray:[parserTokensTable objectForKey:@"@multiLineComments"]];
    NSAssert(0 == toks.count % 2, @"@multiLineComments must be specified as quoted strings in multiples of 2");
    [parserTokensTable removeObjectForKey:@"@multiLineComment"];
    [parserTokensTable removeObjectForKey:@"@multiLineComments"];
    if (toks.count > 1) {
        NSInteger i = 0;
        for ( ; i < toks.count - 1; i++) {
            TDToken *startTok = [toks objectAtIndex:i];
            TDToken *endTok = [toks objectAtIndex:++i];
            if (startTok.isQuotedString && endTok.isQuotedString) {
                NSString *start = [startTok.stringValue stringByTrimmingQuotes];
                NSString *end = [endTok.stringValue stringByTrimmingQuotes];
                [t.commentState addMultiLineStartMarker:start endMarker:end];
            }
        }
    }

    // delimited strings
    toks = [NSArray arrayWithArray:[parserTokensTable objectForKey:@"@delimitedString"]];
    toks = [toks arrayByAddingObjectsFromArray:[parserTokensTable objectForKey:@"@delimitedStrings"]];
    NSAssert(0 == toks.count % 3, @"@delimitedString must be specified as quoted strings in multiples of 3");
    [parserTokensTable removeObjectForKey:@"@delimitedString"];
    [parserTokensTable removeObjectForKey:@"@delimitedStrings"];
    if (toks.count > 1) {
        NSInteger i = 0;
        for ( ; i < toks.count - 2; i++) {
            TDToken *startTok = [toks objectAtIndex:i];
            TDToken *endTok = [toks objectAtIndex:++i];
            TDToken *charSetTok = [toks objectAtIndex:++i];
            if (startTok.isQuotedString && endTok.isQuotedString) {
                NSString *start = [startTok.stringValue stringByTrimmingQuotes];
                NSString *end = [endTok.stringValue stringByTrimmingQuotes];
                NSCharacterSet *charSet = nil;
                if (charSetTok.isQuotedString) {
                    charSet = [NSCharacterSet characterSetWithCharactersInString:[charSetTok.stringValue stringByTrimmingQuotes]];
                }
                [t.delimitState addStartMarker:start endMarker:end allowedCharacterSet:charSet];
            }
        }
    }
    
    return t;
}


- (BOOL)boolForTokenForKey:(NSString *)key {
    BOOL result = NO;
    NSArray *toks = [parserTokensTable objectForKey:key];
    if (toks.count) {
        TDToken *tok = [toks objectAtIndex:0];
        if (tok.isWord && [tok.stringValue isEqualToString:@"YES"]) {
            result = YES;
        }
    }
    [parserTokensTable removeObjectForKey:key];
    return result;
}


- (void)setTokenizerState:(TDTokenizerState *)state onTokenizer:(TDTokenizer *)t forTokensForKey:(NSString *)key {
    NSArray *toks = [parserTokensTable objectForKey:key];
    for (TDToken *tok in toks) {
        if (tok.isQuotedString) {
            NSString *s = [tok.stringValue stringByTrimmingQuotes];
            if (1 == s.length) {
                NSInteger c = [s characterAtIndex:0];
                [t setTokenizerState:state from:c to:c];
            }
        }
    }
    [parserTokensTable removeObjectForKey:key];
}


- (void)setFallbackStateOn:(TDTokenizerState *)state withTokenizer:(TDTokenizer *)t forTokensForKey:(NSString *)key {
    NSArray *toks = [parserTokensTable objectForKey:key];
    if (toks.count) {
        TDToken *tok = [toks objectAtIndex:0];
        if (tok.isWord) {
            TDTokenizerState *fallbackState = [t valueForKey:tok.stringValue];
            if (state != fallbackState) {
                state.fallbackState = fallbackState;
            }
        }
    }
    [parserTokensTable removeObjectForKey:key];
}


- (PKParser *)expandedParserForName:(NSString *)parserName {
    id obj = [parserTokensTable objectForKey:parserName];
    if ([obj isKindOfClass:[PKParser class]]) {
        return obj;
    } else {
        // prevent infinite loops by creating a parser of the correct type first, and putting it in the table
        NSString *className = [parserClassTable objectForKey:parserName];

        PKParser *p = [[NSClassFromString(className) alloc] init];
        [parserTokensTable setObject:p forKey:parserName];
        [p release];
        
        p = [self expandParser:p fromTokenArray:obj];
        p.name = parserName;

        [self setAssemblerForParser:p];

        [parserTokensTable setObject:p forKey:parserName];
        return p;
    }
}


- (void)setAssemblerForParser:(PKParser *)p {
    NSString *parserName = p.name;
    NSString *selName = [selectorTable objectForKey:parserName];

    BOOL setOnAll = (assemblerSettingBehavior & TDParserFactoryAssemblerSettingBehaviorOnAll);

    if (setOnAll) {
        // continue
    } else {
        BOOL setOnExplicit = (assemblerSettingBehavior & TDParserFactoryAssemblerSettingBehaviorOnExplicit);
        if (setOnExplicit && selName) {
            // continue
        } else {
            BOOL isTerminal = [p isKindOfClass:[PKTerminal class]];
            if (!isTerminal && !setOnExplicit) return;
            
            BOOL setOnTerminals = (assemblerSettingBehavior & TDParserFactoryAssemblerSettingBehaviorOnTerminals);
            if (setOnTerminals && isTerminal) {
                // continue
            } else {
                return;
            }
        }
    }
    
    if (!selName) {
        selName = [self defaultAssemblerSelectorNameForParserName:parserName];
    }
                
    SEL sel = NSSelectorFromString(selName);
    if (assembler && [assembler respondsToSelector:sel]) {
        [p setAssembler:assembler selector:sel];
    }
}


- (id)expandParser:(PKParser *)p fromTokenArray:(NSArray *)toks {	
    PKAssembly *a = [TDTokenAssembly assemblyWithTokenArray:toks];
    a.target = parserTokensTable;
    a = [self.exprParser completeMatchFor:a];
    PKParser *res = [a pop];
    if ([p isKindOfClass:[PKCollectionParser class]]) {
        PKCollectionParser *cp = (PKCollectionParser *)p;
        [cp add:res];
        return cp;
    } else {
        return res;
    }
}


// this is just a utility for unit-testing
- (PKSequence *)parserFromExpression:(NSString *)s {
    TDTokenizer *t = [self tokenizerForParsingGrammar];
    t.string = s;
    PKAssembly *a = [TDTokenAssembly assemblyWithTokenizer:t];
    a.target = [NSMutableDictionary dictionary]; // setup the variable lookup table
    a = [self.exprParser completeMatchFor:a];
    return [a pop];
}


- (PKAlternation *)zeroOrOne:(PKParser *)p {
    PKAlternation *a = [PKAlternation alternation];
    [a add:[PKEmpty empty]];
    [a add:p];
    return a;
}


- (PKSequence *)oneOrMore:(PKParser *)p {
    PKSequence *s = [PKSequence sequence];
    [s add:p];
    [s add:[PKRepetition repetitionWithSubparser:p]];
    return s;
}


// @start               = statement*;
// satement             = S* declaration S* '=' expr;
// callback             = S* '(' S* selector S* ')';
// selector             = Word ':';
// expr                 = S* term orTerm* S*;
// term                 = factor nextFactor*;
// orTerm               = S* '|' S* term;
// factor               = phrase | phraseStar | phrasePlus | phraseQuestion | phraseCardinality;
// nextFactor           = S factor;
// phrase               = primaryExpr predicate*;
// primaryExpr          = atomicValue | '(' expr ')';
// predicate            = S* (intersection | exclusion);
// intersection         = '&' S* primaryExpr;
// exclusion            = '-' S* primaryExpr;
// phraseStar           = phrase S* '*';
// phrasePlus           = phrase S* '+';
// phraseQuestion       = phrase S* '?';
// phraseCardinality    = phrase S* cardinality;
// cardinality          = '{' S* Num (S* ',' S* Num)? S* '}';
// atomicValue          =  discard? (pattern | literal | variable | constant | delimitedString);
// discard              = '^' S*;
// pattern              = DelimitedString('/', '/') (Word & /[imxsw]+/)?;
// delimitedString      = 'DelimitedString' S* '(' S* QuotedString (S* ',' QuotedString)? S* ')';
// literal              = QuotedString;
// variable             = LowercaseWord;
// constant             = UppercaseWord;


// satement             = S* declaration S* '=' expr;
- (PKCollectionParser *)statementParser {
    if (!statementParser) {
        self.statementParser = [PKSequence sequence];
        statementParser.name = @"statement";
        [statementParser add:self.optionalWhitespaceParser];
        
        PKTrack *tr = [PKTrack track];
        [tr add:self.declarationParser];
        [tr add:self.optionalWhitespaceParser];
        [tr add:[TDSymbol symbolWithString:@"="]];

        // accept any tokens in the parser expr the first time around. just gather tokens for later
        [tr add:[self oneOrMore:[PKAny any]]];
        
        [statementParser add:tr];
        [statementParser setAssembler:self selector:@selector(workOnStatement:)];
    }
    return statementParser;
}


// declaration          = Word callback?;
- (PKCollectionParser *)declarationParser {
    if (!declarationParser) {
        self.declarationParser = [PKSequence sequence];
        declarationParser.name = @"declaration";
        [declarationParser add:[TDWord word]];
        [declarationParser add:[self zeroOrOne:self.callbackParser]];
    }
    return declarationParser;
}


// callback             = S* '(' S* selector S* ')';
- (PKCollectionParser *)callbackParser {
    if (!callbackParser) {
        self.callbackParser = [PKSequence sequence];
        callbackParser.name = @"callback";
        [callbackParser add:self.optionalWhitespaceParser];
        
        PKTrack *tr = [PKTrack track];
        [tr add:[[TDSymbol symbolWithString:@"("] discard]];
        [tr add:self.optionalWhitespaceParser];
        [tr add:self.selectorParser];
        [tr add:self.optionalWhitespaceParser];
        [tr add:[[TDSymbol symbolWithString:@")"] discard]];
        
        [callbackParser add:tr];
        [callbackParser setAssembler:self selector:@selector(workOnCallback:)];
    }
    return callbackParser;
}


// selector             = Word ':';
- (PKCollectionParser *)selectorParser {
    if (!selectorParser) {
        self.selectorParser = [PKTrack track];
        selectorParser.name = @"selector";
        [selectorParser add:[TDLowercaseWord word]];
        [selectorParser add:[[TDSymbol symbolWithString:@":"] discard]];
    }
    return selectorParser;
}


// expr        = S* term orTerm* S*;
- (PKCollectionParser *)exprParser {
    if (!exprParser) {
        self.exprParser = [PKSequence sequence];
        exprParser.name = @"expr";
        [exprParser add:self.optionalWhitespaceParser];
        [exprParser add:self.termParser];
        [exprParser add:[PKRepetition repetitionWithSubparser:self.orTermParser]];
        [exprParser add:self.optionalWhitespaceParser];
        [exprParser setAssembler:self selector:@selector(workOnExpression:)];
    }
    return exprParser;
}


// term                = factor nextFactor*;
- (PKCollectionParser *)termParser {
    if (!termParser) {
        self.termParser = [PKSequence sequence];
        termParser.name = @"term";
        [termParser add:self.factorParser];
        [termParser add:[PKRepetition repetitionWithSubparser:self.nextFactorParser]];
        [termParser setAssembler:self selector:@selector(workOnAnd:)];
    }
    return termParser;
}


// orTerm               = S* '|' S* term;
- (PKCollectionParser *)orTermParser {
    if (!orTermParser) {
        self.orTermParser = [PKSequence sequence];
        orTermParser.name = @"orTerm";
        [orTermParser add:self.optionalWhitespaceParser];
        
        PKTrack *tr = [PKTrack track];
        [tr add:[TDSymbol symbolWithString:@"|"]]; // preserve as fence
        [tr add:self.optionalWhitespaceParser];
        [tr add:self.termParser];
        
        [orTermParser add:tr];
        [orTermParser setAssembler:self selector:@selector(workOnOr:)];
    }
    return orTermParser;
}


// factor               = phrase | phraseStar | phrasePlus | phraseQuestion | phraseCardinality;
- (PKCollectionParser *)factorParser {
    if (!factorParser) {
        self.factorParser = [PKAlternation alternation];
        factorParser.name = @"factor";
        [factorParser add:self.phraseParser];
        [factorParser add:self.phraseStarParser];
        [factorParser add:self.phrasePlusParser];
        [factorParser add:self.phraseQuestionParser];
        [factorParser add:self.phraseCardinalityParser];
    }
    return factorParser;
}


// nextFactor           = S factor;
- (PKCollectionParser *)nextFactorParser {
    if (!nextFactorParser) {
        self.nextFactorParser = [PKSequence sequence];
        nextFactorParser.name = @"nextFactor";
        [nextFactorParser add:self.whitespaceParser];

        PKAlternation *a = [PKAlternation alternation];
        [a add:self.phraseParser];
        [a add:self.phraseStarParser];
        [a add:self.phrasePlusParser];
        [a add:self.phraseQuestionParser];
        [a add:self.phraseCardinalityParser];

        [nextFactorParser add:a];
    }
    return nextFactorParser;
}


// phrase               = primaryExpr predicate*;
- (PKCollectionParser *)phraseParser {
    if (!phraseParser) {
        self.phraseParser = [PKSequence sequence];
        phraseParser.name = @"phrase";
        [phraseParser add:self.primaryExprParser];
        [phraseParser add:[PKRepetition repetitionWithSubparser:self.predicateParser]];
    }
    return phraseParser;
}


// primaryExpr          = atomicValue | '(' expr ')';
- (PKCollectionParser *)primaryExprParser {
    if (!primaryExprParser) {
        self.primaryExprParser = [PKAlternation alternation];
        primaryExprParser.name = @"primaryExpr";
        [primaryExprParser add:self.atomicValueParser];

        PKSequence *s = [PKSequence sequence];
        [s add:[TDSymbol symbolWithString:@"("]];
        [s add:self.exprParser];
        [s add:[[TDSymbol symbolWithString:@")"] discard]];
        
        [primaryExprParser add:s];
    }
    return primaryExprParser;
}


// predicate            = S* (intersection | exclusion);
- (PKCollectionParser *)predicateParser {
    if (!predicateParser) {
        self.predicateParser = [PKSequence sequence];
        predicateParser.name = @"predicate";
        [predicateParser add:self.optionalWhitespaceParser];

        PKAlternation *a = [PKAlternation alternation];
        [a add:self.intersectionParser];
        [a add:self.exclusionParser];

        [predicateParser add:a];
    }
    return predicateParser;
}


// intersection         = '&' S* primaryExpr;
- (PKCollectionParser *)intersectionParser {
    if (!intersectionParser) {
        self.intersectionParser = [PKTrack track];
        intersectionParser.name = @"intersection";
        
        PKTrack *tr = [PKTrack track];
        [tr add:[[TDSymbol symbolWithString:@"&"] discard]];
        [tr add:self.optionalWhitespaceParser];
        [tr add:self.primaryExprParser];
        
        [intersectionParser add:tr];
        [intersectionParser setAssembler:self selector:@selector(workOnIntersection:)];
    }
    return intersectionParser;
}


// exclusion            = '-' S* primaryExpr;
- (PKCollectionParser *)exclusionParser {
    if (!exclusionParser) {
        self.exclusionParser = [PKTrack track];
        exclusionParser.name = @"exclusion";

        PKTrack *tr = [PKTrack track];
        [tr add:[[TDSymbol symbolWithString:@"-"] discard]];
        [tr add:self.optionalWhitespaceParser];
        [tr add:self.primaryExprParser];
        
        [exclusionParser add:tr];
        [exclusionParser setAssembler:self selector:@selector(workOnExclusion:)];
    }
    return exclusionParser;
}


// phraseStar           = phrase S* '*';
- (PKCollectionParser *)phraseStarParser {
    if (!phraseStarParser) {
        self.phraseStarParser = [PKSequence sequence];
        phraseStarParser.name = @"phraseStar";
        [phraseStarParser add:self.phraseParser];
        [phraseStarParser add:self.optionalWhitespaceParser];
        [phraseStarParser add:[[TDSymbol symbolWithString:@"*"] discard]];
        [phraseStarParser setAssembler:self selector:@selector(workOnStar:)];
    }
    return phraseStarParser;
}


// phrasePlus           = phrase S* '+';
- (PKCollectionParser *)phrasePlusParser {
    if (!phrasePlusParser) {
        self.phrasePlusParser = [PKSequence sequence];
        phrasePlusParser.name = @"phrasePlus";
        [phrasePlusParser add:self.phraseParser];
        [phrasePlusParser add:self.optionalWhitespaceParser];
        [phrasePlusParser add:[[TDSymbol symbolWithString:@"+"] discard]];
        [phrasePlusParser setAssembler:self selector:@selector(workOnPlus:)];
    }
    return phrasePlusParser;
}


// phraseQuestion       = phrase S* '?';
- (PKCollectionParser *)phraseQuestionParser {
    if (!phraseQuestionParser) {
        self.phraseQuestionParser = [PKSequence sequence];
        phraseQuestionParser.name = @"phraseQuestion";
        [phraseQuestionParser add:self.phraseParser];
        [phraseQuestionParser add:self.optionalWhitespaceParser];
        [phraseQuestionParser add:[[TDSymbol symbolWithString:@"?"] discard]];
        [phraseQuestionParser setAssembler:self selector:@selector(workOnQuestion:)];
    }
    return phraseQuestionParser;
}


// phraseCardinality    = phrase S* cardinality;
- (PKCollectionParser *)phraseCardinalityParser {
    if (!phraseCardinalityParser) {
        self.phraseCardinalityParser = [PKSequence sequence];
        phraseCardinalityParser.name = @"phraseCardinality";
        [phraseCardinalityParser add:self.phraseParser];
        [phraseCardinalityParser add:self.optionalWhitespaceParser];
        [phraseCardinalityParser add:self.cardinalityParser];
        [phraseCardinalityParser setAssembler:self selector:@selector(workOnPhraseCardinality:)];
    }
    return phraseCardinalityParser;
}


// cardinality          = '{' S* Num (S* ',' S* Num)? S* '}';
- (PKCollectionParser *)cardinalityParser {
    if (!cardinalityParser) {
        self.cardinalityParser = [PKSequence sequence];
        cardinalityParser.name = @"cardinality";
        
        PKTrack *commaNum = [PKSequence sequence];
        [commaNum add:self.optionalWhitespaceParser];
        [commaNum add:[[TDSymbol symbolWithString:@","] discard]];
        [commaNum add:self.optionalWhitespaceParser];
        [commaNum add:[TDNum num]];
        
        PKTrack *tr = [PKTrack track];
        [tr add:[TDSymbol symbolWithString:@"{"]]; // serves as fence. dont discard
        [tr add:self.optionalWhitespaceParser];
        [tr add:[TDNum num]];
        [tr add:[self zeroOrOne:commaNum]];
        [tr add:self.optionalWhitespaceParser];
        [tr add:[[TDSymbol symbolWithString:@"}"] discard]];
        
        [cardinalityParser add:tr];
        [cardinalityParser setAssembler:self selector:@selector(workOnCardinality:)];
    }
    return cardinalityParser;
}


// atomicValue          =  discard? (pattern | literal | variable | constant | delimitedString);
- (PKCollectionParser *)atomicValueParser {
    if (!atomicValueParser) {
        self.atomicValueParser = [PKSequence sequence];
        atomicValueParser.name = @"atomicValue";

        [atomicValueParser add:[self zeroOrOne:self.discardParser]];
        
        PKAlternation *a = [PKAlternation alternation];
        [a add:self.patternParser];
        [a add:self.literalParser];
        [a add:self.variableParser];
        [a add:self.constantParser];
        [a add:self.delimitedStringParser];
        [atomicValueParser add:a];
    }
    return atomicValueParser;
}


// discard              = '^' S*;
- (PKCollectionParser *)discardParser {
    if (!discardParser) {
        self.discardParser = [PKSequence sequence];
        discardParser.name = @"discardParser";
        [discardParser add:[TDSymbol symbolWithString:@"^"]]; // preserve
        [discardParser add:self.optionalWhitespaceParser];
    }
    return discardParser;
}


// pattern              = DelimitedString('/', '/') (Word & /[imxsw]+/)?;
- (PKCollectionParser *)patternParser {
    if (!patternParser) {
        patternParser.name = @"pattern";
        self.patternParser = [PKSequence sequence];
        [patternParser add:[TDDelimitedString delimitedStringWithStartMarker:@"/" endMarker:@"/"]];
        
        PKParser *opts = [TDPattern patternWithString:@"[imxsw]+" options:TDPatternOptionsNone];
        PKIntersection *inter = [PKIntersection intersection];
        [inter add:[TDWord word]];
        [inter add:opts];
        [inter setAssembler:self selector:@selector(workOnPatternOptions:)];
        
        [patternParser add:[self zeroOrOne:inter]];
        [patternParser setAssembler:self selector:@selector(workOnPattern:)];
    }
    return patternParser;
}


// delimitedString      = 'DelimitedString' S* '(' S* QuotedString (S* ',' QuotedString)? S* ')';
- (PKCollectionParser *)delimitedStringParser {
    if (!delimitedStringParser) {
        self.delimitedStringParser = [PKTrack track];
        delimitedStringParser.name = @"delimitedString";
        
        PKSequence *secondArg = [PKSequence sequence];
        [secondArg add:self.optionalWhitespaceParser];
        
        PKTrack *tr = [PKTrack track];
        [tr add:[[TDSymbol symbolWithString:@","] discard]];
        [tr add:self.optionalWhitespaceParser];
        [tr add:[TDQuotedString quotedString]]; // endMarker
        [secondArg add:tr];
        
        [delimitedStringParser add:[[TDLiteral literalWithString:@"DelimitedString"] discard]];
        [delimitedStringParser add:self.optionalWhitespaceParser];
        [delimitedStringParser add:[TDSymbol symbolWithString:@"("]]; // preserve as fence
        [delimitedStringParser add:self.optionalWhitespaceParser];
        [delimitedStringParser add:[TDQuotedString quotedString]]; // startMarker
        [delimitedStringParser add:[self zeroOrOne:secondArg]];
        [delimitedStringParser add:self.optionalWhitespaceParser];
        [delimitedStringParser add:[[TDSymbol symbolWithString:@")"] discard]];
        
        [delimitedStringParser setAssembler:self selector:@selector(workOnDelimitedString:)];
    }
    return delimitedStringParser;
}


// literal              = QuotedString;
- (PKParser *)literalParser {
    if (!literalParser) {
        self.literalParser = [TDQuotedString quotedString];
        [literalParser setAssembler:self selector:@selector(workOnLiteral:)];
    }
    return literalParser;
}


// variable             = LowercaseWord;
- (PKParser *)variableParser {
    if (!variableParser) {
        self.variableParser = [TDLowercaseWord word];
        variableParser.name = @"variable";
        [variableParser setAssembler:self selector:@selector(workOnVariable:)];
    }
    return variableParser;
}


// constant             = UppercaseWord;
- (PKParser *)constantParser {
    if (!constantParser) {
        self.constantParser = [TDUppercaseWord word];
        constantParser.name = @"constant";
        [constantParser setAssembler:self selector:@selector(workOnConstant:)];
    }
    return constantParser;
}


- (PKParser *)whitespaceParser {
    return [[TDWhitespace whitespace] discard];
}


- (PKCollectionParser *)optionalWhitespaceParser {
    return [PKRepetition repetitionWithSubparser:self.whitespaceParser];
}


- (BOOL)shouldDiscard:(PKAssembly *)a {
    if (![a isStackEmpty]) {
        id obj = [a pop];
        if ([obj isEqual:caret]) {
            return YES;
        } else {
            [a push:obj];
        }
    }
    return NO;
}


- (void)workOnStatement:(PKAssembly *)a {
    NSArray *toks = [[a objectsAbove:equals] reversedArray];
    [a pop]; // discard '=' tok

    NSString *parserName = nil;
    NSString *selName = nil;
    id obj = [a pop];
    if ([obj isKindOfClass:[NSString class]]) { // a callback was provided
        selName = obj;
        parserName = [[a pop] stringValue];
    } else {
        parserName = [obj stringValue];
    }
    
    if (selName) {
        NSAssert(selName.length, @"");
        [selectorTable setObject:selName forKey:parserName];
    }
	NSMutableDictionary *d = a.target;
    //NSLog(@"parserName: %@", parserName);
    NSAssert(toks.count, @"");
    
    // support for multiple @delimitedString = ... tokenizer directives
    if ([parserName hasPrefix:@"@"]) {
        // remove whitespace toks from tokenizer directives
        if (![parserName isEqualToString:@"@start"]) {
            toks = [self tokens:toks byRemovingTokensOfType:TDTokenTypeWhitespace];
        }
        
        NSArray *existingToks = [d objectForKey:parserName];
        if (existingToks.count) {
            toks = [toks arrayByAddingObjectsFromArray:existingToks];
        }
    }
    
    [d setObject:toks forKey:parserName];
}


- (NSArray *)tokens:(NSArray *)toks byRemovingTokensOfType:(TDTokenType)tt {
    NSMutableArray *res = [NSMutableArray array];
    for (TDToken *tok in toks) {
        if (TDTokenTypeWhitespace != tok.tokenType) {
            [res addObject:tok];
        }
    }
    return res;
}


- (NSString *)defaultAssemblerSelectorNameForParserName:(NSString *)parserName {
    NSString *prefix = nil;
    if ([parserName hasPrefix:@"@"]) {
        parserName = [parserName substringFromIndex:1];
        prefix = @"workOn_";
    } else {
        prefix = @"workOn";
    }
    NSString *s = [NSString stringWithFormat:@"%@%@", [[parserName substringToIndex:1] uppercaseString], [parserName substringFromIndex:1]]; 
    return [NSString stringWithFormat:@"%@%@:", prefix, s];
}


- (void)workOnCallback:(PKAssembly *)a {
    TDToken *selNameTok = [a pop];
    NSString *selName = [NSString stringWithFormat:@"%@:", selNameTok.stringValue];
    [a push:selName];
}


- (void)workOnExpression:(PKAssembly *)a {
    NSArray *objs = [a objectsAbove:paren];
    NSAssert(objs.count, @"");
    [a pop]; // pop '('
    if (objs.count > 1) {
        PKSequence *seq = [PKSequence sequence];
        for (id obj in [objs reverseObjectEnumerator]) {
            [seq add:obj];
        }
        [a push:seq];
    } else if (objs.count) {
        [a push:[objs objectAtIndex:0]];
    }
}


- (void)workOnExclusion:(PKAssembly *)a {
    PKParser *predicate = [a pop];
    PKParser *sub = [a pop];
    NSAssert([predicate isKindOfClass:[PKParser class]], @"");
    NSAssert([sub isKindOfClass:[PKParser class]], @"");
    
    PKExclusion *ex = [PKExclusion exclusion];
    [ex add:sub];
    [ex add:predicate];

    [a push:ex];
}


- (void)workOnIntersection:(PKAssembly *)a {
    PKParser *predicate = [a pop];
    PKParser *sub = [a pop];
    NSAssert([predicate isKindOfClass:[PKParser class]], @"");
    NSAssert([sub isKindOfClass:[PKParser class]], @"");
    
    PKIntersection *inter = [PKIntersection intersection];
    [inter add:sub];
    [inter add:predicate];
    
    [a push:inter];
}


- (void)workOnPatternOptions:(PKAssembly *)a {
    TDToken *tok = [a pop];
    NSAssert(tok.isWord, @"");

    NSString *s = tok.stringValue;
    NSAssert(s.length > 0, @"");

    TDPatternOptions opts = TDPatternOptionsNone;
    if (NSNotFound != [s rangeOfString:@"i"].location) {
        opts |= TDPatternOptionsIgnoreCase;
    }
    if (NSNotFound != [s rangeOfString:@"m"].location) {
        opts |= TDPatternOptionsMultiline;
    }
    if (NSNotFound != [s rangeOfString:@"x"].location) {
        opts |= TDPatternOptionsComments;
    }
    if (NSNotFound != [s rangeOfString:@"s"].location) {
        opts |= TDPatternOptionsDotAll;
    }
    if (NSNotFound != [s rangeOfString:@"w"].location) {
        opts |= TDPatternOptionsUnicodeWordBoundaries;
    }
    
    [a push:[NSNumber numberWithInteger:opts]];
}


- (void)workOnPattern:(PKAssembly *)a {
    id obj = [a pop]; // opts (as Number*) or DelimitedString('/', '/')
    
    TDPatternOptions opts = TDPatternOptionsNone;
    if ([obj isKindOfClass:[NSNumber class]]) {
        opts = [obj integerValue];
        obj = [a pop];
    }
    
    NSAssert([obj isMemberOfClass:[TDToken class]], @"");
    TDToken *tok = (TDToken *)obj;
    NSAssert(tok.isDelimitedString, @"");

    NSString *s = tok.stringValue;
    NSAssert(s.length > 2, @"");
    
    NSAssert([s hasPrefix:@"/"], @"");
    NSAssert([s hasSuffix:@"/"], @"");

    NSString *re = [s stringByTrimmingQuotes];
    
    PKTerminal *t = [TDPattern patternWithString:re options:opts];
    
    if ([self shouldDiscard:a]) {
        [t discard];
    }
    
    [a push:t];
}


- (void)workOnLiteral:(PKAssembly *)a {
    TDToken *tok = [a pop];

    NSString *s = [tok.stringValue stringByTrimmingQuotes];
    PKTerminal *t = [TDCaseInsensitiveLiteral literalWithString:s];

    if ([self shouldDiscard:a]) {
        [t discard];
    }
    
    [a push:t];
}


- (void)workOnVariable:(PKAssembly *)a {
    TDToken *tok = [a pop];
    NSString *parserName = tok.stringValue;
    PKParser *p = nil;
    if (isGatheringClasses) {
        // lookup the actual possible parser. 
        // if its not there, or still a token array, just spoof it with a sequence
		NSMutableDictionary *d = a.target;
        p = [d objectForKey:parserName];
        if (![p isKindOfClass:[PKParser parser]]) {
            p = [PKSequence sequence];
        }
    } else {
        if ([parserTokensTable objectForKey:parserName]) {
            p = [self expandedParserForName:parserName];
        }
    }
    [a push:p];
}


- (void)workOnConstant:(PKAssembly *)a {
    TDToken *tok = [a pop];
    NSString *s = tok.stringValue;
    id p = nil;
    if ([s isEqualToString:@"Word"]) {
        p = [TDWord word];
    } else if ([s isEqualToString:@"LowercaseWord"]) {
        p = [TDLowercaseWord word];
    } else if ([s isEqualToString:@"UppercaseWord"]) {
        p = [TDUppercaseWord word];
    } else if ([s isEqualToString:@"Num"]) {
        p = [TDNum num];
    } else if ([s isEqualToString:@"S"]) {
        p = [TDWhitespace whitespace];
    } else if ([s isEqualToString:@"QuotedString"]) {
        p = [TDQuotedString quotedString];
    } else if ([s isEqualToString:@"Symbol"]) {
        p = [TDSymbol symbol];
    } else if ([s isEqualToString:@"Comment"]) {
        p = [TDComment comment];
    } else if ([s isEqualToString:@"Any"]) {
        p = [PKAny any];
    } else if ([s isEqualToString:@"Empty"]) {
        p = [PKEmpty empty];
    } else if ([s isEqualToString:@"Pattern"]) {
        p = tok;
    } else if ([s isEqualToString:@"DelimitedString"]) {
        p = tok;
    } else if ([s isEqualToString:@"YES"] || [s isEqualToString:@"NO"]) {
        p = tok;
    } else {
        [NSException raise:@"Grammar Exception" format:
         @"User Grammar referenced a constant parser name (uppercase word) which is not supported: %@. Must be one of: Word, LowercaseWord, UppercaseWord, QuotedString, Num, Symbol, Empty.", s];
    }
    
    if ([p isKindOfClass:[PKTerminal class]] && [self shouldDiscard:a]) {
        PKTerminal *t = (PKTerminal *)p;
        [t discard];
    }
    
    [a push:p];
}


- (void)workOnDelimitedString:(PKAssembly *)a {
    NSArray *toks = [a objectsAbove:paren];
    [a pop]; // discard '(' fence
    
    NSAssert(toks.count > 0 && toks.count < 3, @"");
    NSString *start = [[[toks lastObject] stringValue] stringByTrimmingQuotes];
    NSString *end = nil;
    if (toks.count > 1) {
        end = [[[toks objectAtIndex:0] stringValue] stringByTrimmingQuotes];
    }

    PKTerminal *t = [TDDelimitedString delimitedStringWithStartMarker:start endMarker:end];
    
    if ([self shouldDiscard:a]) {
        [t discard];
    }
    
    [a push:t];
}


- (void)workOnNum:(PKAssembly *)a {
    TDToken *tok = [a pop];
    [a push:[NSNumber numberWithFloat:tok.floatValue]];
}


- (void)workOnStar:(PKAssembly *)a {
    id top = [a pop];
    PKRepetition *rep = [PKRepetition repetitionWithSubparser:top];
    [a push:rep];
}


- (void)workOnPlus:(PKAssembly *)a {
    id top = [a pop];
    [a push:[self oneOrMore:top]];
}


- (void)workOnQuestion:(PKAssembly *)a {
    id top = [a pop];
    [a push:[self zeroOrOne:top]];
}


- (void)workOnPhraseCardinality:(PKAssembly *)a {
    NSRange r = [[a pop] rangeValue];
    PKParser *p = [a pop];
    PKSequence *s = [PKSequence sequence];
    
    NSInteger start = r.location;
    NSInteger end = r.length;
    
    NSInteger i = 0;
    for ( ; i < start; i++) {
        [s add:p];
    }
    
    for ( ; i < end; i++) {
        [s add:[self zeroOrOne:p]];
    }
    
    [a push:s];
}


- (void)workOnCardinality:(PKAssembly *)a {
    NSArray *toks = [a objectsAbove:self.curly];
    [a pop]; // discard '{' tok

    NSAssert(toks.count > 0, @"");
    
    CGFloat start = [[toks lastObject] floatValue];
    CGFloat end = start;
    if (toks.count > 1) {
        end = [[toks objectAtIndex:0] floatValue];
    }
    
    NSAssert(start <= end, @"");
    
    NSRange r = NSMakeRange(start, end);
    [a push:[NSValue valueWithRange:r]];
}


- (void)workOnOr:(PKAssembly *)a {
    id second = [a pop];
    [a pop]; // pop '|'
    id first = [a pop];
    PKAlternation *p = [PKAlternation alternation];
    [p add:first];
    [p add:second];
    [a push:p];
}


- (void)workOnAnd:(PKAssembly *)a {
    NSMutableArray *parsers = [NSMutableArray array];
    while (![a isStackEmpty]) {
        id obj = [a pop];
        if ([obj isKindOfClass:[PKParser class]]) {
            [parsers addObject:obj];
        } else {
            [a push:obj];
            break;
        }
    }
    
    if (parsers.count > 1) {
        PKSequence *seq = [PKSequence sequence];
        for (PKParser *p in [parsers reverseObjectEnumerator]) {
            [seq add:p];
        }
        
        [a push:seq];
    } else if (1 == parsers.count) {
        [a push:[parsers objectAtIndex:0]];
    }
}

@synthesize assembler;
@synthesize parserTokensTable;
@synthesize parserClassTable;
@synthesize selectorTable;
@synthesize equals;
@synthesize curly;
@synthesize paren;
@synthesize caret;
@synthesize statementParser;
@synthesize declarationParser;
@synthesize callbackParser;
@synthesize selectorParser;
@synthesize exprParser;
@synthesize termParser;
@synthesize orTermParser;
@synthesize factorParser;
@synthesize nextFactorParser;
@synthesize phraseParser;
@synthesize phraseStarParser;
@synthesize phrasePlusParser;
@synthesize phraseQuestionParser;
@synthesize phraseCardinalityParser;
@synthesize cardinalityParser;
@synthesize primaryExprParser;
@synthesize predicateParser;
@synthesize intersectionParser;
@synthesize exclusionParser;
@synthesize atomicValueParser;
@synthesize discardParser;
@synthesize patternParser;
@synthesize delimitedStringParser;
@synthesize literalParser;
@synthesize variableParser;
@synthesize constantParser;
@synthesize assemblerSettingBehavior;
@end
