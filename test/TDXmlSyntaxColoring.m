//
//  TDXmlSyntaxColoring.m
//  TDParseKit
//
//  Created by Todd Ditchendorf on 8/28/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TDXmlSyntaxColoring.h"
#import <TDParseKit/TDParseKit.h>

@interface NSArray (TDXmlSyntaxColoringAdditions)
- (NSMutableArray *)reversedMutableArray;
@end

@implementation NSArray (TDXmlSyntaxColoringAdditions)

- (NSMutableArray *)reversedMutableArray {
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.count];
	NSEnumerator *e = [self reverseObjectEnumerator];
	id obj = nil;
	while (obj = [e nextObject]) {
		[result addObject:obj];
	}
	return result;
}

@end

@interface TDXmlSyntaxColoring ()
- (void)workOnTag;
- (void)workOnText;
- (void)workOnComment;
- (id)peek;
- (id)pop;
- (NSArray *)objectsAbove:(id)fence;
- (TDToken *)nextNonWhitespaceTokenFrom:(NSEnumerator *)e;

@property (retain) TDTokenizer *tokenizer;
@property (retain) NSMutableArray *stack;
@property (retain) TDToken *ltToken;
@property (retain) TDToken *gtToken;
@property (retain) TDToken *startCommentToken;
@property (retain) TDToken *endCommentToken;
@end

@implementation TDXmlSyntaxColoring

- (id)init {
	self = [super init];
	if (self != nil) {
		self.tokenizer = [TDTokenizer tokenizer];
		
		[tokenizer setTokenizerState:tokenizer.symbolState from: '/' to: '/']; // XML doesn't have slash slash or slash star comments

		TDSignificantWhitespaceState *whitespaceState = [[TDSignificantWhitespaceState alloc] init];
		tokenizer.whitespaceState = whitespaceState;
		[tokenizer setTokenizerState:whitespaceState from:0 to:' '];
		[whitespaceState release];
		
		[tokenizer.wordState setWordChars:YES from:':' to:':'];
		
		self.ltToken = [TDToken tokenWithTokenType:TDTT_SYMBOL stringValue:@"<" floatValue:0.0f];
		self.gtToken = [TDToken tokenWithTokenType:TDTT_SYMBOL stringValue:@">" floatValue:0.0f];

		self.startCommentToken = [TDToken tokenWithTokenType:TDTT_SYMBOL stringValue:@"<!--" floatValue:0.0f];
		self.endCommentToken = [TDToken tokenWithTokenType:TDTT_SYMBOL stringValue:@"-->" floatValue:0.0f];

		[tokenizer.symbolState add:startCommentToken.stringValue];
		[tokenizer.symbolState add:endCommentToken.stringValue];

		NSFont *monacoFont = [NSFont fontWithName:@"Monaco" size:11.];
		self.textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
							   [NSColor blackColor], NSForegroundColorAttributeName,
							   monacoFont, NSFontAttributeName,
							   nil];
		self.tagAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
							   [NSColor purpleColor], NSForegroundColorAttributeName,
							   monacoFont, NSFontAttributeName,
							   nil];
		self.attrNameAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSColor blueColor], NSForegroundColorAttributeName,
									monacoFont, NSFontAttributeName,
									nil];
		self.attrValueAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSColor redColor], NSForegroundColorAttributeName,
									monacoFont, NSFontAttributeName,
									nil];
		self.eqAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
							 [NSColor blackColor], NSForegroundColorAttributeName,
							 monacoFont, NSFontAttributeName,
							 nil];
		self.commentAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
								  [NSColor lightGrayColor], NSForegroundColorAttributeName,
								  monacoFont, NSFontAttributeName,
								  nil];
	}
	return self;
}


- (void)dealloc {
	self.tokenizer = nil;
	self.stack = nil;
	self.ltToken = nil;
	self.gtToken = nil;
	self.startCommentToken = nil;
	self.endCommentToken = nil;
	self.coloredString = nil;
	self.textAttributes = nil;
	self.tagAttributes = nil;
	self.attrNameAttributes = nil;
	self.attrValueAttributes = nil;
	self.eqAttributes = nil;
	self.commentAttributes = nil;
	[super dealloc];
}


- (NSAttributedString *)parse:(NSString *)s {
	self.stack = [NSMutableArray array];
	self.coloredString = [[[NSMutableAttributedString alloc] init] autorelease];
	
	tokenizer.string = s;
	TDToken *eof = [TDToken EOFToken];
	TDToken *tok = nil;
	
	while ((tok = [tokenizer nextToken]) != eof) {
		NSString *sval = tok.stringValue;
		
		if (tok.isSymbol) {
			if ([ltToken.stringValue isEqualToString:sval]) {
				[self workOnText];
				[stack addObject:tok];
			} else if ([gtToken.stringValue isEqualToString:sval]) {
				[self workOnTag];
			} else if ([endCommentToken.stringValue isEqualToString:sval]) {
				[self workOnComment];
			} else {
				[stack addObject:tok];
			}
		} else {
			[stack addObject:tok];
		}
	}
	
	return coloredString;
}


