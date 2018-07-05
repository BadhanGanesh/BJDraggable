//
//  ViewController.swift
//  BJDraggableDemo
//
//  Created by BadhanGanesh on 19/05/18.
//  Copyright © 2018 Badhan Ganesh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var draggableButton: UIButton!
    @IBOutlet weak var draggableImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.draggableButton.shouldResetViewPositionAfterRemovingDraggability = true
        self.draggableImageView.shouldResetViewPositionAfterRemovingDraggability = true                
    }
    
    @IBAction func addDraggabilityButtonTouched(_ sender: UIButton) {
        self.draggableButton.addDraggability(withinView: self.view, withMargin: .init(top: 40, left: 100, bottom: 20, right: 20))
        self.draggableImageView.addDraggability(withinView: self.view)
    }
    
    @IBAction func removeDraggabilityButtonTouched(_ sender: UIButton) {
        self.draggableButton.removeDraggability()
        self.draggableImageView.removeDraggability()
    }

}

