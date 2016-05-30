//
//  ViewController.m
//  IOSPermissionControl
//
//  Created by Mittal J. Banker on 26/05/16.
//  Copyright © 2016 digicorp. All rights reserved.
//

#import "PermissionViewController.h"
#import "CIPermissionControl.h"
#import "PermissionType.h"
@interface PermissionViewController ()

@end

@implementation PermissionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.arrPermissionData = [NSMutableArray new];
    PermissionType *permissionType = [[PermissionType alloc] initPermission:@"Location" andMessage:@"We use this to send you\r\nspam and love notes"];
    [self.arrPermissionData addObject:permissionType];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)displayPermissionView:(id)sender{
    CIPermissionControl *picker = [[CIPermissionControl alloc] initWithHeaderTitle:@"Hi!! We need few thigs before start application"];
    picker.delegate = self;
    picker.dataSource = self;
    picker.allowMultipleSelection = YES;
    [picker show];
}

- (NSAttributedString *)CIPermissionControl:(CIPermissionControl *)pickerView
               attributedTitleForRow:(NSInteger)row{
    
    NSAttributedString *att = [[NSAttributedString alloc]
                               initWithString:self.arrPermissionData[row]
                               attributes:@{
                                            NSFontAttributeName:[UIFont fontWithName:@"Avenir-Light" size:18.0]
                                            }];
    return att;
}

- (NSString *)CIPermissionControl:(CIPermissionControl *)pickerView
               titleForRow:(NSInteger)row{
    return self.arrPermissionData[row];
}


- (NSInteger)numberOfRowsInPickerView:(CIPermissionControl *)pickerView{
    return self.arrPermissionData.count;
}

@end
