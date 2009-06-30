//
//  TDComment.h
//  TDParseKit
//
//  Created by Todd Ditchendorf on 12/31/08.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ParseKit/PKTerminal.h>

/*!
    @class      TDComment
    @brief      A <tt>TDComment</tt> matches a comment from a token assembly.
*/
@interface TDComment : PKTerminal {

}

/*!
    @brief      Convenience factory method for initializing an autoreleased <tt>TDComment</tt> object.
    @result     an initialized autoreleased <tt>TDComment</tt> object
*/
+ (id)comment;
@end
