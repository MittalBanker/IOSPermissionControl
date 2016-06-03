//
//  CIPermissionControl.h
//
//  Created by chenzeyu on 9/6/15.
//  Copyright (c) 2015 chenzeyu. All rights reserved.
//

#import "CIPermissionControl.h"
#import "PermissionCell.h"
#import "PermissionType.h"
#import "PermissionViewController.h"
#import "CustomButton.h"
@import AVFoundation;
@import Contacts;

#define CZP_FOOTER_HEIGHT 44.0
#define CZP_HEADER_HEIGHT 64.0
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
#define CZP_BACKGROUND_ALPHA 0.9
#else
#define CZP_BACKGROUND_ALPHA 0.3
#endif

#define kTagPermissionTag -99
#define kTagPermissionMessageTag -100

typedef void (^CZDismissCompletionCallback)(void);

@interface CIPermissionControl ()
@property NSString *headerTitle;
@property UIView *backgroundDimmingView;
@property UIView *containerView;
@property UIView *headerView;
@property UIView *footerview;
@property UIColor *authorizedButtonColor;
@property UIColor *unauthorizedButtonColor;

@property NSMutableArray *selectedIndexPaths;
@property CGRect previousBounds;
@property PermissionViewController *permissionViewController;
@property (strong)CLLocationManager *locationManager;
@property (strong)CBPeripheralManager *bluetoothManager;

@end

@implementation CIPermissionControl
BOOL waitingForBluetooth;
- (id)initWithHeaderTitle:(NSString *)headerTitle{
    self = [super init];
    if(self){
        if([self needHandleOrientation]){
            [[NSNotificationCenter defaultCenter] addObserver: self
                                                     selector:@selector(deviceOrientationDidChange:)
                                                         name:UIDeviceOrientationDidChangeNotification
                                                       object: nil];
        }
        self.tapBackgroundToDismiss = YES;
        self.needFooterView = NO;
        self.allowMultipleSelection = NO;
        self.animationDuration = 0.5f;
        
        self.headerTitle = headerTitle ? headerTitle : @"";
        self.headerTitleColor = [UIColor whiteColor];
        self.headerBackgroundColor = [UIColor colorWithRed:56.0/255 green:185.0/255 blue:158.0/255 alpha:1];
        
        _previousBounds = [UIScreen mainScreen].bounds;
        self.frame = _previousBounds;
        self.authorizedButtonColor = [UIColor colorWithRed:0 green:0.47 blue:1 alpha:1];
        self.unauthorizedButtonColor = [UIColor colorWithRed:0 green:0.47 blue:1 alpha:1];
        //= UIColor(red: 0, green: 0.47, blue: 1, alpha: 1)
        
    }
    return self;
}

- (void)setupSubviews{
    if(!self.backgroundDimmingView){
        self.backgroundDimmingView = [self buildBackgroundDimmingView];
        [self addSubview:self.backgroundDimmingView];
    }
    
    self.containerView = [self buildContainerView];
    [self addSubview:self.containerView];
    
    self.tableView = [self buildTableView];
    [self.containerView addSubview:self.tableView];
    self.headerView = [self buildHeaderView];
    [self.containerView addSubview:self.headerView];
    
    
    CGRect frame = self.containerView.frame;
    
    self.containerView.frame = CGRectMake(frame.origin.x,
                                          frame.origin.y,
                                          frame.size.width,
                                          self.headerView.frame.size.height + self.tableView.frame.size.height);
    self.containerView.center = CGPointMake(self.center.x, self.center.y + self.frame.size.height);
    self.permissionViewController = (PermissionViewController*)self.dataSource;
    
    self.locationManager = [[CLLocationManager alloc] init];
    
    self.locationManager.delegate = self;
    
    self.bluetoothManager = [[CBPeripheralManager alloc]
                             initWithDelegate:self
                             queue:dispatch_get_main_queue()];
    //self
    //queue:dispatch_get_main_queue()
    //options:@{CBCentralManagerOptionShowPowerAlertKey: @(NO)}];
    
}

