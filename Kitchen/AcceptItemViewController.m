//
//  AcceptItemViewController.m
//  Kitchen
//
//  Created by Dylan Lewis on 10/10/2014.
//  Copyright (c) 2014 Dylan Lewis. All rights reserved.
//

#import "AcceptItemViewController.h"
#import "TableOrderItemTableViewCell.h"
#import "UIColor+ApplicationColours.h"

@interface AcceptItemViewController ()

@property (weak, nonatomic) IBOutlet UIView *acceptOrderView;

@property (weak, nonatomic) IBOutlet UIButton *fiveButton;
@property (weak, nonatomic) IBOutlet UIButton *tenButton;
@property (weak, nonatomic) IBOutlet UIButton *fifteenButton;
@property (weak, nonatomic) IBOutlet UIButton *twentyButton;
@property (weak, nonatomic) IBOutlet UIButton *twentyFiveButton;
@property (weak, nonatomic) IBOutlet UIButton *thirtyButton;

@property (weak, nonatomic) IBOutlet UILabel *tableNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentCourseLabel;
@property (weak, nonatomic) IBOutlet UILabel *dishNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dishQuantityLabel;
@property (weak, nonatomic) IBOutlet UILabel *courseNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderedXMinsAgoLabel;

@property (strong, nonatomic) PFObject *orderObject;

@property (strong, nonatomic) NSArray *otherOrderItems;

@end

@implementation AcceptItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self overlayView:_acceptOrderView withImage:_translucentBackground];
    
    // Get the other items in this order's objects.
    [self getTableObjects];
    
    // Align the centers of all buttons.
    [_fiveButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_tenButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_fifteenButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_twentyButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_twentyFiveButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_thirtyButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    [tableOrdersTableView setBackgroundColor:[UIColor clearColor]];
    
    // Set dish name, and option if applicable.
    _dishNameLabel.attributedText = [self dishNameForObject:_orderItem];
    
    // Set the other label.
    _dishQuantityLabel.text = [NSString stringWithFormat:@"%@ x", _orderItem[@"quantity"]];
    _courseNameLabel.text = _orderItem[@"course"];
}

- (NSAttributedString *)dishNameForObject:(PFObject *)orderItem {
    if ([[orderItem[@"option"] allKeys] count]>0) {
        // This means the order item has options.
        
        // Extract the option name.
        NSDictionary *optionKeyValuePair = [[NSDictionary alloc] initWithDictionary:orderItem[@"option"]];
        
        // Concatenate the option name string with the dish name string: Option DishName.
        NSString *concatenatedString = [NSString stringWithFormat:@"%@ %@", [[optionKeyValuePair allKeys] firstObject], [orderItem valueForKey:@"name"]];
        
        // Set basic attributations.
        NSMutableAttributedString *dishNameWithOption = [[NSMutableAttributedString alloc] initWithString:concatenatedString];
        
        [dishNameWithOption addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Thin" size:40.0f] range:NSMakeRange(0, [dishNameWithOption length])];
        
        // Set the option name to blue.
        [dishNameWithOption addAttribute:NSForegroundColorAttributeName value:[UIColor kitchenBlueColour] range:NSMakeRange(0, [[[optionKeyValuePair allKeys] firstObject] length])];
        
        return dishNameWithOption;
    } else {
        // The order item has no options.
        
        // Store the dish name in an attribtued string.
        NSMutableAttributedString *dishName = [[NSMutableAttributedString alloc] initWithString:[orderItem valueForKey:@"name"]];
        [dishName addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Thin" size:40.0f] range:NSMakeRange(0, [dishName length])];
        
        return dishName;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)overlayView:(UIView *)view withImage:(UIImage *)image {
    view.backgroundColor = [UIColor clearColor];
    UIImageView* backView = [[UIImageView alloc] initWithFrame:self.view.frame];
    backView.image = image;
    backView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    [view addSubview:backView];
}

#pragma mark - Button handling

- (IBAction)didTouchFiveButton:(id)sender {
    [self setOrderItemEstimate:nil];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTouchTenButton:(id)sender {
    [self setOrderItemEstimate:nil];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTouchFifteenButton:(id)sender {
    [self setOrderItemEstimate:nil];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTouchTwentyButton:(id)sender {
    [self setOrderItemEstimate:nil];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTouchTwentyFiveButton:(id)sender {
    [self setOrderItemEstimate:nil];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTouchThirtyButton:(id)sender {
    [self setOrderItemEstimate:nil];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Table view

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"orderItemsForTableCell";
    
    TableOrderItemTableViewCell *cell = [tableOrdersTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    [cell setBackgroundColor:[UIColor clearColor]];
    
    PFObject *orderItem = [_otherOrderItems objectAtIndex:[indexPath row]];
    
    cell.dishNameLabel.text = orderItem[@"name"];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_otherOrderItems count];
}

#pragma mark - Parse

- (void)getTableObjects {
    _orderObject = _orderItem[@"forOrder"];
    [_orderObject fetchIfNeededInBackgroundWithBlock:^(PFObject *orderObject, NSError *error) {
        _orderObject = orderObject;
        
        // Update the table number label.
        _tableNumberLabel.text = [NSString stringWithFormat:@"Table %@", _orderObject[@"tableNumber"]];
        
        // Get the other order items.
        PFQuery *getOtherOrderItems = [PFQuery queryWithClassName:@"OrderItem"];
        [getOtherOrderItems whereKey:@"forOrder" equalTo:_orderObject];
        [getOtherOrderItems whereKey:@"state" notEqualTo:@"complete"];
        [getOtherOrderItems whereKey:@"state" notEqualTo:@"new"];
        [getOtherOrderItems whereKey:@"state" notEqualTo:@"delivered"];
        
        [getOtherOrderItems findObjectsInBackgroundWithBlock:^(NSArray *orderItems, NSError *error) {
            if (!error) {
                _otherOrderItems = [[NSArray alloc] initWithArray:orderItems];
                
                [tableOrdersTableView reloadData];
            }
        }];
    }];
}

- (void)setOrderItemEstimate:(NSDate *)completionTime {
    
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
