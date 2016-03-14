//
//  RepositoriesTVC.h
//  Git Users 2
//
//  Created by Bonachev Nikita on 11.03.16.
//  Copyright © 2016 Bonachev Nikita. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RepositoriesTVC : UITableViewController

@property (strong, nonatomic) NSURL *repositoryURL;
@property (nonatomic) NSInteger userID;

- (void)resetRepositories;

@end
