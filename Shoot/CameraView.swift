//
//  CameraView.swift
//  Shoot
//
//  Created by Alexey Primechaev on 7/4/21.
//

import SwiftUI
import VisualEffects
import AVFoundation



struct CameraView: View {
    @StateObject var model = CameraViewModel()
    
    @State var selectedImage = 1
        
    var body: some View {
        
        
        ZStack {
            VStack {
                Spacer()
                Spacer()
                ZStack {
                    
                CameraPreview(session: model.session)
//                    Image("IMG"+String(selectedImage))
//                        .resizable()
//                        .scaledToFill()
                        .aspectRatio(3/4, contentMode: .fit)
//                        .onTapGesture {
//                            if selectedImage < 20 {
//                                selectedImage += 1
//                            } else {
//                                selectedImage = 1
//                            }
//                        }
                    .onAppear {
                        model.configure()
                        if !model.hasChangedIcon {
                            changeIcon()
                        }
                    }
                    
                    if model.showGrid {
                        if model.gridFormat == .square {
                            GridView(numberOfLines: $model.gridLines, gridFormat: model.gridFormat).aspectRatio(1, contentMode: .fit).opacity(model.willCapturePhoto ? 1 : 0.5)
                        } else {
                            GridView(numberOfLines: $model.gridLines, gridFormat: model.gridFormat).aspectRatio(3/4, contentMode: .fit).opacity(model.willCapturePhoto ? 1 : 0.5)
                        }
                    }
                }
                    
                
            
                


                Spacer()
                Spacer()
                Spacer()
                CaptureInterface(model: model)
                Spacer()

            }


        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        
        
    }
}


struct GridView: View {
    
    @Binding var numberOfLines: Int
    
    @State var gridFormat: GridFormat
    
    var body: some View {
        GeometryReader { geometry in
                    Path { path in
                        let numberOfHorizontalGridLines = numberOfLines
                        let numberOfVerticalGridLines = numberOfLines
                        for index in 0...numberOfVerticalGridLines {
                            if gridFormat == .full {
                                if index == 0 {
                                    
                                } else if index < numberOfVerticalGridLines {
                                    let vOffset: CGFloat = CGFloat(index) * geometry.size.width/CGFloat(numberOfLines)
                                    path.move(to: CGPoint(x: vOffset, y: 0))
                                    path.addLine(to: CGPoint(x: vOffset, y: geometry.size.height))
                                }
                            } else {
                                let delta = (0.5 * (index == numberOfLines ? 1 : 0))
                                let vOffset: CGFloat = (0.5 * (index == 0 ? 1 : 0)) + CGFloat(index) * geometry.size.width/CGFloat(numberOfLines) - CGFloat(delta)
                                path.move(to: CGPoint(x: vOffset, y: 0))
                                path.addLine(to: CGPoint(x: vOffset, y: geometry.size.height))
                            }
                        }
                        for index in 0...numberOfHorizontalGridLines {
                            if gridFormat == .full {
                                if index == 0 {
                                    
                                } else if index < numberOfHorizontalGridLines {
                                    let hOffset: CGFloat = CGFloat(index) * geometry.size.height/CGFloat(numberOfLines)
                                    path.move(to: CGPoint(x: 0, y: hOffset))
                                    path.addLine(to: CGPoint(x: geometry.size.width, y: hOffset))
                                }
                            } else {
                                let delta = (0.5 * (index == numberOfLines ? 1 : 0))
                                let hOffset: CGFloat = (0.5 * (index == 0 ? 1 : 0)) + CGFloat(index) * geometry.size.height/CGFloat(numberOfLines) - CGFloat(delta)
                                path.move(to: CGPoint(x: 0, y: hOffset))
                                path.addLine(to: CGPoint(x: geometry.size.width, y: hOffset))
                            }
                        }
                    }
                    .stroke()
                }
       
        .foregroundColor(.white)
    }
    
}



func changeIcon() {
    
    var icon: String? = nil
    
    if UIDevice.modelName == "iPhone X" || UIDevice.modelName == "iPhone XS" || UIDevice.modelName == "iPhone XS Max" {
        icon = "X Lens"
    } else if UIDevice.modelName == "iPhone 11" || UIDevice.modelName == "iPhone 12" || UIDevice.modelName == "iPhone 12 mini" {
        icon = "3 Lens"
    } else if UIDevice.modelName == "iPhone 12 Pro" || UIDevice.modelName == "iPhone 12 Pro Max" || UIDevice.modelName == "iPhone 11 Pro Max" || UIDevice.modelName == "iPhone 11 Pro"{
        icon = nil
    } else if UIDevice.modelName == "iPhone XR" {
        icon = "XR Lens"
    } else {
        icon = "SE Lens"
    }
    
    UIApplication.shared.setAlternateIconName(icon) { error in
        if let error = error {
            print(error.localizedDescription)
        } else {
            print("Success!")
        }
    }
}
