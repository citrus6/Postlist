//
//  NetworkManager.swift
//  Practice
//
//  Created by Victor Yanuchkov on 10/07/2018.
//  Copyright © 2018 Victor Yanuchkov. All rights reserved.
//

import Foundation
import UIKit.UIImage

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

struct Photo: Decodable {
    let id: Int
    let url: String
    let thumbnailUrl: String
}

enum Result<Value>{
    case succes(Value)
    case failure(Error)
}

enum photoResult{
    case succes(Photo)
    case failure(Error)
}

enum downloadImageResult{
    case succes(UIImage?)
    case failure(Error?)
}


func dowloadImage(url: String, completion: ((downloadImageResult) -> Void)?){
    let url = URL(string: url)
    let session = URLSession(configuration: .default)
    
    let getImageFromUrl = session.dataTask(with: url!){ (data, responce, error) in
        if let e = error {
            completion?(.failure(e))
        } else {
            if (responce as? HTTPURLResponse) != nil{
                if let imageData = data {
                    let image = UIImage(data: imageData)
                    completion?(.succes(image)!)
                } else {
                    completion?(.failure(error))
                }
            } else {
                completion?(.failure(error))
            }
        }
    }
    getImageFromUrl.resume()
}

func getPhoto(id: Int, completion: ((photoResult) -> Void)?){
    let str = "https://jsonplaceholder.typicode.com/photos/\(id)"
    
    guard let url = URL(string: str) else {
        return
    }
    URLSession.shared.dataTask(with: url){
        (data, response, error) in
        guard let data = data else{
            return
        }
        guard error == nil else{
            return
        }
        do{
            let ph = try JSONDecoder().decode(Photo.self, from: data)
            completion?(.succes(ph))
        } catch {
            completion?(.failure(error))
        }
        }.resume()
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
                    if postId != nil{
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








