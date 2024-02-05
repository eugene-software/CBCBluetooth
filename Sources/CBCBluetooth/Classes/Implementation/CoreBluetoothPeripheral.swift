//
//  CoreBluetoothPeripheral.swift
//  CBCBluetooth
//
//  Created by Eugene Software on 12/13/21.
//  Copyright © 2021 Eugene Software. All rights reserved.
//

import Combine
import CoreBluetooth

final class CoreBluetoothPeripheral {
    
    var connectionState: CurrentValueSubject<Bool, CBCError> = CurrentValueSubject(false)
    var peripheral: CBPeripheral
    var rssi: NSNumber?
    
    private let delegate: CoreBluetoothPeripheralDelegate
    private weak var centralManager: CoreBluetoothCentralManager?
    private var connectCancellable: AnyCancellable?
    private var discoverServicesCancellable: AnyCancellable?
    private var discoverCharacteristicsCancellable: AnyCancellable?
    private var notifyCounterMap: [CBCharacteristic : Int] = [:]
    
    init(peripheral: CBPeripheral, centralManager: CoreBluetoothCentralManager?) {
        
        self.peripheral = peripheral
        self.delegate = CoreBluetoothPeripheralDelegate()
        self.peripheral.delegate = delegate
        self.centralManager = centralManager
    }
}


//MARK: - Peripheral
//
extension CoreBluetoothPeripheral: CBCPeripheral {
    
    var name: String {
        return peripheral.name ?? ""
    }
    
    var uuid: UUID {
        return peripheral.identifier
    }
    
    func connect() -> AnyPublisher<CBCPeripheral, CBCError> {
        
        let peripheral = self.peripheral
        
        if peripheral.state == .connected {
            connectionState.send(true)
            return Just(self).setFailureType(to: CBCError.self).eraseToAnyPublisher()
        }
        
        let options: [String: Any] = [
            CBConnectPeripheralOptionNotifyOnNotificationKey: true
        ]
        let subject = PassthroughSubject<CBCPeripheral, CBCError>()
        
        connectCancellable?.cancel()
        connectCancellable = connectionState
            .filter { $0 }
            .tryMap { [weak self] _ -> CBCPeripheral in
                guard let `self` = self else { throw CBCError.objectDeallocated }
                return self
            }
            .mapError { $0.cbcError }
            .handleEvents(
                receiveSubscription: {[weak self] _ in
                    self?.centralManager?.connect(peripheral: peripheral, options: options)
                }
            )
            .sink(receiveCompletion: { completion in
                guard case .failure(let error) = completion else { return }
                subject.send(completion: .failure(error))
            }, receiveValue: { value in
                subject.send(value)
                subject.send(completion: .finished)
            })
        
        return subject
            .first()
            .eraseToAnyPublisher()
    }
    
    @discardableResult
    func disconnect() -> AnyPublisher<Void, CBCError> {
        
        guard let centralManager = centralManager else {
            return Future<Void, CBCError>({ $0(.failure(CBCError.objectDeallocated))}).eraseToAnyPublisher()
        }
        
        let publisher = centralManager.cancelPeripheralConnection(self.peripheral).setFailureType(to: CBCError.self)
        
        return publisher
            .first()
            .eraseToAnyPublisher()
    }
    
    func observeRSSI() -> AnyPublisher<NSNumber, CBCError> {
        
        return delegate.readRSSI
            .map { $0.rssi }
            .mapError { $0.cbcError }
            .handleEvents(
                receiveSubscription: {[weak self] _ in
                    self?.peripheral.readRSSI()
                },
                receiveOutput: {[weak self] output in
                    self?.rssi = output
                }
            )
            .first()
            .eraseToAnyPublisher()
    }
    
