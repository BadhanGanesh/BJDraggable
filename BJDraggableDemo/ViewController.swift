//
//  ViewController.swift
//  BJDraggableDemo
//
//  Created by BadhanGanesh on 19/05/18.
//  Copyright © 2018 Badhan Ganesh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var omegaView: UIView!
    @IBOutlet weak var omegaContainerView: UIView!
    @IBOutlet weak var signupButton: UIButton!
    
    fileprivate func configureDraggabilities() {
        self.omegaView.shouldResetViewPositionAfterRemovingDraggability = true
        self.loginView.shouldResetViewPositionAfterRemovingDraggability = true
        self.omegaContainerView.shouldResetViewPositionAfterRemovingDraggability = true
        self.signupButton.shouldResetViewPositionAfterRemovingDraggability = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDraggabilities()
    }
    
    @IBAction func addDraggabilityButtonTouched(_ sender: UIButton) {
        self.loginView.addDraggability(withinView: self.view)
        self.omegaView.addDraggability(withinView: self.omegaContainerView)
        self.omegaContainerView.addDraggability(withinView: self.view)
        self.signupButton.addDraggability(withinView: self.view)
    }
    
    @IBAction func removeDraggabilityButtonTouched(_ sender: UIButton) {
        self.loginView.removeDraggability()
        self.omegaView.removeDraggability()
        self.omegaContainerView.removeDraggability()
        self.signupButton.removeDraggability()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}

extension UITextField {
    open override func awakeFromNib() {
        self.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0)
    }
}
