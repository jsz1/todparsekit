//
//  TDNSPredicateEvaluator.h
//  TDParseKit
//
//  Created by Todd Ditchendorf on 6/17/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TDParseKit/TDParseKit.h>

@class TDNSPredicateEvaluator;

@protocol TDKeyPathResolver <NSObject>
- (id)resolvedValueForKeyPath:(NSString *)s;
@end

@interface TDNSPredicateEvaluator : NSObject {
    id <TDKeyPathResolver>resolver;
    TDParser *parser;
    TDToken *openCurly;
}
- (id)initWithKeyPathResolver:(id <TDKeyPathResolver>)r;

- (BOOL)evaluate:(NSString *)s;

@property (nonatomic, retain) TDParser *parser;
@end