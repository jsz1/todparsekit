//
//  TDRobotCommandTest.m
//  TDParseKit
//
//  Created by Todd Ditchendorf on 7/14/08.
//  Copyright 2008 Todd Ditchendorf. All rights reserved.
//

#import "TDRobotCommandTest.h"

@interface RobotCommand : NSObject {
    NSString *location;
}
@property (copy) NSString *location;
@end

@implementation RobotCommand

- (void)dealloc {
    self.location = nil;
    [super dealloc];
}


- (id)copyWithZone:(NSZone *)zone {
    RobotCommand *c = [[RobotCommand allocWithZone:zone] init];
    c->location = [location copy];
    return c;
}

@synthesize location;
@end

@interface RobotPickCommand : RobotCommand {}
@end
@implementation RobotPickCommand
- (NSString *)description { return [NSString stringWithFormat:@"pick %@", self.location]; }
@end

@interface RobotPlaceCommand : RobotCommand {}
@end
@implementation RobotPlaceCommand
- (NSString *)description { return [NSString stringWithFormat:@"place %@", self.location]; }
@end

@interface RobotScanCommand : RobotCommand {}
@end
@implementation RobotScanCommand
- (NSString *)description { return [NSString stringWithFormat:@"scan %@", self.location]; }
@end

@implementation TDRobotCommandTest

//    e = command*
//    command = pickCommand | placeCommand | scanCommand
//    pickCommand = "pick" "carrier" "from" location
//    placeCommand = "place" "carrier" "at" location
//    scanCommand = "scan" location
//    location = Word

- (PKParser *)location {
    return [TDWord word];
}


- (PKParser *)pickCommand {
    PKSequence *s = [PKSequence sequence];
    [s add:[[TDCaseInsensitiveLiteral literalWithString:@"pick"] discard]];
    [s add:[[TDCaseInsensitiveLiteral literalWithString:@"carrier"] discard]];
    [s add:[[TDCaseInsensitiveLiteral literalWithString:@"from"] discard]];
    [s add:[self location]];
    [s setAssembler:self selector:@selector(workOnPickCommand:)];
    return s;
}


- (PKParser *)placeCommand {
    PKSequence *s = [PKSequence sequence];
    [s add:[[TDCaseInsensitiveLiteral literalWithString:@"place"] discard]];
    [s add:[[TDCaseInsensitiveLiteral literalWithString:@"carrier"] discard]];
    [s add:[[TDCaseInsensitiveLiteral literalWithString:@"at"] discard]];
    [s add:[self location]];
    [s setAssembler:self selector:@selector(workOnPlaceCommand:)];
    return s;
}


- (PKParser *)scanCommand {
    PKSequence *s = [PKSequence sequence];
    [s add:[[TDCaseInsensitiveLiteral literalWithString:@"scan"] discard]];
    [s add:[self location]];
    [s setAssembler:self selector:@selector(workOnScanCommand:)];
    return s;
}


- (PKParser *)command {
    PKAlternation *a = [PKAlternation alternation];
    [a add:[self pickCommand]];
    [a add:[self placeCommand]];
    [a add:[self scanCommand]];
    return a;
}


- (void)testPick {
    NSString *s1 = @"pick carrier from LINE_IN";
    
    PKTokenAssembly *a = [PKTokenAssembly assemblyWithString:s1];
    PKParser *p = [self command];
    PKAssembly *result = [p bestMatchFor:a];

    TDNotNil(result);
    TDEqualObjects(@"[]pick/carrier/from/LINE_IN^", [result description]);

    id target = result.target;
    TDNotNil(target);
    TDEqualObjects(@"pick LINE_IN", [target description]);
}


- (void)testPlace {
    NSString *s2 = @"place carrier at LINE_OUT";
    
    PKTokenAssembly *a = [PKTokenAssembly assemblyWithString:s2];
    PKParser *p = [self command];
    PKAssembly *result = [p bestMatchFor:a];
    
    TDNotNil(result);
    TDEqualObjects(@"[]place/carrier/at/LINE_OUT^", [result description]);

    id target = result.target;
    TDNotNil(target);
    TDEqualObjects(@"place LINE_OUT", [target description]);
}


- (void)testScan {
    NSString *s3 = @"scan DB101_OUT";
    
    PKTokenAssembly *a = [PKTokenAssembly assemblyWithString:s3];
    PKParser *p = [self command];
    PKAssembly *result = [p bestMatchFor:a];
    
    TDNotNil(result);
    TDEqualObjects(@"[]scan/DB101_OUT^", [result description]);

    id target = result.target;
    TDNotNil(target);
    TDEqualObjects(@"scan DB101_OUT", [target description]);
}


- (void)workOnPickCommand:(PKAssembly *)a {
    RobotPickCommand *c = [[[RobotPickCommand alloc] init] autorelease];
    PKToken *location = [a pop];
    c.location = location.stringValue;
    a.target = c;
}


- (void)workOnPlaceCommand:(PKAssembly *)a {
    RobotPlaceCommand *c = [[[RobotPlaceCommand alloc] init] autorelease];
    PKToken *location = [a pop];
    c.location = location.stringValue;
    a.target = c;
}


- (void)workOnScanCommand:(PKAssembly *)a {
    RobotScanCommand *c = [[[RobotScanCommand alloc] init] autorelease];
    PKToken *location = [a pop];
    c.location = location.stringValue;
    a.target = c;
}

@end
