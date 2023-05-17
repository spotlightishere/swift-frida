//
//  DeviceManager.swift
//  swift-frida
//
//  Created by Spotlight Deveaux on 2023-05-17.
//

import CoreFrida

/// You use DeviceManager to query devices attached to the local machine,
/// manually add and remove devices, and to be notified on any device changes.
public class DeviceManager {
    let manager: OpaquePointer!

    /// Wraps around a new FridaDeviceManager.
    init() {
        manager = frida_device_manager_new()
    }

    deinit {
        // We have no way to use any error result, if needed... oops :)
        frida_device_manager_close_finish(self.manager, nil, nil)
    }

    /// Enumerate all attached devices to this machine.
    public func enumerateDevices() async throws -> [Device] {
        // Synchronously get all devices.
        var enumerationError: UnsafeMutablePointer<GError>?
        var devices = frida_device_manager_enumerate_devices_sync(manager, nil, &enumerationError)
        if let enumerationError {
            throw enumerationError.pointee
        }

        // Make sure we have devices queried.
        let deviceCount = frida_device_list_size(devices)
        if deviceCount == 0 {
            return []
        }

        // Loop through all devices and convert them to our Swift abstraction.
        var resultDevices: [Device] = []
        for i in 0 ..< deviceCount {
            guard var currentDevice = frida_device_list_get(devices, i) else {
                throw FridaError.nilDevices
            }

            try resultDevices.append(Device(from: currentDevice))
            // TODO: Properly manage references
            // g_object_unref(&currentDevice)
        }

        frida_unref(&devices)
        return resultDevices
    }
}
