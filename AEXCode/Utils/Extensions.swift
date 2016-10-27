//
//  Extensions.swift
//  AEXCode
//
//  Created by Tomas Harkema on 14-10-16.
//  Copyright © 2016 Tomas Harkema. All rights reserved.
//

import Foundation

extension CGSize {
  static var res1920x1080: CGSize {
    return CGSize(width: 1920, height: 1080)
  }
  
  func downscale(initialScale: CGFloat) -> CGSize {
    return CGSize(width: width / initialScale, height: height / initialScale)
  }
}
