//
//  AppController.h
//  FlashMachine
//
//  Created by Steve Streza on 5/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "FMFlashGame.h"

#define kFMAppControllerSelectedGameDefaultsKey @"selectedGame"

@interface AppController : NSWindowController {
	IBOutlet WebView *_webView;
	IBOutlet NSArrayController *_flashGamesController;
		
	IBOutlet NSSlider *_volumeSlider;
	
	NSArray *_flashGames;
}

@property (readonly) NSArray *flashGames;

-(void)addGameAtURL:(NSURL *)url;
-(void)loadGamesFromDirectory:(NSString *)dir;

-(void)selectGame:(FMFlashGame *)game;

-(float)volume;
-(void)setVolume:(float)involume;

@end
