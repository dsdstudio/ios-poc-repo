//
//  BLEViewController.swift
//  ios-poc
//
//  Created by bohyung kim on 2018. 6. 16..
//  Copyright © 2018년 dsdstudio.inc. All rights reserved.
//

import UIKit

import CoreBluetooth

class BLEViewController: UIViewController {
    var peripheralManager: CBPeripheralManager?
    var centralManager :CBCentralManager?
    override func viewDidLoad() {
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
}

// MARK : Client
extension BLEViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOff: print("centralManager state::powerdOff")
        case .poweredOn: print("centralManager state::poweredOn")
        case .unauthorized: print("centralManager state::unauthorized")
        case .unknown: print("centralManager state::unknown")
        case .unsupported: print("centralManager state::unsupported")
        case .resetting: print("centralManager state::resetting")
        }
        guard central.state != .unauthorized else {
            return
        }
    }
}

// MARK : Server
extension BLEViewController: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOff: print("peripheralManager state::powerdOff")
        case .poweredOn: print("peripheralManager state::poweredOn")
        case .unauthorized: print("peripheralManager state::unauthorized")
        case .unknown: print("peripheralManager state::unknown")
        case .unsupported: print("peripheralManager state::unsupported")
        case .resetting: print("peripheralManager state::resetting")
        }
        guard peripheral.state != .unauthorized else {
            return
        }
    }
}
