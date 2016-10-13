//
//  Layer.swift
//  AEXCode
//
//  Created by Tomas Harkema on 13-10-16.
//  Copyright © 2016 Tomas Harkema. All rights reserved.
//

import Foundation
import JavaScriptCore

@objc protocol LayerJsExport: JSExport {
  var x: NSNumber {get set}
  var y: NSNumber {get set}
  var width: NSNumber {get set}
  var height: NSNumber {get set}
  var backgroundColor: String {get set}
}

class AEXScriptClass {

  @objc class JSLayer: NSObject, LayerJsExport {
    dynamic var x: NSNumber
    dynamic var y: NSNumber
    dynamic var width: NSNumber
    dynamic var height: NSNumber
    dynamic var backgroundColor: String
    
    init(x: NSNumber, y: NSNumber, width: NSNumber, height: NSNumber, backgroundColor: String) {
      self.x = x
      self.y = y
      self.width = width
      self.height = height
      self.backgroundColor = backgroundColor
    }

    init?(dict: NSDictionary) {
      guard let x = dict["x"] as? NSNumber else {
        return nil
      }
      guard let y = dict["y"] as? NSNumber else {
        return nil
      }
      guard let width = dict["width"] as? NSNumber else {
        return nil
      }
      guard let height = dict["height"] as? NSNumber else {
        return nil
      }
      guard let backgroundColor = dict["backgroundColor"] as? String else {
        return nil
      }
      
      self.x = x
      self.y = y
      self.width = width
      self.height = height
      self.backgroundColor = backgroundColor
    }
    
    func toLayer() -> Layer {
      return Layer(x: x.floatValue, y: y.floatValue, width: width.floatValue, height: height.floatValue, backgroundColor: backgroundColor)
    }
  }
}

struct Layer {
  let x: Float
  let y: Float
  let width: Float
  let height: Float
  let backgroundColor: String
}
