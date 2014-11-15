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
#import "UIImage+ImageEffects.h"
#import "AcceptItemViewController.h"
#import "UIColor+ApplicationColours.h"
#import "ExistingOrderTableViewCell.h"

@interface OrderItemManagerViewController ()

@property (strong, nonatomic) NSMutableArray *theNewOrderItemsArray;
@property (strong, nonatomic) NSMutableDictionary *theNewOrderItemsByTable;
@property (strong, nonatomic) NSMutableArray *existingOrderItemsArray;

@end

@implementation OrderItemManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [newOrdersTable reloadData];
    [existingOrdersTable reloadData];
    
    [self getParseData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getParseData) name:@"newItems" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getParseData) name:@"setEstimate" object:nil];
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

#pragma mark - Button handling

- (IBAction)didTouchAcceptNewOrderButton:(id)sender {
    NewOrderItemTableViewCell *touchedCell = (NewOrderItemTableViewCell *)[[sender superview] superview];
    
    PFObject *orderItem = [touchedCell orderItemObject];
    
    [self performSegueWithIdentifier:@"acceptItemSegue" sender:orderItem];
}

- (IBAction)didTouchLogoutButton:(id)sender {
    // Logout the current user and return to the login screen.
    [PFUser logOut];
    
    [self performSegueWithIdentifier:@"logoutUserSegue" sender:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:newOrdersTable]) {
        NSString *keyForSection = [[_theNewOrderItemsByTable allKeys] objectAtIndex:[indexPath section]];
        
        PFObject *orderItem = [[_theNewOrderItemsByTable valueForKey:keyForSection] objectAtIndex:[indexPath row]];
        
        [self performSegueWithIdentifier:@"acceptItemSegue" sender:orderItem];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)didTouchRejectNewOrderButton:(id)sender {
    NewOrderItemTableViewCell *touchedCell = (NewOrderItemTableViewCell *)[[sender superview] superview];
    
    PFObject *orderItem = [touchedCell orderItemObject];
    
    orderItem[@"state"] = @"rejected";
    [orderItem saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self getParseData];
    }];
}

- (IBAction)didTouchSetCompleteButton:(id)sender {
    ExistingOrderTableViewCell *touchedCell = (ExistingOrderTableViewCell *)[[sender superview] superview];
    
    PFObject *orderItem = [touchedCell orderItemObject];
    
    orderItem[@"state"] = @"ready";
    [orderItem saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self getParseData];
        
    
    }];
    
    // Update the order state.
    PFObject *order = orderItem[@"forOrder"];
    [self setOrderStateForOrder:order];
    
    // Get the table number of the completed order item.
    NSString *tableNumberString = [NSString stringWithFormat:@"table%@", orderItem[@"tableNumber"]];
    
    // Get the relevant order id
    NSString *orderID = order.objectId;
    
    // Create the message to send.
    NSString *notificationMessage = [NSString stringWithFormat:@"%@ x %@ is now ready for Table %@", orderItem[@"quantity"], orderItem[@"name"], orderItem[@"tableNumber"]];
    
    // Send a notification which increments the badge, and sends the orderID as an object.
    PFPush *push = [[PFPush alloc] init];
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          notificationMessage, @"alert",
	                          orderID, @"oID",
                          nil];
    [push setChannels:@[tableNumberString]];
    [push setData:data];
    [push sendPushInBackground];
}

- (void)setOrderStateForOrder:(PFObject *)order {
    // Get all the items belonging to this order.
    PFQuery *getOrderItems = [PFQuery queryWithClassName:@"OrderItem"];
    [getOrderItems whereKey:@"forOrder" equalTo:order];
    [getOrderItems findObjectsInBackgroundWithBlock:^(NSArray *orderItems, NSError *error) {
        if (!error) {
            NSInteger noOfItems=0;
            NSInteger noOfCollectedItems=0;
            NSInteger noOfAcceptedItems=0;
            NSInteger noOfRejectedItems=0;
            NSInteger noOfReadyItems=0;
            
            // Go through each of the order items and update the count variables.
            for (PFObject *orderItem in orderItems) {
                noOfItems++;
                if ([orderItem[@"state"] isEqualToString:@"collected"]) {
                    noOfCollectedItems++;
                } else if ([orderItem[@"state"] isEqualToString:@"accepted"]) {
                    noOfAcceptedItems++;
                } else if ([orderItem[@"state"] isEqualToString:@"rejected"]) {
                    noOfRejectedItems++;
                } else if ([orderItem[@"state"] isEqualToString:@"ready"]) {
                    noOfReadyItems++;
                }
            }
            
            NSString *state;
            
            // Go through each of the variables, and try and assign the most dominant item state to the whole order.
            if (noOfReadyItems>0) {
                state = @"readyToCollect";
            } else if (noOfRejectedItems>0) {
                state = @"itemRejected";
            } else if (noOfAcceptedItems>0) {
                state = @"estimatesSet";
            } else if (noOfCollectedItems>0) {
                state = @"itemsCollected";
            } else if (noOfItems>0) {
                state = @"itemsOrdered";
            } else {
                state = @"new";
            }
            
            order[@"state"] = state;
            [order saveInBackground];
        }
    }];
}

