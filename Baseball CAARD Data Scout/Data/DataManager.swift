//
//  DataManager.swift
//  Baseball CAARD Data Scout
//
//  Created by Benjamin Hilger on 7/26/21.
//

import Foundation
import SystemConfiguration

class DataManager {
    
    private let baseURL = "dev.grandslamanalytics.com:8080/api/v2/"
    
    func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)

        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }

        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        if flags.isEmpty {
            return false
        }

        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)

        return (isReachable && !needsConnection)
    }
    
//    func loginUser(email: String, password: String) {
//        let loginURL = baseURL + "account/login?email=" + email + "&password=" + password
//        let task = URLSession.shared.dataTask(with: loginURL) { (data, response, error) in
//            if let error = error {
//                print("There was an issue processing the data: " + error)
//                return
//            }
//            guard let httpResponse = response as? HTTPURLResponse,
//               (200...299).contains(httpResponse.statusCode) else {
//                print("Error with the response, unexpected status code: \(response)")
//                return
//            }
//            if let data = data,
//                let filmSummary = try? JSONDecoder().decode(FilmSummary.self, from: data) {
//                completionHandler(filmSummary.results ?? [])
//            }
//        }
//        task
//    }
}
