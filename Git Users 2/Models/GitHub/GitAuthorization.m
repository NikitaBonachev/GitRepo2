//
//  GitAuthorization.m
//  Git Users 2
//
//  Created by Bonachev Nikita on 13.03.16.
//  Copyright © 2016 Bonachev Nikita. All rights reserved.
//

#import "GitAuthorization.h"
#import "AuthorizationAlert.h"

@implementation GitAuthorization

+ (void)startAuthorizationWithLogin:(NSString *)login password:(NSString *)password {
	NSURL *url = [NSURL URLWithString: @"https://api.github.com"];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	NSString *authStr = [NSString stringWithFormat:@"%@:%@", login, password];
	NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
	NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
	
	[request setHTTPMethod:@"GET"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	[request setValue:authValue forHTTPHeaderField:@"Authorization"];
	
	NSURLSession *session = [NSURLSession sharedSession];
	
	[[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
		
		if (!error) {
			NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
			
			if ([responseDictionary[@"message"] isEqual: @"Bad credentials"]) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[[NSNotificationCenter defaultCenter] postNotificationName:@"BadCredentialsLoginOrPassword" object:self];
				});
			} else {
				dispatch_async(dispatch_get_main_queue(), ^{
					[[NSNotificationCenter defaultCenter] postNotificationName:@"GoodCredentials" object:self];
				});
			}
			
		}
		
	}] resume];
}

@end
