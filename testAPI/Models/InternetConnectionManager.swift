//
//  InternetConnectionManager.swift
//  testAPI
//
//  Created by Артем Макар on 16.12.22.
//

import Foundation
import SystemConfiguration
import UIKit

public class InternetConnectionManager {
    
    
    private init() {
        
    }
//    public static func alerFunc() {
//
//        DispatchQueue.main.async {
//            let alertController = UIAlertController(title: "internet connection problems", message: "check your internet connection and try again", preferredStyle: .alert)
//            let alertAction = UIAlertAction(title: "OK", style: .cancel){ _ in
//                if !InternetConnectionManager.isConnectedToNetwork() {
//                    //alerFunc()
//                }
//            }
//            alertController.addAction(alertAction)
//            print("Alert:", Int.random(in: 0...100000))
//            SettingsController().present(alertController, animated: true, completion: nil)
//           // ViewController().present(alertController, animated: true, completion: nil)
//        }
//    }
    
    public static func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                
                SCNetworkReachabilityCreateWithAddress(nil, $0)
                
            }
            
        }) else {
            
            return false
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
}
