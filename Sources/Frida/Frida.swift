//
//  DeviceManager.swift
//  swift-frida
//
//  Created by Spotlight Deveaux on 2023-05-16.
//

import CoreFrida

/// Frida is a dynamic instrumentation toolkit for developers, reverse-engineers, and security researchers.
public class Frida {
    /// A shared version of Frida with its runtime initialized. Prefer always accessing via shared.
    public static let shared = Frida()
    /// A manager for devices connected to this Frida server.
    public lazy var deviceManager = DeviceManager()

    /// Allow Frida to set up its GMainLoop.
    private init() {
        frida_init()
    }

    /// Enforce Frida tears down its GMainLoop.
    deinit {
        frida_deinit()
    }

    /// Returns the version of this build of Frida.
    public func version() -> String {
        String(cString: frida_version_string())
    }
}
