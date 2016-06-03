//
//  PermissionType.m
//  IOSPermissionControl
//
//  Created by Mittal J. Banker on 26/05/16.
//  Copyright © 2016 digicorp. All rights reserved.
//

#import "PermissionType.h"

@implementation PermissionType

-(PermissionType*)initPermission:(AllPermissionType)strName andMessage:(NSString*)strMessage{
    self.name = strName;
    self.message = strMessage;
    self.type = strName;
    return self;
}

+ (NSDictionary *)typeDisplayNames
{
    return @{@(Contacts) : @"Contacts",
             @(Photos) : @"Photos",
             @(LocationAlways) : @"LocationAlways",
             @(Camera) : @"Camera",
             @(Microphone) : @"Microphone" ,
             @(Bluetooth) : @"Bluetooth" ,
             @(Events) : @"Events" ,
             @(Reminders) : @"Reminders" ,
             @(Notifications) : @"Notifications" ,
             };
}

- (NSString *)typeDisplayName
{
    return [[self class] typeDisplayNames][@(self.name)];
}

@end
