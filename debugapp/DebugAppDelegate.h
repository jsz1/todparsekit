//
//  DebugAppDelegate.h
//  TDParseKit
//
//  Created by Todd Ditchendorf on 8/12/08.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DebugAppDelegate : NSObject {
	NSAttributedString *displayString;
}
- (IBAction)run:(id)sender;

@property (retain) NSAttributedString *displayString;
@end
