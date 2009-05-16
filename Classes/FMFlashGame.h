//
//  FMFlashGame.h
//  FlashMachine
//
//  Created by Steve Streza on 5/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface FMFlashGame : NSObject {
	NSURL *_path;
}

+(FMFlashGame *)flashGameForURL:(NSURL *)aPath;
+(FMFlashGame *)flashGameForURL:(NSURL *)aPath createIfNecessary:(BOOL)create;

-(id)initWithURL:(NSURL *)aPath;

@property (readonly) NSURL *path;
-(NSString *)fileName;

@end
