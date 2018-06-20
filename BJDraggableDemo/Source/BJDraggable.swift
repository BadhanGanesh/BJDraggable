//
//  BJDraggable
//  Created by Badhan Ganesh on 28-05-2018
//

// This code is distributed under the terms and conditions of the MIT license.

// Copyright © 2018 Badhan Ganesh
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

var kReferenceViewKey: String = "ReferenceViewKey"
var kDynamicAnimatorKey: String = "DynamicAnimatorKey"
var kAttachmentBehaviourKey: String = "AttachmentBehaviourKey"
var kPanGestureKey: String = "PanGestureKey"
var kResetPositionKey: String = "ResetPositionKey"

///A simple protocol *(No need to implement methods and properties yourself. Just drop-in the BJDraggable file to your project and all done)* utilizing the powerful `UIKitDynamics` API, which makes **ANY** `UIView` draggable within a boundary view that acts as collision body, with a single method call.
@objc protocol BJDraggable: class {
    
    /**
     Gives you the power to drag your `UIView` anywhere within a specified view, and collide within its bounds.
     - parameter referenceView: The boundary view which acts as a wall, and your view will collide with it and would never fall out of bounds hopefully. **Note that the reference view should contain the view that you're trying to add draggability to in its view hierarchy. The app would crash otherwise.**
     */
    @objc func addDraggability(withinView referenceView: UIView)
    
    /**
     This single method call will give you the power to drag your `UIView` anywhere within a specified view, and collide within its bounds.
     - parameter referenceView: This is the boundary view which acts as a wall, and your view will collide with it and would never fall out of bounds hopefully. **Note that the reference view should contain the view that you're trying to add draggability to in its view hierarchy. The app would crash otherwise.**
     - parameter insets: If you want to make the boundary to be offset positively or negatively, you can specify that here. This is nothing but a margin for the boundary.
     */
    @objc func addDraggability(withinView referenceView: UIView, withMargin insets:UIEdgeInsets)
    
    /**
     Removes the power from you, to drag the view in question
    */
    @objc func removeDraggability()
    
}


///Implementation of `BJDraggable` protocol
extension UIView: BJDraggable {
    
    public var shouldResetViewPositionAfterRemovingDraggability: Bool {
        get {
            let getValue = (objc_getAssociatedObject(self, &kResetPositionKey) as? Bool)
            return getValue == nil ? false : getValue!
        }
        set {
            objc_setAssociatedObject(self, &kResetPositionKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            self.translatesAutoresizingMaskIntoConstraints = !newValue
        }
    }
    
    fileprivate var referenceView: UIView? {
        get {
            return objc_getAssociatedObject(self, &kReferenceViewKey) as? UIView
        }
        set {
            objc_setAssociatedObject(self, &kReferenceViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    fileprivate var animator: UIDynamicAnimator? {
        get {
            return objc_getAssociatedObject(self, &kDynamicAnimatorKey) as? UIDynamicAnimator
        }
        set {
            objc_setAssociatedObject(self, &kDynamicAnimatorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    fileprivate var attachmentBehaviour: UIAttachmentBehavior? {
        get {
            return objc_getAssociatedObject(self, &kAttachmentBehaviourKey) as? UIAttachmentBehavior
        }
        set {
            objc_setAssociatedObject(self, &kAttachmentBehaviourKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    fileprivate var panGestureRecognizer: UIPanGestureRecognizer? {
        get {
            return objc_getAssociatedObject(self, &kPanGestureKey) as? UIPanGestureRecognizer
        }
        set {
            objc_setAssociatedObject(self, &kPanGestureKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    final func addDraggability(withinView referenceView: UIView) {
        self.addDraggability(withinView: referenceView, withMargin: UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0))
    }
    
    final func addDraggability(withinView referenceView: UIView, withMargin insets:UIEdgeInsets) {
        
        //We check if we had already added the drag power to view. If yes, we return and do nothing.
        guard self.animator == nil else { return }
        
        //Important step. Pan gesture recognizer will not work without this being true.
        self.isUserInteractionEnabled = true
        
        let panGestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(panGestureHandler(_:)))        
        self.addGestureRecognizer(panGestureRecognizer)
        
        let attachmentAnchorPoint = self.center
        
        //See `panGestureHandler` method for attachmentBehaviour usage.
        let attachmentBehaviour = UIAttachmentBehavior.init(item: self, attachedToAnchor: attachmentAnchorPoint)
        attachmentBehaviour.frequency = 0
        attachmentBehaviour.damping = 0
        
        let collisionBehaviour = UICollisionBehavior.init(items: [self])
        collisionBehaviour.translatesReferenceBoundsIntoBoundary = true
        collisionBehaviour.collisionMode = .boundaries
        collisionBehaviour.setTranslatesReferenceBoundsIntoBoundary(with: insets)
        
        let animator = UIDynamicAnimator.init(referenceView: referenceView)
        animator.addBehavior(attachmentBehaviour)
        animator.addBehavior(collisionBehaviour)
        
        //Store these variables using `objc_setAssociatedObject` for use in other places, as if these are instance variables.
        self.animator = animator
        self.referenceView = referenceView
        self.attachmentBehaviour = attachmentBehaviour
        self.panGestureRecognizer = panGestureRecognizer
    }
    
    final func removeDraggability() {
        if let recognizer = self.panGestureRecognizer { self.removeGestureRecognizer(recognizer) }
        self.translatesAutoresizingMaskIntoConstraints = !self.shouldResetViewPositionAfterRemovingDraggability
        self.animator?.removeAllBehaviors()
        
        self.referenceView = nil
        self.attachmentBehaviour = nil
        self.animator = nil
        self.panGestureRecognizer = nil
    }
    
    @objc final func panGestureHandler(_ gesture: UIPanGestureRecognizer) {
        guard let referenceView = self.referenceView else { return }
        let touchPoint = gesture.location(in: referenceView)
        self.attachmentBehaviour?.anchorPoint = touchPoint
    }
    
}
