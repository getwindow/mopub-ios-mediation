//
//  VungleAdvancedBidder.m
//  MoPub-Vungle-Adapters
//
//

#import "VungleAdvancedBidder.h"
#import "MPVungleRouter.h"
#import <VungleSDK/VungleSDK.h>
#import <VungleSDK/VungleSDKHeaderBidding.h>

@interface VungleAdvancedBidder() <VungleSDKHeaderBidding>
// Maps [placement ID: token]
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> * tokenMap;
@end

@implementation VungleAdvancedBidder

- (instancetype)init {
    if (self = [super init]) {
        // Initialize the empty token map.
        _tokenMap = [NSMutableDictionary dictionary];
        
        // Respond to header bidding notifications
        [[VungleSDK sharedSDK] setHeaderBiddingDelegate:self];
        
        // Add self to Vungle Router to manage the removal of tokens.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        if ([MPVungleRouter.sharedRouter respondsToSelector:@selector(setBidder:)]) {
            [MPVungleRouter.sharedRouter performSelector:@selector(setBidder:) withObject:self];
        }
#pragma clang diagnostic pop
    }
    
    return self;
}

- (void)removeTokenForPlacement:(NSString *)placement {
    if (placement == nil) {
        return;
    }
    
    self.tokenMap[placement] = nil;
}

#pragma mark - MPAdvancedBidder

- (NSString *)creativeNetworkName {
    return @"vungle";
}

- (NSString *)token {
#warning TODO: Figure out real spec with Backend
    // No tokens
    if (self.tokenMap.count == 0) {
        return nil;
    }
    
    // Generate a JSON string from the bidder token map.
    NSError * error = nil;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:self.tokenMap options:0 error:&error];
    if (error != nil) {
        NSLog(@"Failed to generate JSON payload from Vungle bidder tokens: %@", error.localizedDescription);
        return nil;
    }
    
    NSString * json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return json;
}

#pragma mark - VungleSDKHeaderBidding

/**
 * If implemented, this will get called when the SDK has a placement prepared with a
 * corresponding bid token.
 * @param placement The ID of a placement which is ready to be played
 * @param bidToken An encrypted bid token used to identify the placement through the auction
 */
- (void)placementPrepared:(NSString *)placement withBidToken:(NSString *)bidToken {
    // Validate that `placement` and `bidToken` are valid.
    if (placement == nil) {
        NSLog(@"VungleSDKHeaderBidding placementPrepared: gave back a nil placement");
        return;
    }
    
    if (bidToken == nil) {
        NSLog(@"VungleSDKHeaderBidding placementPrepared: gave back a nil bidToken");
        return;
    }
    
    // Set the token
    self.tokenMap[placement] = bidToken;
}

@end
