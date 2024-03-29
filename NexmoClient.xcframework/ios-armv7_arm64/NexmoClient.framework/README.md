# NexmoClient SDK iOS

[![ci][ci-svg]][ci-link] ![Xcode][xcode-svg] ![Support][support-svg] [![Podspec][podspec-svg]][podspec-link] ![Platforms][platforms-svg] [![License][license-svg]][license-link]

This repository contains code which is used by Nexmo Client native team.
NexmoClient serves as your gateway for integrating communications in your app.
With a set of features including IP-IP calls, IP-PSTN/PSTN-IP calls, chat messages and more, you can easily address your communications needs.

## Documentation

- [Contributing](#contributing)
- [Release flow](https://confluence.vonage.com/display/CAPI/iOS+SDK+Release+Flow)
- [Xcode(s) choice and setup guide](./XcodeChoiceAndSetup.md)
- [Release notes](https://developer.nexmo.com/client-sdk/sdk-documentation/ios/release-notes)
- [Nexmo mobile developer guide](https://developer.nexmo.com/client-sdk/setup/add-sdk-to-your-app/ios)
- [Code documentation](./CodeDocumentation.md)
- [License](#License)

## Contributing

Please read our [contributing guidelines](https://github.com/nexmoinc/nexmoclient-sdk-ios/blob/master/CONTRIBUTE.md) prior to submitting a Pull Request.

## Setup

Clone the repository, update `.gitmodules` branches, run

```bash
./Utils/local_update_git_submodules.sh
```

then open project file **NXMiOSSDK.xcodeproj**.

Choose **NexmoClient** target and press build.

- [Structure](#structure)
- [Dependencies](#Dependencies)
- [Architecture](#Architecture)

### Structure

Here is a description of the main files and folders in the root of out repository:

- **NXMiOSSDK.xcodeproj** - is the main project which contains all of our targets.
- **NexmoClient** - framework target which contains all of Nexmo client SDK source code.
- **NexmoClient/info.plist** -  build settings (like version number) which used for NexmoClient SDK.
- **NexmoClientTests** - test target that contains all of nexmo client SDK unit tests.
- **NexmoSwiftApp** - application target in Swift which used for internal testing for the SDK.
- **Makefile** - NexmoClient target makefile.
- **Utils** - scripts and tools used by our build process.
- **Frameworks** - NexmoClient dependencies.
- **Output** - NexmoClient target output.

### Dependencies

NexmoClient uses a number of projects to work properly:

- [MiniRTC](https://github.com/nexmoinc/nexmoclient-mini-rtc) - Nexmo WebRTC wrapper
- [NexmoClientInfrastructures](https://github.com/nexmoinc/nexmoclient-infrastructures) - NexmoClient and MiniRTC infrastructure framework, currently we use this framework for logging.

### Architecture

<p align="center">
    <img src="https://github.com/nexmoinc/nexmoclient-sdk-ios/blob/master/Utils/SDKDiagram.png" title="Class diagram">
</p>

### SDK High level class diagram

<p align="center">
    <img src="https://github.com/nexmoinc/nexmoclient-sdk-ios/blob/master/Utils/SDKClassDiagram.png" title="Class diagram">
</p>

## License

Copyright © 2021 Vonage. All rights reserved. Licensed only under the Nexmo SDK License Agreement (the "License") located at [License file](license-link).

[podspec-svg]: https://img.shields.io/cocoapods/v/NexmoClient.svg
[podspec-link]: https://cocoapods.org/pods/NexmoClient
[platforms-svg]: https://img.shields.io/cocoapods/p/NexmoClient
[license-svg]: https://img.shields.io/cocoapods/l/NexmoClient
[license-link]: https://github.com/nexmoinc/nexmoclient-sdk-ios/blob/master/LICENSE
[xcode-svg]: https://img.shields.io/badge/xcode-10.3%20%7C%2011-orange
[ci-svg]: https://github.com/nexmoinc/nexmoclient-sdk-ios/actions/workflows/ci.yml/badge.svg
[ci-link]: https://github.com/nexmoinc/nexmoclient-sdk-ios/actions/workflows/ci.yml
[support-svg]: https://img.shields.io/badge/support-Swift%20%7C%20ObjC-blue
