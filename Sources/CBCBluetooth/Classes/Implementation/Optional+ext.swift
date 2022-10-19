//
//  Optional+ext.swift
//  CBCBluetooth
//
//  Created by Eugene Software on 12/13/21.
//  Copyright © 2021 Eugene Software. All rights reserved.
//

import Foundation

extension Optional {
    
    func unwrapped(with error: Error) throws -> Wrapped {
        guard let unwrapped = self else { throw error }
        return unwrapped as Wrapped
    }
}