- (TDToken *)nextNonWhitespaceTokenFrom:(NSEnumerator *)e {
	TDToken *tok = [e nextObject];
	while (tok.isWhitespace) {
		NSAttributedString *as = [[NSAttributedString alloc] initWithString:tok.stringValue attributes:tagAttributes];
		[coloredString appendAttributedString:as];
		[as release];
		tok = [e nextObject];
	}
	return tok;
}


- (void)workOnComment {
	// reverse toks to be in document order
	NSMutableArray *toks = [[self objectsAbove:startCommentToken] reversedMutableArray];
	
	NSAttributedString *as = [[NSAttributedString alloc] initWithString:startCommentToken.stringValue attributes:commentAttributes];
	[coloredString appendAttributedString:as];
	[as release];

	NSEnumerator *e = [toks objectEnumerator];

	TDToken *tok = nil;
	while (tok = [self nextNonWhitespaceTokenFrom:e]) {
		if ([tok isEqual:endCommentToken]) {
			break;
		} else {
			as = [[NSAttributedString alloc] initWithString:tok.stringValue attributes:commentAttributes];
			[coloredString appendAttributedString:as];
			[as release];			
		}
	}

	as = [[NSAttributedString alloc] initWithString:endCommentToken.stringValue attributes:commentAttributes];
	[coloredString appendAttributedString:as];
	[as release];
}


- (void)workOnStartTag:(NSEnumerator *)e {
	// tagName
	TDToken *tok = [self nextNonWhitespaceTokenFrom:e];
	if (!tok) return;
	
	NSDictionary *attrs = nil;
	if ([tok.stringValue isEqualToString:@"/"]) {
		attrs = tagAttributes;
	} else {
		attrs = attrNameAttributes;
	}
	
	NSAttributedString *as = [[NSAttributedString alloc] initWithString:tok.stringValue attributes:attrs];
	[coloredString appendAttributedString:as];
	[as release];
	
	// attr name or ns prefix decl "xmlns:foo" or "/" for empty element
	tok = [self nextNonWhitespaceTokenFrom:e];
	if (!tok) return;
	
	// "="
	as = [[NSAttributedString alloc] initWithString:tok.stringValue attributes:eqAttributes];
	[coloredString appendAttributedString:as];
	[as release];
	
	// quoted string attr value or ns url value
	tok = [self nextNonWhitespaceTokenFrom:e];
	if (!tok) return;
	
	as = [[NSAttributedString alloc] initWithString:tok.stringValue attributes:attrValueAttributes];
	[coloredString appendAttributedString:as];
	[as release];
}


- (void)workOnEndTag:(NSEnumerator *)e {
	// consume tagName
	TDToken *tok = [e nextObject];
	NSAttributedString *as = [[NSAttributedString alloc] initWithString:tok.stringValue attributes:tagAttributes];
	[coloredString appendAttributedString:as];
	[as release];
}


- (void)workOnTag {
	// reverse toks to be in document order
	NSMutableArray *toks = [[self objectsAbove:ltToken] reversedMutableArray];
	
	// append "<"
	NSAttributedString *as = [[NSAttributedString alloc] initWithString:ltToken.stringValue attributes:tagAttributes];
	[coloredString appendAttributedString:as];
	[as release];
	
	NSEnumerator *e = [toks objectEnumerator];

	// consume whitespace to tagName or "/" for end tags or "!" for comments
	TDToken *tok = [self nextNonWhitespaceTokenFrom:e];
	
	if (tok) {
		// consume tagName or "/"
		as = [[NSAttributedString alloc] initWithString:tok.stringValue attributes:tagAttributes];
		[coloredString appendAttributedString:as];
		[as release];
		
		if ([tok.stringValue isEqualToString:@"/"]) {
			[self workOnEndTag:e];
		} else {
			[self workOnStartTag:e];
		}
	}
		
	// append ">"
	as = [[NSAttributedString alloc] initWithString:gtToken.stringValue attributes:tagAttributes];
	[coloredString appendAttributedString:as];
	[as release];
}


- (void)workOnText {
	NSArray *a = [self objectsAbove:gtToken];
	NSEnumerator *e = [a reverseObjectEnumerator];
	TDToken *tok = nil;
	while (tok = [e nextObject]) {
		NSAttributedString *as = [[NSAttributedString alloc] initWithString:tok.stringValue attributes:textAttributes];
		[coloredString appendAttributedString:as];
		[as release];
	}
}


- (NSArray *)objectsAbove:(id)fence {
	NSMutableArray *res = [NSMutableArray array];
	while (1) {
		if (!stack.count) {
			break;
		}
		id obj = [self pop];
		if ([obj isEqual:fence]) {
			break;
		}
		[res addObject:obj];
	}
	return res;
}


- (id)peek {
	id obj = nil;
	if (stack.count) {
		obj = [stack lastObject];
	}
	return obj;
}


- (id)pop {
	id obj = [self peek];
	if (obj) {
		[stack removeLastObject];
	}
	return obj;
}

@synthesize stack;
@synthesize tokenizer;
@synthesize ltToken;
@synthesize gtToken;
@synthesize startCommentToken;
@synthesize endCommentToken;
@synthesize coloredString;
@synthesize tagAttributes;
@synthesize textAttributes;
@synthesize attrNameAttributes;
@synthesize attrValueAttributes;
@synthesize eqAttributes;
@synthesize commentAttributes;
@end
