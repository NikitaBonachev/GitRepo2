//
//  AppDelegate.m
//  Git Users 2
//
//  Created by Bonachev Nikita on 11.03.16.
//  Copyright © 2016 Bonachev Nikita. All rights reserved.
//

#import "AppDelegate.h"
#import "RepositoriesTVC.h"
#import "Reachability.h"
#import "UsersTVC.h"
#import "LostConnectionAlert.h"
#import "AuthorizationAlert.h"

@interface AppDelegate () <UISplitViewControllerDelegate>
@property (nonatomic, strong) NSString *databaseName;
@property (nonatomic, strong) AuthorizationAlert *authorizationAlert;
@end

@implementation AppDelegate

#pragma mark - Application Life Cycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Создаем, настраиваем БД
	[self createDatabasePath];
	[self createAndCheckDatabase];
	
	// Установки для SplitView Controller
	if ([self.window.rootViewController isKindOfClass:[UISplitViewController class]]) {
		UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
		if ([splitViewController.viewControllers.lastObject isKindOfClass:[UINavigationController class]]) {
			UINavigationController *navigationController = splitViewController.viewControllers.lastObject;
			navigationController.topViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem;
			navigationController.topViewController.navigationItem.leftItemsSupplementBackButton = YES;
			splitViewController.delegate = self;
			splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
		}
	}
	
	// Будем наблюдать за интернетом
	Reachability *reachability;
	reachability = [Reachability reachabilityForInternetConnection];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionError) name:kReachabilityChangedNotification object:nil];
	[reachability startNotifier];
	
	// Будем наблюдать за ошибками подключения
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionError) name:@"ConnectionError" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needAuthoriozation) name:@"NeedAuthorization" object:nil];
	
	[self.window makeKeyAndVisible];
	
	return YES;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Reachability

- (void)connectionError {
	Reachability* reach = [Reachability reachabilityWithHostname:@"https://api.github.com/"];
	if (!reach.isReachable) {
		[LostConnectionAlert lostConnectionShow]; // Интернет отпал. Выводим уведомление об этом событии
	}
}

#pragma mark - Authoriozation

- (void)needAuthoriozation {
	Reachability* reach = [Reachability reachabilityWithHostname:@"https://api.github.com/"];
	
	if (!reach.isReachable) {
		[LostConnectionAlert lostConnectionShow]; // Интернет отпал. Выводим уведомление об этом событии
	} else {
		[AuthorizationAlert authorizationDialogShow];
	}
}

#pragma mark - Database

- (void)createDatabasePath {
	self.databaseName = @"git_users.db";
	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentDir = [documentPaths objectAtIndex:0];
	self.databasePath = [documentDir stringByAppendingPathComponent:self.databaseName];
}

- (void)createAndCheckDatabase {
	BOOL success;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	success = [fileManager fileExistsAtPath:self.databasePath];
	
	if(success) return; // Если база данных уже есть, то ничего не копируем
	
	NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:self.databaseName];
	[fileManager copyItemAtPath:databasePathFromApp toPath:self.databasePath error:nil];
}

#pragma mark - Split View Controller

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {
	return true;
}

@end
