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

#import <CoreAudio/AudioHardware.h>

@interface AppController (Private)

-(void)_updateSelectedGame;
-(void)_setupAudio;

@end

@implementation AppController

@synthesize flashGames=_flashGames;

-(void)awakeFromNib{
	[self _setupAudio];

	_flashGames = [[NSMutableArray array] retain];
	[_flashGamesController addObserver:self forKeyPath:@"selection" options:0 context:nil];

	NSURL *savedURL = [[NSUserDefaults standardUserDefaults] objectForKey:kFMAppControllerSelectedGameDefaultsKey];
	savedURL = [NSURL URLWithString:(NSString *)savedURL];
	
	NSString *directory = [@"~/Dropbox/Flash Games/" stringByExpandingTildeInPath];
	[self loadGamesFromDirectory:directory];
	
	[self selectGame:[FMFlashGame flashGameForURL:savedURL createIfNecessary:YES]];
}

-(void)_setupAudio{
#define FMThrowIfError(__cond, __msg) do{ error = (__cond); if(error != noErr){ NSLog(@"Error: %@",(__msg)); goto fail; } }while(0)
#define FMCatch() fail:

#define FMLogBytes(__bytes, __length) \
do{ \
NSUInteger __fmIndex=0; \
NSUInteger __fmLength = (__length); \
void *__fmBytes = (void*)(__bytes); \
for(__fmIndex=0; __fmIndex < __fmLength; __fmIndex++){\
printf("%02X ", ((char*)(__fmBytes))[__fmIndex]);\
}\
printf("\n");\
}while(0)

}

- (float)volume {
	float			b_vol;
	OSStatus		err;
	AudioDeviceID		device;
	UInt32			size;
	UInt32			channels[2];
	float			volume[2];
	
	// get device
	size = sizeof device;
	err = AudioHardwareGetProperty(kAudioHardwarePropertyDefaultOutputDevice, &size, &device);
	if(err!=noErr) {
		NSLog(@"audio-volume error get device");
		return 0.0;
	}
	
	// try set master volume (channel 0)
	size = sizeof b_vol;
	err = AudioDeviceGetProperty(device, 0, 0, kAudioDevicePropertyVolumeScalar, &size, &b_vol);	//kAudioDevicePropertyVolumeScalarToDecibels
	if(noErr==err) return b_vol;
	
	// otherwise, try seperate channels
	// get channel numbers
	size = sizeof(channels);
	err = AudioDeviceGetProperty(device, 0, 0,kAudioDevicePropertyPreferredChannelsForStereo, &size,&channels);
	if(err!=noErr) NSLog(@"error getting channel-numbers");
	
	size = sizeof(float);
	err = AudioDeviceGetProperty(device, channels[0], 0, kAudioDevicePropertyVolumeScalar, &size, &volume[0]);
	if(noErr!=err) NSLog(@"error getting volume of channel %d",channels[0]);
	err = AudioDeviceGetProperty(device, channels[1], 0, kAudioDevicePropertyVolumeScalar, &size, &volume[1]);
	if(noErr!=err) NSLog(@"error getting volume of channel %d",channels[1]);
	
	b_vol = (volume[0]+volume[1])/2.00;
	
	return  b_vol;
}

// setting system volume
- (void)setVolume:(float)involume {
	OSStatus		err;
	AudioDeviceID		device;
	UInt32			size;
	Boolean			canset	= false;
	UInt32			channels[2];
	//float			volume[2];
	
	// get default device
	size = sizeof device;
	err = AudioHardwareGetProperty(kAudioHardwarePropertyDefaultOutputDevice, &size, &device);
	if(err!=noErr) {
		NSLog(@"audio-volume error get device");
		return;
	}
	
	
	// try set master-channel (0) volume
	size = sizeof canset;
	err = AudioDeviceGetPropertyInfo(device, 0, false, kAudioDevicePropertyVolumeScalar, &size, &canset);
	if(err==noErr && canset==true) {
		size = sizeof involume;
		err = AudioDeviceSetProperty(device, NULL, 0, false, kAudioDevicePropertyVolumeScalar, size, &involume);
		return;
	}
	
	// else, try seperate channes
	// get channels
	size = sizeof(channels);
	err = AudioDeviceGetProperty(device, 0, false, kAudioDevicePropertyPreferredChannelsForStereo, &size,&channels);
	if(err!=noErr) {
		NSLog(@"error getting channel-numbers");
		return;
	}
	
	// set volume
	size = sizeof(float);
	err = AudioDeviceSetProperty(device, 0, channels[0], false, kAudioDevicePropertyVolumeScalar, size, &involume);
	if(noErr!=err) NSLog(@"error setting volume of channel %d",channels[0]);
	err = AudioDeviceSetProperty(device, 0, channels[1], false, kAudioDevicePropertyVolumeScalar, size, &involume);
	if(noErr!=err) NSLog(@"error setting volume of channel %d",channels[1]);
	
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
