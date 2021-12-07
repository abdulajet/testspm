@import Foundation;

@class NXMPinningConfig;

/**
  Object containing NXMClient endpoints configuration.
 */
@interface NXMClientConfig: NSObject

/// The API URL of the your chosen datacenter.
@property (nonnull, nonatomic) NSString *apiUrl;

/// The WebSocket URL of the your chosen datacenter.
@property (nonnull, nonatomic) NSString *websocketUrl;

/// The IPS URL of the your chosen datacenter.
@property (nonnull, nonatomic) NSString *ipsUrl;

/// Your chosen Interactive Connectivity Establishment (ICE) servers.
@property (nonnull, nonatomic) NSArray<NSString *> *iceServerUrls;

/// Optional API pinning configuration.
@property (nullable, nonatomic) NXMPinningConfig *apiPinning;

/// Optional WebSocket pinning configuration.
@property (nullable, nonatomic) NXMPinningConfig *websocketPinning;

/// Whether to use the first ICE candidate or not.
@property (nonatomic) BOOL useFirstIceCandidate;

/// Allow the sdk to automatically reconnect media when network interfaces changes
@property (nonatomic) BOOL autoMediaReoffer;

/**
 The default initializer for the class.

 Default values:

     apiURL:               @"https://api.nexmo.com/"
     websocketUrl:         @"https://ws.nexmo.com/"
     ipsUrl:               @"https://api.nexmo.com/v1/image/"
     iceServerUrls:        @[@"stun:stun.l.google.com:19302"]
     apiPublicKeys:        NULL
     websocketPublicKeys:  NULL
     useFirstIceCandidate: YES
     autoMediaReoffer:     NO
 */
- (nonnull instancetype)init;

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
                  useFirstIceCandidate:(BOOL)useFirstIceCandidate
                      autoMediaReoffer:(BOOL)autoMediaReoffer;


/// A static helper for the Amsterdam datacenter.
+ (nonnull NXMClientConfig *)AMS;

/// A static helper for the London datacenter.
+ (nonnull NXMClientConfig *)LON;

/// A static helper for the Singapore datacenter.
+ (nonnull NXMClientConfig *)SNG;

/// A static helper for the Dallas datacenter.
+ (nonnull NXMClientConfig *)DAL;

/// A static helper for the Washington DC datacenter.
+ (nonnull NXMClientConfig *)WDC;


/// NXMClientConfig's description.
- (nonnull NSString *)description;


/**
 An additional initializer for the class.
 @param apiURL The API URL of the your chosen datacenter.
 @param websocketUrl The WebSocket URL of the your chosen datacenter.
 @param ipsUrl The IPS URL of the your chosen datacenter.
 */
- (nonnull instancetype)initWithApiUrl:(nonnull NSString *)apiURL
                          websocketUrl:(nonnull NSString *)websocketUrl
                                ipsUrl:(nonnull NSString *)ipsUrl
OBJC_DEPRECATED("generate a new instance with [NXMClientConfig new], then modify its properties before setting NXMClient's configuration");

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
                         iceServerUrls:(nonnull NSArray<NSString *> *)iceServerUrls
OBJC_DEPRECATED("generate a new instance with [NXMClientConfig new], then modify its properties before setting NXMClient's configuration");

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
                  useFirstIceCandidate:(BOOL)useFirstIceCandidate
OBJC_DEPRECATED("generate a new instance with [NXMClientConfig new], then modify its properties before setting NXMClient's configuration");


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
                  useFirstIceCandidate:(BOOL)useFirstIceCandidate
OBJC_DEPRECATED("generate a new instance with [NXMClientConfig new], then modify its properties before setting NXMClient's configuration");

@end
