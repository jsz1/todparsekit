//
//  TDSignificantWhitespaceState.h
//  TDParseKit
//
//  Created by Todd Ditchendorf on 7/14/08.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ParseKit/TDWhitespaceState.h>
#import <ParseKit/PKToken.h>

// NOTE: this class is not currently in use or included in the Framework. It is an example of how to add a new token type

static const NSInteger TDTokenTypeWhitespace = 5;

@interface PKToken (TDSignificantWhitespaceStateAdditions)
@property (nonatomic, readonly, getter=isWhitespace) BOOL whitespace;
@end

@interface TDSignificantWhitespaceState : TDWhitespaceState {

}
@end
