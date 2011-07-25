//
//  Product.h
//  groupbuy
//
//  Created by qqn_pipi on 11-7-23.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Product : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * data;
@property (nonatomic, retain) NSNumber * useFor;
@property (nonatomic, retain) NSString * productId;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSNumber * value;
@property (nonatomic, retain) NSNumber * rebate;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * loc;
@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSNumber * deleteFlag;
@property (nonatomic, retain) NSNumber * deleteTimeStamp;
@property (nonatomic, retain) NSNumber * bought;
@property (nonatomic, retain) NSString * siteName;
@property (nonatomic, retain) NSString * siteURL;
@property (nonatomic, retain) NSDate * browseDate;

@end
