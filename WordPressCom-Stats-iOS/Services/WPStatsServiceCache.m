//
//  WPStatsServiceCache.m
//  WordPressCom-Stats-iOS
//
//  Copyright © 2016 Automattic Inc. All rights reserved.
//

#import "WPStatsServiceCache.h"

@interface WPStatsServiceCache ()

@property (nonnull, nonatomic, strong) NSCache *cache;

@end

@implementation WPStatsServiceCache

- (instancetype)init
{
    if (self = [super init]) {
        self.cache = [NSCache new];
    }
    return self;
}

- (nullable WPStatsService *)serviceForSiteID:(nonnull NSNumber *)siteID
{
    NSParameterAssert(siteID);
    return [self.cache objectForKey:siteID];
}

- (void)setService:(nonnull WPStatsService *)service forSiteID:(nonnull NSNumber *)siteID
{
    NSParameterAssert(siteID);
    [self.cache setObject:service forKey:siteID];
}

@end
