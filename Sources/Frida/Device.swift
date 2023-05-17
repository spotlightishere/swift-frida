//
//  Device.swift
//  swift-frida
//
//  Created by Spotlight Deveaux on 2023-05-17.
//

import CoreFrida

public struct Device {
    /// The name of this device.
    public let name: String
    
    init(from device: OpaquePointer) throws {
        // TODO: Properly handle device information
        name = String(cString: frida_device_get_name(device)!)
    }
}
