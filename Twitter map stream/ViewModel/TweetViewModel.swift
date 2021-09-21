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
    @Published var annotations:[Annotation]
    
    var bearer:String
    let headers: HTTPHeaders
        
    /**
        Initializing variables and remove previous rule if it's necessary
     */
    init(){
        
        bearer = "AAAAAAAAAAAAAAAAAAAAAK3kTgEAAAAA511Y6dBIZoXK1qxTwUvP0XQuYRM%3DkSMx9z0IGay7WPa3C9I1Fcc0VyfSmsM5JOKHbLqTf8qBOW1zeC"
        headers = ["Authorization" : "Bearer \(bearer)"]
        
        searchText="default text"
        tweetStream = [Tweet]()
        annotations = [Annotation]()
        
        removePreviousRule()
    }
    
    /**
     Just remove the rule we used last time for stream in real time
     */
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
    
    
    
    /**
     Search logic. Before start the search we must delete the rule is used at this moment and insert the new one with the keyword to search
     */
    func searchTweets(Text text:String){
        //1. remove the rule
        removePreviousRule()

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
            switch response.result {
            case .success:
                AF.streamRequest("https://api.twitter.com/2/tweets/search/stream?expansions=geo.place_id&place.fields=country,country_code,geo",method: .get, headers: self.headers)
                    .validate()
                    .responseStreamDecodable(of: Tweet.self){ [self] stream in
                        print(stream)
                        switch stream.event {
                        case let .stream(result):
                            switch result {
                                
                            case let .success(tweet):
                                //4. save the tweet and create the annotation used in the map
                                if((tweet.includes?.places[0].geo.bbox) != nil){
                            
                                    self.tweetStream.append(tweet)
                                    createAnnotation(associatedTweet: tweet)

                                }
                                
                            case let .failure(error):
                                print("Something went wrong during the stream: \(error)")
                            }
                        case .complete(_):
                            print("end")
                        }
                    }
            case .failure:
                print("Something went wrong during the rule creation")
            }
        }
    }
    
    /**
     When we find a tweet with latitude and longitude er generate an annotation to put in a map
     */
    func createAnnotation(associatedTweet tweet:Tweet){
        
        for (key, value) in tweet.includes?.places[0].geo.bbox ?? [:]{
            annotations.append(Annotation(name: tweet.data.id, location: .init(latitude: key, longitude: value)))
        }
        
    }

    /**
        Function used to remove the first tweet with certain lifespan
     */
    func removeTweets(lifetime lifeInSeconds:Double){
        
        Timer.scheduledTimer(withTimeInterval: lifeInSeconds, repeats: true) { timer in
            
            self.annotations.removeFirst()
            self.tweetStream.removeFirst()
          
        }
        
        
    }
    
}

