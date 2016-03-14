//
//  RepositoriesTVC.m
//  Git Users 2
//
//  Created by Bonachev Nikita on 11.03.16.
//  Copyright © 2016 Bonachev Nikita. All rights reserved.
//

#import "RepositoriesTVC.h"
#import "RepositoriesStore.h"
#import "RepositoryCell.h"
#import "Repository.h"
#import "GitFetcher.h"

@interface RepositoriesTVC ()
@property (nonatomic, strong) RepositoriesStore *repositoriesStore;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@end

@implementation RepositoriesTVC

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
	
	self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	self.spinner.hidesWhenStopped = YES;
	[self.navigationController.view addSubview:self.spinner]; // Возможно, странное решение добавлять именнно так, но зато спиннер всегда будет там где надо

	if (self.repositoryURL) {
		if ([GitFetcher checkConnection]) {
			[self.spinner startAnimating];
		} else {
			[self.spinner stopAnimating];
		}
		self.repositoriesStore = [[RepositoriesStore alloc] initStoreForUserID:self.userID repositoryURL:self.repositoryURL];
	}
	
	self.tableView.estimatedRowHeight = 146.0;
	self.tableView.rowHeight = UITableViewAutomaticDimension;
	self.tableView.allowsSelection = NO;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUI) name:@"RepositoriesDataChanged" object:nil]; // Загрузка репозиториев
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUI) name:@"NeedAuthorization" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUI) name:@"SuccessReloadUserStore" object:nil];
}

-(void)viewDidLayoutSubviews {   // Спиннер всегда будет там где надо
	[super viewDidLayoutSubviews];
	[self.navigationController.view setNeedsLayout];
	[self.navigationController.view layoutIfNeeded];
	self.spinner.frame = CGRectMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2, 10, 10);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateUI {
	[self.tableView reloadData];
	[self.spinner stopAnimating];
}

- (void)resetRepositories {
	self.repositoryURL = nil;
	self.title = @"Repositories";
	self.repositoriesStore = nil;
	[self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if ([[self.repositoriesStore repositories] count] != 0) {
		return [[self.repositoriesStore repositories] count];
	}
	if ([self.spinner isAnimating]) {
		return 0;
	}
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([[self.repositoriesStore repositories] count] == 0 && ![self.spinner isAnimating]) {
		RepositoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"emptyCell" forIndexPath:indexPath];
		return cell;
	} else {
		RepositoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"repositoryCell" forIndexPath:indexPath];
		Repository *repository = [self.repositoriesStore repositories][indexPath.row];
		
		cell.repositoryNameLabel.text = [repository repositoryName];
		cell.repositoryURLField.text = [[repository repositoryURL] absoluteString];
		cell.ownerURLField.text = [[repository ownerURL] absoluteString];
		
		if (![[repository repositoryDescription] isEqualToString:@""]) {
			cell.descriptionLabel.text = [repository repositoryDescription];
		} else {
			cell.descriptionLabel.text = @"No description";
		}
		
		if (repository.fork) {
			cell.backgroundColor = [UIColor colorWithRed:1.00 green:0.95 blue:0.60 alpha:0.4];
		}
		
		return cell;
	}
}

#pragma mark - Navigation

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	Repository *repository = [self.repositoriesStore repositories][indexPath.row];
	[[UIApplication sharedApplication] openURL:repository.repositoryURL];
}

@end
