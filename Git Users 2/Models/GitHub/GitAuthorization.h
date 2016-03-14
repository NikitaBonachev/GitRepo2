//
//  GitAuthorization.h
//  Git Users 2
//
//  Created by Bonachev Nikita on 13.03.16.
//  Copyright © 2016 Bonachev Nikita. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GitAuthorization : NSObject

+ (void)startAuthorizationWithLogin:(NSString *)login password:(NSString *)password;

@end
