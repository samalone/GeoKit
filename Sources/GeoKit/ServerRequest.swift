//
//  File.swift
//  
//
//  Created by Stuart A. Malone on 3/22/23.
//

import Foundation
import JWT

struct ServerRequest<T: Codable>: JWTPayload {
    enum CodingKeys: String, CodingKey {
        case expiration = "exp"
        case value = "value"
    }
    
    var expiration: ExpirationClaim
    
    var value: T
    
    func verify(using signer: JWTSigner) throws {
        try self.expiration.verifyNotExpired()
    }
}
