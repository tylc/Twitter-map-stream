//
//  TweetViewModel.swift
//  Twitter map stream
//
//  Created by Enric Herce on 20/9/21.
//

import Foundation
import Alamofire
import MapKit

class TweetViewModel:ObservableObject{
    
    @Published var tweetStream:[Tweet]
    @Published var searchText:String
    @Published var annotations:[PointofInterest]
    
    var bearer:String
    let headers: HTTPHeaders
        
    
    init(){
        
        bearer = "AAAAAAAAAAAAAAAAAAAAAK3kTgEAAAAA511Y6dBIZoXK1qxTwUvP0XQuYRM%3DkSMx9z0IGay7WPa3C9I1Fcc0VyfSmsM5JOKHbLqTf8qBOW1zeC"
        headers = ["Authorization" : "Bearer \(bearer)"]
        
        searchText="default text"
        tweetStream = [Tweet]()
        annotations = [PointofInterest]()
        //removePreviousRule()
    }

    func removePreviousRule(){
        
       
        AF.request("https://api.twitter.com/2/tweets/search/stream/rules", headers: headers)
            .validate()
            .responseDecodable(of:Rules.self) { response in
                
                switch response.result {
                case .success:
                    guard let rules:Rules = response.value else {return}
                    
                    let removeRules: [String: Any] = [
                        "delete": [
                            "ids" :[
                                "\(rules.data[0].id)"
                            ]
                        ]
                    ]
                    
                    AF.request("https://api.twitter.com/2/tweets/search/stream/rules",method: .post, parameters:removeRules, encoding: JSONEncoding.default, headers: self.headers).responseString{response in
                        switch response.result {
                        case .success:
                            print(response)
                            print("rule removed")
                        case .failure(let error):
                            print("Something went wrong: \(error)")
                        }
                    }
                case .failure:
                    print("Tere is no rules to remove")
                }
                
            }
    }
    
    
    
    
    func searchTweets(Text text:String){
        
        //1. Remove previous rule
        AF.request("https://api.twitter.com/2/tweets/search/stream/rules", headers: self.headers)
            .validate()
            .responseDecodable(of:Rules.self) { response in
                switch response.result {
                case .success:
                    guard let rules:Rules = response.value else {return}
                    
                    let removeRules: [String: Any] = [
                        "delete": [
                            "ids" :[
                                "\(rules.data[0].id)"
                            ]
                        ]
                    ]
                    
                    AF.request("https://api.twitter.com/2/tweets/search/stream/rules",method: .post, parameters:removeRules, encoding: JSONEncoding.default, headers: self.headers).responseString{response in
                        switch response.result {
                        case .success:
                            print(response)
                            print("rule removed")
                            
                            //2. add new rule
                            let searchParameter: [String: Any] = [
                                "add": [
                                    [
                                        "value": "\(text)"
                                    ]
                                ]
                            ]
                            
                            AF.request("https://api.twitter.com/2/tweets/search/stream/rules",method: .post, parameters:searchParameter, encoding: JSONEncoding.default, headers: self.headers).responseJSON { response in
                                
                                print(response)
                                //3. search stream
                                AF.streamRequest("https://api.twitter.com/2/tweets/search/stream?expansions=geo.place_id&place.fields=country,country_code,geo",method: .get, headers: self.headers)
                                    .validate()
                                    .responseStreamDecodable(of: Tweet.self){ [self] stream in
                                        print(stream)
                                        switch stream.event {
                                        case let .stream(result):
                                            switch result {
                                            
                                            case let .success(tweet):
                                                if((tweet.includes?.places[0].geo.bbox) != nil){
                                                    print("localizado")
                                                    print (tweet.includes?.places[0].geo.bbox as Any)

                                                    self.tweetStream.append(tweet)
                                                    
                                                    createAnnotation(associatedTweet: tweet)
                                                    print(self.tweetStream.count)
                                                }
                                            
                                            case let .failure(error):
                                                print("Something went wrong during the stream: \(error)")
                                            }
                                        case .complete(_):
                                            print("end")
                                        }
                                    }
                            }
                        case .failure(let error):
                            print("Something went wrong during the rule creation: \(error)")
                        }
                    }
                case .failure:
                    print("Tere is no rules to remove")
                }
            }
        
        
        
    }
    func createAnnotation(associatedTweet tweet:Tweet){
        
        for (key, value) in tweet.includes?.places[0].geo.bbox ?? [:]{
            print("\(key) -> \(value)")
            annotations.append(PointofInterest(name: tweet.data.id, location: .init(latitude: key, longitude: value)))
        }
        
    }

    func removeTweets(lifetime lifeInSeconds:Double){
        
        Timer.scheduledTimer(withTimeInterval: lifeInSeconds, repeats: true) { timer in
            
            self.annotations.removeFirst()
            self.tweetStream.removeFirst()
          
        }
        
        
    }
    
}
