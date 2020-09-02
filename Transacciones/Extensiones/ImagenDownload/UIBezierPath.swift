//
//  BezierPath.swift
//  LoadingImageView
//

import UIKit

extension UIBezierPath {
  
  convenience init(semiCircleInRect rect: CGRect, inset: CGFloat) {
    self.init()
    let center = CGPoint(x: rect.width / CGFloat(2.0),
      y: rect.height / CGFloat(2.0))
    let minSize = min(rect.width, rect.height)
    let radius = minSize / CGFloat(2.0) - inset
    let PI2 = CGFloat(2.0 * Double.pi)
    self.addArc(withCenter: center, radius: radius, startAngle: CGFloat(0.0), endAngle: PI2, clockwise: true)
  }
}
