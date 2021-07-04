//
//  CameraView.swift
//  Shoot
//
//  Created by Alexey Primechaev on 7/4/21.
//

import SwiftUI

struct CameraView: View {
    @StateObject var model = CameraViewModel()
    
    
    var captureButton: some View {
        Button(action: {
            model.capturePhoto()
        }, label: {
            Circle()
                .foregroundColor(.white)
                .frame(width: 73, height: 73, alignment: .center)

        })
    }
    

    

    
    var body: some View {

                
        ZStack {
                VStack {
                   
                    Spacer()
                    CameraPreview(session: model.session)
                        
                        .aspectRatio(3/4, contentMode: .fit)

                        .onAppear {
                            model.configure()
                        }

                    
                    Spacer()
                    GeometryReader { geometry in
                        
                            captureButton.position(x: geometry.size.width/2)
                            
                            Menu {
                                
                            } label: {
                                Image(systemName: "ellipsis.circle.fill").font(.title).padding(28).foregroundColor(.white)
                            }.position(x: geometry.size.width - (geometry.size.width - (geometry.size.width + 73)/2)/2)
                        
                        .frame(height: 73)
                        .onAppear {
                            print(geometry.size.width)
                            print(geometry.size.height)
                        }
                        
                    }.frame(height: 73)

                    Spacer()
                    
                }
            
            
        }.background(Color.black.edgesIgnoringSafeArea(.all))
      
    }
}
