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
@import AVFoundation;



@interface PermissionViewController ()

@end

@implementation PermissionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.arrPermissionData = [NSMutableArray new];
//    PermissionType *permissionType = [[PermissionType alloc] initPermission:Location andMessage:@"We use this to send you\r\nspam and love notes"];
//    [self.arrPermissionData addObject:permissionType];
    PermissionType *permissionType = [[PermissionType alloc] initPermission:Photos andMessage:@"We use this to access your photos"];
    [self.arrPermissionData addObject:permissionType];
    permissionType = [[PermissionType alloc] initPermission:Contacts andMessage:@"We use this to steal\r\nyour friends"];
    [self.arrPermissionData addObject:permissionType];
    permissionType = [[PermissionType alloc] initPermission:Camera andMessage:@"We use this to steal\r\nyour friends"];
    [self.arrPermissionData addObject:permissionType];
    permissionType = [[PermissionType alloc] initPermission:LocationAlways andMessage:@"We use this to access Location"];
    [self.arrPermissionData addObject:permissionType];
    permissionType = [[PermissionType alloc] initPermission:Microphone andMessage:@"We use this to access headphone"];
    [self.arrPermissionData addObject:permissionType];
    permissionType = [[PermissionType alloc] initPermission:Bluetooth andMessage:@"We use this to access bluetooth"];
    [self.arrPermissionData addObject:permissionType];
    permissionType = [[PermissionType alloc] initPermission:Events andMessage:@"We use this to access event creation"];
    [self.arrPermissionData addObject:permissionType];
    permissionType = [[PermissionType alloc] initPermission:Reminders andMessage:@"We use this to create Reminders"];
    [self.arrPermissionData addObject:permissionType];
    permissionType = [[PermissionType alloc] initPermission:Notifications andMessage:@"We use this to send Notifications"];
    [self.arrPermissionData addObject:permissionType];

    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)displayPermissionView:(id)sender{
    picker = [[CIPermissionControl alloc] initWithHeaderTitle:@"Hi!! We need few thigs before start application"];
    picker.pickerWidth = 300;
    picker.delegate = self;
    picker.dataSource = self;
    picker.parentView = self.view;
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

- (void)CIPermissionControlDidPresentAlert:(PermissionType*)type{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
        dispatch_async(dispatch_get_main_queue(), ^(void){
            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:[NSString stringWithFormat:@"Permission for %@ was denied",[type typeDisplayName]]
                                                  message:[NSString stringWithFormat:@"Please enable access to %@ in the Settings app",[type typeDisplayName]]
                                                  preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction
                                           actionWithTitle:@"OK"
                                           style:UIAlertActionStyleCancel
                                           handler:^(UIAlertAction *action)
                                           {
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                    [picker.tableView  reloadData];
                                               });
                                              
                                           }];
            
            UIAlertAction *okAction = [UIAlertAction
                                       actionWithTitle:@"Show me"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appForegroundedAfterSettings) name:UIApplicationDidBecomeActiveNotification object:nil];
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               [picker.tableView  reloadData];
                                           });
                                           NSLog(@"OK action");
                                           [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                           
                                       }];
            
            [alertController addAction:cancelAction];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:^{
                //
            }];

        });
    });

   
}

-(void)appForegroundedAfterSettings{
    [[NSNotificationCenter defaultCenter] removeObserver:self  name:UIApplicationDidBecomeActiveNotification object:nil];
    [self detectAndCallback];
}

-(void)detectAndCallback{
    
    [picker.tableView reloadData];
    
}

@end
