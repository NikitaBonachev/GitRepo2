//
//  User.h
//  Git users
//
//  Created by Bonachev Nikita on 03.03.16.
//  Copyright © 2016 Bonachev Nikita. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface User : NSObject

@property (strong, nonatomic, readonly) NSString *userName;
@property (strong, nonatomic, readonly) NSURL *photoURL;
@property (strong, nonatomic, readonly) NSURL *repositoriesURL;
@property (nonatomic,readonly) NSInteger userID;

- (instancetype)initWithUserName:(NSString *)name photoURL:(NSURL *)phURL repositoriesURL:(NSURL *)reposURL userID:(NSInteger)uID;

@end
