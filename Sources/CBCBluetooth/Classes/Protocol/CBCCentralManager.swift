//
//  CBCCentralManager.swift
//  CBCBluetooth
//
//  Created by Eugene Software on 12/13/21.
//
//  Copyright (c) 2022 Eugene Software
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation
import Combine

/// The power state of bluetooth enum
///
public enum CentralManagerPowerState {
    
    /// System power on (if authorized)
    ///
    case poweredOn
    
    /// System power off (if authorized)
    ///
    case poweredOff
    
    /// Not authorized or unavailable on this device
    ///
    case unspecified
}

/// If bluetooth manager isn't authhorized, the power state is unspecified
///
public enum CentralManagerAuthorizationState {
    
    /// Approved by user
    ///
    case authorized
    
    /// Rejected by user
    ///
    case unauthorized
    
    /// Not yet asked
    ///
    case unspecified
}

public protocol CBCCentralManager {
    
    /// Shows whether `CBCCentralManager` is scanning or not
    ///
    var isScanning: Bool { get }
    
    /// The power state of bluetooth subject. Never fails and shows `CentralManagerPowerState` value
    ///
    var powerState: CurrentValueSubject<CentralManagerPowerState, Never> { get }
    
    /// The authorization state of bluetooth subject. Never fails and shows `CentralManagerAuthorizationState` value
    ///
    var authState: CurrentValueSubject<CentralManagerAuthorizationState, Never> { get }
    
    /// Starts scan for particular service UUIDs. `nil` can be passed to scan for all possible peripherals
    /// - Parameters:
    ///   - serviceIds: ID string for particular services
    /// - Returns: Publisher that passes found `CBCPeripheral`
    ///
    func startScan(with serviceIds: [String]?) -> AnyPublisher<CBCPeripheral, CBCError>
    
    /// Stops scan process. Doesn't cancel publishers
    ///
    func stopScan()
    
    /// Immediately disconnects from all peripherals with particular services
    ///
    func disconnectAllPeripherals(for serviceIds: [String])
    
    /// Returns all cached peripherals with particular UUIDs
    /// - Parameters:
    ///   - uuids: UUIDs of peripherals
    /// - Returns: found `CBCPeripheral` objects
    ///
    func getPeripherals(with uuids: [UUID]) -> [CBCPeripheral]
    
    /// Returns connected by iOS system cached peripherals with particular UUIDs
    /// - Parameters:
    ///   - serviceIds: IDs of services to filter
    /// - Returns: found `CBCPeripheral` objects
    ///
    func getConnectedPeripherals(with serviceIds: [String]) -> [CBCPeripheral]
    
    /// When application launches, it can restore connection of peripherals by itself, and the app can handle them by this methhod
    /// - Parameters:
    ///   - uuid: UUID of restorable peripheral
    /// - Returns: Publisher that passes found `CBCPeripheral`
    ///
    func observeWillRestoreState(for uuid: UUID) -> AnyPublisher<CBCPeripheral, Never>
}
