//
//  CoreBluetoothCentralManager.swift
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
import CoreBluetooth

final class CoreBluetoothCentralManager {
    
    var powerState: CurrentValueSubject<CentralManagerPowerState, Never> = CurrentValueSubject(.unspecified)
    var authState: CurrentValueSubject<CentralManagerAuthorizationState, Never> = CurrentValueSubject(.unspecified)
    
    private var queue: DispatchQueue = DispatchQueue(label: String(describing: CoreBluetoothPeripheral.self), attributes: .concurrent)
    private let centralManager: CBCentralManager
    private let delegate: CoreBluetoothdCentralManagerDelegate
    private var peripherals: [UUID: CoreBluetoothPeripheral] = [:]
    private var cancellables: Set<AnyCancellable> = .init()
    private var connectedPeripherals: [UUID: CoreBluetoothPeripheral] = [:]
    
    private let lock = NSLock()
    
    init() {
        self.delegate = CoreBluetoothdCentralManagerDelegate()
        let options: [String: Any] = [
            CBCentralManagerOptionShowPowerAlertKey: true,
            CBCentralManagerOptionRestoreIdentifierKey: "CoreBluetoothCentralManager"
        ]
        self.centralManager = CBCentralManager(delegate: delegate, queue: nil, options: options)
        
        startObserving()
    }
}

// MARK: - Public Methods
//
extension CoreBluetoothCentralManager {
    
    func connect(peripheral: CBPeripheral, options: [String:Any]?) {
        centralManager.connect(peripheral, options: options)
    }
    
    func cancelPeripheralConnection(_ peripheral: CBPeripheral) -> AnyPublisher<Void, Never> {
        
        centralManager.cancelPeripheralConnection(peripheral)
        connectedPeripherals[peripheral.identifier] = nil
        peripherals[peripheral.identifier] = nil
        delegate.disconnectPeripheral.send(.init(peripheral: peripheral, error: nil))
        
        return Just(()).eraseToAnyPublisher()
    }
}


// MARK: - CentralManager
//
extension CoreBluetoothCentralManager: CBCCentralManager {
    
    var isScanning: Bool {
        return centralManager.isScanning
    }
    
    func stopScan() {
        return centralManager.stopScan()
    }
    
    func disconnectAllPeripherals(for services: [String]) {
        
        let cbuuids: [CBUUID] = services.map { CBUUID(string: $0) }
        let retrievedPeripherals = centralManager.retrieveConnectedPeripherals(withServices: cbuuids)
        retrievedPeripherals.forEach {
            self.centralManager.cancelPeripheralConnection($0)
        }
    }
    
    func getPeripherals(with identifiers: [UUID]) -> AnyPublisher<CBCPeripheral, CBCError> {
        
        let retrievedPeripherals = centralManager.retrievePeripherals(withIdentifiers: identifiers)
        return convertToDTOPeripherals(from: retrievedPeripherals).eraseToAnyPublisher()
    }
    
    func getConnectedPeripherals(with serviceIds: [String]) -> AnyPublisher<CBCPeripheral, CBCError> {
        
        let cbuuids: [CBUUID] = serviceIds.map { CBUUID(string: $0) }
        
        let retrievedPeripherals = centralManager.retrieveConnectedPeripherals(withServices: cbuuids)
        return convertToDTOPeripherals(from: retrievedPeripherals).eraseToAnyPublisher()
    }
    
    func startScan(with serviceIds: [String]?) -> AnyPublisher<CBCPeripheral, CBCError> {
        
        let cbuuids: [CBUUID] = serviceIds?.map { CBUUID(string: $0) } ?? []
        
        return waitUntilPoweredOn()
            .tryMap { [weak self] central -> CoreBluetoothCentralManager in
                return try self.unwrapped(with: CBCError.objectDeallocated)
            }
            .mapError { $0.cbcError }
            .flatMap { manager -> AnyPublisher<CBCPeripheral, CBCError> in
                let central = manager.centralManager
                central.scanForPeripherals(withServices: cbuuids, options: nil)
                return manager.observeDiscoveredPeripherals()
            }
            .eraseToAnyPublisher()
    }
    
    func observeWillRestoreState(for identifier: UUID) -> AnyPublisher<CBCPeripheral, Never> {
        
        return delegate.restoreState
            .compactMap { state -> CBPeripheral? in
                let identifiers = state[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral]
                let filtered = identifiers?.filter { $0.identifier == identifier }
                return filtered?.first
            }
            .compactMap {[weak self] peripheral in
                guard let `self` = self else { return nil }
                return CoreBluetoothPeripheral(peripheral: peripheral, centralManager: self)
            }
            .eraseToAnyPublisher()
    }
}


// MARK: - Local state observers
//
private extension CoreBluetoothCentralManager {
    
    func startObserving() {
        
        observeUpdateState()
        observeConnectPeripheral()
        observeDisconnectPeripheral()
        observeFailToConnectPeripheral()
    }
    
