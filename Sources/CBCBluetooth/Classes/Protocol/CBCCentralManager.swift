//
//  CentralManager.swift
//  CBCBluetooth
//
//  Created by Eugene Software on 12/13/21.
//  Copyright © 2021 Eugene Software. All rights reserved.
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
    ///   - serviceUUIDs: UUID string for particular services
    /// - Returns: Publisher that passes found `CBCPeripheral`
    ///
    func startScan(with serviceUUIDs: [UUID]?) -> AnyPublisher<CBCPeripheral, CBCError>
    
    /// Stops scan process. Doesn't cancel publishers
    ///
    func stopScan()
    
    /// Immediately disconnects from all peripherals with particular services
    ///
    func disconnectAllPeripherals(for services: [UUID])
    
    /// Returns all cached peripherals with particular UUIDs
    /// - Parameters:
    ///   - uuids: UUIDs of peripherals
    /// - Returns: Publisher that passes found `CBCPeripheral`
    ///
    func getPeripherals(with uuids: [UUID]) -> AnyPublisher<CBCPeripheral, CBCError>
    
    /// Returns connected by iOS system cached peripherals with particular UUIDs
    /// - Parameters:
    ///   - uuids: UUIDs of peripherals
    /// - Returns: Publisher that passes found `CBCPeripheral`
    ///
    func getConnectedPeripherals(with serviceUUIDs: [UUID]) -> AnyPublisher<CBCPeripheral, CBCError>
    
    /// When application launches, it can restore connection of peripherals by itself, and the app can handle them bu this methhod
    /// - Parameters:
    ///   - uuid: UUID of restorable
    /// - Returns: Publisher that passes found `CBCPeripheral`
    ///
    func observeWillRestoreState(for uuid: UUID) -> AnyPublisher<CBCPeripheral, Never>
}
