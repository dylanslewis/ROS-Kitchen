//
//  AcceptItemViewController.h
//  Kitchen
//
//  Created by Dylan Lewis on 10/10/2014.
//  Copyright (c) 2014 Dylan Lewis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface AcceptItemViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    __weak IBOutlet UITableView *tableOrdersTableView;
}

@property (strong, nonatomic) UIImage *translucentBackground;

@property (strong, nonatomic) PFObject *orderItem;

@end
