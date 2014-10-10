//
//  NewOrderItemTableViewCell.h
//  Kitchen
//
//  Created by Dylan Lewis on 08/10/2014.
//  Copyright (c) 2014 Dylan Lewis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface NewOrderItemTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *orderItemNameLabel;

@property (weak, nonatomic) PFObject *orderItemObject;

@end
