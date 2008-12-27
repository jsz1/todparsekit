//
//  TDOldGrammarParserFactory.m
//  TDParseKit
//
//  Created by Todd Ditchendorf on 12/12/08.
//  Copyright 2008 Todd Ditchendorf All rights reserved.
//

#import "TDOldGrammarParserFactory.h"
#import "NSString+TDParseKitAdditions.h"

@interface TDOldGrammarParserFactory ()
- (TDSequence *)parserForExpression:(NSString *)s;
- (NSString *)defaultAssemblerSelectorNameForParserName:(NSString *)parserName;

@property (nonatomic, retain) TDTokenizer *tokenizer;
@property (nonatomic, retain) id assembler;
@property (nonatomic, retain) TDToken *equals;
@property (nonatomic, retain) TDToken *curly;
@property (nonatomic, retain) TDCollectionParser *statementParser;
@property (nonatomic, retain) TDCollectionParser *declarationParser;
@property (nonatomic, retain) TDCollectionParser *callbackParser;
@property (nonatomic, retain) TDCollectionParser *selectorParser;
@property (nonatomic, retain) TDCollectionParser *expressionParser;
@property (nonatomic, retain) TDCollectionParser *termParser;
@property (nonatomic, retain) TDCollectionParser *orTermParser;
@property (nonatomic, retain) TDCollectionParser *factorParser;
@property (nonatomic, retain) TDCollectionParser *nextFactorParser;
@property (nonatomic, retain) TDCollectionParser *phraseParser;
@property (nonatomic, retain) TDCollectionParser *phraseStarParser;
@property (nonatomic, retain) TDCollectionParser *phrasePlusParser;
@property (nonatomic, retain) TDCollectionParser *phraseQuestionParser;
@property (nonatomic, retain) TDCollectionParser *phraseCardinalityParser;
@property (nonatomic, retain) TDCollectionParser *cardinalityParser;
@property (nonatomic, retain) TDCollectionParser *atomicValueParser;
@property (nonatomic, retain) TDParser *literalParser;
@property (nonatomic, retain) TDParser *variableParser;
@property (nonatomic, retain) TDParser *constantParser;
@property (nonatomic, retain) TDParser *numParser;
@end

@implementation TDOldGrammarParserFactory

+ (id)factory {
    return [[[TDOldGrammarParserFactory alloc] init] autorelease];
}


- (id)init {
    self = [super init];
    if (self) {
        self.equals = [TDToken tokenWithTokenType:TDTokenTypeSymbol stringValue:@"=" floatValue:0.0];
        self.curly = [TDToken tokenWithTokenType:TDTokenTypeSymbol stringValue:@"{" floatValue:0.0];
    }
    return self;
}


- (void)dealloc {
    self.tokenizer = nil;
    self.assembler = nil;
    self.equals = nil;
    self.curly = nil;
    self.statementParser = nil;
    self.expressionParser = nil;
    self.declarationParser = nil;
    self.callbackParser = nil;
    self.selectorParser = nil;
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
    self.atomicValueParser = nil;
    self.literalParser = nil;
    self.variableParser = nil;
    self.constantParser = nil;
    self.numParser = nil;
    [super dealloc];
}


- (TDParser *)parserForGrammar:(NSString *)s assembler:(id)ass {
    self.tokenizer.string = s;
    self.assembler = ass;
    
    TDTokenArraySource *src = [[TDTokenArraySource alloc] initWithTokenizer:self.tokenizer delimiter:@";"];
    id target = [NSMutableDictionary dictionary]; // setup the variable lookup table
    
    while ([src hasMore]) {
        NSArray *toks = [src nextTokenArray];
        TDAssembly *a = [TDTokenAssembly assemblyWithTokenArray:toks];
        a.target = target;
        a = [self.statementParser completeMatchFor:a];
        target = a.target;
    }
    
    [src release];
    
    TDCollectionParser *start = [target objectForKey:@"start"];
    
    if (start && [start isKindOfClass:[TDParser class]]) {
        return start;
    } else {
        [NSException raise:@"GrammarException" format:@"The provided language grammar was invalid"];
        return nil;
    }
}


