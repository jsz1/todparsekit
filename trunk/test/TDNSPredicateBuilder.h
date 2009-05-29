//
//  PredicateParser.h
//  TDParseKit
//
//  Created by Todd Ditchendorf on 5/27/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <TDParseKit/TDParseKit.h>

@interface TDNSPredicateBuilder : NSObject {
    NSArray *reservedWords;
    TDToken *nonReservedWordFence;
    TDCollectionParser *exprParser;
    TDCollectionParser *orTermParser;
    TDCollectionParser *termParser;
    TDCollectionParser *andPrimaryExprParser;
    TDCollectionParser *primaryExprParser;
    TDCollectionParser *phraseParser;
    TDCollectionParser *negatedPredicateParser;
    TDCollectionParser *predicateParser;
    TDCollectionParser *completePredicateParser;
    TDCollectionParser *attrValuePredicateParser;
    TDCollectionParser *attrPredicateParser;
	TDCollectionParser *valuePredicateParser;
    TDCollectionParser *attrParser;
    TDCollectionParser *tagParser;
    TDCollectionParser *relationParser;
    TDCollectionParser *valueParser;
    TDCollectionParser *boolParser;
    TDParser *trueParser;
    TDParser *falseParser;
    TDCollectionParser *stringParser;
    TDParser *quotedStringParser;
    TDCollectionParser *unquotedStringParser;
    TDTerminal *nonReservedWordParser;
    TDParser *numberParser;
}
- (NSPredicate *)buildFrom:(NSString *)s;

@property (nonatomic, copy) NSArray *reservedWords;

@property (nonatomic, retain) TDCollectionParser *exprParser;
@property (nonatomic, retain) TDCollectionParser *orTermParser;
@property (nonatomic, retain) TDCollectionParser *termParser;
@property (nonatomic, retain) TDCollectionParser *andPrimaryExprParser;
@property (nonatomic, retain) TDCollectionParser *primaryExprParser;
@property (nonatomic, retain) TDCollectionParser *phraseParser;
@property (nonatomic, retain) TDCollectionParser *negatedPredicateParser;
@property (nonatomic, retain) TDCollectionParser *predicateParser;
@property (nonatomic, retain) TDCollectionParser *completePredicateParser;
@property (nonatomic, retain) TDCollectionParser *attrValuePredicateParser;
@property (nonatomic, retain) TDCollectionParser *attrPredicateParser;
@property (nonatomic, retain) TDCollectionParser *valuePredicateParser;
@property (nonatomic, retain) TDCollectionParser *attrParser;
@property (nonatomic, retain) TDCollectionParser *tagParser;
@property (nonatomic, retain) TDCollectionParser *relationParser;
@property (nonatomic, retain) TDCollectionParser *valueParser;
@property (nonatomic, retain) TDCollectionParser *boolParser;
@property (nonatomic, retain) TDParser *trueParser;
@property (nonatomic, retain) TDParser *falseParser;
@property (nonatomic, retain) TDCollectionParser *stringParser;
@property (nonatomic, retain) TDParser *quotedStringParser;
@property (nonatomic, retain) TDCollectionParser *unquotedStringParser;
@property (nonatomic, retain) TDTerminal *nonReservedWordParser;
@property (nonatomic, retain) TDParser *numberParser;
@end
