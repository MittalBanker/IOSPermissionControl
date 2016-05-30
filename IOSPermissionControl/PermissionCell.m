//
//  voicerCell.m
//  Voicetation
//
//  Created by Riddhi R. Makvana on 13/08/15.
//  Copyright (c) 2015 Digicorp. All rights reserved.
//

#import "PermissionCell.h"

@implementation voicerCell

- (void)awakeFromNib {
    [self.imgProfilePic.layer setBorderColor:GRAY_COLOR.CGColor];
    [self.imgProfilePic.layer setBorderWidth:0.5];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
