//
//  ConnectionDelegate.m
//  iCouldUse
//
//  Created by ka010 on 07.11.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ConnectionDelegate.h"

@protocol ConnectionResultDelegate <NSObject>
-(void)serverAvailable;
-(void)serverUnavailable;
@end

@interface ConnectionDelegate()
@property (nonatomic, weak) id<ConnectionResultDelegate> target;
@end

@implementation ConnectionDelegate
@synthesize target;

- (id) initWithTarget:(id)aTarget
{
	self = [super init];
	if (self != nil) {
		self.target = aTarget;
	}
	return self;
}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[self.target serverUnavailable];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[self.target serverAvailable];
}
@end
