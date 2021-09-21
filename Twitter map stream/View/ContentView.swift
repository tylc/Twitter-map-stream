//
//  ContentView.swift
//  Twitter map stream
//
//  Created by Enric Herce on 20/9/21.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @State var showModal: Bool = false

    @ObservedObject var tweetStream:TweetViewModel = TweetViewModel()

    @State var mapRegion:MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 40, longitude: 1), span: MKCoordinateSpan(latitudeDelta: 40, longitudeDelta: 40))
    
    @State var searchText:String = ""

    
    var body: some View {
        NavigationView{
            ZStack{
                Map(coordinateRegion: $mapRegion, annotationItems: tweetStream.annotations){
                    item in
                        //MapMarker(coordinate: item.location, tint: .red)
                    MapAnnotation(coordinate: item.location) {
                           Circle()
                               .fill(Color.red)
                            
                            .frame(width: 20, height: 20)
                               
                           .onTapGesture {
                            
                                print("tap")
                                showModal=true
                           }
                              
                    }
                    
                        
                }
                .sheet(isPresented: $showModal) {DetailView(showModal: $showModal)}
                
                .ignoresSafeArea(.all)
                
                VStack{
                  
                    TextField("Let's search", text: $searchText, onCommit: {
                        tweetStream.searchTweets(Text: searchText)
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
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

