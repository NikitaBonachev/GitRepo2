//
//  RepositoryCell.h
//  Git Users 2
//
//  Created by Bonachev Nikita on 12.03.16.
//  Copyright © 2016 Bonachev Nikita. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RepositoryCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *repositoryNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *repositoryURLField;
@property (weak, nonatomic) IBOutlet UITextField *ownerURLField;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@end
