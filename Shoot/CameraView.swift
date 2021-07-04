//
//  CameraView.swift
//  Shoot
//
//  Created by Alexey Primechaev on 7/4/21.
//

import SwiftUI

struct CameraView: View {
    @StateObject var model = CameraViewModel()
    
    
    var body: some View {
        
//        Picker(selection: $model.isFlashOn, label: Text("Flash"), content: {
//            Text("Flash On").tag(true)
//            Text("Flash Off").tag(false)
//        })
        
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
