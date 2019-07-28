# NexmoClient mobile SDK for iOS Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 1.0.0 - 2019-07-15
### Fixed
- NexmoClient when disconnected returns error callback for all function.
- NXMConversationEventsController returns the last event.
- CallMember status calculated by the current leg status.

### Added
Added the member state initiator.
```
NXMMember *member = someMember;
NSDictionary<NSValue *, NXMInitiator *> *initiators = member.initiators; 

NXMInitiator leftStateInitiator = initiators[NXMMemberStateLeft];
leftStateInitiator.isSystem; 
leftStateInitiator.userId; 
leftStateInitiator.memberId;
leftStateInitiator.time;
```

Added NXMConversationUpdatesDelegate to notify on member updates like media,leg,state.
Added updatesDelegate property to NXMConversation.
```
@property (nonatomic, weak, nullable) id <NXMConversationUpdatesDelegate> updatesDelegate;
```
Example
```
@interface MyClass() <NXMConversationUpdatesDelegate>
@implementation MyClass

- (void)setConversation:(NXMConversation *conversation) {
	conversation.updatesDelegate(self); // register to conversation updatesDelegate
}

- (void)memberUpdated:(nonnull NXMMember *)member forUpdateType:(NXMMemberUpdateType)type {
	if (type == NXMMemberUpdateTypeState) {
		// the member state changed
	}

	if (type == NXMMemberUpdateTypeMedia) {
		// the member media changed
	}
}
@end
```

### Changed

NXMConversation otherMembers property renamed to allMembers.
```
NXMConversation myConversation = someConversation;
NSArray<NXMMember *> * allMembers = myConversation.allMembers // return the all conversation members
```

Use username instead of userId
Renamed
NXMCall
```
- (void)addCallMemberWithUsername:(nonnull NSString *)username completionHandler:(NXMErrorCallback _Nullable)completionHandler;
- (void)rejectWithCompletionHandler:(NXMErrorCallback _Nullable)completionHandler;
```
Removed callId property:
```
@property (nonatomic, copy, nonnull) NSString *callId;
```
Removed on NXMCallMemberStatus the statuses:
```
NXMCallMemberStatusDialling
NXMCallMemberStatusCancelled
```

NXMConversation Renamed:
```
- (void)joinMemberWithUsername:(nonnull NSString *)username
```

NexmoClient logger exposed - NXMLogger object
```
[NXMLogger setLogLevel:NXMLoggerLevelDebug];
NSArray *logNames = [NXMLogger getLogFileNames];
```
Removed NXMLoggerDelegate
```
NXMClient myClient
[myClient setLoggerDelegate:LoggerDelegate];
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
