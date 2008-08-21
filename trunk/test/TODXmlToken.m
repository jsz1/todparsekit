//
//  TODXmlToken.m
//  TODParseKit
//
//  Created by Todd Ditchendorf on 8/16/08.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

#import "TODXmlToken.h"

@interface TODXmlTokenEOF : TODXmlToken {}
@end

@implementation TODXmlTokenEOF
- (NSString *)description {
	return [NSString stringWithFormat:@"<TODXmlTokenEOF %p>", self];
}
@end

@interface TODXmlToken ()
@property (nonatomic, readwrite, getter=isNone) BOOL none;
@property (nonatomic, readwrite, getter=isStartTag) BOOL startTag;
@property (nonatomic, readwrite, getter=isAttribute) BOOL attribute;
@property (nonatomic, readwrite, getter=isText) BOOL text;
@property (nonatomic, readwrite, getter=isCdata) BOOL cdata;
@property (nonatomic, readwrite, getter=isEntityRef) BOOL entityRef;
@property (nonatomic, readwrite, getter=isEntity) BOOL entity;
@property (nonatomic, readwrite, getter=isProcessingInstruction) BOOL processingInstruction;
@property (nonatomic, readwrite, getter=isComment) BOOL comment;
@property (nonatomic, readwrite, getter=isDocument) BOOL document;
@property (nonatomic, readwrite, getter=isDoctype) BOOL doctype;
@property (nonatomic, readwrite, getter=isFragment) BOOL fragment;
@property (nonatomic, readwrite, getter=isNotation) BOOL notation;
@property (nonatomic, readwrite, getter=isWhitespace) BOOL whitespace;
@property (nonatomic, readwrite, getter=isSignificantWhitespace) BOOL significantWhitespace;
@property (nonatomic, readwrite, getter=isEndTag) BOOL endTag;
@property (nonatomic, readwrite, getter=isEndEntity) BOOL endEntity;
@property (nonatomic, readwrite, getter=isXmlDecl) BOOL xmlDecl;
@property (nonatomic, readwrite, copy) NSString *stringValue;
@property (nonatomic, readwrite) TODXmlTokenType tokenType;
@property (nonatomic, readwrite, copy) id value;
@end

@implementation TODXmlToken

+ (TODXmlToken *)EOFToken {
	static TODXmlToken *EOFToken = nil;
	@synchronized (self) {
		if (!EOFToken) {
			EOFToken = [[TODXmlTokenEOF alloc] initWithTokenType:TODTT_XML_EOF stringValue:nil];
		}
	}
	return EOFToken;
}


+ (id)tokenWithTokenType:(TODXmlTokenType)t stringValue:(NSString *)s {
	return [[[[self class] alloc] initWithTokenType:t stringValue:s] autorelease];
}


#pragma mark -

// designated initializer
- (id)initWithTokenType:(TODXmlTokenType)t stringValue:(NSString *)s {
	self = [super init];
	if (self != nil) {
		self.tokenType = t;
		self.stringValue = s;
		
		self.none = (TODTT_XML_NONE == t);
		self.startTag = (TODTT_XML_START_TAG == t);
		self.attribute = (TODTT_XML_ATTRIBUTE == t);
		self.text = (TODTT_XML_TEXT == t);
		self.cdata = (TODTT_XML_CDATA == t);
		self.entityRef = (TODTT_XML_ENTITY_REF == t);
		self.entity = (TODTT_XML_ENTITY == t);
		self.processingInstruction = (TODTT_XML_PROCESSING_INSTRUCTION == t);
		self.comment = (TODTT_XML_COMMENT == t);
		self.document = (TODTT_XML_DOCUMENT == t);
		self.doctype = (TODTT_XML_DOCTYPE == t);
		self.fragment = (TODTT_XML_FRAGMENT == t);
		self.notation = (TODTT_XML_NOTATION == t);
		self.whitespace = (TODTT_XML_WHITESPACE == t);
		self.significantWhitespace = (TODTT_XML_SIGNIFICANT_WHITESPACE == t);
		self.endTag = (TODTT_XML_END_TAG == t);
		self.endEntity = (TODTT_XML_END_ENTITY == t);
		self.xmlDecl = (TODTT_XML_XML_DECL == t);
		
		self.value = stringValue;
	}
	return self;
}


- (void)dealloc {
	self.stringValue = nil;
	self.value = nil;
	[super dealloc];
}


- (NSUInteger)hash {
	return [stringValue hash];
}


- (BOOL)isEqual:(id)rhv {
	if (![rhv isMemberOfClass:[TODXmlToken class]]) {
		return NO;
	}
	
	TODXmlToken *that = (TODXmlToken *)rhv;
	if (tokenType != that.tokenType) {
		return NO;
	}
	
	return [stringValue isEqualToString:that.stringValue];
}


- (BOOL)isEqualIgnoringCase:(id)rhv {
	if (![rhv isMemberOfClass:[TODXmlToken class]]) {
		return NO;
	}
	
	TODXmlToken *that = (TODXmlToken *)rhv;
	if (tokenType != that.tokenType) {
		return NO;
	}
	
	return [stringValue.lowercaseString isEqualToString:that.stringValue.lowercaseString];
}


- (NSString *)debugDescription {
	NSString *typeString = nil;
	if (self.isNone) {
		typeString = @"None";
	} else if (self.isStartTag) {
		typeString = @"Start Tag";
	} else if (self.isAttribute) {
		typeString = @"Attribute";
	} else if (self.isText) {
		typeString = @"Text";
	} else if (self.isCdata) {
		typeString = @"CData";
	} else if (self.isEntityRef) {
		typeString = @"Entity Reference";
	} else if (self.isEntity) {
		typeString = @"Entity";
	} else if (self.isProcessingInstruction) {
		typeString = @"Processing Instruction";
	} else if (self.isComment) {
		typeString = @"Comment";
	} else if (self.isDocument) {
		typeString = @"Document";
	} else if (self.isDoctype) {
		typeString = @"Doctype";
	} else if (self.isFragment) {
		typeString = @"Fragment";
	} else if (self.isNotation) {
		typeString = @"Notation";
	} else if (self.isWhitespace) {
		typeString = @"Whitespace";
	} else if (self.isSignificantWhitespace) {
		typeString = @"Significant Whitespace";
	} else if (self.isEndTag) {
		typeString = @"End Tag";
	} else if (self.isEndEntity) {
		typeString = @"End Entity";
	} else if (self.isXmlDecl) {
		typeString = @"XML Declaration";
	}
	return [NSString stringWithFormat:@"<%@ %C%@%C>", typeString, 0x00ab, self.value, 0x00bb];
}


- (NSString *)description {
	return stringValue;
}

@synthesize none;
@synthesize startTag;
@synthesize attribute;
@synthesize text;
@synthesize cdata;
@synthesize entityRef;
@synthesize entity;
@synthesize processingInstruction;
@synthesize comment;
@synthesize document;
@synthesize doctype;
@synthesize fragment;
@synthesize notation;
@synthesize whitespace;
@synthesize significantWhitespace;
@synthesize endTag;
@synthesize endEntity;
@synthesize xmlDecl;
@synthesize stringValue;
@synthesize tokenType;
@synthesize value;
@end
