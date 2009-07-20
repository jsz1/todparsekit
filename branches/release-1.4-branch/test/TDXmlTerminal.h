//
//  PKXmlTerminal.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/20/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/PKTerminal.h>

@class TDXmlToken;

@interface TDXmlTerminal : PKTerminal {
    TDXmlToken *tok;
}
@property (nonatomic, retain) TDXmlToken *tok;
@end
