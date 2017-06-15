//
//  motionData.swift
//  sober-test
//
//  Created by Jon Nelson1 on 6/12/17.
//  Copyright © 2017 Jon Nelson. All rights reserved.
//

import Foundation
import Realm

private var _sharedSingletonInstance: Control!

class Control: RLMObject {
    
        dynamic var controlAcc = 0.0
        dynamic var controlGyro = 0.0

    class var shared: Control {
        if _sharedSingletonInstance == nil {
            _sharedSingletonInstance = Control()
        }
        return _sharedSingletonInstance
    }

    
}
