//
//  ContextManager.swift
//  ZDKDemo
//
//  Copyright © 2019 Securax. All rights reserved.
//

import Foundation
import UIKit

let zdkVersion = "ZDK for iOS 2.0"
let documentsDirPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!.path + "/"

enum CodecId: Int {
    case NA
    case g729
    case GSM
    case iLBC20
    case iLBC30
    case h264
    case vp8
    case h264Hardware
    case speex
    case speexWide
    case speexUltra
    case g726
    case opusNarrow
    case opusWide
    case opusSuper
    case opusFull
    case AMR
    case AMRWide
    case uLaw
    case aLaw
    case g722
}

class ContextManager: NSObject {
    
    private var zdkContext: ZDKContext
    private let zdkAccountProvider: ZDKAccountProvider
    private var zdkAccount: ZDKAccount? = nil
    private var zdkCall : ZDKCall? = nil
    
    private let pollInterval: Int32 = 400
    private let reRegistrationTime: Int32 = 600
    private let accountName = "Demo SIP Account"
    
    var context: ZDKContext {
        return zdkContext
    }
    
    override init() {
        zdkContext = HelperFactory.sharedInstance().context
        zdkAccountProvider = HelperFactory.sharedInstance().context.accountProvider
        
        super.init()
        
        zdkContext.setStatusListener(self)
        initContext()
    }
    
    func initContext() {
        zdkContext.configuration.sipUdpPort = Int32.random(in: 32000..<65000)
        repeat {
            zdkContext.configuration.rtpPort = Int32.random(in: 32000..<65000)
        } while (zdkContext.configuration.rtpPort != zdkContext.configuration.sipUdpPort)
        
        zdkContext.audioControls.setAutomaticGainMode(.agct_Hardware, gain: 0.0)
        zdkContext.audioControls.echoCancellation     = .ect_Hardware
        zdkContext.audioControls.noiseSuppression     = true
        zdkContext.configuration.enableIPv6           = true
    }
    
