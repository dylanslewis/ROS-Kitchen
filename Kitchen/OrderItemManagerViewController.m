//
//  OrderItemManagerViewController.m
//  Kitchen
//
//  Created by Dylan Lewis on 08/10/2014.
//  Copyright (c) 2014 Dylan Lewis. All rights reserved.
//

#import "OrderItemManagerViewController.h"
#import <Parse/Parse.h>
#import "NewOrderItemTableViewCell.h"

@interface OrderItemManagerViewController ()

@property (strong, nonatomic) NSArray *orderItemsArray;

@end

@implementation OrderItemManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getParseData];
}

- (void)viewDidAppear:(BOOL)animated {
    // Get the current user.
    PFUser *user=[PFUser currentUser];
    
    // If there is no user logged in, return to the login screen.
    if (!user) {
        [self performSegueWithIdentifier:@"logoutUserSegue" sender:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
/*
    // Get the key for this section from the dictionary.
    NSString *key = [[_orderItemSections allKeys] objectAtIndex:section];
    
    // Get the order item objects belonging to this key, and store in an array.
    NSArray *orderItemsForKey = [_orderItemSections valueForKey:key];
    
    return [orderItemsForKey count];
    */
    return [_orderItemsArray count];
}

/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[_orderItemSections allKeys] objectAtIndex:section];
}
 */

/*
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // Code for method adapted from: http://stackoverflow.com/questions/15611374/customize-uitableview-header-section
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 18)];
    [label setFont:[UIFont systemFontOfSize:14]];
    label.textColor = [UIColor grayColor];
    
    NSString *string = [[_orderItemSections allKeys] objectAtIndex:section];
    
    [label setText:string];
    [view addSubview:label];
    
    // Set background colour for header.
    [view setBackgroundColor:[UIColor whiteColor]];
    
    return view;
}
 */

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"newOrderItemCell";

    NewOrderItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    PFObject *orderItem = [_orderItemsArray objectAtIndex:[indexPath row]];
    
    cell.orderItemNameLabel.text = orderItem[@"name"];
    
    return cell;
}




- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    // This stops the button automatically logging out the user, without checking confirmation.
    if ([identifier isEqualToString:@"logoutUserSegue"]) {
        return NO;
    }
    return YES;
}

#pragma mark - Parse

- (void)getParseData {
    // Get order items for this order.
    PFQuery *getOrderItems = [PFQuery queryWithClassName:@"OrderItem"];
    [getOrderItems whereKey:@"state" equalTo:@"new"];
    [getOrderItems whereKey:@"type" equalTo:@"Food"];
    
    [getOrderItems findObjectsInBackgroundWithBlock:^(NSArray *orderItems, NSError *error) {
        if (!error) {
            // Create an array of all order items.
            _orderItemsArray = [[NSArray alloc] initWithArray:orderItems];
            //_orderItemSections = [[NSMutableDictionary alloc] init];
            
            // Go through the 'raw' list of order items.
            for (NSDictionary *orderItem in _orderItemsArray) {
                // Extract the current item's course.
                NSString *courseName=[orderItem valueForKey:@"course"];
                
                /*
                // If we don't already have this course, add it.
                if (![[_orderItemSections allKeys] containsObject:courseName]) {
                    // Create an array containing the current order item object.
                    NSMutableArray *orderItemsForCourse = [[NSMutableArray alloc] initWithObjects:orderItem, nil];
                    
                    [_orderItemSections setObject:orderItemsForCourse forKey:courseName];
                } else {
                    // If the key (i.e. course) already exists, add this order item to its array.
                    NSMutableArray *orderItemsForCourse = [_orderItemSections valueForKey:courseName];
                    [orderItemsForCourse addObject:orderItem];
                    
                    [_orderItemSections setObject:orderItemsForCourse forKey:courseName];
                }
                 */
            }
        }
        
        // Reload the table.
        [newOrdersTable reloadData];
    }];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
