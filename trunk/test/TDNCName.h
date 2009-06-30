//
//  TDNCName.h
//  TDParseKit
//
//  Created by Todd Ditchendorf on 8/16/08.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

#import "PKTerminal.h"
#import "PKToken.h"

extern const NSInteger TDTokenTypeNCName;

@interface PKToken (NCNameAdditions)
@property (readonly, getter=isNCName) BOOL NCName;
@end

@interface TDNCName : PKTerminal {

}
+ (id)NCName;
@end
