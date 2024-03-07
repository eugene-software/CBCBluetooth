//
//  CoreBluetoothdCentralManagerDelegate.swift
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
