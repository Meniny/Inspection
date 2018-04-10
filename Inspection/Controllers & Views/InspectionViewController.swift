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

final class InspectionViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    deinit {
        if let ob = observer {
            NotificationCenter.default.removeObserver(ob)
        }
    }
    
    private var observer: Any?
    unowned var inspection: Inspection
    
    init(inspection: Inspection) {
        self.inspection = inspection
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate var models = [UIView]()
    
    internal lazy var inspectionView: InspectionOverlayView = {
        let view = InspectionLayoutOverlayView(theme: inspection.options.theme)
        view.delegate = self
        return view
    }()
    
    lazy var attributesButton: InspectionButton = {
        let button = InspectionButton(theme: inspection.options.theme)
        button.addTarget(self, action: #selector(showInspectors), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(inspectionView, constraints: [
            equal(\.leadingAnchor), equal(\.trailingAnchor),
            equal(\.topAnchor), equal(\.bottomAnchor)
        ])
        
        parseView(inspection.inspectioningWindow)
        models.reverse()
        
        view.backgroundColor = .clear
        
        view.addSubview(attributesButton, constraints: [
            equal(\.centerXAnchor)
        ])
        
        bottomLayoutGuide.bottomAnchor.constraint(equalTo: attributesButton.bottomAnchor, constant: 30).isActive = true
        setAttributesButton(hidden: true, animated: false)
        
        inspectionView.refresh()
    }
    
    private func setAttributesButton(hidden: Bool, animated: Bool) {
        let transform = CGAffineTransform(translationX: 0, y: 120)
        
        guard animated else {
            attributesButton.transform = hidden ? transform : .identity
            return
        }
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .beginFromCurrentState, animations: {
            self.attributesButton.transform = hidden ? transform : .identity
        }, completion: nil)
    }
    
    private var feedbackGenerator: Any?
    
    @available(iOS 10.0, *)
    private func haptic() -> UIImpactFeedbackGenerator? {
        return feedbackGenerator as? UIImpactFeedbackGenerator
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animateAlongsideTransition(in: view, animation: { _ in
            self.inspectionView.refresh()
        }, completion: nil)
    }
    
    private func parseView(_ view: UIView) {
        for view in view.subviews {
            if view.isVisibleInOverlay(options: inspection.options) {
                models.append(view)
            }
            
            if view.subviews.count > 0 {
                parseView(view)
            }
        }
    }
    
    fileprivate func updateBackgroundColor(alpha: CGFloat) {
        view.backgroundColor = inspection.options.theme.overlayBackgroundColor.withAlphaComponent(alpha)
        
        let animation = CATransition()
        animation.type = kCATransitionFade
        animation.duration = 0.1
        view.layer.add(animation, forKey: "fade")
    }
    
    @objc private func showInspectors() {
        guard let index = inspectionView.indexesForSelectedItems.last else { return }
        let model = models[index]
        presentInspectorsForModel(model)
    }
    
    fileprivate func presentInspectorsForModel(_ model: Inspectionable) {
        let rect = inspection.inspectioningWindow.bounds

        var defaults: [String: Bool] = [:]
        Group.all.forEach {
            defaults[$0.title] = $0.isExpandedByDefault
        }
        UserDefaults.standard.register(defaults: defaults)
        
        inspection.screenshot = ImageRenderer(size: CGSize(width: rect.width, height: rect.height)).image { [unowned self] context in
            let rect = context.format.bounds
            self.inspection.inspectioningWindow.drawHierarchy(in: rect, afterScreenUpdates: true)
            
            self.attributesButton.isHidden = true
            self.inspection.window?.drawHierarchy(in: rect, afterScreenUpdates: true)
            self.attributesButton.isHidden = false
        }
        
        if let model = model as? UIView {
            let inspector = InspectionInspectorViewController(inspection: inspection, model: model)
            let nav = UINavigationController(rootViewController: inspector)
            
            definesPresentationContext = true
            nav.view.frame = view.bounds
            
            presentModal(nav, from: model, animated: true, completion: nil)
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return inspection.supportedOrientations
    }
    
    override var prefersStatusBarHidden: Bool {
        return inspection.previousStatusBarHidden
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return inspection.previousStatusBarStyle
    }
    
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        // iOS 10 now requires device motion handlers to be on a UIViewController
        inspection.handleShake(motion)
    }
    
}

extension InspectionViewController: InspectionOverlayViewDelegate {
    
    func viewModels(in overlayView: InspectionOverlayView) -> [ViewModel] {
        return models as [ViewModel]
    }
    
    func showInsectorFor(viewModel: ViewModel, in overlayView: InspectionOverlayView) {
        presentInspectorsForModel(viewModel)
    }
    
    func didSelect(viewModel: ViewModel, in overlayView: InspectionOverlayView) {
        
    }
    
    func didBegin(in overlayView: InspectionOverlayView) {
        setAttributesButton(hidden: true, animated: true)
    }
    
    func didEnd(in overlayView: InspectionOverlayView) {
        let hidden = inspectionView.indexesForSelectedItems.count == 0
        setAttributesButton(hidden: hidden, animated: true)
    }
    
}
