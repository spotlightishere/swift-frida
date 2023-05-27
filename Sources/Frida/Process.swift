//
//  Process.swift
//  swift-frida
//
//  Created by Spotlight Deveaux on 2023-05-26.
//

import CoreFrida
import Foundation

/// You use a Device to interact with processes running on it.
public class Process: CustomStringConvertible {
    /// The internal device we wrap around.
    private var process: OpaquePointer!

    /// The name of this process.
    public let name: String

    /// The PID of this process.
    public let pid: UInt

    init(from process: OpaquePointer) throws {
        self.process = process
        g_object_ref(&self.process)

        frida_process_get_type()

        // Initialize properties
        pid = UInt(frida_process_get_pid(process))

        guard let processName = frida_process_get_name(process) else {
            throw FridaError.invalidProcess
        }
        name = String(cString: processName)
    }

    deinit {
        g_object_unref(&process)
    }

    public var description: String {
        "Frida.Process(pid: \(pid), name: \(name))"
    }
}
