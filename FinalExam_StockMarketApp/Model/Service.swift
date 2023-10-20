//
//  Service.swift
//  FinalExam_StockMarketApp
//
//  Created by user248634 on 10/16/23.
//

import Foundation

class Service{
    
    //using singleton design pattern
    private init() {}
    static var shared = Service()
    
    //function to get data from an api
    func getData(urlString: String, query :[String:String]?, completion:@escaping (Result<Data,Error>)->()){
        
        //creating headers
        let headers = [
            "X-RapidAPI-Key": "562f007be0msh92c97f3d9b838ecp15ba90jsn8d323031b052",
            "X-RapidAPI-Host": "ms-finance.p.rapidapi.com"
        ]
        
        //creating query items and attaching it to url componenets
        var urlComponent = URLComponents(string: urlString)!
        if let query = query {
            urlComponent.queryItems = query.map(
                { URLQueryItem(name: $0.key, value: $0.value) }
            )
        }
        
        //calling the api by creating a url request and attaching header to it
        if let urlObj = urlComponent.url {
            print("\(urlObj)")
            var request = URLRequest(url: urlObj, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = headers
            
            URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
                if let error = error{
                    completion(.failure(error))
                }else if let data = data{
                    completion(.success(data))
                }
            }.resume()
        }
    }
}
