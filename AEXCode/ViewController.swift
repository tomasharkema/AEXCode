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
  
  @IBOutlet weak var contentView: NSView!
  
  private let parser = CodeParser()
  
  private var canvasSize: CGSize?
  
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
      size: CGSize(width: CGFloat(env.configuration.width), height: CGFloat(env.configuration.height)).downscale(initialScale: scale)
    )
    
    view.window?.setContentSize(rect.size)
    view.window?.maxSize = rect.size
    view.window?.minSize = rect.size
    view.window?.makeKeyAndOrderFront(nil)
    
    // Layers
    
    view.addSubview(contentView)
    contentView.layer?.backgroundColor = NSColor.black.cgColor
    
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
      y: view.frame.height - (CGFloat(layer.y) / scale) - (CGFloat(layer.height) / scale),
      width: CGFloat(layer.width) / scale,
      height: CGFloat(layer.height) / scale
    )
    
    newLayer.backgroundColor = NSColor.white.cgColor
    contentView.layer?.addSublayer(newLayer)
  }
}


