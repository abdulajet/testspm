#import <Foundation/Foundation.h>

/**
 @brief Object containing NXMClient endpoints configuration.
 */
@interface NXMClientConfig : NSObject

@property (nonnull, nonatomic, readonly) NSString *apiUrl;
@property (nonnull, nonatomic, readonly) NSString *websocketUrl;
@property (nonnull, nonatomic, readonly) NSString *ipsUrl;

/**
 @brief Default values:
     apiURL      : "https://api.nexmo.com/"
     websocketUrl: "https://ws.nexmo.com/"
     ipsUrl      : "https://api.nexmo.com/v1/image/"
 */
- (nonnull instancetype)init;

- (nonnull instancetype)initWithApiUrl:(nonnull NSString *)apiURL
                          websocketUrl:(nonnull NSString *)websocketUrl
                                ipsUrl:(nonnull NSString *)ipsUrl;

+ (nonnull NXMClientConfig *)LON;
+ (nonnull NXMClientConfig *)SNG;
+ (nonnull NXMClientConfig *)DAL;
+ (nonnull NXMClientConfig *)WDC;

@end
