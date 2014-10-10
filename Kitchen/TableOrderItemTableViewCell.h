//
//  TableOrderItemTableViewCell.h
//  Kitchen
//
//  Created by Dylan Lewis on 10/10/2014.
//  Copyright (c) 2014 Dylan Lewis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableOrderItemTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *dishNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dishTimeRemainingLabel;

@end
