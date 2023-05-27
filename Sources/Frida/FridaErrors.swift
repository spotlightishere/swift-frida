//
//  FridaErrors.swift
//  swift-frida
//
//  Created by Spotlight Deveaux on 2023-05-17.
//

import Foundation

public enum FridaError: Error {
    case invalidDevice
    case nilDevices
    case gError(domain: String, code: Int, message: String)
    case invalidProcess
}
