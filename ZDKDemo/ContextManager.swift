//
//  ContextManager.swift
//  ZDKDemo
//
//  Copyright © 2019 Securax. All rights reserved.
//

import Foundation

let zdkVersion = "ZDK for iOS 2.0"
let documentsDirPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!.path + "/"

enum CodecId: Int {
    case NA = -1
    case uLaw = 0
    case GSM = 1
    case aLaw = 6
    case g722 = 7
    case g729 = 16
    case speex = 24
    case speexWide = 25
    case speexUltra = 26
    case iLBC30 = 27
    case g726 = 29
    case h263Plus = 30
    case vp8 = 31
    case opusNarrow = 34
    case opusWide = 35
    case opusSuper = 36
    case opusFull = 37
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
        zdkContext.configuration.sipPort = Int32.random(in: 32000..<65000)
        repeat {
            zdkContext.configuration.rtpPort = Int32.random(in: 32000..<65000)
        } while (zdkContext.configuration.rtpPort != zdkContext.configuration.sipPort)
        
        zdkContext.audioControls.echoCancellation     = .ect_Hardware
        zdkContext.audioControls.automaticGainControl = .agct_Hardware
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
        
        let result =  zdkContext.activation.start(cacheFile,
                                                  moduleName: nil,
                                                  // 0x10 - E_ACTIVATION_FLAG_USE_V4_CERTIFICATE
                                                  // 0x2  - E_ACTIVATION_FLAG_SKIP_CHECKSUM_VERIFICATION
                                                  opFlags: 0x10 + 0x2,
                                                  username: username,
                                                  password: password,
                                                  version: zdkVersion,
                                                  certPem: certPem)
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
        
        sipConfiguration.enablePushNotifications = false
        sipConfiguration.pushTransport           = .tt_TCP
        
        sipConfiguration.stun = createDefaultSTUNConfiguration()
        
        return sipConfiguration
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
        
        if activationResult.status == .as_Success {
            self.performSelector(onMainThread: #selector(startContext), with: nil, waitUntilDone: false)
        }
    }
}

// MARK: - Account events handler

extension ContextManager: ZDKAccountEventsHandler {
    func onAccount(_ account: ZDKAccount, status: ZDKAccountStatus, changed statusCode: Int32) {
        if statusCode != 0 {
            appLogger.logError(.lf_Softphone, message: "Account '\(String(describing: account.accountName!))' status change to \(status.rawValue) failed, code: \(statusCode).")
        } else {
            appLogger.logInfo(.lf_Softphone, message: "Successfully changed account '\(String(describing: account.accountName!))' status to \(status.rawValue).")
        }
        
        let title : String
        if status == .as_Registered {
            title = "Unregister"
        } else {
            title = "Register"
        }
        
        accountViewController?.performSelector(onMainThread: #selector(accountViewController?.changeRegisterButtonTitleTo), with: title, waitUntilDone: false)
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