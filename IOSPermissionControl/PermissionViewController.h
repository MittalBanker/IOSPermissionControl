//
//  ViewController.h
//  IOSPermissionControl
//
//  Created by Mittal J. Banker on 26/05/16.
//  Copyright © 2016 digicorp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CIPermissionControl.h"
@class PermissionType;
@interface PermissionViewController : UIViewController<CIPermissionControlDelegate,CIPermissionControlDataSource>

@property(strong)NSMutableArray *arrPermissionData;
@end

