//
//  MealDetailViewController.swift
//  Foodsie
//
//  Created by Cons Bulaqueña on 28/05/2018.
//  Copyright © 2018 consios. All rights reserved.
//

import UIKit
import Alamofire

class MealDetailViewController : UIViewController
{
    @IBOutlet weak var quantityButtonsContainerView: UIView!
    @IBOutlet weak var mealImageView: UIImageView!
    @IBOutlet weak var mealNameLabel: UILabel!
    @IBOutlet weak var mealDecriptionLabel: UILabel!
    @IBOutlet weak var cartBarButtonItem: UIBarButtonItem! {
        didSet {
            let icon = UIImage(named: "icon_cart")
            let iconSize = CGRect(origin: CGPoint.zero, size: icon!.size)
            let iconButton = UIButton(frame: iconSize)
            iconButton.setBackgroundImage(icon, for: .normal)
            cartBarButtonItem.customView = iconButton
            if Cart.currentCart.items.count != 0 {
              self.updateCartBarButtonItemBadgeNumber()
            }
        }
    }
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    
    var meal: Meal!
    var restaurant: Restaurant!
    var quantity = 1
    


    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = cartBarButtonItem
        quantityButtonsContainerView.layer.cornerRadius = 21.0
        quantityButtonsContainerView.layer.borderColor = UIColor.lightGray.cgColor
        quantityButtonsContainerView.layer.borderWidth = 1.0
        quantityButtonsContainerView.layer.masksToBounds = true
        
        self.navigationController?.navigationBar.tintColor = UIColor.black
        title = "Meal"
        mealNameLabel.text = meal.name
        
        if let price = meal.price {
            priceLabel.text = "Php \(price)"
        }

        mealDecriptionLabel.text = meal.description
        if let imageURLString = meal.imageURL {
            let imageURL = URL(string: imageURLString)
        
            //Alamofire use to dL image
            Alamofire.request(imageURL!).response { (responseData) in
                DispatchQueue.main.async {
                    if let imageData = responseData.data {
                        self.mealImageView.image = UIImage(data: imageData)
                        
                    }
                }
            }
            
        }
        updateTotalLabel()
        quantityLabel.text = "\(quantity)"
        
    }
    func updateTotalLabel()
    {
        if let price = meal.price {
            totalLabel.text = "Php \(price * Double(quantity))"
        }
    }
    
    // MARK: - Quantity
    

    @IBAction func addQuantity(_ sender: Any)
    {
        if quantity < 99 {
            quantity += 1
            quantityLabel.text = String(quantity)
        
            updateTotalLabel()
        }
    }
    
    @IBAction func decreasedQuantity(_sender: Any)
    {
        if quantity > 0 {
            quantity -= 1
            quantityLabel.text = String(quantity)
        
            updateTotalLabel()
        }
    }
    // MARK - Add to Cart
    
    @IBAction func addToCart(_ sender: Any)
    {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        imageView.image = self.mealImageView.image
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.center = CGPoint(x: self.view.frame.width/2.0, y: self.view.frame.height - 50)
        self.view.addSubview(imageView)
        startAnimatingCartButton()
        
        
        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseOut, animations: {
            imageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
            imageView.center = CGPoint(x: self.view.frame.width - 40, y: 24)
            
        }) { (complete) in
            imageView.removeFromSuperview()
            let cartItem = CartItem(meal: self.meal, quantity: self.quantity)
            
            // Ensure restaurant = cart's restaurant
            guard let cartRestaurant = Cart.currentCart.restaurant, let currentRestaurant = self.restaurant else {
                // New cart to create
                Cart.currentCart.restaurant = self.restaurant
                Cart.currentCart.items.append(cartItem)
                self.updateCartBarButtonItemBadgeNumber()
                return
            }
            
            
            //if there's already a restaurant
            //Else, if ordered meals same restaurant. Existing cart
            if cartRestaurant.id == currentRestaurant.id {
                //check if meal is already in cart
                let itemIndex = Cart.currentCart.items.index(where: { (currentItem) -> Bool in
                    return currentItem.meal.id == cartItem.meal.id
                })
                
                if let itemIndex = itemIndex {
                    // Already added in cary
                    //Add alert want to add more same meal
                    let alertController = UIAlertController(title: "Want to add more?", message: "Your cart already had this item. Do you want to add more?", preferredStyle: .alert)
                    let sureAction = UIAlertAction(title: "Sure!", style: .default, handler: { (action) in
                        Cart.currentCart.items[itemIndex].quantity += self.quantity
                        self.startAnimatingCartButton()
                        
                    })
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    alertController.addAction(sureAction)
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    // User want to add meals don't exist in cart
                    Cart.currentCart.items.append(cartItem)
                    
                    
                }
            } else {
                //Meals not from same restaurant
                let alertController = UIAlertController(title: "Start a new Cart?", message: "You're ordering from a different restaurant. Would you like to start a new one?" , preferredStyle: .alert)
                let sureAction = UIAlertAction(title: "Sure!", style: .default, handler: { (action) in
                    //Reset cart
                
                    Cart.currentCart.reset()
                    Cart.currentCart.items.append(cartItem)
                    Cart.currentCart.restaurant = self.restaurant
                    self.startAnimatingCartButton()
                    
                })
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alertController.addAction(sureAction)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
                
            }
                self.updateCartBarButtonItemBadgeNumber()
        }
        

    }
    
    func startAnimatingCartButton()
    {
        cartBarButtonItem.tintColor = UIColor(red: 216/255.0, green: 36/255.0, blue: 46/255.0, alpha: 1)
        cartBarButtonItem.customView?.transform = CGAffineTransform(scaleX: 0, y: 0)
        cartBarButtonItem.customView?.tintColor = UIColor(red: 216/255.0, green: 36/255.0, blue: 46/255.0, alpha: 1)
        
        UIView.animate(withDuration: 1.0, delay: 0.5, usingSpringWithDamping: 0.5, initialSpringVelocity: 10, options: .curveLinear,  animations: {
            self.cartBarButtonItem.customView?.transform = .identity
        }) { (complete) in
            
            self.updateCartBarButtonItemBadgeNumber()
        }
    }
    
    func updateCartBarButtonItemBadgeNumber()
    {
        self.cartBarButtonItem.addBadge(number: Cart.currentCart.getTotalQuantity())
    }
}