#pragma mark - Translucency effects

// All translucency code adapted from http://stackoverflow.com/questions/19177348/ios-7-translucent-modal-view-controller

-(UIImage *)convertViewToImage:(UIView *)view {
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)makeTranslucent:(UIImage *)image {
    image = [self convertViewToImage:self.view];
    image = [image applyBlurWithRadius:20
                                             tintColor:[UIColor colorWithWhite:1.0 alpha:0.2]
                                 saturationDeltaFactor:1.3
                                             maskImage:nil];
    
    return image;
}

#pragma mark - Table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([tableView isEqual:newOrdersTable]) {
        return [_theNewOrderItemsByTable count];
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:newOrdersTable]) {
        // Get the key for this section from the dictionary.
        NSString *key = [[_theNewOrderItemsByTable allKeys] objectAtIndex:section];
        
        // Get the order item objects belonging to this key, and store in an array.
        NSArray *orderItemsForKey = [_theNewOrderItemsByTable valueForKey:key];
        
        return [orderItemsForKey count];
    } else {
        return [_existingOrderItemsArray count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([tableView isEqual:newOrdersTable]) {
        return [NSString stringWithFormat:@"Table %@", [[_theNewOrderItemsByTable allKeys] objectAtIndex:section]];
    } else {
        return nil;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([tableView isEqual:newOrdersTable]) {
        // Code for method adapted from: http://stackoverflow.com/questions/15611374/customize-uitableview-header-section
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width, 30)];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width, 30)];
        [label setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:20]];
        label.textColor = [UIColor kitchenBlueColour];
        
        NSString *string = [NSString stringWithFormat:@"Table %@", [[_theNewOrderItemsByTable allKeys] objectAtIndex:section]];
        
        [label setText:string];
        [view addSubview:label];
        
        // Set background colour for header.
        [view setBackgroundColor:[UIColor whiteColor]];
        
        return view;
    } else {
        #warning ugly solution, think of a better way.
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        return view;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:newOrdersTable]) {
        static NSString *CellIdentifier = @"newOrderItemCell";
        
        NSString *keyForSection = [[_theNewOrderItemsByTable allKeys] objectAtIndex:[indexPath section]];
        
        PFObject *orderItem = [[_theNewOrderItemsByTable valueForKey:keyForSection] objectAtIndex:[indexPath row]];
        
        NewOrderItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if ([[orderItem[@"option"] allKeys] count]>0) {
            // This means the order item has options.
            
            // Extract the option name.
            NSDictionary *optionKeyValuePair = [[NSDictionary alloc] initWithDictionary:orderItem[@"option"]];
            
            // Concatenate the option name string with the dish name string: Option DishName.
            NSString *concatenatedString = [NSString stringWithFormat:@"%@ %@", [[optionKeyValuePair allKeys] firstObject], [orderItem valueForKey:@"name"]];
            
            // Set basic attributations.
            NSMutableAttributedString *dishNameWithOption = [[NSMutableAttributedString alloc] initWithString:concatenatedString];
            
            [dishNameWithOption addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Light" size:20.0f] range:NSMakeRange(0, [dishNameWithOption length])];
            
            // Set the option name to blue.
            [dishNameWithOption addAttribute:NSForegroundColorAttributeName value:[UIColor kitchenBlueColour] range:NSMakeRange(0, [[[optionKeyValuePair allKeys] firstObject] length])];
            
            cell.orderItemNameLabel.attributedText = dishNameWithOption;
        } else {
            // The order item has no options.
            
            // Store the dish name in an attribtued string.
            NSMutableAttributedString *dishName = [[NSMutableAttributedString alloc] initWithString:[orderItem valueForKey:@"name"]];
            [dishName addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Light" size:20.0f] range:NSMakeRange(0, [dishName length])];
            
            cell.orderItemNameLabel.attributedText = dishName;
        }
        
        cell.orderItemObject = orderItem;
        
        return cell;
    } else if ([tableView isEqual:existingOrdersTable]) {
        static NSString *CellIdentifier = @"existingOrderItemCell";
        
        PFObject *orderItem = [_existingOrderItemsArray objectAtIndex:[indexPath row]];
        
        ExistingOrderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

        if ([[orderItem[@"option"] allKeys] count]>0) {
            // This means the order item has options.
            
            // Extract the option name.
            NSDictionary *optionKeyValuePair = [[NSDictionary alloc] initWithDictionary:orderItem[@"option"]];
            
            NSString *quantityString = [NSString stringWithFormat:@"%@ x", orderItem[@"quantity"]];
            
            // Concatenate the option name string with the dish name string: Option DishName.
            NSString *concatenatedString = [NSString stringWithFormat:@"%@ %@ %@", quantityString, [[optionKeyValuePair allKeys] firstObject], [orderItem valueForKey:@"name"]];
            
            // Set basic attributations.
            NSMutableAttributedString *dishNameWithOption = [[NSMutableAttributedString alloc] initWithString:concatenatedString];
            
            [dishNameWithOption addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Light" size:17] range:NSMakeRange(0, [dishNameWithOption length])];
            
            // Set the quantity to grey.
            [dishNameWithOption addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(0, [quantityString length])];
            
            // Set the option name to blue.
            [dishNameWithOption addAttribute:NSForegroundColorAttributeName value:[UIColor kitchenBlueColour] range:NSMakeRange([quantityString length], [quantityString length] + [[[optionKeyValuePair allKeys] firstObject] length] -1)];
            
            cell.dishNameLabel.attributedText = dishNameWithOption;
        } else {
            // The order item has no options.
            
            NSString *quantityString = [NSString stringWithFormat:@"%@ x", orderItem[@"quantity"]];
            
            // Concatenate the quantity and dish name.
            NSString *concatenatedString = [NSString stringWithFormat:@"%@ %@", quantityString, orderItem[@"name"]];
            
            // Set basic attributations.
            NSMutableAttributedString *dishNameWithOption = [[NSMutableAttributedString alloc] initWithString:concatenatedString];
            [dishNameWithOption addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Light" size:17] range:NSMakeRange(0, [dishNameWithOption length])];
            
            // Set the quantity to grey.
            [dishNameWithOption addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(0, [quantityString length])];
            
            cell.dishNameLabel.attributedText = dishNameWithOption;
        }
        
        cell.tableNumberLabel.text = orderItem[@"tableNumber"];
        
        // Work out the time until completion.
        NSDate *currentDate = [NSDate date];
        NSDate *completionDate = (NSDate *)orderItem[@"estimatedCompletionTime"];
        NSTimeInterval secondsBetween = [completionDate timeIntervalSinceDate:currentDate];
        int numberOfMinutes = secondsBetween / 60;
        
        cell.timeRemainingLabel.text = [NSString stringWithFormat:@"%d", numberOfMinutes];
        cell.orderItemObject = orderItem;
        
        return cell;
    }
    
    return nil;
}


#pragma mark - Parse

- (void)getParseData {
    // Get order items for this order.
    PFQuery *getOrderItems = [PFQuery queryWithClassName:@"OrderItem"];
    [getOrderItems whereKey:@"state" notContainedIn:@[@"rejected", @"collected", @"ready"]];
    [getOrderItems whereKey:@"type" equalTo:@"Food"];
    
    [getOrderItems findObjectsInBackgroundWithBlock:^(NSArray *orderItems, NSError *error) {
        if (!error) {
            // Create an array of all order items.
            _theNewOrderItemsArray = [[NSMutableArray alloc] init];
            _theNewOrderItemsByTable = [[NSMutableDictionary alloc] init];
            _existingOrderItemsArray = [[NSMutableArray alloc] init];
            
            
            // Go through the 'raw' list of order items.
            for (PFObject *orderItem in orderItems) {
                if ([orderItem[@"state"] isEqualToString:@"accepted"]) {
                    // This is an existing item.
                    
                    [_existingOrderItemsArray addObject:orderItem];
                } else {
                    // This is a new item.
                    
                    // Extract the item's orders table number.
                    NSString *tableNumber=[orderItem valueForKey:@"tableNumber"];
                    
                    [_theNewOrderItemsArray addObject:orderItem];
                    
                    // If we don't already have this table, add it.
                    if (![[_theNewOrderItemsByTable allKeys] containsObject:tableNumber]) {
                        // Create an array containing the current order item object.
                        NSMutableArray *orderItemsForCourse = [[NSMutableArray alloc] initWithObjects:orderItem, nil];
                        
                        [_theNewOrderItemsByTable setObject:orderItemsForCourse forKey:tableNumber];
                    } else {
                        // If the key (i.e. course) already exists, add this order item to its array.
                        NSMutableArray *orderItemsForCourse = [_theNewOrderItemsByTable valueForKey:tableNumber];
                        [orderItemsForCourse addObject:orderItem];
                        
                        [_theNewOrderItemsByTable setObject:orderItemsForCourse forKey:tableNumber];
                    }
                    
                    // Update the item's state
                    orderItem[@"state"] = @"delivered";
                    [orderItem saveInBackground];
                }
            }
        }
        
        // Reload the tables.
        [newOrdersTable reloadData];
        [existingOrdersTable reloadData];
    }];
}


#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    // This stops the button automatically logging in the user, without checking credentials.
    if ([identifier isEqualToString:@"logoutUserSegue"]) {
        return NO;
    } else if ([identifier isEqualToString:@"acceptItemSegue"]) {
        return NO;
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"acceptItemSegue"]) {
        UIImage *currentBackground = [self makeTranslucent:[self convertViewToImage:self.view]];
        
        PFObject *orderItem = (PFObject *)sender;
        
        [[segue destinationViewController] setTranslucentBackground:currentBackground];
        [[segue destinationViewController] setOrderItem:orderItem];
    }
}

@end
