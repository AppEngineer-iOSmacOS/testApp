//
//  Help.swift
//  goJekTest
//
//  Created by Nikolay S on 19.10.2019.
//  Copyright © 2019 Nikolay S. All rights reserved.
//

import Foundation
import UIKit
import Dodo

extension UIViewController {
    
    func showTopDo(_ showText:String, hexColor:String) {
        
        func showDodo() {
            view.dodo.topAnchor = view.safeAreaLayoutGuide.topAnchor
            view.dodo.bottomAnchor = view.safeAreaLayoutGuide.bottomAnchor
            view.dodo.style.bar.marginToSuperview = CGSize(width: 5, height: 40)
            view.dodo.style.bar.backgroundColor = DodoColor.fromHexString(hexColor)
            self.view.dodo.show(showText)
            hideDodo()
        }
        
        func hideDodo() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.view.dodo.hide()
            }
        }
        showDodo()
    }
}

extension UIView {
    func layerGradient() {
        for layer: CALayer in self.layer.sublayers! {
            if layer is CAGradientLayer {
                layer.removeFromSuperlayer()
                }
           }
        let colorTop =  UIColor.white
        let colorBottom = UIColor(red: 80.0/255.0, green: 227.0/255.0, blue: 194.0/255.0, alpha: 0.28).cgColor
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.bounds
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    // hide keyboard
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        self.endEditing(true)
    }
    
    typealias SwipeResponseClosure = (_ swipe: UISwipeGestureRecognizer) -> Void
    private struct ClosureStorage {
        static var SwipeClosureStorage: [UISwipeGestureRecognizer : SwipeResponseClosure] = [:]
    }
    
    func addLeftSwipeGestureRecognizerWithResponder(responder: @escaping SwipeResponseClosure) {
        self.addLeftSwipeGestureRecognizerForNumberOfTouches(numberOfTouches: 1, withResponder: responder)
    }
    func addLeftSwipeGestureRecognizerForNumberOfTouches(numberOfTouches: Int, withResponder responder: @escaping SwipeResponseClosure) {
        self.addSwipeGestureRecognizerForNumberOfTouches(numberOfTouches: numberOfTouches, forSwipeDirection: .left, withResponder: responder)
    }
    
    func addRightSwipeGestureRecognizerWithResponder(responder: @escaping SwipeResponseClosure) {
        self.addRightSwipeGestureRecognizerForNumberOfTouches(numberOfTouches: 1, withResponder: responder)
    }
    func addRightSwipeGestureRecognizerForNumberOfTouches(numberOfTouches: Int, withResponder responder: @escaping SwipeResponseClosure) {
        self.addSwipeGestureRecognizerForNumberOfTouches(numberOfTouches: numberOfTouches, forSwipeDirection: .right, withResponder: responder)
    }
    
    
    func addSwipeGestureRecognizerForNumberOfTouches(numberOfTouches: Int, forSwipeDirection swipeDirection: UISwipeGestureRecognizer.Direction, withResponder responder: @escaping SwipeResponseClosure) {
        let swipe = UISwipeGestureRecognizer()
        swipe.direction = swipeDirection
        swipe.numberOfTouchesRequired = numberOfTouches
        swipe.addTarget(self, action: #selector (handleSwipe))
        self.addGestureRecognizer(swipe)
        
        ClosureStorage.SwipeClosureStorage[swipe] = responder
    }
    
    @objc func handleSwipe(sender: UISwipeGestureRecognizer) {
        if let closureForSwipe = ClosureStorage.SwipeClosureStorage[sender] {
            closureForSwipe(sender)
        }
    }
}
extension String {
    
    enum RegularExpressions: String {
           case phone = "^\\s*(?:\\+?(\\d{1,3}))?([-. (]*(\\d{3})[-. )]*)?((\\d{3})[-. ]*(\\d{2,4})(?:[-.x ]*(\\d+))?)\\s*$"
       }
    
        func isValid(regex: RegularExpressions) -> Bool {
           return isValid(regex: regex.rawValue)
       }
       
       func isValid(regex: String) -> Bool {
           let matches = range(of: regex, options: .regularExpression)
           return matches != nil
       }

    
       func onlyDigits() -> String {
           let filtredUnicodeScalars = unicodeScalars.filter{CharacterSet.decimalDigits.contains($0)}
           return String(String.UnicodeScalarView(filtredUnicodeScalars))
       }
    
    func makeAColl() {
        if isValid(regex: .phone) {
            if let url = URL(string: "tel://\(self.onlyDigits())"), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
    
    var isPhoneNumber: Bool {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: self, options: [], range: NSMakeRange(0, self.count))
            if let res = matches.first {
                return res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == self.count
            } else {
                return false
            }
        } catch {
            return false
        }
    }
    
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
}
