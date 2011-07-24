//
//  ProductPriceDataLoader.m
//  groupbuy
//
//  Created by qqn_pipi on 11-7-23.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "ProductPriceDataLoader.h"
#import "ProductManager.h"
#import "ProductService.h"

@implementation ProductPriceDataLoader

- (NSArray*)requestProductListFromDB
{
    return [ProductManager getAllProductsByUseFor:USE_FOR_PRICE sortByKey:@"price"];
}

- (void)requestProductListFromServer:(BOOL)isRequestLastest controller:(CommonProductListController*)controller
{
    ProductService* productService = GlobalGetProductService();
    if (isRequestLastest){
        [productService requestProductData:controller useFor:USE_FOR_PRICE startOffset:0 cleanData:YES];
    }
    else{
        int startOffset = [controller.dataList count];
        [productService requestProductData:controller useFor:USE_FOR_PRICE startOffset:startOffset cleanData:NO];
    }        
}

@end

@implementation ProductRebateDataLoader

- (NSArray*)requestProductListFromDB
{
    return [ProductManager getAllProductsByUseFor:USE_FOR_PRICE sortByKey:@"rebate"];
}

- (void)requestProductListFromServer:(BOOL)isRequestLastest controller:(CommonProductListController*)controller
{
    ProductService* productService = GlobalGetProductService();
    if (isRequestLastest){
        [productService requestProductData:controller useFor:USE_FOR_REBATE startOffset:0 cleanData:YES];
    }
    else{
        int startOffset = [controller.dataList count];
        [productService requestProductData:controller useFor:USE_FOR_REBATE startOffset:startOffset cleanData:NO];
    }        
}

@end
