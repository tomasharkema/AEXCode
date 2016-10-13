 //
//  CodeParser.swift
//  AEXCode
//
//  Created by Tomas Harkema on 13-10-16.
//  Copyright © 2016 Tomas Harkema. All rights reserved.
//

import Foundation
import JavaScriptCore
import Promissum

enum ParseResult<ValueType> {
  case result(ValueType)
  case error(ParseError)
  
  var error: ParseError? {
    switch self {
    case .error(let err):
      return err
    case _:
      return nil
    }
  }
  
  var value: ValueType? {
    switch self {
    case .result(let value):
      return value
    case _:
      return nil
    }
  }
}

enum ParseError: Error {
  case jsError(value: JSValue)
  case propertyOfWrongType(object: String, propertyName: String, expected: String, actual: String)
  case propertyMissing(object: String, propertyName: String)
  case valueMissing(name: String)
  case wrongType(actual: String, expected: String)
  case unknownError(String)
}

struct Configuration {
  let width: Float
  let height: Float
  
  static func fromJsValue(jsValue: JSValue) -> ParseResult<Configuration> {
    guard let dict = jsValue.toDictionary() else {
      return .error(.wrongType(actual: "", expected: "Object"))
    }
    
    guard let widthValue = dict["width"] else {
      return .error(.propertyMissing(object: "Configuration", propertyName: "width"))
    }
    
    guard let width = widthValue as? Float else {
      return .error(.propertyOfWrongType(object: "Configuration", propertyName: "width", expected: "Float", actual: String(describing: type(of: widthValue))))
    }
    
    guard let heightValue = dict["height"] else {
      return .error(.propertyMissing(object: "Configuration", propertyName: "height"))
    }
    
    guard let height = heightValue as? Float else {
      return .error(.propertyOfWrongType(object: "Configuration", propertyName: "height", expected: "Float", actual: String(describing: type(of: widthValue))))
    }
    
    return .result(Configuration(width: width, height: height))
  }
}
 
struct Environment {
  let configuration: Configuration
  let layers: [Layer]
}

final class CodeParser {
  private let queue = DispatchQueue(label: "JavascriptQueue")
  
  private func parseConfiguration(context: JSContext) -> ParseResult<Configuration> {
    let configurationValue = context.objectForKeyedSubscript("configuration")
    
    let configuration = configurationValue.flatMap { Configuration.fromJsValue(jsValue: $0) }
    
    return configuration ?? .error(.valueMissing(name: "configuration"))
  }
  
  private func parseLayers(context: JSContext) -> ParseResult<[Layer]> {
    guard let layersValue = context.objectForKeyedSubscript("layers").toArray() else {
      return .error(.valueMissing(name: "layers"))
    }
    
    let layers = layersValue.enumerated().map { (i, value) -> ParseResult<Layer> in
      let result = value as? AEXScriptClass.JSLayer ?? (value as? NSDictionary).flatMap { dict in
        AEXScriptClass.JSLayer.init(dict: dict)
      }
      
      return result.map {
        ParseResult.result($0.toLayer())
      } ?? ParseResult.error(.unknownError("some wrong entity \(i)"))
    }
    
    let errors = layers.filter {
      $0.error != nil
    }
    
    guard errors.isEmpty else {
      return .error(.valueMissing(name: "configuration"))
    }
    
    return .result(layers.map { $0.value! })
  }
  
  private func parseJavascript(context: JSContext, js: [String]) -> Promise<Environment, ParseError> {
    let promiseSource = PromiseSource<Environment, ParseError>()
    
    queue.async {
      
      context.exceptionHandler = {
        promiseSource.reject(.jsError(value: $0.1!))
      }
      
      context.setObject(AEXScriptClass.JSLayer.self, forKeyedSubscript: "Layer" as (NSCopying & NSObjectProtocol)!)
      
      // INSERT CODE
      js.forEach { context.evaluateScript($0) }
      
      // CONFIGURATION
      let confResult = self.parseConfiguration(context: context)
      guard case .result(let configuration) = confResult else {
        promiseSource.reject(confResult.error!)
        return
      }
      
      let layersResult = self.parseLayers(context: context)
      guard case .result(let layers) = layersResult else {
        promiseSource.reject(confResult.error!)
        return
      }
      
      promiseSource.resolve(Environment(configuration: configuration, layers: layers))
    }
    
    return promiseSource.promise
  }
  
  func run(file: String) -> Promise<Environment, Error> {
    let reader = FileReader()
    
    return whenBoth(reader.javascriptFile(file: "aexscript"), reader.javascriptFile(file: "default"))
      .dispatch(on: queue)
      .flatMap { [weak self] aexScript, userFile in
        guard let this = self else {
          return Promise(error: ParseError.unknownError("This has been deallocated") as Error)
        }
        return this.parseJavascript(context: JSContext()!, js: [aexScript, userFile])
          .mapError { $0 as Error }
      }
      .dispatch(on: DispatchQueue.main)
  }
}
