# Introduction

## Generic Information

**By default zdk.objc.framework is not included in the example. If you still don't have the framework, please contact us on zoiper.com. zdk.objc.framework MUST be placed in current folder!
**


This guide is here to assist software developers to create a VoIP application with the use of Zoiper SDK 2.0. With this guide you will get an overview of the entities in the SDK and some examples of their implementation, usage and configurataion.

You will find sections for each of the following:

- Windows Microsoft .Net Framework
- Windows Java
- Linux Java
- Android Java
- iOS Objective C/Swift

## Licensing

Zoiper SDK 2.0 requires a license which can be purchased from Zoiper. There are two possibilities:

- Licensed per end-user installation model;
- Unlimited instalations;

Contact Zoiper for more details and test licenses.

## Common stuff for Zoiper SDK 2.0

### Threading model

Zoiper SDK 2.0 is thread-safe — shared objects can be called simultaneously from multiple threads. All callbacks from the SDK modules to the application code are performed in the context of the application thread which invokes the respective functions and methods. Processing time must be given to the SDK from the application core by invoking the respective functions in order to receive callbacks. In most cases on Android, iOS, and macOS, the main UI thread handles the giving of processing time to the SDK.

Regarding the sockets and transports, the SDK manages and utilizes the threads internally.

The SDK internally manages and utilizes its own separate thread for interaction with sockets/transports. Like that the application code can utilize the processing time without blocking the SDK sockets.

### Additional resources

Additionally to that document, inside the SDK packages you can find the respective reference for all the methods, functions, APIs, callbacks and so on. The basic usage of each one of these is also illustrated in it. 

## Third-party software

Portions copyrights:

- JThread, Copyright (C) 2000-2005 Jori Liesenborgs (jori@lumumba.uhasselt.be)
- JRTPLIB, part of JRTPLIB Copyright (C) 1999-2005 Jori Liesenborgs
- GSM, Copyright 1992, 1993, 1994 by Jutta Degener and Carsten Bormann, Technische Universitaet Berlin
- iLBC, iLBC Speech Coder ANSI-C Source Code iLBC_define.h Copyright (C) The Internet Society (2004). All Rights Reserved.
- SPEEX The Xiph OSC and the Speex Parrot logos are trademarks (TM) of Xiph.Org.
- OpenLDAP, Copyright 1999-2003 The OpenLDAP Foundation, Redwood City, California, USA. All Rights Reserved.
- PortAudio, Copyright (C) 1999-2002 Ross Bencina and Phil Burk
- PortMixer, PortMixer, Windows WMME Implementation, Copyright (C) 2002, Written by Dominic Mazzoni and Augustus Saunders
- Resiprocate, The Vovida license The Vovida Software License, Version 1.0, Copyright (C) 2000 Vovida Networks, Inc. All rights reserved.
- This product includes cryptographic software written by Eric Young (eay@cryptsoft.com).
- This product includes software written by Tim Hudson (tjh@cryptsoft.com).
- This product is using the gloox XMPP library - Copyright by Jakob Schroeter.

For any concerns and for more information please contact sales@zoiper.com.

# iOS

## Introduction to Zoiper SDK 2.0 for iOS
This section is intended for developers who are designing a VoIP application using Objective-C™, or Swift and provides information for setting up the Zoiper Software Development Kit for iOS.

Zoiper SDK 2.0 is an all-inclusive solution for developing applications with audio calls (SIP, IAX), video calls (SIP), presence, messaging, call recordings and other functionality. The SDK consists of an iOS Framework with the respective headers that can be easily integrated into a target application.
### Hardware and software requirements
| Requirement | Description |
|--------|--------|
|Processor|Intel Core i3 or better|
|Memory|4GB (minimum), 8 GB (recommended)|
|Hard disk space|1 GB|
|Xcode®|Xcode 9 or later|
|Operating system (Development environment)|macOS 10.13 or later|
|Operating system (Runtime environment)|iOS 8 or later|
|Architecture|armv7, armv7s, arm64|
|Mode|Live device|
### Contents of the SDK package
| Folder | Description |
|--------|--------|
|package\Documentation|Contains the Zoiper SDK 2.0 Documentation. There is an HTML folder, which holds the HTML reference documentation. Open the index.html file to open the reference documentation at the main page.|
|package\zdk.objc.framework|The actual framework, which has to be imported in the project. |

## Setting up the Demo project
The sample application for Objective-C — Zoiper SDK Demo — is a demonstration of how to implement some of the Zoiper Software Development Kit for iOS functionality. Zoiper SDK 2.0 Demo initializes and lets the user to configure and register an account on a SIP server, and to make an audio call. The Demo illustrates how the SDK is implemented into real project, shows the connection of the development kit with the project, and demonstrates how some of the functionality is used. In addition, the demonstrational application presents how the callbacks are handled and gives an idea of the SDK logging.

It is assumed that you have familiarity with iOS and Objective-C concepts such as delegates, Objective-C memory management, and Cocoa’s Storyboard for the UI elements of the sample app. Keep in mind that the UI is very basic and limited. It intends to demonstrate the main functionality of Zoiper SDK 2.0.
### Prerequisites
To compile the Demo project, you must have all the following:
    • an Apple developer account
    • a developer-registered iOS device
    • XCode
    • a SIP server to test with
    • a SIP account corresponding to the SIP Server
    • a license for the Zoiper SDK 2.0 and the activation details.
