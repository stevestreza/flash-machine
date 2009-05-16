//
//  NSArray+FMExtensions.m
//  FlashMachine
//
//  Created by Steve Streza on 5/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NSArray+FMExtensions.h"

@implementation NSArray (FMExtensions)

-(id)firstObject{
	if(self.count > 0){
		return [self objectAtIndex:0];
	}
	return nil;
}

@end
