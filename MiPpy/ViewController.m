//
//  ViewController.m
//  MiPpy
//
//  Created by ewan on 1/10/15.
//  Copyright (c) 2015 Laconic Droid. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // listen for callbacks
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mipFoundNotification:)
                                                 name:MipRobotFinderNotificationID object:nil];
    
    // Init the robot finder
    [MipRobotFinder sharedInstance];
    
    [[MipRobotFinder sharedInstance] scanForMipsForDuration:5];
}


- (void) MipDeviceReady:(MipRobot *)mip {
    NSLog(@"We are connected to MiP and ready to go");
}

- (void) MipDeviceDisconnected:(MipRobot *)mip error:(NSError *)error {
    NSLog(@"A mip was disconnected");
}

- (void)mipFoundNotification:(NSNotification *)note {
    NSDictionary *noteDict = note.userInfo;
    if (!noteDict || !noteDict[@"code"]) {
        // Looks like an invalid notification
        NSLog(@"Invalid Notification...");
        return;
    }
    MipRobotFinderNote noteType = (MipRobotFinderNote)[noteDict[@"code"] integerValue];
    
    if (noteType == MipRobotFinderNote_MipFound) {
        MipRobot *mip = noteDict[@"data"];
        NSLog(@"Found: %@", mip);
        mip.delegate = self;
        
        // TODO: change this if you don't need to automatically connect to first mip
        [mip connect];
    } else if (noteType == MipRobotFinderNote_BluetoothError) {
        CBCentralManagerState errorCode = (CBCentralManagerState)[noteDict[@"data"] integerValue];
        if (errorCode == CBCentralManagerStateUnsupported) {
            NSLog(@"Bluetooth Unsupported on this device");
        } else if (errorCode == CBCentralManagerStatePoweredOff) {
            NSLog(@"Bluetooth is turned off");
        }
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MipRobotFinderNotificationID object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
