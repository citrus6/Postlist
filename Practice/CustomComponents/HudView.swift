//
//  HudView.swift
//  Practice
//
//  Created by Виктор on 31.07.2018.
//  Copyright © 2018 Victor Yanuchkov. All rights reserved.
//

import Foundation

import Foundation
import UIKit

class HudView: UIView {
    class func hud(inView view: UIView, animated: Bool) ->HudView {
        let hudView = HudView(frame: view.bounds)
        hudView.isOpaque = false
        
        view.addSubview(hudView)
        view.isUserInteractionEnabled = false
        
        hudView.show(animated: animated)
        return hudView
    }
    
    override func draw(_ rect: CGRect) {
        let boxWidth: CGFloat = 96
        let boxHeight: CGFloat = 96
        
        let boxRect = CGRect(x: round((bounds.size.width - boxWidth) / 2), y: round((bounds.size.height - boxHeight) / 2), width: boxWidth, height: boxHeight)
        
        let roundedRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 10)
        UIColor(white: 0.85, alpha: 0.8).setFill()
        roundedRect.fill()
        
        let image = #imageLiteral(resourceName: "checkmark_ios")
        let imagePoint = CGPoint(x: center.x - round(image.size.width / 2), y: center.y - round(image.size.height) + boxHeight / 4)
        image.draw(at: imagePoint)
    }
    
    func show(animated: Bool) {
        if animated {
            alpha = 0
            transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            UIView.animate(withDuration: 0.3, animations: {
                self.alpha = 1
                self.transform = CGAffineTransform.identity
            }, completion: nil)
        }
    }
}