- (TDSequence *)parserForExpression:(NSString *)s {
    TDOldGrammarParserFactory *p = [[[TDOldGrammarParserFactory alloc] init] autorelease];
    p.tokenizer.string = s;
    TDSequence *seq = [TDSequence sequence];
    [seq add:p.expressionParser];
    TDAssembly *a = [TDTokenAssembly assemblyWithTokenizer:p.tokenizer];
    a.target = [NSMutableDictionary dictionary]; // setup the variable lookup table
    a = [seq completeMatchFor:a];
    return [a pop];
}


- (TDTokenizer *)tokenizer {
    if (!tokenizer) {
        self.tokenizer = [TDTokenizer tokenizer];
        // customize here
    }
    return tokenizer;
}

// start                = statement*
// satement             = declaration '=' expression
// declaration          = LowercaseWord callback?
// callback             = '(' selector ')'
// selector             = Word ':'
// expression           = term orTerm*
// term                 = factor nextFactor*
// orTerm               = '|' term
// factor               = phrase | phraseStar | phrasePlus | phraseQuestion | phraseCardinality
// nextFactor           = factor
// phrase               = atomicValue | '(' expression ')'
// phraseStar           = phrase '*'
// phrasePlus           = phrase '+'
// phraseQuestion       = phrase '?'
// phraseCardinality    = phrase cardinality
// cardinality          = '{' Num '}'
// atomicValue          = literal | variable | constant
// literal              = QuotedString
// variable             = LowercaseWord
// constant             = UppercaseWord


// satement             = declaration '=' expression
- (TDCollectionParser *)statementParser {
    if (!statementParser) {
        self.statementParser = [TDTrack track];
        statementParser.name = @"statement";
        [statementParser add:self.declarationParser];
        [statementParser add:[TDSymbol symbolWithString:@"="]];
        [statementParser add:self.expressionParser];
        [statementParser setAssembler:self selector:@selector(workOnStatementAssembly:)];
    }
    return statementParser;
}


// declaration          = LowercaseWord callback?
- (TDCollectionParser *)declarationParser {
    if (!declarationParser) {
        self.declarationParser = [TDSequence sequence];
        [declarationParser add:[TDLowercaseWord word]];
        
        TDAlternation *a = [TDAlternation alternation];
        [a add:[TDEmpty empty]];
        [a add:self.callbackParser];
        [declarationParser add:a];
    }
    return declarationParser;
}


// callback             = '(' selector ')'
- (TDCollectionParser *)callbackParser {
    if (!callbackParser) {
        self.callbackParser = [TDTrack track];
        [callbackParser add:[[TDSymbol symbolWithString:@"("] discard]];
        [callbackParser add:self.selectorParser];
        [callbackParser add:[[TDSymbol symbolWithString:@")"] discard]];
        [callbackParser setAssembler:self selector:@selector(workOnCallbackAssembly:)];
    }
    return callbackParser;
}


// selector             = Word ':'
- (TDCollectionParser *)selectorParser {
    if (!selectorParser) {
        self.selectorParser = [TDTrack track];
        [selectorParser add:[TDWord word]];
        [selectorParser add:[[TDSymbol symbolWithString:@":"] discard]];
    }
    return selectorParser;
}


// expression        = term orTerm*
- (TDCollectionParser *)expressionParser {
    if (!expressionParser) {
        self.expressionParser = [TDSequence sequence];
        expressionParser.name = @"expression";
        [expressionParser add:self.termParser];
        [expressionParser add:[TDRepetition repetitionWithSubparser:self.orTermParser]];
        [expressionParser setAssembler:self selector:@selector(workOnExpressionAssembly:)];
    }
    return expressionParser;
}


// term                = factor nextFactor*
- (TDCollectionParser *)termParser {
    if (!termParser) {
        self.termParser = [TDSequence sequence];
        termParser.name = @"term";
        [termParser add:self.factorParser];
        [termParser add:[TDRepetition repetitionWithSubparser:self.nextFactorParser]];
    }
    return termParser;
}


