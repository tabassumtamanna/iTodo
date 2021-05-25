//
//  jokesApi.swift
//  iTodo
//
//  Created by Tabassum Tamanna on 5/24/21.
//

import Foundation

// MARK: - 
class  OfficialJokesApi {
    
    private static let getRandomJokesUrl: URL = 
            URL(string: "https://official-joke-api.appspot.com/random_joke")!
    
    
    
    // MARK: - Task For GET Request
    @discardableResult class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionTask {
       
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let err = error{
                print(err.localizedDescription)
                completion(nil, err)
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
        return task
    }
    
    // MARK: - Get Random Jokes
    class func getRandomJokes(completion: @escaping (String?, String?, Error?) -> Void){
        
        taskForGETRequest(url: getRandomJokesUrl, responseType: OfficialJokesApiResponse.self) { (response, error) in
            
            if let response = response {
                completion(response.setup, response.punchline, nil)
            } else {
                completion(nil, nil,  error)
            }
        }
    }
    
    
}
