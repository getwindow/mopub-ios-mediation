//
//  VungleAdvancedBidder.h
//  MoPub-Vungle-Adapters
//

#if __has_include(<MoPub/MoPub.h>)
#import <MoPub/MoPub.h>
#else
#import "MPAdvancedBidder.h"
#endif

@interface VungleAdvancedBidder : NSObject <MPAdvancedBidder>
@property (nonatomic, copy, readonly) NSString * creativeNetworkName;
@property (nonatomic, copy, readonly) NSString * token;

/**
 Removes any token for the specified placement.
 @param placement Placement ID.
 */
- (void)removeTokenForPlacement:(NSString *)placement;
@end
