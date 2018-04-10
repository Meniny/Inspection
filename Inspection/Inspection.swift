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

import Foundation

struct InspectionAssociationKey {
    static var Inspection: UInt8 = 1
}

/// The primary class where Inspection can be activated/disabled
public final class Inspection: NSObject {
    
    /// Returns true if Inspection is already being presented -- this is to prevent
    public static var alreadyPresented: Bool = false
    internal var screenshot: UIImage?
    
    /// Enables/disables Inspection
    public var enabled: Bool = false {
        didSet {
            if enabled {
                configure(options: options)
            } else {
                activationController?.unregister()
            }
        }
    }
    
    /// The status bar style of the underlying app -- used to reset values when Inspection is deactivated
    var previousStatusBarStyle = UIStatusBarStyle.default
    /// The status bar hidden state of the underlying app -- used to reset values when Inspection is deactivated
    var previousStatusBarHidden = false
    var supportedOrientations = UIInterfaceOrientationMask.all
    unowned var inspectioningWindow: UIWindow // since this is the app's window, we don't want to retain it!
    
    fileprivate var activationController: InspectionActivating?
    fileprivate var volumeController: VolumeController?
    fileprivate(set) var options = InspectionOptions()
    fileprivate(set) var window: UIWindow? // this is the Inspection Overlay window, so we have to retain it!
    
    init(window: UIWindow) {
        inspectioningWindow = window
        super.init()
    }
    
    /**
     Presents Inspection
     */
    public func present() {
        guard enabled else {
            print("Inspection is disabled!")
            return
        }
        
        guard !Inspection.alreadyPresented else {
            print("Inspection is already being presented!")
            return
        }
        
        supportedOrientations = inspectioningWindow.rootViewController?.topViewController().supportedInterfaceOrientations ?? .all
        previousStatusBarStyle = UIApplication.shared.statusBarStyle
        previousStatusBarHidden = UIApplication.shared.isStatusBarHidden
        
        inspectioningWindow.endEditing(true)
        
        window = UIWindow()
        window?.backgroundColor = UIColor.clear
        window?.frame = inspectioningWindow.bounds
        window?.windowLevel = UIWindowLevelNormal
        window?.alpha = 0
        
        window?.rootViewController = InspectionViewController(inspection: self)
        window?.makeKeyAndVisible()
        
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.window?.alpha = 1
        }) 
        
        Inspection.alreadyPresented = true
    }
    
    /**
     Dismisses Inspection
     */
    public func dismiss() {
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.window?.alpha = 0
        }, completion: { (_) -> Void in
            if let controller = self.window?.rootViewController?.presentedViewController {
                controller.presentingViewController?.dismiss(animated: false, completion: nil)
            }
            
            self.inspectioningWindow.makeKeyAndVisible()
            self.window?.rootViewController?.view.removeFromSuperview()
            self.window?.rootViewController = nil
            self.window = nil
            self.screenshot = nil
            
            Inspection.alreadyPresented = false
        }) 
    }
    
    /**
     On iOS 10+ call this from your rootViewController. Otherwise use your AppDelegate. This will only activate/deactivate Inspection when activationMode == .Shake or the app is being run from the Simulator. On iOS 10+ this will also dismiss the Inspectors view when visible.
     - parameter motion: The motion events to handle
     */
    public func handleShake(_ motion: UIEventSubtype) {
        if motion != .motionShake || !enabled {
            return
        }
        
        if (options.activationMode == .auto && UIDevice.current.isSimulator)
            || options.activationMode == .shake {
            handleActivation()
        }
    }
    
    private func handleActivation() {
        if let nav = window?.rootViewController?.presentedViewController as? UINavigationController {
            let inspectors = nav.viewControllers.compactMap { $0 as? InspectionInspectorViewController }

            if inspectors.first(where: { $0.tableView.isEditing }) == nil {
                nav.dismiss(animated: true, completion: nil)
            }
            
            return
        }
        
        if Inspection.alreadyPresented {
            inspectioningWindow.inspection.dismiss()
        } else {
            inspectioningWindow.inspection.present()
        }
    }
    
    /**
     Enables Inspection with the specified options
     
     - parameter options: The options to use for configuring Inspection
     */
    public func enable(options: (_ options: InspectionOptions) -> Void) {
        let opts = InspectionOptions()
        options(opts)
        self.options = opts
        enabled = true
    }
    
    fileprivate func configure(options: InspectionOptions) {
        self.options = options
        
        if options.activationMode == .auto && !UIDevice.current.isSimulator {
            activationController = VolumeController(inspection: self, handleActivation: handleActivation)
        }
    }
    
}
