//
//  PKParseTreeAssembler.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 7/11/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "PKParseTreeAssembler.h"
#import "PKParseTree.h"
#import "PKRuleNode.h"
#import "PKTokenNode.h"
#import <ParseKit/ParseKit.h>

@interface PKParseTreeAssembler ()
- (NSString *)ruleNameForSelName:(NSString *)selName withPrefix:(NSString *)pre;
- (void)didMatchRuleNamed:(NSString *)name assembly:(PKAssembly *)a;
- (void)willMatchRuleNamed:(NSString *)name assembly:(PKAssembly *)a;
- (void)didMatchToken:(PKAssembly *)a;
- (PKParseTree *)currentFrom:(PKAssembly *)a;

@property (nonatomic, retain) NSMutableDictionary *ruleNames;
@property (nonatomic, copy) NSString *assemblerPrefix;
@property (nonatomic, copy) NSString *preassemblerPrefix;
@property (nonatomic, copy) NSString *suffix;
@end

@implementation PKParseTreeAssembler

- (id)init {
    if (self = [super init]) {
        self.ruleNames = [NSMutableDictionary dictionary];
        self.preassemblerPrefix = @"willMatch";
        self.assemblerPrefix = @"didMatch";
        self.suffix = @":";
    }
    return self;
}


- (void)dealloc {
    self.preassemblerPrefix = nil;
    self.assemblerPrefix = nil;
    self.suffix = nil;
    [super dealloc];
}


- (BOOL)respondsToSelector:(SEL)sel {
    return YES;
    if ([super respondsToSelector:sel]) {
        return YES;
    } else {
        NSString *selName = NSStringFromSelector(sel);
        if ([selName hasPrefix:assemblerPrefix] && [selName hasSuffix:suffix]) {
            return YES;
        }
    }
    return NO;
}


- (id)performSelector:(SEL)sel withObject:(id)obj {
    NSString *selName = NSStringFromSelector(sel);
    
    if ([selName hasPrefix:assemblerPrefix] && [selName hasSuffix:suffix]) {
        [self didMatchRuleNamed:[self ruleNameForSelName:selName withPrefix:assemblerPrefix] assembly:obj];
    } else if ([selName hasPrefix:preassemblerPrefix] && [selName hasSuffix:suffix]) {
        [self willMatchRuleNamed:[self ruleNameForSelName:selName withPrefix:preassemblerPrefix] assembly:obj];
    } else if ([super respondsToSelector:sel]) {
        return [super performSelector:sel withObject:obj];
    } else {
        NSAssert(0, @"");
    }
    return nil;
}


- (NSString *)ruleNameForSelName:(NSString *)selName withPrefix:(NSString *)prefix {
    NSString *ruleName = [ruleNames objectForKey:selName];
    
    if (!ruleName) {
        NSUInteger prefixLen = prefix.length;
        NSInteger c = ((NSInteger)[selName characterAtIndex:prefixLen]) + 32; // lowercase
        NSRange r = NSMakeRange(prefixLen + 1, selName.length - (prefixLen + suffix.length + 1 /*:*/));
        ruleName = [NSString stringWithFormat:@"%C%@", c, [selName substringWithRange:r]];
        [ruleNames setObject:ruleName forKey:selName];
    }
    
    return ruleName;
}


- (void)willMatchRuleNamed:(NSString *)name assembly:(PKAssembly *)a {
//    NSLog(@"willMatch %@ %@", name, a);
    PKParseTree *current = [self currentFrom:a];
    [self didMatchToken:a];
    current = [current addChildRule:name];
    a.target = current;
}


- (void)didMatchRuleNamed:(NSString *)name assembly:(PKAssembly *)a {
//    NSLog(@"didMatch %@ %@", name, a);
    id current = [self currentFrom:a];
    
    
    //id original = [[current retain] autorelease];
    NSArray *origChildren = [[[current children] mutableCopy] autorelease];
    id oldCurrent = nil;
    while ([current isKindOfClass:[PKRuleNode class]] && ![[(id)current name] isEqualToString:name]) {
        NSLog(@"NOT MATCHED %@ %d", [current name], [[current children] count]);
        oldCurrent = [[current retain] autorelease];
        if (![oldCurrent isMatched]) {
           // [(id)[[oldCurrent parent] children] removeObject:oldCurrent];
        }
        a.target = [current parent];
        current = [self currentFrom:a];
        [self didMatchToken:a];        
    }

    if (oldCurrent && ![oldCurrent isMatched]) {
       // [(id)[[oldCurrent parent] children] removeLastObject];
        [(id)[current children] addObjectsFromArray:origChildren];
    }

    
    [self didMatchToken:a];        
    current = [self currentFrom:a];
    
    NSMutableArray *remove = [NSMutableArray array];
    for (id child in [current children]) {
        if (![child isMatched]) {
            [remove addObject:child];
        }
    }
    
    for (id child in remove) {
        NSLog(@"removing : %@", child);
        [(id)[current children] removeObject:child];
    }
    
    [current setMatched:YES];
    a.target = [current parent];
}


- (PKParseTree *)currentFrom:(PKAssembly *)a {
    PKParseTree *current = a.target;
    if (!current) {
        current = [PKParseTree parseTree];
        a.target = current;
    }
    return current;
}


- (void)didMatchToken:(PKAssembly *)a {
//    NSLog(@"didMatchToken %@", a);
    NSMutableArray *toks = [NSMutableArray arrayWithCapacity:[a.stack count]];
    while (![a isStackEmpty]) {
        id tok = [a pop];
        NSAssert([tok isKindOfClass:[PKToken class]], @"");
        [toks addObject:tok];
    }

    id current = [self currentFrom:a];
    for (id tok in [toks reverseObjectEnumerator]) {
        PKTokenNode *n = [current addChildToken:tok];
        [n setMatched:YES];
        [current setMatched:YES];
    }
}

@synthesize ruleNames;
@synthesize preassemblerPrefix;
@synthesize assemblerPrefix;
@synthesize suffix;
@end
