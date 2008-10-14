//
//  TDTrackException.h
//  TDParseKit
//
//  Created by Todd Ditchendorf on 10/14/08.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 @class     TDTrackException
 @brief		Signals that a parser could not match text after a specific point.
 @details	The <tt>userInfo</tt> for this exception contains the following keys:
			<tt>after</tt> (<tt>NSString *</tt>) - some indication of what text was interpretable
			<tt>expected</tt> (<tt>NSString *</tt>) - some indication of what kind of thing was expected, such as a ')' token
			<tt>found</tt> (<tt>NSString *</tt>) - the text element the thrower actually found when it expected something else
 */
@interface TDTrackException : NSException {

}

@end
