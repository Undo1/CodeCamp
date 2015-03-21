/*
     File: StoreManager.m
 Abstract: Retrieves product information from the App Store using SKRequestDelegate, SKProductsRequestDelegate,SKProductsResponse, and
           SKProductsRequest. Notifies its observer with a list of products available for sale along with a list of invalid product
           identifiers. Logs an error message if the product request failed.
 
  Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 
*/

#import "StoreManager.h"
#import "RMStore.h"

NSString * const IAPProductRequestNotification = @"IAPProductRequestNotification";

@interface StoreManager()<SKRequestDelegate, SKProductsRequestDelegate>
@end

@implementation StoreManager

+ (StoreManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    static StoreManager * storeManagerSharedInstance;
    
    dispatch_once(&onceToken, ^{
        storeManagerSharedInstance = [[StoreManager alloc] init];
    });
    return storeManagerSharedInstance;
}


- (id)init
{
    self = [super init];
	if (self != nil)
	{
		_availableProducts = [[NSMutableArray alloc] initWithCapacity:0];
		_invalidProductIds = [[NSMutableArray alloc] initWithCapacity:0];
	}
    return self;
}


#pragma mark -
#pragma mark Request information

// Fetch information about your products from the App Store
-(void)fetchProductInformationForIds:(NSArray *)productIds
{
    [[RMStore defaultStore] requestProducts:[NSSet setWithArray:productIds] success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
        if (products.count > 0)
        {
            self.availableProducts = products.mutableCopy;
            self.status = IAPProductsFound;
            [[NSNotificationCenter defaultCenter] postNotificationName:IAPProductRequestNotification object:self];
        }
        
        if (invalidProductIdentifiers.count > 0)
        {
            self.invalidProductIds = invalidProductIdentifiers.mutableCopy;
            self.status = IAPIdentifiersNotFound;
            [[NSNotificationCenter defaultCenter] postNotificationName:IAPProductRequestNotification object:self];
        }
        
    } failure:^(NSError *error) {
        NSLog(@"Product Request Status: %@",[error localizedDescription]);
    }];
}

#pragma mark -
#pragma mark Helper method

// Return the product's title matching a given product identifier
-(NSString *)titleMatchingProductIdentifier:(NSString *)identifier
{
    NSString *productTitle = nil;
    // Iterate through availableProducts to find the product whose productIdentifier
    // property matches identifier, return its localized title when found
    for (SKProduct *product in self.availableProducts)
    {
        if ([product.productIdentifier isEqualToString:identifier])
        {
            productTitle = product.localizedTitle;
        }
    }
    return productTitle;
}

@end
