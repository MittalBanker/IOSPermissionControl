//
//  customTextField.h
//  customTextField
//
//  Created by Mittal J. Banker on 12/05/16.
//  Copyright © 2016 digicorp. All rights reserved.
//

#import "CustomButton.h"

@implementation CustomButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.layer.cornerRadius = 4;
        
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder: aDecoder];
    self.layer.cornerRadius = 4;
    return self;
}





@end
