#import <Foundation/Foundation.h>

/**
  Object containing NXMClient endpoints configuration.
 */
@interface NXMClientConfig : NSObject

/// The API URL of the your chosen datacenter.
@property (nonnull, nonatomic, readonly) NSString *apiUrl;

/// The WebSocket URL of the your chosen datacenter.
@property (nonnull, nonatomic, readonly) NSString *websocketUrl;

/// The IPS URL of the your chosen datacenter.
@property (nonnull, nonatomic, readonly) NSString *ipsUrl;

/// Your chosen Interactive Connectivity Establishment (ICE) servers.
@property (nonnull, nonatomic, readonly) NSArray<NSString *> *iceServerUrls;

/// Whether to use the first ICE candidate or not.
@property (nonatomic, readonly) BOOL useFirstIceCandidate;

/**
 The default initializer for the class.
 
 Default values:
 
     apiURL:        @"https://api.nexmo.com/"
     websocketUrl:  @"https://ws.nexmo.com/"
     ipsUrl:        @"https://api.nexmo.com/v1/image/"
     iceServerUrls: @[@"stun:stun.l.google.com:19302"]
     useFirstIceCandidate: NO
 */
- (nonnull instancetype)init;

/**
 An additional initializer for the class.
 @param apiURL The API URL of the your chosen datacenter.
 @param websocketUrl The WebSocket URL of the your chosen datacenter.
 @param ipsUrl The IPS URL of the your chosen datacenter.
 */
- (nonnull instancetype)initWithApiUrl:(nonnull NSString *)apiURL
                          websocketUrl:(nonnull NSString *)websocketUrl
                                ipsUrl:(nonnull NSString *)ipsUrl;

/**
 An additional initializer for the class.
 @param apiURL The API URL of the your chosen datacenter.
 @param websocketUrl The WebSocket URL of the your chosen datacenter.
 @param ipsUrl The IPS URL of the your chosen datacenter.
 @param iceServerUrls Your chosen Interactive Connectivity Establishment (ICE) servers.
 */
- (nonnull instancetype)initWithApiUrl:(nonnull NSString *)apiURL
                          websocketUrl:(nonnull NSString *)websocketUrl
                                ipsUrl:(nonnull NSString *)ipsUrl
                         iceServerUrls:(nonnull NSArray<NSString *> *)iceServerUrls;

/**
 An additional initializer for the class.
 @param apiURL The API URL of the your chosen datacenter.
 @param websocketUrl The WebSocket URL of the your chosen datacenter.
 @param ipsUrl The IPS URL of the your chosen datacenter.
 @param useFirstIceCandidate Whether to use the first ICE candidate or not.
 */
- (nonnull instancetype)initWithApiUrl:(nonnull NSString *)apiURL
                          websocketUrl:(nonnull NSString *)websocketUrl
                                ipsUrl:(nonnull NSString *)ipsUrl
                  useFirstIceCandidate:(BOOL) useFirstIceCandidate;

/**
 An additional initializer for the class.
 @param apiURL The API URL of the your chosen datacenter.
 @param websocketUrl The WebSocket URL of the your chosen datacenter.
 @param ipsUrl The IPS URL of the your chosen datacenter.
 @param iceServerUrls Your chosen Interactive Connectivity Establishment (ICE) servers.
 @param useFirstIceCandidate Whether to use the first ICE candidate or not.
 */
- (nonnull instancetype)initWithApiUrl:(nonnull NSString *)apiURL
                          websocketUrl:(nonnull NSString *)websocketUrl
                                ipsUrl:(nonnull NSString *)ipsUrl
                         iceServerUrls:(nonnull NSArray<NSString *> *)iceServerUrls
                  useFirstIceCandidate:(BOOL) useFirstIceCandidate;

///A static helper for the Amsterdam datacenter.
+ (nonnull NXMClientConfig *)AMS;

///A static helper for the London datacenter.
+ (nonnull NXMClientConfig *)LON;

///A static helper for the Singapore datacenter.
+ (nonnull NXMClientConfig *)SNG;

///A static helper for the Dallas datacenter.
+ (nonnull NXMClientConfig *)DAL;

///A static helper for the Washington DC datacenter.
+ (nonnull NXMClientConfig *)WDC;

@end
