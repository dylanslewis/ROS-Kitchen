//
//  ExistingOrderTableViewCell.h
//  Kitchen
//
//  Created by Dylan Lewis on 13/10/2014.
//  Copyright (c) 2014 Dylan Lewis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ExistingOrderTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *tableNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *dishNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeRemainingLabel;

@property (weak, nonatomic) PFObject *orderItemObject;

@end
