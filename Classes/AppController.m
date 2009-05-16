//
//  AppController.m
//  FlashMachine
//
//  Created by Steve Streza on 5/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AppController.h"
#import "FMFlashGame.h"
#import "NSArray+FMExtensions.h"

@interface AppController (Private)

-(void)_updateSelectedGame;

@end

@implementation AppController

@synthesize flashGames=_flashGames;

-(void)awakeFromNib{
	_flashGames = [[NSMutableArray array] retain];
	[_flashGamesController addObserver:self forKeyPath:@"selection" options:0 context:nil];

	NSURL *savedURL = [[NSUserDefaults standardUserDefaults] objectForKey:kFMAppControllerSelectedGameDefaultsKey];
	savedURL = [NSURL URLWithString:(NSString *)savedURL];
	
	NSString *directory = [@"~/Dropbox/Flash Games/" stringByExpandingTildeInPath];
	[self loadGamesFromDirectory:directory];
	
	[self selectGame:[FMFlashGame flashGameForURL:savedURL createIfNecessary:YES]];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == _flashGamesController && [keyPath isEqualToString:@"selection"]) {
		[self _updateSelectedGame];
	}else{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

-(void)selectGame:(FMFlashGame *)game{
	if(game){
		[_flashGamesController setSelectedObjects:[NSArray arrayWithObject:game]];
	}
}

-(void)_updateSelectedGame{
	FMFlashGame *game = [[_flashGamesController selectedObjects] firstObject];
	if(game){
		[[self window] setTitle:[game fileName]];

		[[_webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[game path]]];
		[[self window] makeFirstResponder:_webView];
		
		[[NSUserDefaults standardUserDefaults] setObject: [[game path]  absoluteString]
												  forKey: kFMAppControllerSelectedGameDefaultsKey];
	}
}

-(void)loadGamesFromDirectory:(NSString *)dir{
	NSFileManager *fm = [[[NSFileManager alloc] init] autorelease];
	
	if([fm changeCurrentDirectoryPath:dir]){
		NSArray *files = [fm contentsOfDirectoryAtPath:@"." error:nil];
		for(NSString *filename in files){
			if([[filename pathExtension] isEqualToString:@"swf"]){
				NSString *fullPath = [dir stringByAppendingPathComponent:filename];
				NSURL *fileURL = (NSURL *)(CFURLCreateWithFileSystemPath(NULL, (CFStringRef)fullPath, kCFURLPOSIXPathStyle, NO));
				
				[self addGameAtURL:fileURL];
				
				[fileURL release];
			}
		}
	}
}

-(void)addGameAtURL:(NSURL *)url{
	if(!url) return;
	
	FMFlashGame *game = [[FMFlashGame alloc] initWithURL:url];
	NSLog(@"Adding game at URL %@ - %@ (%@)",url, game, [game fileName]);
	
	NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:_flashGames.count];
	
	[self willChange: NSKeyValueChangeInsertion 
	 valuesAtIndexes: indexSet
			  forKey: @"flashGames"];

	[(NSMutableArray *)_flashGames addObject:game];

	[self  didChange: NSKeyValueChangeInsertion 
	 valuesAtIndexes: indexSet
			  forKey: @"flashGames"];
	
	[game release];
}

@end
