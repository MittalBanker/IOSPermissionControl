//
//  CZPickerView.h
//
//  Created by chenzeyu on 9/6/15.
//  Copyright (c) 2015 chenzeyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CIPermissionControl;

@protocol CZPickerViewDataSource <NSObject>

@required
/* number of items for picker */
- (NSInteger)numberOfRowsInPickerView:(CIPermissionControl *)pickerView;

@optional
/*
 Implement at least one of the following method,
 CZPickerView:(CZPickerView *)pickerView
 attributedTitleForRow:(NSInteger)row has higer priority
*/

/* attributed picker item title for each row */
- (NSAttributedString *)czpickerView:(CIPermissionControl *)pickerView
                            attributedTitleForRow:(NSInteger)row;

/* picker item title for each row */
- (NSString *)czpickerView:(CIPermissionControl *)pickerView
                            titleForRow:(NSInteger)row;

/* picker item image for each row */
- (UIImage *)czpickerView:(CIPermissionControl *)pickerView imageForRow:(NSInteger)row;

@end

@protocol CZPickerViewDelegate <NSObject>

@optional

/** delegate method for picking one item */
- (void)czpickerView:(CIPermissionControl *)pickerView
          didConfirmWithItemAtRow:(NSInteger)row;

/*
 delegate method for picking multiple items,
 implement this method if allowMultipleSelection is YES,
 rows is an array of NSNumbers
 */
- (void)czpickerView:(CIPermissionControl *)pickerView
          didConfirmWithItemsAtRows:(NSArray *)rows;

/** delegate method for canceling */
- (void)czpickerViewDidClickCancelButton:(CIPermissionControl *)pickerView;
@end

@interface CIPermissionControl : UIView<UITableViewDataSource, UITableViewDelegate>

/** Initialize the picker view with titles
 @param headerTitle The title of header
 @param cancelButtonTitle The title for cancelButton
 @param confirmButtonTitle The title for confirmButton
 */
- (id)initWithHeaderTitle:(NSString *)headerTitle
        cancelButtonTitle:(NSString *)cancelButtonTitle
       confirmButtonTitle:(NSString *)confirmButtonTitle;

/** show the picker */
- (void)show;

/** return previously selected row, in array of NSNumber form. */
- (NSArray *)selectedRows;

/** set pre-selected rows, rows should be array of NSNumber. */
- (void)setSelectedRows: (NSArray *)rows;

@property id<CZPickerViewDelegate> delegate;

@property id<CZPickerViewDataSource> dataSource;

/** whether to show footer (including confirm and cancel buttons), default NO */
@property BOOL needFooterView;

/** whether allow tap background to dismiss the picker, default YES */
@property BOOL tapBackgroundToDismiss;

/** whether allow selection of multiple items/rows, default NO, if this
 property is YES, then footerView will be shown */
@property BOOL allowMultipleSelection;

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
