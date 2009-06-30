//
//  PKJSNumberState.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/9/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDJSNumberState.h"
#import "PKJSUtils.h"
#import "TDJSTokenizerState.h"
#import <ParseKit/PKNumberState.h>

#pragma mark -
#pragma mark Methods

static JSValueRef TDNumberState_toString(JSContextRef ctx, JSObjectRef function, JSObjectRef this, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    TDPreconditionInstaceOf(TDNumberState_class, "toString");
    return TDNSStringToJSValue(ctx, @"[object PKNumberState]", ex);
}

#pragma mark -
#pragma mark Properties

static JSValueRef TDNumberState_getAllowsTrailingDot(JSContextRef ctx, JSObjectRef this, JSStringRef propName, JSValueRef *ex) {
    PKNumberState *data = JSObjectGetPrivate(this);
    return JSValueMakeBoolean(ctx, data.allowsTrailingDot);
}

static bool TDNumberState_setAllowsTrailingDot(JSContextRef ctx, JSObjectRef this, JSStringRef propertyName, JSValueRef value, JSValueRef *ex) {
    PKNumberState *data = JSObjectGetPrivate(this);
    data.allowsTrailingDot = JSValueToBoolean(ctx, value);
    return true;
}

#pragma mark -
#pragma mark Initializer/Finalizer

static void TDNumberState_initialize(JSContextRef ctx, JSObjectRef this) {
    
}

static void TDNumberState_finalize(JSObjectRef this) {
    // released in TDTokenizerState_finalize
}

static JSStaticFunction TDNumberState_staticFunctions[] = {
{ "toString", TDNumberState_toString, kJSPropertyAttributeDontDelete },
{ 0, 0, 0 }
};

static JSStaticValue TDNumberState_staticValues[] = {        
{ "allowsTrailingDot", TDNumberState_getAllowsTrailingDot, TDNumberState_setAllowsTrailingDot, kJSPropertyAttributeDontDelete }, // Boolean
{ 0, 0, 0, 0 }
};

#pragma mark -
#pragma mark Public

JSClassRef TDNumberState_class(JSContextRef ctx) {
    static JSClassRef jsClass = NULL;
    if (!jsClass) {                
        JSClassDefinition def = kJSClassDefinitionEmpty;
        def.parentClass = TDTokenizerState_class(ctx);
        def.staticFunctions = TDNumberState_staticFunctions;
        def.staticValues = TDNumberState_staticValues;
        def.initialize = TDNumberState_initialize;
        def.finalize = TDNumberState_finalize;
        jsClass = JSClassCreate(&def);
    }
    return jsClass;
}

JSObjectRef TDNumberState_new(JSContextRef ctx, void *data) {
    return JSObjectMake(ctx, TDNumberState_class(ctx), data);
}

JSObjectRef TDNumberState_construct(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKNumberState *data = [[PKNumberState alloc] init];
    return TDNumberState_new(ctx, data);
}
