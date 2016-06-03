//
//  CIPermissionControl.h
//
//  Created by chenzeyu on 9/6/15.
//  Copyright (c) 2015 chenzeyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PermissionType.h"
@class CIPermissionControl;

@protocol CIPermissionControlDataSource <NSObject>

@required
/* number of items for picker */
- (NSInteger)numberOfRowsInPickerView:(CIPermissionControl *)pickerView;

@optional
/*
 Implement at least one of the following method,
 CIPermissionControl:(CIPermissionControl *)pickerView
 attributedTitleForRow:(NSInteger)row has higer priority
*/

/* attributed picker item title for each row */
- (NSAttributedString *)CIPermissionControl:(CIPermissionControl *)pickerView
                            attributedTitleForRow:(NSInteger)row;

/* picker item title for each row */
- (NSString *)CIPermissionControl:(CIPermissionControl *)pickerView
                            titleForRow:(NSInteger)row;

/* picker item image for each row */
- (UIImage *)CIPermissionControl:(CIPermissionControl *)pickerView imageForRow:(NSInteger)row;

@end

@protocol CIPermissionControlDelegate <NSObject>

@optional

/** delegate method for picking one item */
- (void)CIPermissionControl:(CIPermissionControl *)pickerView
          didConfirmWithItemAtRow:(NSInteger)row;

/*
 delegate method for picking multiple items,
 implement this method if allowMultipleSelection is YES,
 rows is an array of NSNumbers
 */
- (void)CIPermissionControl:(CIPermissionControl *)pickerView
          didConfirmWithItemsAtRows:(NSArray *)rows;

/** delegate method for canceling */

- (void)CIPermissionControlDidPresentAlert:(PermissionType*)type;

- (void)CIPermissionControlDidClickCancelButton:(CIPermissionControl *)pickerView;
@end

@interface CIPermissionControl : UIView<UITableViewDataSource, UITableViewDelegate,CLLocationManagerDelegate,CBPeripheralManagerDelegate>
{
    NSTimer *notificationTimer;
}
/** Initialize the picker view with titles
 @param headerTitle The title of header
 @param cancelButtonTitle The title for cancelButton
 @param confirmButtonTitle The title for confirmButton
 */

- (id)initWithHeaderTitle:(NSString *)headerTitle;

/** show the picker */
- (void)show;

/** return previously selected row, in array of NSNumber form. */
- (NSArray *)selectedRows;

/** set pre-selected rows, rows should be array of NSNumber. */
- (void)setSelectedRows: (NSArray *)rows;

@property id<CIPermissionControlDelegate> delegate;

@property id<CIPermissionControlDataSource> dataSource;

/** whether to show footer (including confirm and cancel buttons), default NO */
@property BOOL needFooterView;

/** whether allow tap background to dismiss the picker, default YES */
@property BOOL tapBackgroundToDismiss;

/** whether allow selection of multiple items/rows, default NO, if this
 property is YES, then footerView will be shown */

@property UITableView *tableView;

/** property to decide parent view*/
@property UIView *parentView;
 
@property BOOL allowMultipleSelection;
@property NSMutableArray *arrPermission;
/** picker header background color */
@property (nonatomic, strong) UIColor *headerBackgroundColor;

/** picker header title font */
@property (nonatomic, strong) UIFont *headerTitleFont;

/** picker header title color */
@property (nonatomic, strong) UIColor *headerTitleColor;

/** picker cancel button background color */
/** picker's animation duration for showing and dismissing */
@property CGFloat animationDuration;

/** width of picker */
@property CGFloat pickerWidth;


@end
