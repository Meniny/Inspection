/*
 Copyright © 23/04/2016 Shaps
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

import UIKit

extension UIDevice {
    
    open override func prepareInspection(with coordinator: Coordinator) {
        coordinator.appendDynamic(keyPaths: [
            "batteryMonitoringEnabled",
            "proximityMonitoringEnabled"
        ], forModel: self, in: .states)
        
        (coordinator as? SwiftCoordinator)?
            .appendEnum(keyPath: "batteryState", into: UIDeviceBatteryState.self, forModel: self, group: .general)
        
        coordinator.appendDynamic(keyPaths: [
            "batteryLevel",
        ], forModel: self, in: .general)
        
        coordinator.appendTransformed(keyPaths: ["inspection_totalMemory"], valueTransformer: { value in
            guard let value = value as? Int64 else { return nil }
            let formatter = ByteCountFormatter()
            formatter.countStyle = .memory
            return formatter.string(fromByteCount: value)
        }, forModel: self, in: .general)
        
        coordinator.appendTransformed(keyPaths: ["inspection_totalStorage"], valueTransformer: { value in
            guard let value = value as? Int64 else { return nil }
            let formatter = ByteCountFormatter()
            formatter.countStyle = .file
            return formatter.string(fromByteCount: value)
        }, forModel: self, in: .general)
        
        coordinator.appendTransformed(keyPaths: ["inspection_usedStorage"], valueTransformer: { value in
            guard let value = value as? Int64 else { return nil }
            let formatter = ByteCountFormatter()
            formatter.countStyle = .file
            return formatter.string(fromByteCount: value)
        }, forModel: self, in: .general)
        
        coordinator.appendTransformed(keyPaths: ["inspection_availableStorage"], valueTransformer: { value in
            guard let value = value as? Int64 else { return nil }
            let formatter = ByteCountFormatter()
            formatter.countStyle = .file
            return formatter.string(fromByteCount: value)
        }, forModel: self, in: .general)
        
        coordinator.appendDynamic(keyPaths: [
            "name",
            "model",
            "systemVersion"
        ], forModel: self, in: .general)
        
        super.prepareInspection(with: coordinator)
    }
    
    @objc private var inspection_usedStorage: Int64 {
        return inspection_totalStorage - inspection_availableStorage
    }
    
    @objc private var inspection_totalStorage: Int64 {
        let attributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
        return attributes?[.systemSize] as? Int64 ?? 0
    }
    
    @objc private var inspection_availableStorage: Int64 {
        let attributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
        return attributes?[.systemFreeSize] as? Int64 ?? 0
    }
    
    @objc private var inspection_totalMemory: Int64 {
        return Int64(ProcessInfo.processInfo.physicalMemory)
    }
    
}
