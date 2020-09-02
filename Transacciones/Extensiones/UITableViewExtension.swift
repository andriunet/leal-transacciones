//
//  UITableViewExtension.swift
//  Transacciones
//
//  Created by Andres Marin on 26/08/20.
//  Copyright © 2020 Andres Marin. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
    
    public enum Efecto {
        case Roll
        case IzquierdaDerecha
    }
    
    public func reloadData(efecto: Efecto) {
        self.reloadData()
        
        switch efecto {
        case .Roll:
            roll()
            break
        case .IzquierdaDerecha:
            izquierdaDerecha()
            break
        }
        
    }
    
    private func roll() {
        let cells = self.visibleCells
        
        for cell in cells {
            cell.transform = CGAffineTransform(translationX: 0, y: self.bounds.height)
        }
        
        var delayCounter = 0
        
        for cell in cells {
            UIView.animate(withDuration: 2, delay: Double(delayCounter) * 0.035, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                cell.transform = CGAffineTransform.identity
            }, completion: nil)
            delayCounter += 1
        }
    }
    
    private func izquierdaDerecha() {
        let cells = self.visibleCells        
        
        var flag = false
        
        for cell in cells {
            cell.transform = CGAffineTransform(translationX: flag ? self.bounds.width : self.bounds.width * -1, y: 0)
            flag = !flag
        }
        
        var delayCounter = 0
        
        for cell in cells {
            UIView.animate(withDuration: 2, delay: Double(delayCounter) * 0.035, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                cell.transform = CGAffineTransform.identity
            }, completion: nil)
            delayCounter += 1
        }
    }
}
