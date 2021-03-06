//
//  ShoppingEffectiveDateCell.h
//  groupbuy
//
//  Created by LouisLee on 11-8-20.
//  Copyright 2011 ET. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPTableViewCell.h"
#import "PPSegmentControl.h"

#define ONE_WEEK 7
#define ONE_MONTH 30
#define THREE_MONTH 90
#define HALF_YEAR 183
#define UNLIMIT 0
#define PERIOD_UNLIMIT_INDEX 4

#define NOT_LIMIT @"不限"
#define TIME_ZONE @"Asia/Shanghai"


@interface ShoppingValidPeriodCell : PPTableViewCell<PPSegmentControlDelegate> {

    UIButton *validPeriod;
    NSDate *expireDate;
    PPSegmentControl *periodSeg;
}
@property (nonatomic, retain) IBOutlet UIButton *validPeriod;
@property (nonatomic, retain) NSDate *exipireDate;
@property (nonatomic, retain) PPSegmentControl * periodSeg;

+ (ShoppingValidPeriodCell*)createCell:(id)delegate;
+ (NSString*)getCellIdentifier;
+ (CGFloat)getCellHeight;
//+ (NSString *) getPeriodTextWithDate:(NSDate *)date;

+ (NSDate *)calculateValidPeriodSinceNow:(NSInteger) day;

+ (NSArray *)getDayArray;

+ (NSDate *)calculateValidPeriodWithSegmentIndex:(NSInteger) index;

- (NSInteger)segmentIndexForDate:(NSDate *)date;

- (void)setCellInfo:(NSDate *)date;

- (NSDate *)getExpireDate;

@end