    func activateZDK(_ zdkVersion: String, withUserName username: String, andPassword password: String) {
        let path = documentsDirPath + "private/"
        if !FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                appLogger.logError(.lf_UI, message: error.localizedDescription);
            }
        }
        
        let cacheFile = path + "activationFile"
        let certPem = "-----BEGIN PUBLIC KEY-----\n" +
                      "MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAwX+jHbOCZkZxXBR0V5tq\n" +
                      "uo+tGD0uioUB3yXfWPJGkX3jxuGIj3TdIVOoe39CveojovF8imhOTmlFNZzyzsua\n" +
                      "Wi/mb03+xu2rBO/UznOptOtOblGG77jIywZZ4pSIXY+0A+7GcauyuR46XQNryy+v\n" +
                      "VtRJfuu+pbqrGkldNRhWcr8duhAV4PhezyrwJyz1cfJjXObS4ysENHVkbeilQdM9\n" +
                      "oaofjqM0wD9YyE7ICQJ9c7f+0amZHvQPqljFoQE9uwvf63yyI5rToiNBUI7BK6tZ\n" +
                      "qEn/wZnueOjLSlP8ZBEI8pWDV1DEq6Kk8zE+yNenH21dEf+6T8ZXWTqlYakE9NlT\n" +
                      "SrBTPYoRM8Gji0dFwuw6rfibNqqLc5Tgtuc6MsPzVtTxsh0+Cf13bSEpyXqEyLu5\n" +
                      "m/lMllvvBbz2wLbget6/b5XNym4xC9xOWNcFVNnA0tHMKNAWwqlWgeF++Ydi20YE\n" +
                      "fo6LHnCs9AR/aIWHX7FdqlsGNzK0aQQLgf97ZHuMoZOMw+m4Poy5naUo3PKN+87h\n" +
                      "lSTSz3dGesgv4L66Dnyldlf7zt0krhmN5KJNx9jMtOJI7EAyrJtipXms6x8y+bhB\n" +
                      "8Ao+qIT5OcgFAUFrZ6den9XMBNIYTSCyCYnEtD4vBiO/BrnYwmJ2RTNFRjWE60V0\n" +
                      "xU+U6NFcvqbNpGEF5O6yi90CAwEAAQ==\n" +
                      "-----END PUBLIC KEY-----\n"
        
        let result = zdkContext.activation.startSDK(cacheFile, username: username, password: password)
        
        if result.code != .rc_Ok {
            appLogger.logError(.lf_Softphone, message: "Failed to start activation: \(result.text) (code: \(result.code.rawValue))")
        } else {
            appLogger.logInfo(.lf_Softphone, message: "Activation started.")

        }
    }
    
    @discardableResult @objc
    func startContext() -> ZDKResult {
        let result = context.start()
        if result.code == .rc_Ok {
            appLogger.logInfo(.lf_Softphone, message: "ZDK context is started.")
        } else {
            appLogger.logError(.lf_Softphone, message: "ZDK context failed to start, code: \(result.code.rawValue).")
        }
        
        return result
    }
    
    private func createDefaultSTUNConfiguration() ->ZDKStunConfig {
        let stunConfiguration = zdkAccountProvider.createStunConfiguration()
        stunConfiguration.stunEnabled = false
        
        stunConfiguration.stunServer  = "stun.zoiper.com"
        stunConfiguration.stunPort    = 3478
        stunConfiguration.stunRefresh = 30
        
        return stunConfiguration
    }
    
    private func createDefaultSIPConfiguration() -> ZDKSIPConfig {
        let sipConfiguration = zdkAccountProvider.createSIPConfiguration()
        
        sipConfiguration.transport = .tt_TCP
        
        sipConfiguration.useOutboundProxy = false
        sipConfiguration.outboundProxy    = nil
        sipConfiguration.authUsername     = nil
        
        sipConfiguration.callerID   = accountName
        sipConfiguration.rPort      = .rpt_Signaling
        sipConfiguration.enableSRTP = false
        sipConfiguration.dtmf       = .dtmftsip_RFC_2833
        
        sipConfiguration.stun = createDefaultSTUNConfiguration()
        
        return sipConfiguration
    }
    
    private func createDefaultPushConfiguration() -> ZDKPushConfig {
        let pushConfiguration = zdkAccountProvider.createPushConfiguration()
        
        pushConfiguration.enabled = false // Use of push notification
        pushConfiguration.rtpMediaProxy = false // Use of RTP media proxy
        pushConfiguration.transport = .tt_TCP // "iOS App - Push proxy" communication protocol
        pushConfiguration.cid = Bundle.main.bundleIdentifier! // App's bundle identifier!
        pushConfiguration.uri = "https://gateway.push.apple.com:2195" // For sandbox use https://gateway.sandbox.push.apple.com:2195
        pushConfiguration.type = "apple" // Example type
        pushConfiguration.proxy = "www.push_proxy.com" // Example push proxy server
        pushConfiguration.token = "a6954b367dc0d28308a92dff76b7041abf9193e834bafd50cee0222068cb632b" // Example push token. Take it from the app!
                        
        return pushConfiguration
    }
    
    static var changeTest: Bool = false
    private func createSIPHeaderFieldsConfiguration() -> [ZDKHeaderField] {
        var headers: [ZDKHeaderField] = [ZDKHeaderField]()
        
        var header1Values: [String] = [String]()
        header1Values.append("header_1_value_1")
        headers.append(zdkAccountProvider.createSIPHeaderField("test_header_1", values: header1Values, method: .smt_All))
        
        var header2Values: [String] = [String]()
        header2Values.append("header_2_value_1")
        header2Values.append("header_2_value_2")
        headers.append(zdkAccountProvider.createSIPHeaderField("test_header_2", values: header2Values, method: .smt_Register))
        
        var header3Values: [String] = [String]()
        header3Values.append("header_3_value_1")
        header3Values.append("header_3_value_2")
        header3Values.append("header_3_value_3")
        headers.append(zdkAccountProvider.createSIPHeaderField("test_header_3", values: header3Values, method: .smt_Invite))
        
        var header4Values: [String] = [String]()
        header4Values.append("header_4_value_1")
        header4Values.append("header_4_value_2")
        header4Values.append("header_4_value_3")
        if ContextManager.changeTest {
            header4Values.append("header_4_value_4")
        } else {
            header4Values.append("header_4_value_5")
        }
        ContextManager.changeTest = !ContextManager.changeTest
        headers.append(zdkAccountProvider.createSIPHeaderField("test_header_4", values: header4Values, method: .smt_All))
        
        return headers
    }
    
    @discardableResult
    private func createAccountWithDomain(_ domain: String, username: String, andPassword password: String) -> ZDKAccount? {
        zdkAccount = zdkAccountProvider.createUserAccount()
        guard zdkAccount != nil else {
            appLogger.logError(.lf_Softphone, message: "Failed to create ZDK account." )
            return nil
        }
        
        zdkAccount!.accountName = accountName
        
        let accountConfiguration = zdkAccount!.configuration
        accountConfiguration.userName = username
        accountConfiguration.password = password
        accountConfiguration.type = .pt_SIP
        
        accountConfiguration.reregistrationTime = reRegistrationTime
        
        accountConfiguration.sip = createDefaultSIPConfiguration()
        guard accountConfiguration.sip != nil else {
            appLogger.logError(.lf_Softphone, message: "Failed to create SIP configuration.")
            zdkAccount = nil
            return nil
        }
        accountConfiguration.sip!.domain = domain
        
        accountConfiguration.sip?.push = createDefaultPushConfiguration()
        
        accountConfiguration.sip?.additionalHeaders = createSIPHeaderFieldsConfiguration()
        
        zdkAccount!.configuration = accountConfiguration
        zdkAccount!.mediaCodecs = [CodecId.uLaw.rawValue as NSNumber,
                                   CodecId.aLaw.rawValue as NSNumber,
                                   CodecId.GSM.rawValue as NSNumber,
                                   CodecId.speex.rawValue as NSNumber,
                                   CodecId.iLBC30.rawValue as NSNumber,
                                   CodecId.g729.rawValue as NSNumber,
                                   CodecId.vp8.rawValue as NSNumber]
        
        return zdkAccount
    }
    
    func registerAccountWithDomain(_ domain: String, username: String, andPassword password: String) {
        var result : ZDKResult
        
        guard context.contextRunning else {
            appLogger.logError(.lf_Softphone, message: "Cannot register account- ZDK context is not started.")
            return
        }
        
        if zdkAccount == nil {
            createAccountWithDomain(domain, username: username, andPassword: password)
            
            guard zdkAccount != nil else {
                appLogger.logError(.lf_Softphone, message: "Cannot register account- ZDK Account is nil!")
                return
            }
            zdkAccount!.removeUser()
            result = zdkAccount!.createUser()
            if result.code != .rc_Ok {
                appLogger.logError(.lf_Softphone, message: "Failed to create ZDK account- \(result.text), code: \(result.code.rawValue).")
                return;
            }
            
            zdkAccount!.setStatusEventListener(self)
        }
        
        context.accountProvider.setAsDefaultAccount(zdkAccount!)
        
        if zdkAccount!.registrationStatus == .as_Registered {
            result = zdkAccount!.unRegister()
            if result.code != .rc_Ok {
                appLogger.logError(.lf_Softphone, message: "Failed to unregsiter ZDK account- \(result.text), code: \(result.code.rawValue).")
                return;
            }
            appLogger.logInfo(.lf_Softphone, message: "Unregistering ZDK account...")
        } else {
            // Update account data
            let config = zdkAccount!.configuration
            config.sip!.domain = domain
            config.userName    = username
            config.password    = password
            zdkAccount!.configuration = config
            
            result = zdkAccount!.register()
            if result.code != .rc_Ok {
                appLogger.logError(.lf_Softphone, message: "Failed to register ZDK account- \(result.text), code: \(result.code.rawValue).")
                return;
            }
            appLogger.logInfo(.lf_Softphone, message: "Registering ZDK account...")
        }
    }
    
    func isInCall() -> Bool {
        return zdkCall != nil
    }
    
    func hangupCall() {
        guard zdkCall != nil else {
            appLogger.logWarning(.lf_Softphone, message: "Cannot hang-up non-existing call!")
            return
        }
        
        let result = zdkCall?.hangUp()
        if result!.code != .rc_Ok {
            appLogger.logError(.lf_Softphone, message: "Hang-up call, something went wrong- \(result!.description), code: \(result!.code.rawValue)")
        } else {
            appLogger.logInfo(.lf_Softphone, message: "Call hung up successfully.")
        }
        
        zdkCall?.dropStatusListener(self)
        zdkCall = nil
    }
    
    func makeCallTo(callee:String) {
        guard context.contextRunning else {
            appLogger.logError(.lf_Softphone, message: "Cannot make a call- ZDK context is not started.")
            return
        }
        
        guard zdkAccount != nil else {
            appLogger.logWarning(.lf_Softphone, message: "Cannot make a call- please create an account.")
            return
        }
        
        guard context.callsProvider.activeCall == nil else {
            appLogger.logWarning(.lf_Softphone, message: "There is already an active call.")
            return
        }

        appLogger.logInfo(.lf_Softphone, message: "Dialling \(callee)...")
        
        zdkCall = zdkAccount?.createCall(callee, handlingVoipPhoneCallEvents: true, video: false)
        guard zdkCall != nil else {
            appLogger.logError(.lf_Softphone, message: "Something went wrong, failed to create a call!")
            return
        }
        zdkCall?.setCallStatusListener(self)
    }
}

