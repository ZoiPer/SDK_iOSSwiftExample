# Before you start

## Purpose of this documentation

This guide assists you in rapidly developing your VoIP application with Zoiper SDK 2.0. This manual contains an overview of the entities in the SDK with a lot of practical examples of implementation, usage and configuration.

**By default zdk.objc.framework is not included in the example. If you still don't have the framework, please contact us on zoiper.com. zdk.objc.framework MUST be placed in current folder!
**

## Licensing

To enjoy the powerful benefits of Zoiper SDK 2.0, you need a license. Depending on your needs, you can buy 2 different types of licenses:

- Installation license per end-user
- Unlimited installations;

Please [<span style="color:orange">contact Zoiper</span>](mailto:sales@zoiper.com) for more details and test licenses or to receive licenses for testing purposes.

## Threading model

Zoiper SDK 2.0 is thread-safe. Shared objects can be called simultaneously from multiple threads. All callbacks from the SDK modules to the application code are performed in the context of the application thread which invokes the respective functions and methods.

In order to receive callbacks, the SDK needs to receive processing time from your application core. You can achieve this by invoking the respective functions.

On Android, iOS, and macOS, the main UI thread usually handles the assignment of processing time to the SDK.

Regarding sockets and transports, the SDK manages and utilizes the threads internally. For the interaction with sockets and transports, the SDK also internally manages and utilizes its own separate thread. As a result, the application code can use the processing time without blocking the SDK sockets.

## More resources

Inside the SDK packages, you can find the respective reference and examples of basic usage for all:

- methods
- functions
- APIs
- callbacks
- etc.

## Third-party software

The SDK is (partially) built with:

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

Please contact [<span style="color:orange">sales@zoiper.com</span>](mailto:sales@zoiper.com) for more information.


## Introduction to Zoiper SDK 2.0 for iOS

Developing your VoIP application for iOS with Objective-C™, or Swift becomes easier with the Zoiper Software Development Kit for iOS.
Zoiper SDK 2.0 is namely an all-inclusive solution for developing iOS applications with
- audio calls (SIP, IAX)
- video call (SIP)
- presence
- messaging
- call recordings
- other functionalities

The SDK consists of an iOS Framework with the respective headers that you can easily integrate into your target application.

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
| package/Documentation | Contains the Zoiper SDK 2.0 Documentation. Click on the index.html file to open the documentation in your browser. |
| package/zdk.objc.framework | The actual framework which you need to import in your project. |

## Setting up the Demo project

The demo application for Objective-C — Zoiper SDK Demo — gives you a clear idea on how to implement functionalities of the Zoiper Software Development Kit for iOS. 
After the initialization of the Zoiper SDK 2.0 Demo, you can configure and register an account on a SIP server. Upon success, you can make an
audio call. 
The Demo illustrates how...

- to implement the SDK into a real project
- to connect the development kit with your project 
- the main functionalities are used
- callbacks are handled 
- SDK logging takes place

We assume that you are already familiar with iOS and Objective-C concepts such as: 

- delegates
- Objective-C memory management
- Cocoa’s Storyboard for the UI elements of the demo app 

Since the purpose of the demo is to illustrate the main functionalities of the Zoiper SDK 2.0, the UI is limited. 

### Prerequisites
To compile the Demo project, you must have all of the following:

- an Apple developer account
- a developer-registered iOS device
- XCode
- a SIP server to test with
- a SIP account corresponding to the SIP Server
- a license for the Zoiper SDK 2.0 and the activation details.

### Setting up the project files
1. Download the Zoiper SDK 2.0 Demo
2. Open the xcodeproj file with XCode.
3. Connect a registered iOS device and select it as a building target.
4. Click the Run button to build the sample app for the device.
5. When the application runs enter the Activation details to activate the product.

To be able to run the Zoiper Swift Example, you will need to include the zdk.objc.framework to the project and then to build it. By default zdk.objc.framework is not included in the example. If you still don't have the framework, please contact us on zoiper.com.

zdk.objc.framework MUST be placed in current folder!

### Default configuration
Transport type: TCP
Enabled codecs: 
- aLaw
- uLaw
- GSM
- speex
- iLBC30
- G729
- VP8

STUN: Disabled
Default STUN settings:

- Server: stun.zoiper.com
- Port: 3478
- Refresh period: 30

### Activation

To test the demo, you need activation credentials from Zoiper. You can enter them manually, or hardcode them in your application. 

#####Manual

Enter your username and password in the Activation fields and click on the “Activate” button.

When the activation is fine, the status will change to “Success”. If it is not successful a “Failed” status will be returned, followed by an error code.

#####Hardcoded

To hardcode your credentials, use the following call:
```
let appDelegate = UIApplication.shared.delegate as! AppDelegate appDelegate.contextManager.activateZDK(zdkVersion,
withUserName: activationUsername!.text!,
andPassword: activationPassword!.text!)
```
Do not take your credentials from the GUI, but pass them.

### Account registration

You need a SIP account to register to the server and make calls. To configure it, follow these steps:
1. Enter its details (username, password and hostname at least)
2. Click on the „Register“ button

The status screen will show a registration status. When the registration is successful you should be able to make calls. In the other case, the status screen will show an error code.

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
Possible values:

- .tt_TCP
- .tt_UDP
- .tt_TLS

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
Possible values:

- .dtmfsip_RFC_2833
- .dtmfsip_SIPInfo
- .dtmfsip_inband
- disabled

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

## Create your iOS VoIP App
You need to set up your environment in the same way as for the demo application. Keep in mind that the application must run on a real device. It cannot be used with simulators.

To use Zoiper SDK 2.0 in your iOS project, you need to add it as a required framework to your project and initialize it as a context. Below, you can see how to initialize the context:

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
Keep in mind that inside the initialization of the Context, the SIP and RTP ports will be also initialized. Right after this, you can best activate the Zoiper SDK 2.0 license. Use the activation username and password you received from Zoiper.com. You can complete the activation by invoking the activateZDK method as follows:

activateZDK method like so:
```
contextManager.activateZDK(zdkVersion,
withUserName: activationUsername,
andPassword: activationPassword)
```

## iOS SDK Reference - Swift/Objective C

You can find the API and method references [<span style=color:orange>here</span>](https://www.zoiper.com/documentation/ios-objective-c-sdk/html/annotated.html).