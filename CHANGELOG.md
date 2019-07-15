# NexmoClient mobile SDK for iOS Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [###VERSION###] - 2019-07-03
### Fixed
- NXMConversationEventsController returns the last event
- CallMember status calculated by the current leg status.

### Added
Added initiators property to NXMMember 
```
@property (nonatomic, readonly, nonnull) NSDictionary<NSValue *, NXMInitiator *> *initiators;

@interface NXMInitiator : NSObject
@property (nonatomic, readonly) BOOL isSystem;
@property (nonatomic, copy, nullable) NSString *userId;
@property (nonatomic, copy, nullable) NSString *memberId;
@property (nonatomic, copy, nonnull) NSDate *time;
@end
```

Added NXMConversationUpdatesDelegate to notify on member updates like media,leg,state
```
@protocol NXMConversationUpdatesDelegate <NSObject>
@optional
- (void)memberUpdated:(nonnull NXMMember *)member forUpdateType:(NXMMemberUpdateType)type;
@end
```

Example:
```

- (void)memberUpdated:(NXMMember *)member forUpdateType:(NXMMemberUpdateType)type {
	NSLog("member updated")
	// do something with the member and the type 
}

```

Added updatesDelegate property to NXMConversation 
```
@property (nonatomic, weak, nullable) id <NXMConversationUpdatesDelegate> updatesDelegate;
```

### Changed
Renamed
```
- (void)rejectWithCompletionHandler:(NXMErrorCallback _Nullable)completionHandler;
```

Removed on NXMCallMemberStatus enum the statuses:
```
NXMCallMemberStatusDialling
NXMCallMemberStatusCancelled
```

Removed on NXMCall object the callId property:
```
@property (nonatomic, copy, nonnull) NSString *callId;
```

## [0.3.0] - 2019-06-02
### Added
- Calls JS and Native SDKs support.

### Changed
- Add member channel and direction data
```
NXMCallMember
@property (nonatomic, readonly, nullable) NXMChannel *channel;


NXMChannel channel {
	NXMDirection from {
		NXMDirectionType type,
		NSString Data
	},
	NXMDirection to {
		NXMDirectionType type,
		NSString Data
	}
}
```

Deprecated
```
NXMCallMember
@property (nonatomic, copy, nullable) NSString *phoneNumber;
@property (nonatomic, copy, nonnull) NSString *channelType;
```


## [0.2.56] - 2019-01-24
### Added
- Change log file.

### Changed
- Memory managment improvments.
- Fetch missing and new events on network changes.
- Returning User objects instead of Ids.
- Bug fixes.
- Add nonnull or nullable to properties
- Rename call.decline to call.reject.


## [0.1.52] - 2019-01-21
- Initial beta release with basic call and chat features.

	- Please refer to list of features and usage  
	  https://developer.nexmo.com/

	- **Cocoapods**  
	  https://cocoapods.org/pods/nexmoclient
