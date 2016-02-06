//
//  WPStatsServiceCache.h
//  WordPressCom-Stats-iOS
//
//  Copyright © 2016 Automattic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WPStatsService.h"

@interface WPStatsServiceCache : NSObject

- (nullable WPStatsService *)serviceForSiteID:(nonnull NSNumber *)siteID;
- (void)setService:(nonnull WPStatsService *)service forSiteID:(nonnull NSNumber *)siteID;

@end
