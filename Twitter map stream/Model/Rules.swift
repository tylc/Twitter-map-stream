//
//  Rules.swift
//  Twitter map stream
//
//  Created by Enric Herce on 20/9/21.
//

import Foundation

struct Rules:Decodable{
    var data:[Rule]
}

struct Rule:Decodable{
    var id:String
    //var value:String
}
