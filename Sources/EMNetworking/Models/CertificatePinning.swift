//
//  CertificatePinning.swift
//
//
//  Created by Mickael Belhassen on 01/08/2024.
//

import Foundation
import Security

public protocol CertificatePinning: Sendable {
    func validate(serverTrust: SecTrust, for host: String) -> Bool
}

public enum PinningStrategy: Sendable {
    case certificate([Data])
    case publicKey([Data])
    case certificateAuthority([Data])
}

public struct DefaultCertificatePinning: CertificatePinning {
    private let strategy: PinningStrategy
    private let allowSelfSignedCertificates: Bool
    
    public init(strategy: PinningStrategy, allowSelfSignedCertificates: Bool = false) {
        self.strategy = strategy
        self.allowSelfSignedCertificates = allowSelfSignedCertificates
    }
    
    public func validate(serverTrust: SecTrust, for host: String) -> Bool {
        guard let certificateChain = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate],
              let serverCertificate = certificateChain.first else {
            return false
        }
        
        switch strategy {
        case .certificate(let pinnedCertificates):
            return validateCertificate(serverCertificate, against: pinnedCertificates)
            
        case .publicKey(let pinnedPublicKeys):
            return validatePublicKey(of: serverTrust, against: pinnedPublicKeys)
            
        case .certificateAuthority(let pinnedCACertificates):
            return validateCertificateAuthority(certificateChain, against: pinnedCACertificates)
        }
    }
    
    private func validateCertificate(_ certificate: SecCertificate, against pinnedCertificates: [Data]) -> Bool {
        let serverCertData = SecCertificateCopyData(certificate)
        let serverCertificateData = Data(bytes: CFDataGetBytePtr(serverCertData), count: CFDataGetLength(serverCertData))
        
        return pinnedCertificates.contains(serverCertificateData)
    }
    
    private func validatePublicKey(of serverTrust: SecTrust, against pinnedPublicKeys: [Data]) -> Bool {
        guard let serverPublicKey = SecTrustCopyKey(serverTrust),
              let serverPublicKeyData = SecKeyCopyExternalRepresentation(serverPublicKey, nil) else {
            return false
        }
        
        let serverKeyData = Data(bytes: CFDataGetBytePtr(serverPublicKeyData), count: CFDataGetLength(serverPublicKeyData))
        return pinnedPublicKeys.contains(serverKeyData)
    }
    
    private func validateCertificateAuthority(_ certificateChain: [SecCertificate], against pinnedCACertificates: [Data]) -> Bool {
        for certificate in certificateChain {
            let certData = SecCertificateCopyData(certificate)
            let certificateData = Data(bytes: CFDataGetBytePtr(certData), count: CFDataGetLength(certData))
            
            if pinnedCACertificates.contains(certificateData) {
                return true
            }
        }
        
        return false
    }
    
    private func extractPublicKey(from certificate: SecCertificate) -> SecKey? {
        let policy = SecPolicyCreateBasicX509()
        var trust: SecTrust?
        let trustCreationStatus = SecTrustCreateWithCertificates(certificate, policy, &trust)
        
        guard trustCreationStatus == errSecSuccess, let createdTrust = trust else {
            return nil
        }
        
        return SecTrustCopyKey(createdTrust)
    }
}