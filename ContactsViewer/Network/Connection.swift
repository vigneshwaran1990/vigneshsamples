//
//  Connections.swift
//  ContactsViewer
//
//  Created by Vigneshwaran S on 25/10/19.
//  Copyright © 2019 Vigneshwaran S. All rights reserved.



import UIKit

enum HttpMethodType {
    case GetMethod
    case PutMethod
    case PostMethod
    case DeleteMethod
}

enum ContentType {
    case URLEncode
    case Json
}

typealias requestCompletionBlock = (Any?, Error?) -> Void

class Connection: NSObject {
    var urlString : String = ""
    var httpType : HttpMethodType = HttpMethodType.GetMethod
    var contentType : ContentType = ContentType.Json
    
    override init() {
        super.init()
    }
    
    func loadRequest(requestCompletionBlock: @escaping (Any?, Error?) -> Swift.Void) {
        
        guard let url = URL(string: urlString) else { return }
        
        let request = NSMutableURLRequest(url: url)
        request.timeoutInterval = 60.0 
        switch httpType {
        case .DeleteMethod:
             request.httpMethod = "DELETE"
             break
        case .PutMethod:
            request.httpMethod = "PUT"
            break
        case .PostMethod:
            request.httpMethod = "POST"
            break
        default:
            request.httpMethod = "GET"
            break
        }
        
        switch contentType {
        case .URLEncode:
             request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
             break
        default:
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            break
        }
        
        let session = URLSession.shared
        let task : URLSessionDataTask = session.dataTask(with: request as URLRequest) { data, response, error in
              guard let data = data else { return }
            do {
               var jsonResp: Any? = nil
                jsonResp = try JSONSerialization.jsonObject(with: data, options: [])
                requestCompletionBlock(jsonResp, error)
            }
            catch let err {
                requestCompletionBlock(nil, err)
            }
        }
        task.resume()
    }
}
