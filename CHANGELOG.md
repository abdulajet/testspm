# NexmoClient mobile SDK for iOS Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [###VERSION###] - 2019-06-02
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
