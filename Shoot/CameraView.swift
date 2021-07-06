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
        
    var body: some View {
        
        
        ZStack {
            VStack {
                Spacer()
                Spacer()
                ZStack {
                CameraPreview(session: model.session)
                    .aspectRatio(3/4, contentMode: .fit)
                    .onAppear {
                        model.configure()
                    }
                    
                    if model.showGrid {
                        if model.gridFormat == .square {
                        GridView(numberOfLines: $model.gridLines, gridFormat: model.gridFormat).aspectRatio(1, contentMode: .fit)
                        } else {
                            GridView(numberOfLines: $model.gridLines, gridFormat: model.gridFormat).aspectRatio(3/4, contentMode: .fit)
                        }
                    }
                }
                    
                
            
                


                Spacer()
                Spacer()
                Spacer()
                CaptureInterface(model: model, numberOfLines: $model.gridLines)
                Spacer()

            }


        }.background(Color.black.edgesIgnoringSafeArea(.all))
        
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
                                let vOffset: CGFloat = CGFloat(index) * geometry.size.width/CGFloat(numberOfLines)
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
                                let hOffset: CGFloat = CGFloat(index) * geometry.size.height/CGFloat(numberOfLines)
                                path.move(to: CGPoint(x: 0, y: hOffset))
                                path.addLine(to: CGPoint(x: geometry.size.width, y: hOffset))
                            }
                        }
                    }
                    .stroke()
                }
       
        .foregroundColor(.white).opacity(0.5)
    }
    
}