- (void)performContainerAnimation {
    
    [UIView animateWithDuration:self.animationDuration delay:0 usingSpringWithDamping:0.7f initialSpringVelocity:3.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        self.containerView.center = self.center;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)show{
    
    //UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
    self.frame = self.parentView.frame;
    [self.parentView addSubview:self];
    [self setupSubviews];
    [self performContainerAnimation];
    
    [UIView animateWithDuration:0.3f animations:^{
        self.backgroundDimmingView.alpha = CZP_BACKGROUND_ALPHA;
    }];
    
}

- (void)dismissPicker:(CZDismissCompletionCallback)completion{
    [UIView animateWithDuration:self.animationDuration delay:0 usingSpringWithDamping:0.7f initialSpringVelocity:3.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        self.containerView.center = CGPointMake(self.center.x, self.center.y + self.frame.size.height);
    }completion:^(BOOL finished) {
    }];
    
    [UIView animateWithDuration:0.3f animations:^{
        self.backgroundDimmingView.alpha = 0.0;
    } completion:^(BOOL finished) {
        if(finished){
            if(completion){
                completion();
            }
            [self removeFromSuperview];
        }
    }];
}

- (UIView *)buildContainerView{
    CGFloat widthRatio = _pickerWidth ? _pickerWidth / [UIScreen mainScreen].bounds.size.width : 0.8;
    CGAffineTransform transform = CGAffineTransformMake(widthRatio, 0, 0, 0.8, 0, 0);
    CGRect newRect = CGRectApplyAffineTransform(self.frame, transform);
    UIView *cv = [[UIView alloc] initWithFrame:newRect];
    cv.layer.cornerRadius = 6.0f;
    cv.clipsToBounds = YES;
    cv.center = CGPointMake(self.center.x, self.center.y + self.frame.size.height);
    return cv;
}

- (UITableView *)buildTableView{
    CGFloat widthRatio = _pickerWidth ? _pickerWidth / [UIScreen mainScreen].bounds.size.width : 0.8;
    CGAffineTransform transform = CGAffineTransformMake(widthRatio, 0, 0, 0.8, 0, 0);
    CGRect newRect = CGRectApplyAffineTransform(self.frame, transform);
    NSInteger n = [self.dataSource numberOfRowsInPickerView:self];
    CGRect tableRect;
    float heightOffset = CZP_HEADER_HEIGHT + CZP_FOOTER_HEIGHT;
    if(n > 0){
        float height = n * 80;
        height = height > newRect.size.height - heightOffset ? newRect.size.height -heightOffset : height;
        tableRect = CGRectMake(0, CZP_HEADER_HEIGHT, newRect.size.width, height);
    } else {
        tableRect = CGRectMake(0, CZP_HEADER_HEIGHT, newRect.size.width, newRect.size.height - heightOffset);
    }
    UITableView *tableView = [[UITableView alloc] initWithFrame:tableRect style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    return tableView;
}

- (UIView *)buildBackgroundDimmingView{
    
    UIView *bgView;
    //blur effect for iOS8
    CGFloat frameHeight = self.frame.size.height;
    CGFloat frameWidth = self.frame.size.width;
    CGFloat sideLength = frameHeight > frameWidth ? frameHeight : frameWidth;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) {
        UIBlurEffect *eff = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        bgView = [[UIVisualEffectView alloc] initWithEffect:eff];
        bgView.frame = CGRectMake(0, 0, sideLength, sideLength);
    }
    else {
        bgView = [[UIView alloc] initWithFrame:self.frame];
        bgView.backgroundColor = [UIColor blackColor];
    }
    bgView.alpha = 0.0;
    if(self.tapBackgroundToDismiss){
        [bgView addGestureRecognizer:
         [[UITapGestureRecognizer alloc] initWithTarget:self
                                                 action:@selector(cancelButtonPressed:)]];
    }
    return bgView;
}

- (UIView *)buildHeaderView{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, CZP_HEADER_HEIGHT)];
    view.backgroundColor = self.headerBackgroundColor;
    
    UIFont *headerFont = self.headerTitleFont == nil ? [UIFont systemFontOfSize:18.0] : self.headerTitleFont;
    
    NSDictionary *dict = @{
                           NSForegroundColorAttributeName: self.headerTitleColor,
                           NSFontAttributeName:headerFont
                           };
    NSAttributedString *at = [[NSAttributedString alloc] initWithString:self.headerTitle attributes:dict];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, view.frame.origin.y
                                                               , view.frame.size.width, view.frame.size.height)];
    label.attributedText = at;
    label.numberOfLines = 3;
    // [label sizeToFit];
    [view addSubview:label];
    //label.center = view.center;
    return view;
}

- (IBAction)cancelButtonPressed:(id)sender{
    [self dismissPicker:^{
        if([self.delegate respondsToSelector:@selector(CIPermissionControlDidClickCancelButton:)]){
            [self.delegate CIPermissionControlDidClickCancelButton:self];
        }
    }];
}

