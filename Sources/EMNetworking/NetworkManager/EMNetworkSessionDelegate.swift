//
//  EMNetworkSessionDelegate.swift
//
//
//  Created by Mickael Belhassen on 01/08/2024.
//

import Foundation

final class EMNetworkSessionDelegate: NSObject, URLSessionDelegate, Sendable {
    private let certificatePinning: CertificatePinning?
    
    init(certificatePinning: CertificatePinning?) {
        self.certificatePinning = certificatePinning
        super.init()
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
    
        guard let certificatePinning = certificatePinning,
              let serverTrust = challenge.protectionSpace.serverTrust,
              challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        
        let host = challenge.protectionSpace.host
        
        if certificatePinning.validate(serverTrust: serverTrust, for: host) {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
    
}