// orTerm            = '|' term
- (TDCollectionParser *)orTermParser {
    if (!orTermParser) {
        self.orTermParser = [TDTrack track];
        orTermParser.name = @"orTerm";
        [orTermParser add:[[TDSymbol symbolWithString:@"|"] discard]];
        [orTermParser add:self.termParser];
        [orTermParser setAssembler:self selector:@selector(workOnOrAssembly:)];
    }
    return orTermParser;
}


// factor            = phrase | phraseStar | phrasePlus | phraseQuestion | phraseCardinality
- (TDCollectionParser *)factorParser {
    if (!factorParser) {
        self.factorParser = [TDAlternation alternation];
        factorParser.name = @"factor";
        [factorParser add:self.phraseParser];
        [factorParser add:self.phraseStarParser];
        [factorParser add:self.phrasePlusParser];
        [factorParser add:self.phraseQuestionParser];
        [factorParser add:self.phraseCardinalityParser];
    }
    return factorParser;
}


// nextFactor        = factor
- (TDCollectionParser *)nextFactorParser {
    if (!nextFactorParser) {
        self.nextFactorParser = [TDAlternation alternation];
        nextFactorParser.name = @"nextFactor";
        [nextFactorParser add:self.phraseParser];
        [nextFactorParser add:self.phraseStarParser];
        [nextFactorParser add:self.phrasePlusParser];
        [nextFactorParser add:self.phraseQuestionParser];
        [nextFactorParser add:self.phraseCardinalityParser];
    }
    return nextFactorParser;
}


// phrase            = atomicValue | '(' expression ')'
- (TDCollectionParser *)phraseParser {
    if (!phraseParser) {
        self.phraseParser = [TDAlternation alternation];
        phraseParser.name = @"phrase";
        [phraseParser add:self.atomicValueParser];
        
        TDTrack *t = [TDTrack track];
        [t add:[[TDSymbol symbolWithString:@"("] discard]];
        [t add:self.expressionParser];
        [t add:[[TDSymbol symbolWithString:@")"] discard]];
        [phraseParser add:t];
    }
    return phraseParser;
}


// phraseStar        = phrase '*'
- (TDCollectionParser *)phraseStarParser {
    if (!phraseStarParser) {
        self.phraseStarParser = [TDSequence sequence];
        phraseStarParser.name = @"phraseStar";
        [phraseStarParser add:self.phraseParser];
        [phraseStarParser add:[[TDSymbol symbolWithString:@"*"] discard]];
        [phraseStarParser setAssembler:self selector:@selector(workOnStarAssembly:)];
    }
    return phraseStarParser;
}


// phrasePlus        = phrase '+'
- (TDCollectionParser *)phrasePlusParser {
    if (!phrasePlusParser) {
        self.phrasePlusParser = [TDSequence sequence];
        phrasePlusParser.name = @"phrasePlus";
        [phrasePlusParser add:self.phraseParser];
        [phrasePlusParser add:[[TDSymbol symbolWithString:@"+"] discard]];
        [phrasePlusParser setAssembler:self selector:@selector(workOnPlusAssembly:)];
    }
    return phrasePlusParser;
}


// phraseQuestion       = phrase '?'
- (TDCollectionParser *)phraseQuestionParser {
    if (!phraseQuestionParser) {
        self.phraseQuestionParser = [TDSequence sequence];
        phraseQuestionParser.name = @"phraseQuestion";
        [phraseQuestionParser add:self.phraseParser];
        [phraseQuestionParser add:[[TDSymbol symbolWithString:@"?"] discard]];
        [phraseQuestionParser setAssembler:self selector:@selector(workOnQuestionAssembly:)];
    }
    return phraseQuestionParser;
}