- (IBAction)confirmButtonPressed:(id)sender{
    [self dismissPicker:^{
        if(self.allowMultipleSelection && [self.delegate respondsToSelector:@selector(CIPermissionControl:didConfirmWithItemsAtRows:)]){
            [self.delegate CIPermissionControl:self didConfirmWithItemsAtRows:[self selectedRows]];
        }
        
        else if(!self.allowMultipleSelection && [self.delegate respondsToSelector:@selector(CIPermissionControl:didConfirmWithItemAtRow:)]){
            if (self.selectedIndexPaths.count > 0){
                NSInteger row = ((NSIndexPath *)self.selectedIndexPaths[0]).row;
                [self.delegate CIPermissionControl:self didConfirmWithItemAtRow:row];
            }
        }
    }];
}

- (NSArray *)selectedRows {
    NSMutableArray *rows = [NSMutableArray new];
    for (NSIndexPath *ip in self.selectedIndexPaths) {
        [rows addObject:@(ip.row)];
    }
    return rows;
}

- (void)setSelectedRows:(NSArray *)rows{
    if (![rows isKindOfClass: NSArray.class]) {
        return;
    }
    self.selectedIndexPaths = [NSMutableArray new];
    for (NSNumber *n in rows){
        NSIndexPath *ip = [NSIndexPath indexPathForRow:[n integerValue] inSection: 0];
        [self.selectedIndexPaths addObject:ip];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([self.dataSource respondsToSelector:@selector(numberOfRowsInPickerView:)]) {
        return [self.dataSource numberOfRowsInPickerView:self];
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"Permissioncell";
    self.permissionViewController = (PermissionViewController*)self.dataSource;
    PermissionType *permissionType = (PermissionType*)[self.permissionViewController.arrPermissionData objectAtIndex:indexPath.row];
    
    PermissionCell *cell = (PermissionCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"Permissioncell" owner:self options:nil];
        cell = (PermissionCell*)[nib objectAtIndex:0];
        
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    CustomButton *btnPermission = (CustomButton*)[cell viewWithTag:kTagPermissionTag];
    btnPermission.tagOfButton = indexPath.row;
    [btnPermission setTitle:permissionType.typeDisplayName forState:UIControlStateNormal];
    
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"request%@:",permissionType.typeDisplayName]);
    [btnPermission addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    UILabel *lblMessage = (UILabel*)[cell viewWithTag:kTagPermissionMessageTag];
    [lblMessage setTextAlignment:NSTextAlignmentCenter];
    [lblMessage setText:permissionType.message];
    if([self getResultsForConfig:permissionType.name]==Authorized){
        [btnPermission setBackgroundColor:[UIColor greenColor]];
    } else if ([self getResultsForConfig:permissionType.name]==Unauthorized){
        [btnPermission setBackgroundColor:[UIColor orangeColor]];
    } else{
        [btnPermission setBackgroundColor:_unauthorizedButtonColor];
    }
    
    return cell;
    
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  80;
}

#pragma mark - Notification Handler

- (BOOL)needHandleOrientation{
    NSArray *supportedOrientations = [[[NSBundle mainBundle] infoDictionary]
                                      objectForKey:@"UISupportedInterfaceOrientations"];
    NSMutableSet *set = [NSMutableSet set];
    for(NSString *o in supportedOrientations){
        NSRange range = [o rangeOfString:@"Portrait"];
        if (range.location != NSNotFound) {
            [set addObject:@"Portrait"];
        }
        
        range = [o rangeOfString:@"Landscape"];
        if (range.location != NSNotFound) {
            [set addObject:@"Landscape"];
        }
    }
    return set.count == 2;
}

- (void)deviceOrientationDidChange:(NSNotification *)notification{
    CGRect rect = [UIScreen mainScreen].bounds;
    if (CGRectEqualToRect(rect, _previousBounds)) {
        return;
    }
    _previousBounds = rect;
    self.frame = rect;
    for(UIView *v in self.subviews){
        if([v isEqual:self.backgroundDimmingView]) continue;
        
        [UIView animateWithDuration:0.2f animations:^{
            v.alpha = 0.0;
        } completion:^(BOOL finished) {
            [v removeFromSuperview];
            //as backgroundDimmingView will not be removed
            if(self.subviews.count == 1){
                [self setupSubviews];
                [self performContainerAnimation];
            }
        }];
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - custom events

-(PermissionStatus)getResultsForConfig:(AllPermissionType)strPerName{
    PermissionStatus status = Unknown;
    switch(strPerName) {
        case Photos:
            status = [self statusPhotos];
            break;
        case Contacts:
            status = [self statusContacts];
            break;
        case Camera:
            status = [self statusCamera];
            break;
        case LocationAlways:
            status = [self statusLocationAlways];
            break;
        case Microphone:
            status = [self statusMicrophone];
            break;
        case Events:
            status = [self statusEvents];
            break;
        case Reminders:
            status = [self statusReminders];
            break;
        case Notifications:
            status = [self statusNotifications];
            break;
        default:
            break;
    }
    return status;
}

-(void)requestLocationAlways:(CustomButton*)sender{
    BOOL value = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"]==nil;
    
    NSAssert(value,@"Info.plist does not contain NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription");
    PermissionStatus authStatus = [self statusLocationAlways];
    PermissionType *type = [self.permissionViewController.arrPermissionData objectAtIndex:sender.tagOfButton];
    switch (authStatus) {
        case Unknown:
            if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
                
                [[NSUserDefaults standardUserDefaults]setBool:true forKey:requestedInUseToAlwaysUpgrade];
                [[NSUserDefaults standardUserDefaults]synchronize];
            }
            if ([self.locationManager respondsToSelector:@selector
                 (requestWhenInUseAuthorization)]) {
                [self.locationManager requestWhenInUseAuthorization];
            }
            // [self.locationManager  startUpdatingLocation];
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


-(PermissionStatus)statusBluetooth{
    if ([self askedBluetooth:requestedBluetooth]){
        [self triggerBluetoothStatusUpdate ];
    } else {
        return Unknown;
    }
    int authStatus = [CBPeripheralManager authorizationStatus];
    switch (authStatus) {
        case CBCentralManagerStatePoweredOn:
            return Authorized;
            break;
        case CBCentralManagerStateUnauthorized:
            return Unauthorized;
            break;
        case CBCentralManagerStateUnsupported:
        case CBCentralManagerStatePoweredOff:
            return Disabled;
            break;
        case CBCentralManagerStateUnknown:
            return Unknown;
            break;
        default:
            break;
    }
    return Unknown;
}



-(PermissionStatus)statusLocationAlways{
    if([CLLocationManager locationServicesEnabled])
    {
        [self.locationManager startUpdatingLocation];
        
    } else {
        return Disabled;
    }
    int authStatus = [CLLocationManager authorizationStatus];
    switch (authStatus) {
        case kCLAuthorizationStatusAuthorizedAlways:
            return Authorized;
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            return Authorized;
            break;
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
            break;
            return Unauthorized;
        case kCLAuthorizationStatusNotDetermined:
            return Unknown;
            break;
    }
    return Unknown;
}

-(PermissionStatus)statusPhotos{
    
    PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
    
    switch (authStatus) {
        case PHAuthorizationStatusAuthorized:
            return Authorized;
            break;
        case PHAuthorizationStatusRestricted:
        case PHAuthorizationStatusDenied:
            return Unauthorized;
            break;
        case PHAuthorizationStatusNotDetermined:
            return Unknown;
            break;
    }
    return Unknown;
    
}

-(PermissionStatus)statusMicrophone{
    AVAudioSessionRecordPermission authStatus = [[AVAudioSession sharedInstance]recordPermission];
    switch (authStatus) {
        case AVAudioSessionRecordPermissionGranted:
            return Authorized;
        case AVAudioSessionRecordPermissionDenied:
            return Unauthorized;
        case AVAudioSessionRecordPermissionUndetermined:
            return Unknown;
    }
    return Unknown;
}

-(PermissionStatus)statusCamera{
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (authStatus) {
        case AVAuthorizationStatusAuthorized:
            return Authorized;
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied:
            return Unauthorized;
        case AVAuthorizationStatusNotDetermined:
            return Unknown;
    }
    return Unknown;
    
}


-(PermissionStatus) statusContacts {
    int authStatus = 0;
    if ([CNContactStore class]){
        authStatus = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        switch(authStatus){
            case CNAuthorizationStatusAuthorized:
                return Authorized;
            case CNAuthorizationStatusRestricted:
            case CNAuthorizationStatusDenied:
                return Unauthorized;
            case CNAuthorizationStatusNotDetermined:
                return Unknown;
        }
    } else {
        ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
        int authStatus = ABAddressBookGetAuthorizationStatus();
        // Fallback on earlier versions
        switch(authStatus){
            case AVAuthorizationStatusAuthorized:
                return Authorized;
            case AVAuthorizationStatusRestricted:
            case AVAuthorizationStatusDenied:
                return Unauthorized;
            case AVAuthorizationStatusNotDetermined:
                return Unknown;
        }
        
    }
    return authStatus;
}

-(PermissionStatus) statusReminders{
    int authStatus = 0;
    authStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
    
    switch (authStatus) {
        case EKAuthorizationStatusAuthorized:
            return Authorized;
            break;
        case EKAuthorizationStatusRestricted:
        case EKAuthorizationStatusDenied:
            return Unauthorized;
            break;
        case EKAuthorizationStatusNotDetermined:
            return Unknown;
            break;
    }
    return authStatus;
}

-(PermissionStatus) statusEvents{
    int authStatus = 0;
    authStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    
    switch (authStatus) {
        case EKAuthorizationStatusAuthorized:
            return Authorized;
            break;
        case EKAuthorizationStatusRestricted:
        case EKAuthorizationStatusDenied:
            return Unauthorized;
            break;
        case EKAuthorizationStatusNotDetermined:
            return Unknown;
            break;
    }
    return authStatus;
}

-(PermissionStatus) statusNotifications{
    
    int authStatus = 0;
    UIUserNotificationSettings *settings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    if(settings.types!= UIUserNotificationTypeNone){
        return Authorized;
    } else {
        if([[NSUserDefaults standardUserDefaults]boolForKey:requestedNotifications]){
            return Unauthorized;
        } else {
            return Unknown;
        }
    }
    return authStatus;
}

-(PermissionStatus) status{
    int authStatus = 0;
    return authStatus;
}


-(void)requestMicrophone:(CustomButton*)sender{
    PermissionStatus authStatus = [self statusMicrophone];
    PermissionType *type = [self.permissionViewController.arrPermissionData objectAtIndex:sender.tagOfButton];
    switch (authStatus) {
        case Unknown:
            [self accessmicroPhone];
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
    //wwjeopwjeow
}

-(void)showingNotificationPermission {
    NSNotificationCenter* notifCenter = [NSNotificationCenter defaultCenter];
    
    [notifCenter removeObserver:notifCenter name:UIApplicationWillResignActiveNotification object:nil];
    [notifCenter addObserver:self selector:@selector(finishedShowingNotificationPermission) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [notificationTimer invalidate ];
}

-(void)finishedShowingNotificationPermission{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [notificationTimer invalidate ];
    
    [[NSUserDefaults standardUserDefaults]setBool:true forKey:requestedNotifications];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    // callback after a short delay, otherwise notifications don't report proper auth
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(0.1 * (double)(NSEC_PER_SEC))), dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after delay
        [self detectAndCallback];
    });
    
}

-(void)accessNotification{
    
    //    let notificationsPermission = self.configuredPermissions
    //    .first { $0 is NotificationsPermission } as? NotificationsPermission
    //    let notificationsPermissionSet = notificationsPermission?.notificationCategories
    //
    NSNotificationCenter* notifCenter = [NSNotificationCenter defaultCenter];
    [notifCenter addObserver:self selector:@selector(showingNotificationPermission) name:UIApplicationWillResignActiveNotification object:nil];
    notificationTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(finishedShowingNotificationPermission) userInfo:nil repeats:false];
    UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    
    
    
}
-(void)requestNotifications:(CustomButton*)sender{
    PermissionStatus authStatus = [self statusNotifications];
    PermissionType *type = [self.permissionViewController.arrPermissionData objectAtIndex:sender.tagOfButton];
    switch (authStatus) {
        case Unknown:
            [self accessNotification];
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

-(void)accessEvents{
    EKEventStore *store = [[EKEventStore alloc] init];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        [self detectAndCallback];
    }];
}

-(void)accessReminders{
    EKEventStore *store = [[EKEventStore alloc] init];
    [store requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
        [self detectAndCallback];
        // handle access here
    }];
}

-(void)requestReminders:(CustomButton*)sender{
    PermissionStatus authStatus = [self statusReminders];
    PermissionType *type = [self.permissionViewController.arrPermissionData objectAtIndex:sender.tagOfButton];
    switch (authStatus) {
        case Unknown:
            [self accessReminders];
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

-(void)requestEvents:(CustomButton*)sender{
    PermissionStatus authStatus = [self statusEvents];
    PermissionType *type = [self.permissionViewController.arrPermissionData objectAtIndex:sender.tagOfButton];
    switch (authStatus) {
        case Unknown:
            [self accessEvents];
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

-(void)accessmicroPhone{
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (granted) {
            
        }
        [self detectAndCallback];
    }];
}

-(void)accessPhotoLibrary{
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        [self detectAndCallback];
        
    }];
}

/**
 Request access to Camera, if necessary.
 */

- (void)requestCamera:(CustomButton*)sender{
    PermissionStatus authStatus = [self statusCamera ];
    PermissionType *type = [self.permissionViewController.arrPermissionData objectAtIndex:sender.tagOfButton];
    switch (authStatus) {
        case Unknown:
            [self accessCamera];
            break;
        case Unauthorized:
            [self showDeniedAlert:type];
            break;
        default:
            break;
            
    }
}
-(void)accessCamera{
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                             completionHandler:^(BOOL granted) {
                                 [self detectAndCallback];
                             }];
}

