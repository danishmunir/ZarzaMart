//
//  HTTPService.swift
//  Gropare
//
//  Created by Danish Munir on 07/10/2020.
//

import Foundation

class HTTPService{
    
    typealias WSCompletionBlock = (_ data: NSDictionary?) ->()
    
    //MARK: Get Api
    func getRequest(urlString:String,completionBlock:@escaping WSCompletionBlock) -> () {
            guard let requestUrl = URL(string:urlString) else { return }
            let session = URLSession.shared
            var request = URLRequest(url: requestUrl as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 60)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let task = session.dataTask(with: request) {
                (data, response, error) in
                
                if let responseError = error{
                    completionBlock([:])
                    print("Response error: \(responseError)")
                }
                else
                {
                    do {
                        
                        let dictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                        DispatchQueue.main.async(execute: {
                            completionBlock(dictionary)
                        })
                    }
                    catch let jsonError as NSError{
                        print("JSON error: \(jsonError.localizedDescription)")
                        completionBlock([:])
                    }
                }
            }
            
            task.resume()
            
        }
    
    func requestWithPost(parameters : [String: Any] , Url : String, completionalHandler: @escaping([String : AnyObject]? , Error?) -> Void)  {
        
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            return
        }
        request.httpBody = httpBody
        request.timeoutInterval = 20
        let session = URLSession.shared
       
        session.dataTask(with: request) { (data, response, error) in
            if response != nil {
                print(response as Any)
            }
             if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String : AnyObject]
                    completionalHandler(json,nil)
                    
                } catch {
                    print(error)
                    completionalHandler(nil,error)
                }
            }
        }.resume()
        
    }
    
}
