//
//  SSLPinningHandler.swift
//  
//
//  Created by Abhijith Pm on 08/11/22.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

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
        
        guard let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        let remoteCertificate: NSData = SecCertificateCopyData(certificate)
        
        // This is for domain name checks
        let policy: NSMutableArray = .init()
        policy.add(
            SecPolicyCreateSSL(true, challenge.protectionSpace.host as CFString)
        )
        
        // Evaluate server certificate
        let isServerTrusted = SecTrustEvaluateWithError(serverTrust, nil)
        
        // Local Certificate Data
        guard let filePath = Bundle.main.path(forResource: "JSONPlaceholder", ofType: "cer"),
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
