# BJDraggable
A simple protocol *(No need to subclass, no need to implement methods and properties yourself. Just drop the BJDraggable file into your project)* utilizing the powerful `UIKitDynamics` API, which makes **ANY** `UIView` draggable within a boundary view that acts as collision body, with a single method call.

<img src="./Resources/BJDraggable.gif" alt="BJDraggable Demo" width="300" height="533">

## Installation

Use `pod 'BJDraggable'`

**OR**

Drag and Drop the **BJDraggable.swift** file (Located inside the Source folder in repo.) into your Xcode project.

## Usage

- Just call the `addDraggability` method on your view and pass in a boundary view and that's it:

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    self.loginView.addDraggability(withinView: self.view)
    self.omegaView.addDraggability(withinView: self.omegaContainerView)
    self.omegaContainerView.addDraggability(withinView: self.view)
    self.signupButton.addDraggability(withinView: self.view)
}
```

- You can also add margin to your boundary view by passing in a `UIEdgeInsets` parameter:

```swift
self.loginView.addDraggability(withinView: self.view, withMargin: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
```


- To stop the dragging ability, simply call `removeDraggability` method: 

```swift
@IBAction func removeDraggabilityButtonTouched(_ sender: UIButton) {
    self.loginView.removeDraggability()
    self.omegaView.removeDraggability()
    self.omegaContainerView.removeDraggability()
    self.signupButton.removeDraggability()
}
```
**Note:** Call `removeDraggability()` in the `deinit` of your `UIViewController` or `UIView` if your think you're done with it. This does the cleanup of memory and other variables used.

## Optional Usage

- If you want the view to move to its original position (respecting its autolayout constraints) after removing draggability like in the example GIF above, set the `shouldResetViewPositionAfterRemovingDraggability` property to `true`. Default value is `false`.


- To visually highlight the boundary lines within which the drag will happen, you can make `isDraggableDebugModeEnabled` property to `true`. The effective boundary (with margins applied) will be highlighted in red color. Specifying your own color will be added in the next or subsequent commits.

## Limitations
- Currently, due to the nature of the implementation, the draggability will not work well with rounded-corner views, since invisible walls are drawn around the superview separately in the manner like `left`, `right`, `top`, `bottom` to simulate boundary.
- This could be overcome by eliminating the use of imaginary special views and instead, using real boundaries with paths. BUT this method comes with one little caveat that, the view that you're dragging will not slide against the walls, they just stick to it.

## License

This code is distributed under the terms and conditions of the [MIT license](LICENSE).
