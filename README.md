# BJDraggable
A simple protocol *(No need to subclass, no need to implement methods and properties yourself. Just drop-in the BJDraggable file to your project and all done)* utilizing the powerful `UIKitDynamics` API, which makes **ANY** `UIView` draggable within a boundary view that acts as collision body, with a single method call.

![BJDraggable Demo](https://media.giphy.com/media/yvXWwDtvnhLN7z45vE/giphy.gif)


## Usage

- Drag and Drop the **BJDraggable.swift** file (Located inside the Source folder) into your Xcode project.


- Just call the `addDraggability` method on your view and pass in a boundary view and that's it:

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    self.draggableButton.addDraggability(withinView: self.view)
    self.draggableImageView.addDraggability(withinView: self.view)
}
```


- You can also add margin to your boundary view by passing in a `UIEdgeInsets` parameter:

```swift
self.draggableImageView.addDraggability(withinView: self.view, withMargin: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
```


- To stop the dragging ability, simply call `removeDraggability` method: 

```swift
@IBAction func removeDraggabilityButtonTouched(_ sender: UIButton) {
    self.draggableButton.removeDraggability()
    self.draggableImageView.removeDraggability()
}
```

## Limitation
The dragging mechanism contains one little caveat where the view when dragged against the boundary's edges, it will not slide against it. Instead, the view will stick to it. This one will be addressed and fixed soon.


## License

This code is distributed under the terms and conditions of the [MIT license](LICENSE).
