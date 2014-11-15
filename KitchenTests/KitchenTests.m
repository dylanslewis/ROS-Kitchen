//
//  KitchenTests.m
//  KitchenTests
//
//  Created by Dylan Lewis on 01/10/2014.
//  Copyright (c) 2014 Dylan Lewis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <Parse/Parse.h>
#import "LoginViewController.h"

@interface KitchenTests : XCTestCase

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;

@property (strong, nonatomic) NSMutableArray *createdObjects;

@end

@implementation KitchenTests

- (void)setUp {
    [super setUp];
    
    _username = @"dylan";
    _password = @"password";
    
    _createdObjects = [[NSMutableArray alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
    // Delete all created objects.
    for (PFObject *object in _createdObjects) {
        // Delete the object.
        [object deleteInBackground];
        
        // Remove from the array.
        [_createdObjects removeObject:object];
    }
}

#pragma mark - Parse

- (PFQuery *)queryForObjectWithClassName:className withName:name {
    PFQuery *query = [PFQuery queryWithClassName:className];
    [query whereKey:@"name" equalTo:name];
    
    return query;
}

#pragma mark - Login

- (void)testLogin {
    LoginViewController *loginController = [[LoginViewController alloc] init];
    [loginController loginUserWithUsername:_username withPassword:_password];
    
    // Test the success of the login.
    PFUser *user = [PFUser currentUser];
    
    if ([user.username isEqualToString:_username]) {
        XCTAssert(YES, @"Login success");
    } else {
        XCTAssert(NO, @"Login fail");
    }
}

#pragma mark - Orders

// Testing this functionality requires the Waiter app to create orders and Order Items, which the Kitchen can then act upon.

@end
