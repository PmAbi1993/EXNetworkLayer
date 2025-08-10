//
//  SSLPinningHandler.swift
//  
//
//  Created by Abhijith Pm on 08/11/22.
//

import Foundation
import Security

class SSLPinningHandler: NSObject, URLSessionDelegate {

    var fileName: String
    var fileExtension: String
    var bundle: Bundle
    var urlSession: URLSession?
    
    init(bundle: Bundle, fileName: String, fileExtension: String) {
        self.fileName = fileName
        self.fileExtension = fileExtension
        self.bundle = bundle
        super.init()
        self.handleSSLSessionCreation()
    }
    
    private func handleSSLSessionCreation() {
        urlSession = URLSession(
            configuration: .ephemeral,
            delegate: self,
            delegateQueue: nil
        )
    }
    
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        // Obtain the leaf certificate (index 0) using modern API when available
        let certificate: SecCertificate?
        if #available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *) {
            if let chain = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate] {
                certificate = chain.first
            } else {
                certificate = nil
            }
        } else {
            certificate = SecTrustGetCertificateAtIndex(serverTrust, 0)
        }
        guard let certificate else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        let remoteCertificate: NSData = SecCertificateCopyData(certificate)
        
        // This is for domain name checks
        let policy: NSMutableArray = .init()
        policy.add(
            SecPolicyCreateSSL(true, challenge.protectionSpace.host as CFString)
        )
        // Apply policy to the trust object to ensure hostname validation
        SecTrustSetPolicies(serverTrust, policy)
        
        // Evaluate server certificate
        let isServerTrusted = SecTrustEvaluateWithError(serverTrust, nil)
        
        // Local Certificate Data
        guard let filePath = bundle.path(forResource: fileName, ofType: fileExtension),
              let localCertificate = NSData(contentsOfFile: filePath) else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        let isLocalAndRemoteCertificateMatching: Bool = remoteCertificate.isEqual(
            to: (localCertificate as Data)
        )

        if isLocalAndRemoteCertificateMatching && isServerTrusted {
            completionHandler(.useCredential, nil)
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}
