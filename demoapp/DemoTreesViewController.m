//
//  DemoTreesViewController.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/2/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "DemoTreesViewController.h"
#import "PKParseTreeView.h"
#import <ParseKit/ParseKit.h>

@implementation DemoTreesViewController

- (id)init {
    return [self initWithNibName:@"TreesView" bundle:nil];
}


- (id)initWithNibName:(NSString *)name bundle:(NSBundle *)b {
    if (self = [super initWithNibName:name bundle:b]) {
        
    }
    return self;
}


- (void)dealloc {
    self.grammarString = nil;
    self.inString = nil;
    [super dealloc];
}


- (void)awakeFromNib {
//    self.grammarString = @"@allowsScientificNotation=YES;\n@start = expr;\nexpr = addExpr;\naddExpr = multExpr (('+'|'-') multExpr)*;\nmultExpr = atom (('*'|'/') atom)*;\natom = Number;";
//    self.grammarString = @"@start = array;array = '[' Number (commaNumber)* ']';commaNumber = ',' Number;";
    self.grammarString = @"@start = array;array = foo | Word; foo = 'foo';";
//    self.inString = @"4.0*.4 + 2e-12/-47 +3";
//    self.inString = @"[1,2]";
    self.inString = @"foo";
}


- (IBAction)parse:(id)sender {
    if (![inString length] || ![grammarString length]) {
        NSBeep();
        return;
    }
    
    self.busy = YES;
    
    [NSThread detachNewThreadSelector:@selector(doParse) toTarget:self withObject:nil];
}


- (void)doParse {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    PKParseTreeAssembler *as = [[[PKParseTreeAssembler alloc] init] autorelease];
    PKParser *p = [[PKParserFactory factory] parserFromGrammar:grammarString assembler:as preassembler:as];
    PKParseTree *tr = [p parse:inString];
    [parseTreeView drawParseTree:tr];
    
    [self performSelectorOnMainThread:@selector(done) withObject:nil waitUntilDone:NO];
    
    [pool drain];
}


- (void)done {
    self.busy = NO;
}    


#pragma mark -
#pragma mark NSSplitViewDelegate

- (BOOL)splitView:(NSSplitView *)sv canCollapseSubview:(NSView *)v {
    return v == [[sv subviews] objectAtIndex:1];
}


- (BOOL)splitView:(NSSplitView *)sv shouldCollapseSubview:(NSView *)v forDoubleClickOnDividerAtIndex:(NSInteger)i {
    return [self splitView:sv canCollapseSubview:v];
}



// maintain constant splitview width when resizing window
- (void)splitView:(NSSplitView *)sv resizeSubviewsWithOldSize:(NSSize)oldSize {    
    NSRect newFrame = [sv frame]; // get the new size of the whole splitView
    NSView *top = [[sv subviews] objectAtIndex:0];
    NSRect topFrame = [top frame];
    NSView *bottom = [[sv subviews] objectAtIndex:1];
    NSRect bottomFrame = [bottom frame];
    
    CGFloat dividerThickness = [sv dividerThickness];
    topFrame.size.width = newFrame.size.width;
    
    bottomFrame.size.height = newFrame.size.height - topFrame.size.height - dividerThickness;
    bottomFrame.size.width = newFrame.size.width;
    topFrame.origin.y = 0;
    
    [top setFrame:topFrame];
    [bottom setFrame:bottomFrame];
}


- (CGFloat)splitView:(NSSplitView *)sv constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)i {
    if (0 == i) {
        return 200;
    } else {
        return proposedMin;
    }
}


- (CGFloat)splitView:(NSSplitView *)sv constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)i {
    return proposedMax;
}

@synthesize grammarString;
@synthesize inString;
@synthesize busy;
@end

