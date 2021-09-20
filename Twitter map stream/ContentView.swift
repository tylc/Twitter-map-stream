//
//  ContentView.swift
//  Twitter map stream
//
//  Created by Enric Herce on 20/9/21.
//

import SwiftUI
import MapKit

struct ContentView: View {
    
    
    //Example pins
    var pointsOfInterest:[PointofInterest] = [PointofInterest(name: "Ajuntament", location: .init(latitude: 39.52868200876407, longitude: -0.40874755981905453)),
                                              PointofInterest(name: "Poliesportiu", location: .init(latitude: 39.52938539857853, longitude: -0.4076639473986893)),
                                              PointofInterest(name: "Casa", location: .init(latitude: 39.530903868790816, longitude: -0.4081091940776906))]
    
    
    @State var mapRegion:MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 40, longitude: 1), span: MKCoordinateSpan(latitudeDelta: 40, longitudeDelta: 40))
    
    @State var searchText:String = ""

    
    var body: some View {
        ZStack{
            Map(coordinateRegion: $mapRegion, annotationItems: pointsOfInterest){
                item in
                    MapMarker(coordinate: item.location, tint: .red)
                    
            }
                .ignoresSafeArea(.all)
            VStack{
              
                TextField("Let's search", text: $searchText, onCommit: {
                            print("call")
                        })
                .padding(10)
                .padding(.horizontal, 25)
                .frame(width: 300.0)
                .background(Color(.systemGray6))
                .cornerRadius(10.0)

                Spacer()
            }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct PointofInterest:Identifiable{
    var id = UUID()
    var name:String
    var location:CLLocationCoordinate2D
}
