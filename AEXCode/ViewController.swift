//
//  ViewController.swift
//  AEXCode
//
//  Created by Tomas Harkema on 13-10-16.
//  Copyright © 2016 Tomas Harkema. All rights reserved.
//

import Cocoa
import Promissum

final class ViewController: NSViewController {
  
  private let parser = CodeParser()
  
  private let containerView = NSView()
  
  override func viewWillAppear() {
    super.viewWillAppear()
    
    parser.run(file: "default")
      .then { [weak self] in
        guard let this = self else { return }
        
        print("CONFIGURATION: \($0)")
        this.render(env: $0)
      }
      .trap {
        print("ERROR: \($0)")
    }
  }
  
  private func render(env: Environment) {
    let scale = NSScreen.main()?.backingScaleFactor ?? 1
    
    let rect = CGRect(
      origin: view.frame.origin,
      size: CGSize(width: CGFloat(env.configuration.width) / scale, height: CGFloat(env.configuration.height) / scale)
    )
    
    view.window?.setFrame(rect, display: true)
    view.window?.minSize = rect.size
    view.window?.maxSize = rect.size
    
    // Layers
    
    containerView.frame = rect
    view.addSubview(containerView)
    containerView.layer?.backgroundColor = NSColor.black.cgColor
    
    env.layers.forEach {
      self.renderLayer(layer: $0)
    }
  }
  
  private func renderLayer(layer: Layer) {
    let scale = NSScreen.main()?.backingScaleFactor ?? 1
    print("RENDER LAYER")
    
    let newLayer = CALayer()
    newLayer.frame = CGRect(
      x: CGFloat(layer.x) / scale,
      y: view.frame.height - CGFloat(layer.y) / scale,
      width: CGFloat(layer.width) / scale,
      height: CGFloat(layer.height) / scale
    )
    
    newLayer.backgroundColor = NSColor.white.cgColor
    containerView.layer?.addSublayer(newLayer)
  }
}

