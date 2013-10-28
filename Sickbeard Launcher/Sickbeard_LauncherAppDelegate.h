//
//  Sickbeard_LauncherAppDelegate.h
//  Sickbeard Launcher
//
//  Created by Kai Aras on 7/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ConnectionDelegate.h"
@interface Sickbeard_LauncherAppDelegate : NSObject <NSApplicationDelegate>
-(IBAction)open:(id)sender;
-(IBAction)preferences:(id)sender;
-(IBAction)quit:(id)sender;
-(IBAction)setSickbeardPath:(id)sender;
-(IBAction)savePreferences:(id)sender;
-(IBAction)cancelPreferences:(id)sender;
@end