    func discoverServices(with serviceIds: [String]?) -> AnyPublisher<CBCService, CBCError> {
        
        let subject = PassthroughSubject<CBCService, CBCError>()
        let cbuuids: [CBUUID] = serviceIds?.map { CBUUID(string: $0) } ?? []
        
        if let publisher = discoveredServicesPublisher(for: peripheral, with: serviceIds) {
            return publisher
        }

        discoverServicesCancellable?.cancel()
        discoverServicesCancellable = delegate.discoverServices
            .tryFilter { [weak self] in
                guard let `self` = self else { throw CBCError.objectDeallocated }
                return $0.peripheral.identifier == self.peripheral.identifier
            }
            .tryMap { result -> [CBService] in
                guard result.error == nil, let services = result.peripheral.services else { throw CBCError.service(result.error) }
                return services.filter { cbuuids.contains($0.uuid) == true }
            }
            .mapError { $0.cbcError }
            .handleEvents(
                receiveSubscription: {[weak self] _ in
                    self?.peripheral.discoverServices(cbuuids)
                }
            )
            .sink(
                receiveCompletion: { completion in
                    guard case .failure(let error) = completion else { return }
                    subject.send(completion: .failure(error))
                },
                receiveValue: { [weak self] services in
                    guard let self = self else { return }
                    services.forEach { service in
                        subject.send(CoreBluetoothService(service: service, peripheral: self))
                    }
                    subject.send(completion: .finished)
                }
            )
        
        return subject.eraseToAnyPublisher()
    }
}


//MARK: - Public
//
extension CoreBluetoothPeripheral {
    
    func discoverCharacteristics(with uuids: [String]?, for service: CBService) -> AnyPublisher<CBCCharacteristic, CBCError> {
        
        let subject = PassthroughSubject<CBCCharacteristic, CBCError>()
        
        let cbuuids: [CBUUID] = uuids?.map { CBUUID(string: $0) } ?? []
        
        if let publisher = discoveredCharacteristicsPublisher(for: service, with: uuids) {
            return publisher
        }
        
        discoverCharacteristicsCancellable?.cancel()
        discoverCharacteristicsCancellable = delegate.discoverCharacteristicsForService
            .tryFilter { [weak self] in
                return $0.peripheral.identifier == self?.peripheral.identifier
            }
            .tryMap { result -> [CBCharacteristic] in
                guard result.error == nil, let characteristics = result.service.characteristics else { throw CBCError.characteristic(result.error) }
                return characteristics.filter { cbuuids.contains($0.uuid) == true }
            }
            .mapError { $0.cbcError }
            .handleEvents(
                receiveSubscription: { [weak self] _ in
                    self?.peripheral.discoverCharacteristics(cbuuids, for: service)
                }
            )
            .sink(
                receiveCompletion: { completion in
                    guard case .failure(let error) = completion else { return }
                    subject.send(completion: .failure(error))
                },
                receiveValue: { [weak self] characteristics in
                    guard let self = self else { return }
                    characteristics.forEach { characteristic in
                        subject.send(CoreBluetoothCharacteristic(characteristic: characteristic, peripheral: self))
                    }
                }
            )
        return subject.eraseToAnyPublisher()
    }
    
    func readValue(for characteristic: CBCharacteristic) -> AnyPublisher<CBCCharacteristicData, CBCError> {
        
        return readDeferredValue(for: characteristic)
            .handleEvents(
                receiveSubscription: { [weak self] _ in
                    self?.peripheral.readValue(for: characteristic)
                }
            )
            .first()
            .eraseToAnyPublisher()
    }
    
    func observeValue(for characteristic: CBCharacteristic) -> AnyPublisher<CBCCharacteristicData, CBCError> {
        
        return readDeferredValue(for: characteristic)
            .handleEvents(
                receiveSubscription: { [weak self] _ in
                    self?.incrementNotifyCounter(for: characteristic)
                }, receiveCompletion: {[weak self] _ in
                    self?.decrementNotifyCounter(for: characteristic)
                }, receiveCancel: { [weak self] in
                    self?.decrementNotifyCounter(for: characteristic)
                }
            )
            .eraseToAnyPublisher()
    }
    
    func observeNotificationState(for characteristic: CBCharacteristic) -> AnyPublisher<CBCPeripheral, CBCError> {
        
        return self.delegate.updateNotificationStateForCharacteristic
            .filter { $0.characteristic.uuid == characteristic.uuid }
            .tryMap {[weak self] result -> CBCPeripheral in
                if let error = result.error { throw error }
                return try self.unwrapped(with: CBCError.objectDeallocated)
            }
            .mapError { $0 as? CBCError ?? CBCError.pairing }
            .handleEvents(
                receiveSubscription: { [weak self] _ in
                    self?.incrementNotifyCounter(for: characteristic)
                }, receiveCompletion: {[weak self] _ in
                    self?.decrementNotifyCounter(for: characteristic)
                }, receiveCancel: { [weak self] in
                    self?.decrementNotifyCounter(for: characteristic)
                }
            )
            .eraseToAnyPublisher()
    }
    
