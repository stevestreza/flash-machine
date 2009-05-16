//
//  FMFlashGame.m
//  FlashMachine
//
//  Created by Steve Streza on 5/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FMFlashGame.h"


@implementation FMFlashGame

static NSDictionary *sAllFlashGames = nil;

+(FMFlashGame *)flashGameForURL:(NSURL *)aPath{
	return [self flashGameForURL:aPath createIfNecessary:NO];
}

+(FMFlashGame *)flashGameForURL:(NSURL *)aPath createIfNecessary:(BOOL)create{
	id retVal = nil;
	if(aPath && sAllFlashGames){
		retVal = [sAllFlashGames objectForKey:[aPath absoluteString]];
		if(!retVal && create){
			FMFlashGame *game = [[self alloc] initWithURL:aPath];
			retVal = [game autorelease];
		}
	}
	return retVal;
}

-(id)initWithURL:(NSURL *)aPath{
	if(!aPath) goto fail;
	
	if(self = [super init]){
		_path = [aPath copy];
		
		if(!sAllFlashGames){
			sAllFlashGames = [[NSMutableDictionary dictionary] retain];
		}
		[(NSMutableDictionary *)sAllFlashGames setObject:self forKey:[_path absoluteString]];
	}
	return self;
	
fail:
	[self release];
	return nil;
}

-(void)dealloc{
	[_path release];
	_path = nil;
	
	[super dealloc];
}

-(NSURL *)path{
	return _path;
}

-(NSString *)fileName{
	return [[[[_path absoluteString] lastPathComponent] stringByDeletingPathExtension] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

@end
