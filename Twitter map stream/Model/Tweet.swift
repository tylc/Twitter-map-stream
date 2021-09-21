//
//  Tweet.swift
//  Twitter map stream
//
//  Created by Enric Herce on 20/9/21.
//



import Foundation


struct Tweet:Decodable{
    var data:DataTweet
    var includes:Include?
}

struct DataTweet:Decodable{
    //var geo:GeoId
    var id:String
    var text:String
}

struct GeoId:Decodable{
    var place_id:Int?
}

struct Include:Decodable{
    var places:[Place]
}

struct Place:Decodable{
    var country:String
    var country_code:String
    var full_name:String
    var geo:Geo
}

struct Geo:Decodable{
    var type:String
    var bbox:[Double:Double]
}

