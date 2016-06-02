# IOSPermissionControl


<p align="center">
    <img src="https://github.com/MittalBanker/IOSPermissionControl/blob/master/155x0k.gif" alt="IOSPermissionControl gif" />
</p>



IOSPermissionControl **gives you space to explain your reasons for requesting permissions** and **allows users to tackle the system dialogs at their own pace**.

## compatibility
ios 8 and above of it

## installation
you can download project from  https://github.com/MittalBanker/IOSPermissionControl

##How to use
There  is easy way to add permission to PermissionViewController and you can check the status of each permission in screen



    PermissionViewController.m
    
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
    permissionType = [[PermissionType alloc] initPermission:Bluetooth andMessage:@"We use this to access bletooth"];
    [self.arrPermissionData addObject:permissionType];
    
I give you one example how to check one permission ex. Photos

first to check whether photo permission status in tableview cellForRowAtIndexPath
[self getResultsForConfig:permissionType.name]
This statement wili give you the status of permission

//This code run when tap on photos button if photos permission not given then it redirect to alert and then on setting page
/**
 Request access to Photos, if necessary.
 */


    - (void)requestPhotos:(CustomButton*)sender{
        PermissionStatus authStatus = [self statusPhotos];
        PermissionType *type = [self.permissionViewController.arrPermissionData objectAtIndex:sender.tagOfButton];
        switch (authStatus) {
            case Unknown:
                [self accessPhotoLibrary];
                break;
            case Unauthorized:
                [self showDeniedAlert:type];
                break;
            case Disabled:
                [self showDeniedAlert:type];
                break;
            case Authorized:
                break;
            default:
                break;
        }
    }
    
        
        
### Display three color buttons to show status of permission

display orange color button to show permision which are denied.</br>
display green color button to show permision which are given.</br>
display blue color button to show which status is still unknown.
