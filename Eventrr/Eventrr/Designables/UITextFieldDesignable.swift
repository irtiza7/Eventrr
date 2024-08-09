import UIKit

@IBDesignable
class UITextFieldDesignable: UITextField {
    
    // MARK: - IBInspectables
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
       didSet {
           layer.cornerRadius = cornerRadius
           layer.masksToBounds = cornerRadius > 0
       }
    }
    @IBInspectable var borderWidth: CGFloat = 0 {
       didSet {
           layer.borderWidth = borderWidth
       }
    }
    @IBInspectable var borderColor: UIColor? {
       didSet {
           layer.borderColor = borderColor?.cgColor
       }
    }
    
    // MARK: - Private Properties
    
    private let padding: UIEdgeInsets = .init(top: 0, left: 10, bottom: 0, right: -10)
    
    // MARK: - Overridden Methods
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }
}
