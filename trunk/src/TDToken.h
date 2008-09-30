//
//  TDToken.h
//  TDParseKit
//
//  Created by Todd Ditchendorf on 1/20/06.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
	@enum 
	@abstract   Indicates the type of a <tt>TDToken</tt>
	@constant   TDTT_EOF A constant indicating that the endo fo the stream has been read.
	@constant   TDTT_NUMBER A constant indicating that a token is a number, like <tt>3.14</tt>.
	@constant   TDTT_QUOTED A constant indicating that a token is a quoted string, like <tt>"Launch Mi"</tt>.
	@constant   TDTT_SYMBOL A constant indicating that a token is a symbol, like <tt>"<="</tt>.
	@constant   TDTT_WORD A constant indicating that a token is a word, like <tt>cat</tt>.
 */
typedef enum {
	TDTT_EOF,
	TDTT_NUMBER,
	TDTT_QUOTED,
	TDTT_SYMBOL,
	TDTT_WORD
} TDTokenType;

/*!
    @class       TDToken 
    @superclass  NSObject
    @abstract    A token represents a logical chunk of a string.
    @discussion  A token represents a logical chunk of a string. For example, a typical tokenizer would break the string <tt>"1.23 <= 12.3"</tt> into three tokens: the number <tt>1.23</tt>, a less-than-or-equal symbol, and the number <tt>12.3</tt>. A token is a receptacle, and relies on a tokenizer to decide precisely how to divide a string into tokens.
*/
@interface TDToken : NSObject {
	CGFloat floatValue;
	NSString *stringValue;
	TDTokenType tokenType;
	
	BOOL number;
	BOOL quotedString;
	BOOL symbol;
	BOOL word;
	
	id value;
}

/*!
    @method     EOFToken
    @abstract   Factory method for creating a singleton <tt>TDToken</tt> used to indicate that there are no more tokens.
	@result		A singleton used to indicate that there are no more tokens.
*/
+ (TDToken *)EOFToken;

/*!
    @method     tokenWithTokenType:stringValue:floatValue:
    @abstract   Factory convenience method for creating autoreleased <tt>TDToken</tt>.
*/
+ (id)tokenWithTokenType:(TDTokenType)t stringValue:(NSString *)s floatValue:(CGFloat)n;

/*!
    @method     initWithTokenType:stringValue:floatValue:
    @abstract   Designated initializer. Constructs a token of the indicated type and associated string or numeric values.
*/
- (id)initWithTokenType:(TDTokenType)t stringValue:(NSString *)s floatValue:(CGFloat)n;

/*!
    @method     isEqualIgnoringCase:
    @abstract   Returns true if the supplied object is an equivalent token, ignoring differences in case.
*/
- (BOOL)isEqualIgnoringCase:(id)obj;

/*!
    @method     debugDescription
    @abstract   Returns more descriptive textual representation than <tt>-description</tt> which may be useful for debugging puposes only.
    @discussion Usually of format similar to: <tt>&lt;QuotedString "Launch Mi"></tt>, <tt>&lt;Word cat></tt>, or <tt>&lt;Number 3.14></tt>
    @result     A textual representation including more descriptive information than <tt>-description</tt>.
*/
- (NSString *)debugDescription;

/*!
    @method     isNumber
    @abstract   Returns true if this token is a number.
*/
@property (nonatomic, readonly, getter=isNumber) BOOL number;

/*!
	@method     isQuotedString
	@abstract   Returns true if this token is a quoted string.
 */
@property (nonatomic, readonly, getter=isQuotedString) BOOL quotedString;

/*!
	@method     isSymbol
	@abstract   Returns true if this token is a symbol.
 */
@property (nonatomic, readonly, getter=isSymbol) BOOL symbol;

/*!
	@method     isWord
	@abstract   Returns true if this token is a word.
 */
@property (nonatomic, readonly, getter=isWord) BOOL word;

/*!
	@method     tokenType
	@abstract   Returns the type of this token.
 */
@property (nonatomic, readonly) TDTokenType tokenType;

/*!
	@method     floatValue
	@abstract   Returns the numeric value of this token.
 */
@property (nonatomic, readonly) CGFloat floatValue;

/*!
	@method     stringValue
	@abstract   Returns the string value of this token.
 */
@property (nonatomic, readonly, copy) NSString *stringValue;

/*!
	@method     value
	@abstract   Returns an object that represents the value of this token.
 */
@property (nonatomic, readonly, copy) id value;
@end
