//
//  PermissionType.h
//  IOSPermissionControl
//
//  Created by Mittal J. Banker on 26/05/16.
//  Copyright © 2016 digicorp. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum{
    Authorized =  0,
    Unauthorized = 1,
    Unknown = 3,
    Disabled=4
}PermissionStatus;


typedef enum{
    Contacts = 0,
    Photos = 1,
    LocationAlways = 2,
    Camera = 3,
    Microphone = 4,
    Bluetooth = 5,
    Events = 6,
    Reminders = 7,
    Notifications=8
}AllPermissionType;

@interface PermissionType : NSObject{
    
}
@property(strong) NSString *message;
@property(assign) AllPermissionType name;
@property(assign) PermissionStatus status;
@property (nonatomic) AllPermissionType type;


-(PermissionType*)initPermission:(AllPermissionType)strName andMessage:(NSString*)strMessage;
-(NSString *)typeDisplayName;
@end
