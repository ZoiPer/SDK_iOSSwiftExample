//
//  AppLogger.swift
//  ZDKDemo
//
//  Copyright © 2019 petyo. All rights reserved.
//

import Foundation
import UIKit

private struct FacilityKeys {
    static let Unknown       = "iOS:Unknown"
    static let Library       = "iOS:Library"
    static let ZDK           = "iOS:ZDK"
    static let UI            = "iOS:UI"
    static let Network       = "iOS:Network"
    static let Provisioning  = "iOS:Provisioning"
    static let Softphone     = "iOS:Softphone"
    static let Audio         = "iOS:Audio"
    static let Configuration = "iOS:Configuration"
    static let Contacts      = "iOS:Contacts"
    static let Utility       = "iOS:Utility"
    static let Persistence   = "iOS:Persistence"
}

extension ZDKLoggingFacility {
    public var description: String {
        get {
            switch self {
            case .lf_Library:
                return FacilityKeys.Library
            case .lf_ZDK:
                return FacilityKeys.ZDK
            case .lf_UI:
                return FacilityKeys.UI
            case .lf_Network:
                return FacilityKeys.Network
            case .lf_Provisioning:
                return FacilityKeys.Provisioning
            case .lf_Softphone:
                return FacilityKeys.Softphone
            case .lf_Audio:
                return FacilityKeys.Audio
            case .lf_Configuration:
                return FacilityKeys.Configuration
            case .lf_Contacts:
                return FacilityKeys.Contacts
            case .lf_Utility:
                return FacilityKeys.Utility
            case .lf_Persistence:
                return FacilityKeys.Persistence
            default:
                return FacilityKeys.Unknown
            }
        }
    }
}

class AppLogger: NSObject {
    private let logger: ZDKLog = HelperFactory.sharedInstance().log
    private var fileIsOpen = false
    private var maxLevel: ZDKLoggingLevel = .ll_Debug
    
    var outputToConsole: Bool = true
    
    private func serviceInfo() -> String {
        
        let versionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        let iosVersion = UIDevice.current.systemVersion
        var utsStruct = utsname()
        let deviceVersion = uname(&utsStruct) == 0 ? String(cString: &utsStruct.machine.0, encoding: String.Encoding.utf8)!
                                                   : "Unknown"
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        var info = "\n\nZDKDemo \(versionNumber).\(buildNumber) for iOS\n"
        info.append("Library revision: \(appDelegate.contextManager.context.libraryVersion), iOS version: \(iosVersion), Device: \(deviceVersion)\n\n")
        
        return info
    }
    
    @discardableResult
    func startLog(_ path: String = documentsDirPath, maxLevel: ZDKLoggingLevel = .ll_Debug) -> Int {
        let path = path + "ZDKDemo-log.txt"
        
        let result = logger.logOpen(path,
                                    oldFileName: nil,
                                    maxLevel: maxLevel,
                                    maxSizeBytes: 0)
        
        if result.code == .rc_Ok {
            self.maxLevel = maxLevel
            fileIsOpen = true
            logDebug(.lf_UI, message: serviceInfo())
        } else {
            print("Failed to start debug log, code: \(result.code.rawValue)")
        }
        
        return Int(result.code.rawValue)
    }
    
    func log(level: ZDKLoggingLevel, facility: ZDKLoggingFacility, message: String, sourceFileName: String = #file, sourceLine: Int = #line) {
        guard level.rawValue <= maxLevel.rawValue else {
            return
        }
        
        if fileIsOpen {
            logger.logMessage(level,
                              facility: facility,
                              facilityName: facility.description,
                              sourceFileName: sourceFileName,
                              sourceLine: Int32(sourceLine),
                              message: message)
        }
        
        if outputToConsole && logger.shouldLogFacility(facility) {
            print("\n\(facility): \(message)")
        }
    }
}

extension AppLogger {
    func logDebug(_ facility: ZDKLoggingFacility, message: String, sourceFileName: String = #file, sourceLine: Int = #line) {
        log(level: .ll_Debug,
            facility: facility,
            message: message,
            sourceFileName: sourceFileName,
            sourceLine: sourceLine)
    }

    func logWarning(_ facility: ZDKLoggingFacility, message: String, sourceFileName: String = #file, sourceLine: Int = #line) {
        log(level: .ll_Warning,
            facility: facility,
            message: message,
            sourceFileName: sourceFileName,
            sourceLine: sourceLine)
    }

    func logError(_ facility: ZDKLoggingFacility, message: String, sourceFileName: String = #file, sourceLine: Int = #line) {
        log(level: .ll_Error,
            facility: facility,
            message: message,
            sourceFileName: sourceFileName,
            sourceLine: sourceLine)
    }
    
    func logInfo(_ facility: ZDKLoggingFacility, message: String, sourceFileName: String = #file, sourceLine: Int = #line) {
        log(level: .ll_Info,
            facility: facility,
            message: message,
            sourceFileName: sourceFileName,
            sourceLine: sourceLine)
    }
}
