//
//  Backend.swift
//  ucicourses
//
//  Created by Vatsal Rustagi on 9/5/17.
//  Copyright © 2017 Vatsalr23. All rights reserved.
//

import Foundation
import Alamofire

protocol BackendDelegate{
    func processDataOfType(JSON: Dictionary<String, Any>)
    func processDataOfType(str: String)
    func processDataOfType(JSON: Dictionary<String, Any>,withAdditional data: Any)
}

extension BackendDelegate{
    func processDataOfType(str: String){
        // Do Nothing...
    }
    
    func processDataOfType(JSON: Dictionary<String, Any>){
        // Do Nothing...
    }
    
    func processDataOfType(JSON: Dictionary<String, Any>,withAdditional data: Any){
        // Do Nothing...
    }
}

class Backend{
    
    private let baseURL = "http://localhost:3000/"
    
    var delegate: BackendDelegate? = nil
    
    func getJSONData(from url: String,withParams params: Dictionary<String,String>){
        var dataURL = URLComponents(string: baseURL + url)!
        var items: [URLQueryItem] = []
        for (name,value) in params{
            items.append(URLQueryItem(name: name, value: value))
        }
        
        dataURL.queryItems = items
        
        Alamofire.request(dataURL).responseJSON{response in
            debugPrint(response)
            let result = response.result
            if let dict = result.value as? Dictionary<String, Any>{
                if let del = self.delegate{
                    del.processDataOfType(JSON: dict)
                }
            }
        }
        /*
        Alamofire.request(dataURL).responseString{
            response in
            debugPrint(response)
            if let del = self.delegate{
                let result = response.result
                if let l = result.value{
                    del.processDataOfType(str: l)
                }
            }
        }
        */
    }
    
    func getJSONData(from url: String,withParams params: Dictionary<String,String>, with data: Any){
        var dataURL = URLComponents(string: baseURL + url)!
        var items: [URLQueryItem] = []
        for (name,value) in params{
            items.append(URLQueryItem(name: name, value: value))
        }
        
        dataURL.queryItems = items
        
        Alamofire.request(dataURL).responseJSON{response in
            debugPrint(response)
            let result = response.result
            if let dict = result.value as? Dictionary<String, Any>{
                if let del = self.delegate{
                    del.processDataOfType(JSON: dict,withAdditional: data)
                }
            }
        }
    }
    
    func postJSONData(to url: String, withParams params: Dictionary<String, Any>){
        let dataURL = URL(string: baseURL + url)!
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json; charset=utf-8"
        ]
        
        Alamofire.request(dataURL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON
            {
                response in
                debugPrint(response)
                let result = response.result
                if let dict = result.value as? Dictionary<String, Any>{
                    if let del = self.delegate{
                        del.processDataOfType(JSON: dict)
                    }
                }
        }
    }
    
}
