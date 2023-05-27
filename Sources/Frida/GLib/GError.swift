//
//  GError.swift
//  GLib
//
//  Created by Spotlight Deveaux on 2023-05-17.
//

import CoreFrida
import Foundation

/// Allows converting a GError to our FridaErrors type.
extension GError {
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

    /// Converts a GError to the FridaErrors gError enum case.
    var fridaError: FridaError {
        .gError(domain: quarkDomain(), code: Int(code), message: errorMessage())
    }
}