// phraseCardinality    = phrase cardinality
- (TDCollectionParser *)phraseCardinalityParser {
    if (!phraseCardinalityParser) {
        self.phraseCardinalityParser = [TDSequence sequence];
        phraseCardinalityParser.name = @"phraseCardinality";
        [phraseCardinalityParser add:self.phraseParser];
        [phraseCardinalityParser add:self.cardinalityParser];
        [phraseCardinalityParser setAssembler:self selector:@selector(workOnPhraseCardinalityAssembly:)];
    }
    return phraseCardinalityParser;
}


// cardinality          = '{' Num '}'
- (TDCollectionParser *)cardinalityParser {
    if (!cardinalityParser) {
        self.cardinalityParser = [TDSequence sequence];
        cardinalityParser.name = @"cardinality";
        [cardinalityParser add:[TDSymbol symbolWithString:@"{"]]; // serves as fence. dont discard
        [cardinalityParser add:[TDNum num]];
        [cardinalityParser add:[[TDSymbol symbolWithString:@"}"] discard]];
        [cardinalityParser setAssembler:self selector:@selector(workOnCardinalityAssembly:)];
    }
    return cardinalityParser;
}


// atomicValue    = QuotedString | variable | constant
- (TDCollectionParser *)atomicValueParser {
    if (!atomicValueParser) {
        self.atomicValueParser = [TDAlternation alternation];
        atomicValueParser.name = @"atomicValue";
        [atomicValueParser add:self.literalParser];
        [atomicValueParser add:self.variableParser];
        [atomicValueParser add:self.constantParser];
    }
    return atomicValueParser;
}


// literal = QuotedString
- (TDParser *)literalParser {
    if (!literalParser) {
        self.literalParser = [TDQuotedString quotedString];
        [literalParser setAssembler:self selector:@selector(workOnLiteralAssembly:)];
    }
    return literalParser;
}


// variable = LowercaseWord
- (TDParser *)variableParser {
    if (!variableParser) {
        self.variableParser = [TDLowercaseWord word];
        [variableParser setAssembler:self selector:@selector(workOnVariableAssembly:)];
    }
    return variableParser;
}


// constant = UppercaseWord
- (TDParser *)constantParser {
    if (!constantParser) {
        self.constantParser = [TDUppercaseWord word];
        [constantParser setAssembler:self selector:@selector(workOnConstantAssembly:)];
    }
    return constantParser;
}


// num = Num
- (TDParser *)numParser {
    if (!numParser) {
        self.numParser = [TDNum num];
        [numParser setAssembler:self selector:@selector(workOnNumAssembly:)];
    }
    return numParser;
}


- (void)workOnStatementAssembly:(TDAssembly *)a {
    TDParser *p = [a pop];
    [a pop]; // discard '=' tok
    
    NSString *parserName = nil;
    NSString *selName = nil;
    id obj = [a pop];
    if ([obj isKindOfClass:[NSString class]]) { // a callback was provided
        selName = obj;
        parserName = [[a pop] stringValue];
    } else {
        parserName = [obj stringValue];
        selName = [self defaultAssemblerSelectorNameForParserName:parserName];
    }
    p.name = parserName;
    SEL sel = NSSelectorFromString(selName);
    if (assembler && [assembler respondsToSelector:sel]) {
        [p setAssembler:assembler selector:sel];
    }
    [a.target setObject:p forKey:parserName];
}


- (NSString *)defaultAssemblerSelectorNameForParserName:(NSString *)parserName {
    NSString *s = [NSString stringWithFormat:@"%@%@", [[parserName substringToIndex:1] uppercaseString], [parserName substringFromIndex:1]]; 
    return [NSString stringWithFormat:@"workOn%@Assembly:", s];
}


- (void)workOnCallbackAssembly:(TDAssembly *)a {
    TDToken *selNameTok = [a pop];
    NSString *selName = [NSString stringWithFormat:@"%@:", selNameTok.stringValue];
    [a push:selName];
}


- (void)workOnExpressionAssembly:(TDAssembly *)a {
    NSArray *objs = [a objectsAbove:equals];
    if (objs.count > 1) {
        TDSequence *seq = [TDSequence sequence];
        for (id obj in [objs reverseObjectEnumerator]) {
            [seq add:obj];
        }
        [a push:seq];
    } else if (objs.count) {
        TDParser *p = [objs objectAtIndex:0];
        [a push:p];
    }
}


