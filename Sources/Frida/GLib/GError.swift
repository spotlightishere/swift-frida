//
//  GError.swift
//  GLib
//
//  Created by Spotlight Deveaux on 2023-05-17.
//

import CoreFrida
import Foundation

/// Allows throwing GErrors as normal errors.
extension GError: Error {}

/// Even though GErrors have domains, codes, and messages like NSErrors, Swift's error protocol only defines a message.
/// In order to allow for readability, we mock up a localized description including all of these.
extension GError: LocalizedError {
    /// Converts the GQuark of this error to a usable string for our message.
    func quarkDomain() -> String {
        if let quarkDomainPtr = g_quark_to_string(domain) {
            return String(cString: quarkDomainPtr)
        } else {
            return "Unknown domain"
        }
    }

    /// Converts the C string-style error message contained within to a suitable Swift String.
    func errorMessage() -> String {
        if let errorMessage = message {
            return String(cString: errorMessage)
        } else {
            return "Unknown message"
        }
    }

    public var errorDescription: String? {
        "GError: code \(code), domain \(quarkDomain()): \(errorMessage())"
    }
}