### Setting up the project files
1. Once Zoiper SDK 2.0 Demo is downloaded, open the xcodeproj file with XCode.
2. Apply the needed changes for the signing and if required update the Info.plist keys and values.
3. Connect a registered iOS device and select it as a building target.
4. Click the Run button to build the sample app for the device.
5. When the application runs enter the Activation details to activate the product.

To be able to run the Zoiper Swift Example, you will need to include the zdk.objc.framework to the project and then to build it. 
By default zdk.objc.framework is not included in the example. 
If you still don't have the framework, please contact us on zoiper.com.

zdk.objc.framework MUST be placed in current folder!


### Default configuration
Transport type: TCP
Enabled codecs: aLaw, uLaw, GSM, speex, iLBC30, G729, VP8
STUN: Disabled
Default STUN settings:
Server: stun.zoiper.com
Port: 3478
Refresh period: 30
### Activation
To be able to test the example, an SDK Activation is required. You may use the activation username and password received from Zoiper. Just enter them in the Activation fields and hit the **“Activate”** button.

In case the activation is fine, the activation status will change to **“Success”**. If it is not successful **“Failed”** status will be returned, followed by the cause code.

The credentials can be hardcoded as well, so there will be no need to be entered manually. To do so, use the following call:
```
let appDelegate = UIApplication.shared.delegate as! AppDelegate appDelegate.contextManager.activateZDK(zdkVersion, 
withUserName: activationUsername!.text!, 
andPassword: activationPassword!.text!)
```
You would only need to pass your credentials instead of taking them from the GUI.
### Account registration
You will need to have a SIP account in order to register to the server and make calls. To configure it, enter its details – username, password and hostname at least, and then hit the **„Register“** button. 

The status screen will show the registration status. When the registration is successful you should be able to make calls. If not, then the status screen will show the error code for the reason.
### Changing the project configuration
To change the SIP configuration, you will need to adjust the calls in:
```
private func createDefaultSIPConfiguration() -> ZDKSIPConfig
```
You can adjust the configuration by using the following method calls.
#### Transport type
```
sipConfiguration.transport = .tt_TCP
```
Possible values: .tt_TCP, .tt_UDP, .tt_TLS
#### Outbound proxy
```
sipConfiguration.useOutboundProxy = false 
sipConfiguration.outboundProxy = nil 
sipConfiguration.authUsername = nil
```
#### STUN
```
sipConfiguration.stun = createDefaultSTUNConfiguration()
```
#### Rport
```
sipConfiguration.rPort = .rpt_Signaling
```
#### DTMF
```
sipConfiguration.dtmf = .dtmftsip_RFC_2833
```
Possible values: .dtmfsip_RFC_2833, .dtmfsip_SIPInfo, .dtmfsip_inband, disabled
#### Push notifications
```
sipConfiguration.enablePushNotifications = false sipConfiguration.pushTransport = .tt_TCP
```
#### Changing the used codecs
```
zdkAccount!.mediaCodecs = [CodecId.uLaw.rawValue as NSNumber,
CodecId.aLaw.rawValue as NSNumber, 
CodecId.GSM.rawValue as NSNumber, 
CodecId.speex.rawValue as NSNumber, 
CodecId.iLBC30.rawValue as NSNumber, 
CodecId.g729.rawValue as NSNumber, 
CodecId.vp8.rawValue as NSNumber]
```
Possible values and Codec Ids:

| ID | Codec |
|--------|--------|
|0|uLaw|
|1|GSM|
|6|aLaw|
|7|g722|
|16|g729|
|24|speex|
|25|speexWide|
|26|speexUltra|
|27|iLBC30|
|29|g726|
|31|vp8|
|34|opusNarrow|
|35|opusWide|
|36|opusSuper|
|37|opusFull|

## Create your App
You will need to setup your environment the same way as for the test of the example application. Keep in mind that the application must run on a real device and cannot be used with simulators.

To use Zoiper SDK 2.0 in your project, you will need to add it as a required framework to your project and to initialize as a context. A sample of initializing the context is shown here:
```
override init() { 
zdkContext = HelperFactory.sharedInstance().context zdkAccountProvider = HelperFactory.sharedInstance().context.accountProvider 
super.init() 
zdkContext.setStatusListener(self) 
initContext() 
}

func initContext() { 
zdkContext.configuration.sipPort = Int32.random(in: 32000..<65000) 
repeat { 
zdkContext.configuration.rtpPort = Int32.random(in: 32000..<65000) 
} while (zdkContext.configuration.rtpPort != zdkContext.configuration.sipPort) zdkContext.audioControls.echoCancellation = .ect_Hardware zdkContext.audioControls.automaticGainControl = .agct_Hardware zdkContext.configuration.enableIPv6 = true 
}
```
Keep in mind that inside the initialization of the Context, the SIP and RTP ports will be also initialized.
Right after the Zoiper SDK 2.0 is initialized, it is best to activate its license by using the activation username and password, provided to you by [Zoiper.com](https://www.zoiper.com/). The activation can be done by invoking the activateZDK method like so:
```
contextManager.activateZDK(zdkVersion, 
withUserName: activationUsername, 
andPassword: activationPassword)
```

## [iOS SDK Reference - Swift/Objective C](https://www.zoiper.com/documentation/ios-objective-c-sdk/html/annotated.html)

The API and method references can be found [here](https://www.zoiper.com/documentation/ios-objective-c-sdk/html/annotated.html).