- (void)workOnLiteralAssembly:(TDAssembly *)a {
    TDToken *tok = [a pop];
    NSString *s = [tok.stringValue stringByTrimmingQuotes];
    [a push:[TDLiteral literalWithString:s]];
}


- (void)workOnVariableAssembly:(TDAssembly *)a {
    TDToken *tok = [a pop];
    TDParser *p = [a.target objectForKey:tok.stringValue];
    [a push:p];
}


- (void)workOnConstantAssembly:(TDAssembly *)a {
    TDToken *tok = [a pop];
    NSString *s = tok.stringValue;
    TDParser *p = nil;
    if ([s isEqualToString:@"Word"]) {
        p = [TDWord word];
    } else if ([s isEqualToString:@"LowercaseWord"]) {
        p = [TDLowercaseWord word];
    } else if ([s isEqualToString:@"UppercaseWord"]) {
        p = [TDUppercaseWord word];
    } else if ([s isEqualToString:@"Num"]) {
        p = [TDNum num];
    } else if ([s isEqualToString:@"QuotedString"]) {
        p = [TDQuotedString quotedString];
    } else if ([s isEqualToString:@"Symbol"]) {
        p = [TDSymbol symbol];
    } else if ([s isEqualToString:@"Empty"]) {
        p = [TDEmpty empty];
    } else {
        [NSException raise:@"Grammar Exception" format:
         @"User Grammar referenced a constant parser name (uppercase word) which is not supported: %@. Must be one of: Word, LowercaseWord, UppercaseWord, QuotedString, Num, Symbol, Empty.", s];
    }
    [a push:p];
}


- (void)workOnNumAssembly:(TDAssembly *)a {
    TDToken *tok = [a pop];
    [a push:[TDLiteral literalWithString:tok.stringValue]];
}


- (void)workOnStarAssembly:(TDAssembly *)a {
    id top = [a pop];
    TDRepetition *rep = [TDRepetition repetitionWithSubparser:top];
    [a push:rep];
}


- (void)workOnPlusAssembly:(TDAssembly *)a {
    id top = [a pop];
    TDSequence *seq = [TDSequence sequence];
    [seq add:top];
    [seq add:[TDRepetition repetitionWithSubparser:top]];
    [a push:seq];
}


- (void)workOnQuestionAssembly:(TDAssembly *)a {
    id top = [a pop];
    TDAlternation *alt = [TDAlternation alternation];
    [alt add:[TDEmpty empty]];
    [alt add:top];
    [a push:alt];
}


- (void)workOnPhraseCardinalityAssembly:(TDAssembly *)a {
    NSRange r = [[a pop] rangeValue];
    TDParser *p = [a pop];
    TDSequence *s = [TDSequence sequence];
    
    NSInteger i = 0;
    for ( ; i < r.length; i++) {
        [s add:p];
    }
    
    [a push:s];
}


- (void)workOnCardinalityAssembly:(TDAssembly *)a {
    NSArray *toks = [a objectsAbove:self.curly];
    [a pop]; // discard '{' tok
    
    TDToken *start = [toks objectAtIndex:0];
    NSRange r = NSMakeRange(start.floatValue, start.floatValue);
    [a push:[NSValue valueWithRange:r]];
}


- (void)workOnOrAssembly:(TDAssembly *)a {
    id second = [a pop];
    id first = [a pop];
    TDAlternation *p = [TDAlternation alternation];
    [p add:first];
    [p add:second];
    [a push:p];
}

@synthesize tokenizer;
@synthesize assembler;
@synthesize equals;
@synthesize curly;
@synthesize statementParser;
@synthesize declarationParser;
@synthesize callbackParser;
@synthesize selectorParser;
@synthesize expressionParser;
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
@synthesize atomicValueParser;
@synthesize literalParser;
@synthesize variableParser;
@synthesize constantParser;
@synthesize numParser;
@end