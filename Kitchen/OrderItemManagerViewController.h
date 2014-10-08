//
//  OrderItemManagerViewController.h
//  Kitchen
//
//  Created by Dylan Lewis on 08/10/2014.
//  Copyright (c) 2014 Dylan Lewis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderItemManagerViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    
    __weak IBOutlet UITableView *newOrdersTable;
    __weak IBOutlet UITableView *existingOrdersTable;
}

@end
