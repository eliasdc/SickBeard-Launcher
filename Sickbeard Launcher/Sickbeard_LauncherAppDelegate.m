//
//  Sickbeard_LauncherAppDelegate.m
//  Sickbeard Launcher
//
//  Created by Kai Aras on 7/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Sickbeard_LauncherAppDelegate.h"
@interface Sickbeard_LauncherAppDelegate()
@property (nonatomic, strong) NSStatusItem *statusItem;
@property (nonatomic, strong) NSTask *serverTask;
@property (nonatomic, weak) IBOutlet NSWindow *window;
@property (nonatomic, weak) IBOutlet NSMenu *statusMenu;
@property (nonatomic, weak) IBOutlet NSTextField *pathField;
@end

@implementation Sickbeard_LauncherAppDelegate
#pragma mark - IBActions

- (IBAction)open:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://localhost:8081"]];
}

- (IBAction)preferences:(id)sender {
    [self.window makeKeyAndOrderFront:self];
}

- (IBAction)quit:(id)sender {
    [self stopServer];
    exit(0);
}

-(IBAction)setSickbeardPath:(id)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setTitle:@"Select your SickBeard directory"];
    [openPanel setCanChooseFiles:NO];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setAllowsMultipleSelection:NO];
    NSString* fileName;
    if ( [openPanel runModal] == NSFileHandlingPanelOKButton )
    {
        NSArray* files = [openPanel URLs];
        fileName = [[files objectAtIndex:0] path];
        NSLog(@"filename: %@",fileName);
        [self.pathField setStringValue:fileName];
    }
}

-(IBAction)savePreferences:(id)sender {
    [[NSUserDefaults standardUserDefaults]setObject:[self.pathField stringValue] forKey:@"sickbeardpath"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [self.window close];
}

-(IBAction)cancelPreferences:(id)sender {
    [self.window close];
    [self setProperties];
}

#pragma mark - Sickbeard Process Wrapper

- (void)startServer {
    NSString *path = [[self.pathField stringValue] stringByAppendingPathComponent:@"SickBeard.py"];
    NSArray *args = [NSArray arrayWithObjects:path,@"--quiet", nil];
    
    self.serverTask = [[NSTask alloc]init];
    [self.serverTask setLaunchPath:@"/usr/bin/python"];
    [self.serverTask setArguments:args];
    [self.serverTask launch];
}

-(void)stopServer {
    if ([self.serverTask isRunning]) {
        [self.serverTask terminate];
        self.serverTask = nil;
    }
}

-(void)checkServer {
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:8081"]];
    ConnectionDelegate *_delegate = [[ConnectionDelegate alloc]initWithTarget:self];
    [NSURLConnection connectionWithRequest:req delegate:_delegate];
}

-(void)serverUnavailable {
    if ([[NSUserDefaults standardUserDefaults]stringForKey:@"sickbeardpath"] == nil) {
        [self.window makeKeyAndOrderFront:self];
        return;
    }
    NSLog(@"Server unavailable!");
    [self.statusItem setImage:[NSImage imageNamed:@"menuicon_bw"]];
    [self quit:nil];
}

-(void)serverAvailable {
    NSLog(@"Server available!");
}

#pragma mark - NSApp Delegate

-(void)setProperties {
    NSString *path = [[NSUserDefaults standardUserDefaults]stringForKey:@"sickbeardpath"];
    if (path != nil) {
        [self.pathField setStringValue:path];
    }
}

-(void)awakeFromNib {
    [self setProperties];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.statusItem = [[NSStatusBar systemStatusBar]statusItemWithLength:NSVariableStatusItemLength];
	[self.statusItem setMenu:self.statusMenu];
	[self.statusItem setHighlightMode:YES];
	[self.statusItem setImage:[NSImage imageNamed:@"menuicon_bw"]];
    
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:8081"]];
    NSError * error;
    [NSURLConnection sendSynchronousRequest:req returningResponse:nil error:&error];
    if (error != nil) {
        [self startServer];
    } else {
        NSLog(@"SickBeard allready started");
        [self open:nil];
    }
    [self.statusItem setImage:[NSImage imageNamed:@"menuicon"]];
    [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(checkServer) userInfo:nil repeats:YES];
}

-(void)applicationWillTerminate:(NSNotification *)notification {
    [self stopServer];
}
@end
