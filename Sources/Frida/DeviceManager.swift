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

    /// Wraps around an existing FridaDeviceManager - i.e. one obtained from a device.
    init(manager: OpaquePointer) {
        self.manager = manager
    }

    deinit {
        // We have no way to use any error result, if needed... oops :)
        frida_device_manager_close_finish(self.manager, nil, nil)
    }

    /// Returns all attached devices to this machine.
    public func devices() async throws -> [Device] {
        // Synchronously get all devices.
        var enumerationError: UnsafeMutablePointer<GError>?
        var devices = frida_device_manager_enumerate_devices_sync(manager, nil, &enumerationError)
        if let enumerationError {
            throw enumerationError.pointee.fridaError
        }

        // Make sure we have devices queried.
        let deviceCount = frida_device_list_size(devices)
        if deviceCount == 0 {
            frida_unref(&devices)
            return []
        }

        // Loop through all devices and convert them to our Swift abstraction.
        var resultDevices: [Device] = []
        for i in 0 ..< deviceCount {
            guard let currentDevice = frida_device_list_get(devices, i) else {
                throw FridaError.nilDevices
            }

            try resultDevices.append(Device(from: currentDevice))
        }

        frida_unref(&devices)
        return resultDevices
    }

    /// Obtains a device with a specific type.
    public func getDevice(type: DeviceType) async throws -> Device {
        var deviceError: UnsafeMutablePointer<GError>?
        let device = frida_device_manager_get_device_by_type_sync(manager, type.rawValue, 5000, nil, &deviceError)
        if let deviceError {
            throw deviceError.pointee.fridaError
        }

        guard let device else {
            throw FridaError.nilDevices
        }
        return try Device(from: device)
    }
}
