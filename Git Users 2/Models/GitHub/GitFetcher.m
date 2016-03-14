//
//  GitFetcher.m
//  Git users
//
//  Created by Bonachev Nikita on 03.03.16.
//  Copyright © 2016 Bonachev Nikita. All rights reserved.
//

#import "GitFetcher.h"
#import "User.h"
#import "Repository.h"
#import "UsersStore.h"
#import "RepositoriesStore.h"
#import "Reachability.h"

@implementation GitFetcher

- (NSMutableURLRequest *)sharedRequest {
	static NSMutableURLRequest *sharedRequest = nil;
	
	if (!sharedRequest) {
		sharedRequest = [[NSMutableURLRequest alloc] init];
		[sharedRequest setHTTPMethod:@"GET"];
		[sharedRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	}
	
	return sharedRequest;
}

#pragma mark - Запросы

- (void)getUsersFromNumber:(NSInteger)lastUserNumber {
	
	if (![GitFetcher checkConnection]) {
		return; // Завершить, если нет интернета
	}
	
	NSMutableArray *users = [[NSMutableArray alloc] init];
	NSString *urlString = [NSString stringWithFormat:@"https://api.github.com/users?since=%ld&per_page=6", (long)lastUserNumber];
	NSURL *url = [NSURL URLWithString: urlString];
	
	[self.sharedRequest setURL:url];
	[self checkLoginAndPass];
	
	NSURLSession *session = [NSURLSession sharedSession];
	
	[[session dataTaskWithRequest:self.sharedRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
		
		if (!error) {
			
			NSArray *responseArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
			
			if ([responseArray isKindOfClass:[NSArray class]]) {
				
				for (NSDictionary *user in responseArray) {
					
					User *newUser = [[User alloc] initWithUserName:user[@"login"]
														  photoURL:[NSURL URLWithString:user[@"avatar_url"]]
												   repositoriesURL:[NSURL URLWithString:user[@"repos_url"]]
															userID:[user[@"id"] integerValue]];
					[users addObject:newUser];
					
				}
				
				dispatch_async(dispatch_get_main_queue(), ^{ // Все загрузили, добавляем в наше хранилище
					[UsersStore addUsersFromArray:users];
				});
				
			} else {
				// Ошибка. Нужно войти в систему
				dispatch_async(dispatch_get_main_queue(), ^{
					[[NSNotificationCenter defaultCenter] postNotificationName:@"NeedAuthorization" object:self];
				});
			}
			
		} else {
			// Есть ошибки подключение
			dispatch_async(dispatch_get_main_queue(), ^{
				[[NSNotificationCenter defaultCenter] postNotificationName:@"ConnectionError" object:self];
			});
		}
		
	}] resume];
}

- (void)getUserRepositories:(NSURL *)repositoriesURL forRepositoriesStore:(RepositoriesStore *)repositoriesStore {
	
	if (![GitFetcher checkConnection]) {
		return; // Завершить, если нет интернета
	}
	
	[self.sharedRequest setURL:repositoriesURL];
	[self checkLoginAndPass];
	
	NSMutableArray *repositories = [[NSMutableArray alloc] init];
	
	NSURLSession *session = [NSURLSession sharedSession];
	
	[[session dataTaskWithRequest:self.sharedRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
		
		if (!error) {
			
			NSArray *responseArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
			
			if ([responseArray isKindOfClass:[NSArray class]]) {
				
				for (NSDictionary *repository in responseArray) {
					NSString *repoName = [[NSString alloc] initWithString:repository[@"name"]];
					NSString *repoDescription = @"";
					
					if (![repository[@"description"] isKindOfClass:[NSNull class]]) {
						repoDescription = [NSString stringWithString:repository[@"description"]];
					}
					
					NSURL *repoUrl = [NSURL URLWithString:repository[@"html_url"]];
					NSURL *ownerUrl= [NSURL URLWithString:repository[@"owner"][@"html_url"]];
					BOOL isFork = [repository[@"fork"] boolValue];
					NSInteger repoID = [repository[@"id"] integerValue];
					NSInteger ownerID = [repository[@"owner"][@"id"] integerValue];
					
					Repository *newRepository = [[Repository alloc] initWithRepositoryName:repoName
																			  repositoryID:repoID
																	 repositoryDescription:repoDescription
																			 repositoryURL:repoUrl
																				   ownerID:ownerID
																				  ownerURL:ownerUrl
																					  fork:isFork];
					[repositories addObject:newRepository];
				}
				
				dispatch_async(dispatch_get_main_queue(), ^{ // Все загрузили, добавляем в наше хранилище
					[repositoriesStore addRepositoriesFromArray:repositories];
				});
				
			} else {
				dispatch_async(dispatch_get_main_queue(), ^{
					[[NSNotificationCenter defaultCenter] postNotificationName:@"NeedAuthorization" object:self];
				});
			}
			
		} else { // Есть ошибки подключение
			dispatch_async(dispatch_get_main_queue(), ^{
				[[NSNotificationCenter defaultCenter] postNotificationName:@"ConnectionError" object:self];
			});
		}
		
	}] resume];
}

- (void)searchUser:(NSString *)searchText {
	NSString *search = [searchText stringByReplacingOccurrencesOfString:@" " withString:@""];
	
	if ([search isEqualToString:@""]) { return; }
	if (![GitFetcher checkConnection]) {return;} // Завершить, если нет интернета
	
	NSMutableArray *users = [[NSMutableArray alloc] init];
	static NSURLSessionDataTask *searchTask;
	[searchTask cancel];
	
	NSString *urlString = [NSString stringWithFormat:@"https://api.github.com/search/users?q=%@&per_page=15", search];
	NSURL *usersUrl = [[NSURL alloc] initWithString:urlString];
	[self.sharedRequest setURL:usersUrl];
	[self checkLoginAndPass];
	
	NSURLSession *session = [NSURLSession sharedSession];
	
	searchTask = [session dataTaskWithRequest:self.sharedRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
		
		if (data) {
			
			NSDictionary *usersDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
			
			for (NSDictionary *user in usersDictionary[@"items"]) {
				NSURL *photoUrl = [NSURL URLWithString:user[@"avatar_url"]];
				NSInteger userID = [user[@"id"] integerValue];
				User *newUser = [[User alloc] initWithUserName:user[@"login"]
													  photoURL:photoUrl
											   repositoriesURL:[NSURL URLWithString:user[@"repos_url"]]
														userID:userID];
				[users addObject:newUser];
			}
			
			dispatch_async(dispatch_get_main_queue(), ^{
				[UsersStore addSearchResultFromArray:users];
			});
		}
		
	}];
	
	[searchTask resume];
}

#pragma mark - Различные проверки

- (void)checkLoginAndPass { // Добавляем хедер для авторизации
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[self.sharedRequest setValue:nil forHTTPHeaderField:@"Authorization"];
	
	if ([userDefaults objectForKey:@"login"] && [userDefaults objectForKey:@"password"]) {
		NSString *login = [userDefaults objectForKey:@"login"];
		NSString *pass = [userDefaults objectForKey:@"password"];
		NSString *authStr = [NSString stringWithFormat:@"%@:%@", login, pass];
		NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
		NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
		[[self sharedRequest] setValue:authValue forHTTPHeaderField:@"Authorization"];
	}
}

+ (BOOL)checkConnection {
	Reachability *reach = [Reachability reachabilityWithHostname:@"https://api.github.com/"];
	if (reach.isReachable) {
		return YES;
	}
	return NO;
}

@end
