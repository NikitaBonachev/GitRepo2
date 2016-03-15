//
//  UsersTVC.m
//  Git Users 2
//
//  Created by Bonachev Nikita on 11.03.16.
//  Copyright © 2016 Bonachev Nikita. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "AuthorizationAlert.h"
#import "GitFetcher.h"
#import "UsersTVC.h"
#import "RepositoriesTVC.h"
#import "UsersStore.h"
#import "User.h"

@interface UsersTVC () <UISearchResultsUpdating, UISearchControllerDelegate>
@property (strong, nonatomic) UISearchController *searchController;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *authorizationButton;
@property (weak, nonatomic) IBOutlet UILabel *internetStatusLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (strong, nonatomic) RepositoriesTVC *repositoryTVC;
@end

@implementation UsersTVC

#pragma mark - Life cycle

- (void)viewDidLoad {
	[super viewDidLoad];
	if ([self checkConnection]) {
		[self.spinner startAnimating];
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUI) name:@"UsersDataChanged" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needAuthorization) name:@"NeedAuthorization" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successAuthorization) name:@"SuccessAuthorization" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUI) name:@"NewSearchResult" object:nil]; //SuccessReloadUserStore
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUI) name:@"SuccessReloadUserStore" object:nil];
	
	self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
	self.searchController.delegate = self;
	self.searchController.searchResultsUpdater = self;
	self.searchController.dimsBackgroundDuringPresentation = NO;
	self.definesPresentationContext = true;
	self.tableView.tableHeaderView = self.searchController.searchBar;
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	 
	if ([userDefaults objectForKey:@"login"] && [userDefaults objectForKey:@"password"]) {
		self.authorizationButton.title = @"Signout";
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	SDImageCache *imageCache = [SDImageCache sharedImageCache];
	[imageCache clearMemory];
	[imageCache clearDisk];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if ([[[UsersStore sharedStore] users] count] > 0 && !self.searchController.active) {
		return [[[UsersStore sharedStore] users] count];
	} else if ([[[UsersStore sharedStore] usersSearchResult] count] > 0) {
		return [[[UsersStore sharedStore] usersSearchResult] count];
	}
	[self.repositoryTVC resetRepositories];
    return 1; // Если данных нет, то выводим emptyCell
}

#pragma mark - Table view delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([[[UsersStore sharedStore] users] count] > 0 && !self.searchController.active) {
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userCell" forIndexPath:indexPath];
		User *user = [[UsersStore sharedStore] users][indexPath.row];
		cell.textLabel.text = [user userName];
		[cell.imageView sd_setImageWithURL:[user photoURL] placeholderImage:[UIImage imageNamed:@"placeholder"]];
		return cell;
		
	} else if ([[[UsersStore sharedStore] usersSearchResult] count] > 0) {
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userCell" forIndexPath:indexPath];
		User *user = [[UsersStore sharedStore] usersSearchResult][indexPath.row];
		cell.textLabel.text = [user userName];
		[cell.imageView sd_setImageWithURL:[user photoURL] placeholderImage:[UIImage imageNamed:@"placeholder"]];
		return cell;
		
	} else {
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"emptyCell" forIndexPath:indexPath];
		return cell;
		
	}
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (![self checkConnection] || [[[UsersStore sharedStore] users] count] == 0) {
		return; // Если интернета нет, то дальше ничего не делаем
	}
	
	if (indexPath.row == [[[UsersStore sharedStore] users] count] - 1 && !self.searchController.active) {
		[self.spinner startAnimating];
		[self loadUsersFromNumber:[[[[UsersStore sharedStore] users] lastObject] userID]]; // Продолжить загрузку. Нужно больше пользователей
	}
}

#pragma mark - Работа с источником данных. Обновление UI

- (void)loadUsersFromNumber:(NSInteger)lastUserNumber {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
		GitFetcher *gitFetcher = [[GitFetcher alloc] init];
		[gitFetcher getUsersFromNumber:lastUserNumber];
	});
}


- (void)updateUI {
	[self.tableView reloadData];
	[self.spinner stopAnimating];
}

- (BOOL)checkConnection {
	if (![GitFetcher checkConnection]) {
		self.internetStatusLabel.hidden = NO;
		return NO;
	} else {
		self.internetStatusLabel.hidden = YES;
		return YES;
	}
}

- (void)needAuthorization {
	[self.spinner stopAnimating];
}

- (void)successAuthorization {
	self.authorizationButton.title = @"Signout";
	[UsersStore reloadStore];
	
	if (self.searchController.active) {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
			GitFetcher *gitFetcher = [[GitFetcher alloc] init];
			[gitFetcher searchUser: self.searchController.searchBar.text];
		});
	}
}

#pragma mark - Search implementation

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
	[UsersStore setSearchPredicate:searchText];
	
	if (![searchText isEqualToString:@""]) {
		[self.spinner startAnimating];
	}
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
		GitFetcher *gitFetcher = [[GitFetcher alloc] init];
		[gitFetcher searchUser: searchText];
	});
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
	[self filterContentForSearchText:searchController.searchBar.text scope:[[self.searchController.searchBar scopeButtonTitles]
																			objectAtIndex:[self.searchController.searchBar
																						   selectedScopeButtonIndex]]];
	[self.tableView reloadData];
}


- (void)didPresentSearchController:(UISearchController *)searchController {
	[self.searchController.searchBar becomeFirstResponder];
	[self.spinner stopAnimating];
}

- (void)willDismissSearchController:(UISearchController *)searchController {
	[UsersStore removeAllSearchResult];
	[self.tableView reloadData];
	[self.spinner stopAnimating];
}

#pragma mark - Actions

- (IBAction)authorizationAction:(UIBarButtonItem *)sender {
	if ([sender.title isEqualToString:@"Signin"]) {
		[AuthorizationAlert authorizationDialogShow];
	} else {
		sender.title = @"Signin";
		[AuthorizationAlert signout];
		[UsersStore removeAllUsers];
		self.searchController.active = NO;
		[self updateUI];
	}
}

- (IBAction)showSearchBarAction:(UIBarButtonItem *)sender {
	self.searchController.active = YES;
	[self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqual:@"Show Repositories"]) {
		NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
		
		User *user;
		
		if (!self.searchController.active) {
			user = [[UsersStore sharedStore] users][indexPath.row];
		} else {
			user = [[UsersStore sharedStore] usersSearchResult][indexPath.row];
		}
		
		UIViewController *destination = segue.destinationViewController;
		
		if ([destination isKindOfClass:[UINavigationController class]]) {
			UINavigationController *nc = (UINavigationController *)destination;
			destination = (RepositoriesTVC *)nc.visibleViewController;
			destination.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
			destination.navigationItem.leftItemsSupplementBackButton = YES;
		}
		
		self.repositoryTVC = (RepositoriesTVC *)destination;
		
		[self.repositoryTVC setRepositoryURL:user.repositoriesURL];
		[self.repositoryTVC setTitle:user.userName];
		[self.repositoryTVC setUserID:user.userID];
	}
}

@end
