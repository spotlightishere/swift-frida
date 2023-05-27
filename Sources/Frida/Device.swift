//
//  Device.swift
//  swift-frida
//
//  Created by Spotlight Deveaux on 2023-05-17.
//

import CoreFrida

/// Possible types of devices available via Frida.
public enum DeviceType: CustomStringConvertible {
    public typealias RawValue = FridaDeviceType

    case local, remote, usb

    /// Creates a DeviceType from the underlying ``FridaDeviceType``.
    public init?(rawValue: FridaDeviceType) {
        switch rawValue {
        case FRIDA_DEVICE_TYPE_LOCAL:
            self = .local
        case FRIDA_DEVICE_TYPE_REMOTE:
            self = .remote
        case FRIDA_DEVICE_TYPE_USB:
            self = .usb
        default:
            return nil
        }
    }

    var rawValue: FridaDeviceType {
        switch self {
        case .local:
            return FRIDA_DEVICE_TYPE_LOCAL
        case .remote:
            return FRIDA_DEVICE_TYPE_REMOTE
        case .usb:
            return FRIDA_DEVICE_TYPE_USB
        }
    }

    public var description: String {
        switch self {
        case .local:
            return "Local"
        case .remote:
            return "Remote"
        case .usb:
            return "USB"
        }
    }
}

/// You use a Device to interact with processes running on it.
public class Device: CustomStringConvertible {
    /// The internal device we wrap around.
    private var device: OpaquePointer

    /// The ID of this device.
    public let id: String

    /// The name of this device.
    public let name: String

    /// The type of device.
    public let type: DeviceType

    init(from device: OpaquePointer) throws {
        self.device = device
        g_object_ref(&self.device)

        // Initialize properties
        guard let deviceId = frida_device_get_id(device) else {
            throw FridaError.invalidDevice
        }
        id = String(cString: deviceId)

        guard let deviceName = frida_device_get_name(device) else {
            throw FridaError.invalidDevice
        }
        name = String(cString: deviceName)

        guard let deviceType = DeviceType(rawValue: frida_device_get_dtype(device)) else {
            throw FridaError.invalidDevice
        }
        type = deviceType
    }

    deinit {
        g_object_unref(&device)
    }

    /// Retrieves all processes on this device.
    public func processes() async throws -> [Process] {
        var processError: UnsafeMutablePointer<GError>?
        var allProcesses = frida_device_enumerate_processes_sync(device, nil, nil, &processError)
        if let processError {
            throw processError.pointee.fridaError
        }

        let processCount = frida_process_list_size(allProcesses)
        if processCount == 0 {
            frida_unref(&allProcesses)
            return []
        }

        var result: [Process] = []
        for i in 0 ..< processCount {
            guard let currentProcess = frida_process_list_get(allProcesses, i) else {
                throw FridaError.nilDevices
            }

            try result.append(Process(from: currentProcess))
        }

        frida_unref(&allProcesses)
        return result
    }

    public var description: String {
        "Frida.Device(id: \(id), name: \(name), type: \(type))"
    }
}