    func write(data: Data, for characteristic: CBCharacteristic, type: CBCharacteristicWriteType) -> AnyPublisher<Never, CBCError> {
        
        defer {
            peripheral.writeValue(data, for: characteristic, type: type)
        }
        
        switch type {
        case .withResponse:
            return self.delegate.writeValueForCharacteristic
                .filter { $0.characteristic.uuid == characteristic.uuid }
                .tryMap { result -> CBCharacteristic in
                    if let error = result.error {
                        throw error
                    }
                    return result.characteristic
                }
                .mapError { $0.cbcError }
                .first()
                .ignoreOutput()
                .eraseToAnyPublisher()
        default:
            return Empty(completeImmediately: true).eraseToAnyPublisher()
        }
    }
}


//MARK: - Private
//
private extension CoreBluetoothPeripheral {
    
    func discoveredCharacteristicsPublisher(for service: CBService, with uuids: [String]?) -> AnyPublisher<CBCCharacteristic, CBCError>? {
        
        guard let uuids = uuids else { return nil }
        guard let existingCharacteristics = service.characteristics?.filter({ uuids.contains($0.uuid.uuidString)}) else { return nil }
        let existingUUIDsSet = Set(existingCharacteristics.map {$0.uuid.uuidString })
        let incomingUUIDSet = Set(uuids)
        
        if existingUUIDsSet == incomingUUIDSet {
            return Publishers.Sequence(sequence: existingCharacteristics)
                .map { CoreBluetoothCharacteristic(characteristic: $0, peripheral: self) }
                .eraseToAnyPublisher()
        } else {
            return nil
        }
    }
    
    func discoveredServicesPublisher(for peripheral: CBPeripheral, with uuids: [String]?) -> AnyPublisher<CBCService, CBCError>? {
        
        guard let uuids = uuids else { return nil }
        guard let existingServices = peripheral.services?.filter({ uuids.contains($0.uuid.uuidString)}) else { return nil }
        let existingUUIDsSet = Set(existingServices.map {$0.uuid.uuidString })
        let incomingUUIDSet = Set(uuids)
        
        if existingUUIDsSet == incomingUUIDSet {
            return Publishers.Sequence(sequence: existingServices)
                .map { CoreBluetoothService(service: $0, peripheral: self) }
                .eraseToAnyPublisher()
        } else {
            return nil
        }
    }
    
    func readDeferredValue(for characteristic: CBCharacteristic) -> AnyPublisher<CBCCharacteristicData, CBCError> {
        
        let deferred = Deferred<AnyPublisher<CBCCharacteristicData, CBCError>> {[weak self] in
            
            guard let `self` = self else {
                return Fail<CBCCharacteristicData, CBCError>(error: CBCError.objectDeallocated).eraseToAnyPublisher()
            }
            
            return self.delegate.updateValueForCharacteristic
                .filter { $0.characteristic.uuid == characteristic.uuid }
                .tryMap {[weak self] filteredPeripheral -> CBCCharacteristicData in
                    guard let `self` = self else { throw CBCError.objectDeallocated }
                    guard let data = filteredPeripheral.characteristic.value else { throw CBCError.invalidData }
                    return CoreBluetoothCharacteristicData(data: data, peripheral: self, identifier: characteristic.uuid.uuidString)
                }
                .mapError { $0.cbcError }
                .eraseToAnyPublisher()
        }
        
        return deferred.eraseToAnyPublisher()
    }
    
    func incrementNotifyCounter(for characteristic: CBCharacteristic) {
        
        var counter = notifyCounterMap[characteristic] ?? 0
        counter += 1
        
        if counter > 1 { return }
        
        notifyCounterMap[characteristic] = counter
        peripheral.setNotifyValue(true, for: characteristic)
    }
    
    func decrementNotifyCounter(for characteristic: CBCharacteristic) {
        
        guard var counter = notifyCounterMap[characteristic] else { return }
        counter -= 1
        
        if counter > 0 { return }
        
        notifyCounterMap[characteristic] = nil
        peripheral.setNotifyValue(false, for: characteristic)
    }
}