//Create badge on cart

extension CAShapeLayer {
    func drawCircleAtLocation(location: CGPoint, withRadius radius: CGFloat, andColor color: UIColor, filled: Bool) {
        fillColor = filled ? color.cgColor : UIColor.white.cgColor
        strokeColor = color.cgColor
        let origin = CGPoint(x: location.x - radius, y: location.y - radius)
        path = UIBezierPath(ovalIn: CGRect(origin: origin, size: CGSize(width: radius * 2, height: radius * 2))).cgPath
    }
}


private var handle: UInt8 = 0;

extension UIBarButtonItem {
    private var badgeLayer: CAShapeLayer? {
        if let b: AnyObject = objc_getAssociatedObject(self, &handle) as AnyObject? {
            return b as? CAShapeLayer
        } else {
            return nil
        }
    }
    
    func addBadge(number: Int, withOffset offset: CGPoint = CGPoint.zero, andColor color: UIColor = UIColor.red, andFilled filled: Bool = true) {
        guard let view = self.value(forKey: "view") as? UIView else { return }
        
        badgeLayer?.removeFromSuperlayer()
        
        // Initialize Badge
        let badge = CAShapeLayer()
        let radius = CGFloat(7)
        let location = CGPoint(x: view.frame.width - (radius + offset.x), y: (radius + offset.y))
        badge.drawCircleAtLocation(location: location, withRadius: radius, andColor: color, filled: filled)
        view.layer.addSublayer(badge)
        
        // Initialiaze Badge's label
        let label = CATextLayer()
        label.string = "\(number)"
        label.alignmentMode = kCAAlignmentCenter
        label.fontSize = 11
        label.frame = CGRect(origin: CGPoint(x: location.x - 4, y: offset.y), size: CGSize(width: 8, height: 16))
        label.foregroundColor = filled ? UIColor.white.cgColor : color.cgColor
        label.backgroundColor = UIColor.clear.cgColor
        label.contentsScale = UIScreen.main.scale
        badge.addSublayer(label)
        
        // Save Badge as UIBarButtonItem property
        objc_setAssociatedObject(self, &handle, badge, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    func updateBadge(number: Int) {
        if let text = badgeLayer?.sublayers?.filter({ $0 is CATextLayer }).first as? CATextLayer {
            text.string = "\(number)"
        }
    }
    
    func removeBadge() {
        badgeLayer?.removeFromSuperlayer()
    }
}



