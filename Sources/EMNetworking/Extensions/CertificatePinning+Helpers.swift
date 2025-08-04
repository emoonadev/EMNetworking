//
//  CertificatePinning+Helpers.swift
//
//
//  Created by Mickael Belhassen on 01/08/2024.
//

import Foundation

public extension DefaultCertificatePinning {
    
    static func certificatePinning(withCertificateNames certificateNames: [String], in bundle: Bundle = .main) -> DefaultCertificatePinning? {
        let certificates = certificateNames.compactMap { name -> Data? in
            guard let certificatePath = bundle.path(forResource: name, ofType: "cer"),
                  let certificateData = NSData(contentsOfFile: certificatePath) as Data? else {
                return nil
            }
            return certificateData
        }
        
        guard !certificates.isEmpty else { return nil }
        
        return DefaultCertificatePinning(strategy: .certificate(certificates))
    }
    
    static func publicKeyPinning(withCertificateNames certificateNames: [String], in bundle: Bundle = .main) -> DefaultCertificatePinning? {
        let publicKeys = certificateNames.compactMap { name -> Data? in
            guard let certificatePath = bundle.path(forResource: name, ofType: "cer"),
                  let certificateData = NSData(contentsOfFile: certificatePath) as Data?,
                  let certificate = SecCertificateCreateWithData(nil, certificateData as CFData),
                  let publicKey = extractPublicKeyFromCertificate(certificate),
                  let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, nil)
            else { return nil }
            
            return Data(bytes: CFDataGetBytePtr(publicKeyData), count: CFDataGetLength(publicKeyData))
        }
        
        guard !publicKeys.isEmpty else { return nil }
        return DefaultCertificatePinning(strategy: .publicKey(publicKeys))
    }
    
    private static func extractPublicKeyFromCertificate(_ certificate: SecCertificate) -> SecKey? {
        let policy = SecPolicyCreateBasicX509()
        var trust: SecTrust?
        let trustCreationStatus = SecTrustCreateWithCertificates(certificate, policy, &trust)
        
        guard trustCreationStatus == errSecSuccess, let createdTrust = trust else { return nil }
        return SecTrustCopyKey(createdTrust)
    }
    
}
