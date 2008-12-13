//
//  TDPlistParser.h
//  TDParseKit
//
//  Created by Todd Ditchendorf on 12/9/08.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

#import <TDParseKit/TDParseKit.h>

@interface TDPlistParser : TDAlternation {
    TDTokenizer *tokenizer;
    TDCollectionParser *dictParser;
    TDCollectionParser *keyValuePairParser;
    TDCollectionParser *arrayParser;
    TDCollectionParser *commaValueParser;
    TDCollectionParser *keyParser;
    TDCollectionParser *valueParser;
    TDCollectionParser *stringParser;
    TDParser *numParser;
    TDParser *nullParser;
    TDToken *curly;
    TDToken *paren;
}
- (id)parse:(NSString *)s;

@property (nonatomic, retain, readonly) TDTokenizer *tokenizer;
@property (nonatomic, retain) TDCollectionParser *dictParser;
@property (nonatomic, retain) TDCollectionParser *keyValuePairParser;
@property (nonatomic, retain) TDCollectionParser *arrayParser;
@property (nonatomic, retain) TDCollectionParser *commaValueParser;
@property (nonatomic, retain) TDCollectionParser *keyParser;
@property (nonatomic, retain) TDCollectionParser *valueParser;
@property (nonatomic, retain) TDCollectionParser *stringParser;
@property (nonatomic, retain) TDParser *numParser;
@property (nonatomic, retain) TDParser *nullParser;
@end
