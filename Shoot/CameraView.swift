//
//  CameraView.swift
//  Shoot
//
//  Created by Alexey Primechaev on 7/4/21.
//

import SwiftUI
import VisualEffects

struct CameraView: View {
    @StateObject var model = CameraViewModel()
    
    
    var body: some View {
        
        
        ZStack {
            VStack {
                Spacer()
                Spacer()
                CameraPreview(session: model.session)
                    .aspectRatio(3/4, contentMode: .fit)
                    .onAppear {
                        model.configure()
                    }
                
                


                Spacer()
                Spacer()
                Spacer()
                CaptureInterface(model: model)
                Spacer()

            }


        }.background(Color.black.edgesIgnoringSafeArea(.all))
        
    }
}
