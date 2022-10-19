//
//  CoreBluetoothdCentralManagerDelegate.swift
//  CBCBluetooth
//
//  Created by Eugene Software on 12/13/21.
//  Copyright © 2021 Eugene Software. All rights reserved.
//

import Foundation
import CoreBluetooth
import Combine

public final class CoreBluetoothdCentralManagerDelegate: NSObject {
    
    struct DiscoveredPeripheralEvent {
        let peripheral: CBPeripheral
        let rssi: NSNumber
    }
    
    struct DisconnectedPeripheralEvent {
        let peripheral: CBPeripheral
        let error: Error?
    }
    
    let connectPeripheral: PassthroughSubject<CBPeripheral, Never> = PassthroughSubject()
    let disconnectPeripheral: PassthroughSubject<DisconnectedPeripheralEvent, Never> = PassthroughSubject()
    let discoverPeripheral: PassthroughSubject<DiscoveredPeripheralEvent, Never> = PassthroughSubject()
    let failToConnectPeripheral: PassthroughSubject<DisconnectedPeripheralEvent, Never> = PassthroughSubject()
    let updateState: PassthroughSubject<CBManagerState, Never> = PassthroughSubject()
    let restoreState: PassthroughSubject<[String: Any], Never> = PassthroughSubject()
}

extension CoreBluetoothdCentralManagerDelegate: CBCentralManagerDelegate {
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectPeripheral.send(peripheral)
    }

    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        disconnectPeripheral.send(.init(peripheral: peripheral, error: error))
    }

    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        failToConnectPeripheral.send(.init(peripheral: peripheral, error: error))
    }

    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        discoverPeripheral.send(.init(peripheral: peripheral, rssi: RSSI))
    }

    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        updateState.send(central.state)
    }
    
    public func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        restoreState.send(dict)
    }
}
