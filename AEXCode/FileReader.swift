//
//  FileReader.swift
//  AEXCode
//
//  Created by Tomas Harkema on 13-10-16.
//  Copyright © 2016 Tomas Harkema. All rights reserved.
//

import Foundation
import Promissum

final class FileReader {
  private let queue = DispatchQueue(label: "FileReader")

  func javascriptFile(file: String) -> Promise<String, Error> {
    let promiseSource = PromiseSource<String, Error>()
    queue.async {
      guard let path = Bundle.main.path(forResource: file, ofType: "js") else {
        promiseSource.reject(NSError(domain: "", code: 500, userInfo: nil))
        return
      }
      do {
        promiseSource.resolve(try String(contentsOfFile: path))
      } catch {
        promiseSource.reject(error)
      }
    }
    
    return promiseSource.promise
  }
}