// MARK: - Context events handler

extension ContextManager: ZDKContextEventsHandler {
    func eventHandle() -> Int {
        return 0
    }
    
    func handlesDescription() -> String {
        return String()
    }
    
    func onContext(_ context: ZDKContext, secureCerterror secureCert: ZDKSecureCertData) {
        
    }
    
    func onContext(_ context: ZDKContext, activationCompleted activationResult: ZDKActivationResult) {
        var strStatus: String
        
        switch activationResult.status {
        case .as_Failed:
            strStatus = "Failed"
        case .as_Success:
            strStatus = "Success"
        default:
            strStatus = "Failed, code: " + String(describing: activationResult.status.rawValue)
        }
        
        appLogger.logInfo(.lf_Softphone, message: "Activation completed- \"\(activationResult.reason), \(strStatus)\"")
        
        var strActivateionResult : String = ""
        var color : UIColor = UIColor.red
        
        if activationResult.status == .as_Success {
            self.performSelector(onMainThread: #selector(startContext), with: nil, waitUntilDone: false)
            
            strActivateionResult = "Activated"
            color = UIColor.green
            accountViewController?.performSelector(onMainThread: #selector(accountViewController?.changeActivationStatusLabelTitleTo), with: strActivateionResult, waitUntilDone: false)
            accountViewController?.performSelector(onMainThread: #selector(accountViewController?.changeActivationStatusLabelColorTo), with: color, waitUntilDone: false)

        } else {
            accountViewController?.performSelector(onMainThread: #selector(accountViewController?.changeActivationStatusLabelTitleTo), with: strActivateionResult, waitUntilDone: false)
            accountViewController?.activationStatusLabel.text = String(describing: activationResult.status)
        }
    
    }
}

// MARK: - Account events handler

extension ContextManager: ZDKAccountEventsHandler {
    func onAccount(_ account: ZDKAccount, status: ZDKAccountStatus, changed statusCode: Int32) {
        var registrationStatus : String = "Not Registered"
        var registrationColor : UIColor = UIColor.red
        
        if statusCode != 0 {
            appLogger.logError(.lf_Softphone, message: "Account '\(String(describing: account.accountName!))' status change to \(status.rawValue) failed, code: \(statusCode).")
            registrationStatus = "Error \(statusCode)"
        } else {
            appLogger.logInfo(.lf_Softphone, message: "Successfully changed account '\(String(describing: account.accountName!))' status to \(status.rawValue).")
            registrationStatus = "Registered"
            registrationColor = UIColor.green
        }
        
        let title : String
        if status == .as_Registered {
            title = "Unregister"
        } else {
            title = "Register"
        }
        
        accountViewController?.performSelector(onMainThread: #selector(accountViewController?.changeRegisterButtonTitleTo), with: title, waitUntilDone: false)
        accountViewController?.performSelector(onMainThread: #selector(accountViewController?.changeRegistrationStatusLabelTitleTo), with: registrationStatus, waitUntilDone: false)
        accountViewController?.performSelector(onMainThread: #selector(accountViewController?.changeRegistrationStatusLabelColorTo), with: registrationColor, waitUntilDone: false)

    }
    
    func onAccount(_ account: ZDKAccount, extendedError message: ZDKExtendedError) {
        appLogger.logError(.lf_Softphone, message: "'\(String(describing: account.accountName!))' extended error: \(message.message), q931 Code: \(message.q931Code).")
    }
}

// MARK: - Call events handler

extension ContextManager: ZDKCallEventsHandler {
    func onCall(_ call: ZDKCall, statuschanged status: ZDKCallStatus) {
        DispatchQueue.main.async {
            appLogger.logInfo(.lf_Softphone, message: "Call status changed: \(status.description), code: \(status.lineStatus.rawValue)")
            
            if status.origin == .ot_Remote && status.lineStatus == .cls_Active {
                appLogger.logInfo(.lf_Softphone, message: "The call is answered")
            }
            
            if status.lineStatus == .cls_Terminated {
                    callViewController?.changeDialButtonTitleTo("Dial")
            } else {
                callViewController?.changeDialButtonTitleTo("Hangup")
            }
        }
    }
    
    func onCall(_ call: ZDKCall, extendedError error: ZDKExtendedError) {
        appLogger.logError(.lf_Softphone, message: "Call to '\(String(describing: call.calleeNumber))' extended error: \(error.message), q931 Code: \(error.q931Code).")
    }
}
