//
//  LostConnectionAlert.m
//  Git Users 2
//
//  Created by Bonachev Nikita on 12.03.16.
//  Copyright © 2016 Bonachev Nikita. All rights reserved.
//

#import "LostConnectionAlert.h"
#import "UIAlertController+Window.h"

@implementation LostConnectionAlert

+ (void)lostConnectionShow {
	UIAlertController *connectionAlert = [UIAlertController alertControllerWithTitle:@"Error"
																			 message:@"Check your internet connection"
																	  preferredStyle:UIAlertControllerStyleAlert];
	
	UIAlertAction *okayAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
	
	[connectionAlert addAction:okayAction];
	
	[connectionAlert show];
}

@end
