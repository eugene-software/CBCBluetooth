//
//  CBCCentralManagerFactory.swift
//  CBCBluetooth
//
//  Created by Eugene Software on 12/14/21.
//

import Foundation

public final class CBCCentralManagerFactory {
    
    /// Returns an object that wraps `CBCCentralManager` protocol implementation
    /// - Returns: `CBCCentralManager` object
    ///
    public static func create() -> CBCCentralManager {
        return CoreBluetoothCentralManager()
    }
}
