//
//  DetailView.swift
//  Twitter map stream
//
//  Created by Enric Herce on 21/9/21.
//

import SwiftUI

struct DetailView: View {
    @Binding var showModal: Bool
    
    var body: some View {
        NavigationView(){
            VStack{
                Text("Tweet details here")
                
            }.toolbar {
                Button(action:{
                    self.showModal.toggle()
                }
                ,label:{
                    Image(systemName: "xmark.circle")
                        .font(.system(size: 20))
                })
            }
        }
    }
}
