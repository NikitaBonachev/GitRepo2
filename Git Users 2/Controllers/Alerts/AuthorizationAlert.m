//
//  AuthorizationAlert.m
//  Git Users 2
//
//  Created by Bonachev Nikita on 13.03.16.
//  Copyright © 2016 Bonachev Nikita. All rights reserved.
//

#import "UIAlertController+Window.h"
#import "AuthorizationAlert.h"
#import "RepositoriesStore.h"
#import "GitAuthorization.h"

@implementation AuthorizationAlert

static NSString *login;

+ (NSString *) login {
	return login;
}

+ (void) setLogin:(NSString *)newLogin {
	login = newLogin;
}


static NSString *password;

+ (NSString *) password {
	return password;
}
+ (void) setPassword:(NSString *)newPassword {
	password = newPassword;
}

#pragma mark - Show Alerts

+ (void)showSuccessAlert
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	[self saveLogin:self.login password:self.password];
	
	UIAlertController *successAlert = [UIAlertController alertControllerWithTitle:@"Success"
																		  message:@"Now you are authorized."
																   preferredStyle:UIAlertControllerStyleAlert];
	
	[successAlert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
	[successAlert show];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SuccessAuthorization" object:self];
}

+ (void)showErrorAlert
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Error"
																		message:@"Wrong login or password."
																 preferredStyle:UIAlertControllerStyleAlert];
	
	[errorAlert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		[errorAlert dismissViewControllerAnimated:YES completion:nil];
		[self authorizationDialogShow];
	}]];
	
	[errorAlert show];
}

+ (void)authorizationDialogShow
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showErrorAlert) name:@"BadCredentialsLoginOrPassword" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSuccessAlert) name:@"GoodCredentials" object:nil];
	});
	
	__block UITextField *loginTextField;
	__block UITextField *passwordTextField;
	
	UIAlertController *authorizationAlert = [UIAlertController alertControllerWithTitle:@"Authorization"
																				message:@"Enter login and password."
																		 preferredStyle:UIAlertControllerStyleAlert];
	
	[authorizationAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
		loginTextField = textField;
		loginTextField.placeholder = @"Login";
	}];
	
	[authorizationAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
		passwordTextField = textField;
		passwordTextField.placeholder = @"Password";
		passwordTextField.secureTextEntry = YES;
	}];
	
	[authorizationAlert addAction:[UIAlertAction actionWithTitle:@"Login"
														   style:UIAlertActionStyleDefault
														 handler:^(UIAlertAction * _Nonnull action) {
															 [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
															 [authorizationAlert dismissViewControllerAnimated:YES completion:nil];
															 [AuthorizationAlert setLogin:loginTextField.text];
															 self.password = passwordTextField.text;
															 [GitAuthorization startAuthorizationWithLogin:self.login password:self.password];
														 }]];
	
	[authorizationAlert addAction:[UIAlertAction actionWithTitle:@"Cancel"
														   style:UIAlertActionStyleCancel
														 handler:^(UIAlertAction * _Nonnull action) {
															 [authorizationAlert dismissViewControllerAnimated:YES completion:nil];
															 [authorizationAlert.view endEditing:YES];
															 [loginTextField resignFirstResponder];
															 [passwordTextField resignFirstResponder];
															 // Возможно, нужно было сделать по другому
														 }]];

	[authorizationAlert show];
}

#pragma mark - Работа с данными авторизации

+ (void)saveLogin:(NSString *)login password:(NSString *)pass {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:login forKey:@"login"];
	[userDefaults setObject:pass forKey:@"password"];
}

+ (void)signout {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults removeObjectForKey:@"login"];
	[userDefaults removeObjectForKey:@"password"];
}

@end
