//
//  NetworkManager.swift
//  Practice
//
//  Created by Victor Yanuchkov on 10/07/2018.
//  Copyright © 2018 Victor Yanuchkov. All rights reserved.
//

import Foundation

struct Post: Codable {
    let id: Int
    let title: String?
    let body: String?
}

struct Comment: Codable{
    //let postId: Int
    let id: Int
    let name: String
    let email: String
    let body: String
}

enum Result<Value>{
    case succes(Value)
    case failure(Error)
}

func getPosts(for postId:Int? = nil, completion:((Result<[Codable]>) ->Void)?){
    
    var urlComponents = URLComponents()
    urlComponents.scheme = "https"
    urlComponents.host = "jsonplaceholder.typicode.com"
    if let id = postId {
        urlComponents.path = "/comments"
        let commentId = URLQueryItem(name: "postId", value: "\(id)")
        urlComponents.queryItems = [commentId]
    } else {
        urlComponents.path = "/posts"
    }
    //let userIdItem = URLQueryItem(name: "userId", value: "\(userId)")
    //urlComponents.queryItems = [userIdItem]
    guard let url = urlComponents.url else {
        fatalError("Could not create URL from components")
    }
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    
    let config = URLSessionConfiguration.default
    let session = URLSession(configuration: config)
    let task = session.dataTask(with: request){ (responseData, response, responseError) in
        DispatchQueue.main.async {
            if let error = responseError {
                completion?(.failure(error))
            } else if let jsonData = responseData{
                let decoder = JSONDecoder()
                
                do{
                    if let id = postId{
                        let posts = try decoder.decode([Comment].self, from: jsonData)
                        completion?(.succes(posts))
                    } else{
                        let posts = try decoder.decode([Post].self, from: jsonData)
                        completion?(.succes(posts))
                    }
                } catch {
                    completion?(.failure(error))
                }
            } else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Data was not retrieved from request"]) as Error
                completion?(.failure(error))
            }
        }
    }
    task.resume()
}

func submitPost(post: Post, completion:((Error?) -> Void)?){
    var urlComponents = URLComponents()
    urlComponents.scheme = "https"
    urlComponents.host = "jsonplaceholder.typicode.com"
    urlComponents.path = "/posts"
    guard let url = urlComponents.url else { fatalError("Could not create URL from components") }
    
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    var headers = request.allHTTPHeaderFields ?? [:]
    headers["Content-Type"] = "application/json"
    request.allHTTPHeaderFields = headers
    
    
    let encoder = JSONEncoder()
    do {
        let jsonData = try encoder.encode(post)
        
        request.httpBody = jsonData
        print("jsonData: ", String(data: request.httpBody!, encoding: .utf8) ?? "no body data")
    } catch {
        completion?(error)
    }
    
    
    let config = URLSessionConfiguration.default
    let session = URLSession(configuration: config)
    let task = session.dataTask(with: request) { (responseData, response, responseError) in
        guard responseError == nil else {
            completion?(responseError!)
            return
        }
        
        if let data = responseData, let utf8Representation = String(data: data, encoding: .utf8) {
            print("response: ", utf8Representation)
        } else {
            print("no readable data received in response")
        }
    }
    task.resume()
}








