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

///A simple protocol *(No need to implement methods and properties yourself. Just drop-in the BJDraggable file to your project and all done)* utilizing the powerful `UIKitDynamics` API, which makes **ANY** `UIView` draggable within a boundary view that acts as collision body, with a single method call.
@objc protocol BJDraggable: class {
    
    /////Properties
    var referenceView:UIView? { get set }
    var animator:UIDynamicAnimator? { get set }
    var attachmentBehaviour:UIAttachmentBehavior? { get set }
    
    /////Methods
    func panGestureHandler(_ gesture:UIPanGestureRecognizer)
    @objc func addDraggability(withinView referenceView: UIView)
    @objc func addDraggability(withinView referenceView: UIView, withMargin insets:UIEdgeInsets)
    @objc func removeDraggability()
    
}


///This extension of UIView implements the `BJDraggable` protocol's stubs
extension UIView: BJDraggable {
    
    var referenceView: UIView? {
        get {
            return objc_getAssociatedObject(self, &kReferenceViewKey) as? UIView
        }
        set {
            objc_setAssociatedObject(self, &kReferenceViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var animator: UIDynamicAnimator? {
        get {
            return objc_getAssociatedObject(self, &kDynamicAnimatorKey) as? UIDynamicAnimator
        }
        set {
            objc_setAssociatedObject(self, &kDynamicAnimatorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var attachmentBehaviour: UIAttachmentBehavior? {
        get {
            return objc_getAssociatedObject(self, &kAttachmentBehaviourKey) as? UIAttachmentBehavior
        }
        set {
            objc_setAssociatedObject(self, &kAttachmentBehaviourKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var panGestureRecognizer: UIPanGestureRecognizer? {
        get {
            return objc_getAssociatedObject(self, &kPanGestureKey) as? UIPanGestureRecognizer
        }
        set {
            objc_setAssociatedObject(self, &kPanGestureKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /**
     Gives you the power to drag your `UIView` anywhere within a specified view, and collide within its bounds.
     - parameter referenceView: The boundary view which acts as a wall, and your view will collide with it and would never fall out of bounds hopefully. **Note that the reference view should contain the view that you're trying to add draggability to in its view hierarchy. The app would crash otherwise.**
     */
    final func addDraggability(withinView referenceView: UIView) {
        self.addDraggability(withinView: referenceView, withMargin: UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0))
    }
    
    /**
     This single method call will give you the power to drag your `UIView` anywhere within a specified view, and collide within its bounds.
     - parameter referenceView: This is the boundary view which acts as a wall, and your view will collide with it and would never fall out of bounds hopefully. **Note that the reference view should contain the view that you're trying to add draggability to in its view hierarchy. The app would crash otherwise.**
     - parameter insets: If you want to make the boundary to be offset positively or negatively, you can specify that here. This is nothing but a margin for the boundary.
     */
    final func addDraggability(withinView referenceView: UIView, withMargin insets:UIEdgeInsets) {
        
        //Important step. Pan gesture recognizer will not work without this being true.
        self.isUserInteractionEnabled = true
        
        //Basic thing taken care first. Add pan gesture recognizer to `self`.
        let panGestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(panGestureHandler(_:)))        
        self.addGestureRecognizer(panGestureRecognizer)
        
        //Create an attachmentBehaviour for attaching 'self' to a specific point while dragging. See `panGestureHandler` method for its usage.
        let point = self.center
        let attachmentBehaviour = UIAttachmentBehavior.init(item: self, attachedToAnchor: point)
        attachmentBehaviour.frequency = 0
        attachmentBehaviour.damping = 0
        
        //Create a collision behaviour that makes the view ('self') resistant against the walls of the reference view. This will make the view collide against the boundary.
        let collisionBehaviour = UICollisionBehavior.init(items: [self])
        collisionBehaviour.translatesReferenceBoundsIntoBoundary = true
        collisionBehaviour.collisionMode = .boundaries
        collisionBehaviour.setTranslatesReferenceBoundsIntoBoundary(with: insets)
        
        //This `UIDynamicAnimator` object governs and manages various behaviours we add to it. It takes the behaviours and animates the view according to the rules we specified in each behaviour.
        let animator = UIDynamicAnimator.init(referenceView: referenceView)
        animator.addBehavior(attachmentBehaviour)
        animator.addBehavior(collisionBehaviour)
        
        //Store these variables using `objc_setAssociatedObject` for use in other places, as if these are instance variables.
        self.animator = animator
        self.referenceView = referenceView
        self.attachmentBehaviour = attachmentBehaviour
        self.panGestureRecognizer = panGestureRecognizer
    }
    
    ///Removes the power from you, to drag the view in question
    final func removeDraggability() {
        if let recognizer = self.panGestureRecognizer { self.removeGestureRecognizer(recognizer) }
        self.animator?.removeAllBehaviors()
        
        //Nil out vars for memory safety and for removing the association, so that when we call `addDraggability` again, we will be creating new instances.
        self.referenceView = nil
        self.attachmentBehaviour = nil
        self.animator = nil
        self.panGestureRecognizer = nil
    }
    
    ///Supposed to be an internal handler method that handles the pan gesture recognizer.
    final func panGestureHandler(_ gesture: UIPanGestureRecognizer) {
        guard let referenceView = self.referenceView else { return }
        let touchPoint = gesture.location(in: referenceView)
        self.attachmentBehaviour?.anchorPoint = touchPoint
    }
    
}
