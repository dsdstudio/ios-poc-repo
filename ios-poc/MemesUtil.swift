//
//  MemesUtil.swift
//  ios-poc
//
//  Created by bohyung kim on 2018. 2. 9..
//  Copyright © 2018년 dsdstudio.inc. All rights reserved.
//

import UIKit

class MemesUtil: NSObject {
    static func documentDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