    func observeUpdateState() {
        
        delegate.updateState
            .sink { [weak self] state in
                self?.powerState.send(CentralManagerPowerState(state: state))
                self?.authState.send(CentralManagerAuthorizationState(state: state))
                self?.connectedPeripherals.values.forEach {
                    $0.connectionState.send(false)
                }
                self?.connectedPeripherals.removeAll()
            }
            .store(in: &cancellables)
    }
    
    func observeConnectPeripheral() {
        
        delegate.connectPeripheral
            .sink { [weak self] result in
                guard let `self` = self else { return }
                let peripheral = self.provideDTOPeripheral(for: result, centralManager: self)
                peripheral.connectionState.send(true)
                self.connectedPeripherals[peripheral.peripheral.identifier] = peripheral
            }
            .store(in: &cancellables)
    }
    
    func observeDisconnectPeripheral() {
        
        delegate.disconnectPeripheral
            .sink { [weak self] result in
                guard let `self` = self else { return }
                let peripheral = self.provideDTOPeripheral(for: result.peripheral, centralManager: self)
                peripheral.connectionState.send(false)
                self.connectedPeripherals[peripheral.peripheral.identifier] = nil
            }
            .store(in: &cancellables)
    }
    
    func observeFailToConnectPeripheral() {
        
        delegate.failToConnectPeripheral
            .sink { [weak self] result in
                guard let `self` = self else { return }
                let peripheral = self.provideDTOPeripheral(for: result.peripheral, centralManager: self)
                peripheral.connectionState.send(completion: .failure(CBCError.connection(result.error)))
                self.connectedPeripherals[peripheral.peripheral.identifier] = nil
            }
            .store(in: &cancellables)
    }
}


// MARK: - Private methods
//
private extension CoreBluetoothCentralManager {
    
    func observeDiscoveredPeripherals() -> AnyPublisher<CBCPeripheral, CBCError> {
        
        return self.delegate.discoverPeripheral
            .tryMap { [weak self] event in
                guard let `self` = self else { throw CBCError.objectDeallocated }
                let peripheral = self.provideDTOPeripheral(for: event.peripheral, centralManager: self)
                peripheral.rssi = event.rssi
                return peripheral
            }
            .mapError { $0.cbcError }
            .eraseToAnyPublisher()
    }
    
    func convertToDTOPeripherals(from retrievedPeripherals: [CBPeripheral]) -> AnyPublisher<CBCPeripheral, CBCError> {
        
        let peripherals = retrievedPeripherals.compactMap { self.provideDTOPeripheral(for: $0, centralManager: self) }
        
        return Publishers.Sequence(sequence: peripherals)
            .setFailureType(to: CBCError.self)
            .eraseToAnyPublisher()
    }
    
    func provideDTOPeripheral(for peripheral: CBPeripheral, centralManager: CoreBluetoothCentralManager) -> CoreBluetoothPeripheral {
        
        if let existing = safeGetPeripheral(for: peripheral.identifier) {
            return existing
        } else {
            let blePeripheral = CoreBluetoothPeripheral(peripheral: peripheral, centralManager: centralManager)
            safeSet(peripheral: blePeripheral, for: peripheral.identifier)
            return blePeripheral
        }
    }
    
    func safeSet(peripheral: CoreBluetoothPeripheral, for identifier: UUID) {
        
        Just(())
            .receive(on: queue)
            .sink {[weak self] _ in
                self?.lock.lock()
                self?.peripherals[identifier] = peripheral
                self?.lock.unlock()
            }
            .store(in: &cancellables)
    }
    
    func safeGetPeripheral(for identifier: UUID) -> CoreBluetoothPeripheral? {
        return queue.sync { peripherals[identifier] }
    }
    
    func waitUntilPoweredOn() -> AnyPublisher<Void, CBCError> {
        
        if self.powerState.value == .poweredOn {
            return Just(()).setFailureType(to: CBCError.self).eraseToAnyPublisher()
        } else {
            return self.powerState
                .filter { $0 == .poweredOn }
                .first()
                .compactMap {_ in return () }
                .setFailureType(to: CBCError.self)
                .eraseToAnyPublisher()
        }
    }
}


private extension CentralManagerPowerState {
    
    init(state: CBManagerState) {
        switch state {
        case .unknown, .resetting, .unsupported, .unauthorized:
            self = .unspecified
        case .poweredOff:
            self = .poweredOff
        case .poweredOn:
            self = .poweredOn
        @unknown default:
            self = .unspecified
        }
    }
}


private extension CentralManagerAuthorizationState {
    
    init(state: CBManagerState) {
        switch state {
        case .unauthorized:
            self = .unauthorized
        case .unknown, .resetting, .unsupported:
            self = .unspecified
        case .poweredOff, .poweredOn:
            self = .authorized
        @unknown default:
            self = .unspecified
        }
    }
}
