//
//  Annotation.swift
//  Twitter map stream
//
//  Created by Enric Herce on 21/9/21.
//

import Foundation
import MapKit

//Support struct
struct Annotation:Identifiable{
    var id = UUID()
    var name:String
    var location:CLLocationCoordinate2D
}