/**
 Requests access to Bluetooth, if necessary.
 */
-(void)requestBluetooth:(CustomButton*)sender{
    
    
    PermissionStatus status = [self statusBluetooth];
    PermissionType *type = [self.permissionViewController.arrPermissionData objectAtIndex:sender.tagOfButton];
    
    switch (status) {
        case Disabled:
            // showDisabledAlert(.Bluetooth)
            break;
        case Unauthorized:
            [self showDeniedAlert:type];
            break;
        case Unknown:
            [self triggerBluetoothStatusUpdate];
        default:
            break;
    }
    
}

-(void)triggerBluetoothStatusUpdate{
    if (!(waitingForBluetooth && self.bluetoothManager.state == Unknown)){
        [self.bluetoothManager startAdvertising:nil];
        [self.bluetoothManager stopAdvertising];
        [self setaskedBluetooth:true andKey:requestedBluetooth];
        waitingForBluetooth = true;
    }
}
/**
 
 Requests access to Contacts, if necessary.
 */
- (void)requestContacts:(CustomButton*)sender{
    PermissionStatus authStatus = [self statusContacts ];
    PermissionType *type = [self.permissionViewController.arrPermissionData objectAtIndex:sender.tagOfButton];
    switch (authStatus) {
        case Unknown:
            
            if ([CNContactStore class]) {
                //ios9 or later
                CNEntityType entityType = CNEntityTypeContacts;
                if( [CNContactStore authorizationStatusForEntityType:entityType] == CNAuthorizationStatusNotDetermined)
                {
                    CNContactStore * contactStore = [[CNContactStore alloc] init];
                    [contactStore requestAccessForEntityType:entityType completionHandler:^(BOOL granted, NSError * _Nullable error) {
                        [self detectAndCallback];
                    }];
                }
                else if( [CNContactStore authorizationStatusForEntityType:entityType]== CNAuthorizationStatusAuthorized)
                {
                    [self detectAndCallback];
                }
            } else {
                CFErrorRef error = NULL;
                ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
                
                ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                    if (error) {
                        NSLog(@"ABAddressBookRequestAccessWithCompletion error: %@", CFBridgingRelease(error));
                    }
                    
                    if (granted) {
                        // if they gave you permission, then just carry on
                        
                        [self detectAndCallback];
                        ;
                    } else {
                        
                        // however, if they didn't give you permission, handle it gracefully, for example...
                        
                        
                    }
                    
                    CFRelease(addressBook);
                });
            }
            break;
        case Unauthorized:
            [self showDeniedAlert:type];
            break;
        default:
            break;
    }
}


/**
 Request access to LocationInUse, if necessary.
 */

/**
 here display denied error **/
-(void)showDeniedAlert:(PermissionType*)type{
    [self.delegate CIPermissionControlDidPresentAlert:(PermissionType*)type];
    
}
-(void)detectAndCallback{
    //dispatch_async(dispatch_get_global_queue(0, 0), ^{
    //load your data here.
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    //});
}

// CLLocationManager Delegate Methods
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
        [self.locationManager startUpdatingLocation];
    }
    [self detectAndCallback];
}

-(BOOL)askedBluetooth:(NSString*)key{
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}

-(void)setaskedBluetooth:(BOOL)value andKey:(NSString*)key{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:requestedBluetooth];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{
    int state = peripheral.state;
    
}
@end

