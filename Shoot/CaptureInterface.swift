//
//  CaptureInterface.swift
//  Shoot
//
//  Created by Alexey Primechaev on 7/4/21.
//

import SwiftUI
import AVFoundation

struct CaptureInterface: View {
    
    @StateObject var model = CameraViewModel()
    
    @State var isExperimental = false
    
    @Binding var numberOfLines: Int
    
    var body: some View {
        if isExperimental {
            HStack {
                Spacer()
                Button {
                    model.capturePhoto()
                } label: {
                    Circle()
                        .foregroundColor(.white)
                        .frame(width: 73, height: 73, alignment: .center)
                        .overlay(
                            Circle()
                                .stroke(Color.black, lineWidth: 2)
                                .frame(width: 65, height: 65, alignment: .center)
                        )

                }
                Spacer()
                Menu {
                    Picker(selection: $model.isFlashOn, label: Text("Flash"), content: {
                        Label("Telephoto", systemImage: "circle.grid.cross.up.fill")
                        Label("Wide", systemImage: "circle.grid.cross.right.fill").tag(true)
                        Label("Ultrawide", systemImage: "circle.grid.cross.down.fill")
                    })
                    Picker(selection: $model.isFlashOn, label: Text("Flash"), content: {
                        Label("Flash On", systemImage: "bolt").tag(true)
                        Label("Flash Off", systemImage: "bolt.slash").tag(false)
                    })
                    
                    Picker(selection: $numberOfLines, label: Text("Flash"), content: {
                        Label("2x2", systemImage: "rectangle.split.2x2").tag(2)
                        Label("3x3", systemImage: "rectangle.split.3x3").tag(3)
                        Label("Natural", systemImage: "rectangle").tag(0)
                    })
                    
                    
                } label: {
                    Image(systemName: "ellipsis.circle").font(.title).padding(28).foregroundColor(.white)
                }
                Spacer()
                
            }
        } else {
            GeometryReader { geometry in
            
            Group {
                       if model.photo != nil {
                           Image(uiImage: model.photo.image!)
                               .resizable()
                               .aspectRatio(contentMode: .fill)
                               .frame(width: 32, height: 32)
                               .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                               .animation(.spring())
                           
                       } else {
                           RoundedRectangle(cornerRadius: 8)
                               .frame(width: 52, height: 52, alignment: .center)
                               .foregroundColor(.black)
                       }
                   }.position(x: (geometry.size.width - (geometry.size.width + 73)/2)/2)
                
                ZStack {
            Button {
                model.capturePhoto()
            } label: {
                Circle()
                    .foregroundColor(.white)
                    .frame(width: 65, height: 65, alignment: .center)
                    

            }
            .buttonStyle(TitleButtonStyle())
                Circle()
                    .stroke(Color.white, lineWidth: 4)
                    .frame(width: 73, height: 73, alignment: .center)
                }
            .position(x: geometry.size.width/2)

            Menu {
                Picker(selection: $model.selectedCamera, label: Text("Selected Camera"), content: {
                    ForEach(availableDeviceTypes(), id: \.self) { cameraType in
                        switch cameraType {
                        case .telephoto:
                            Label("Telephoto", image: "2.5x.SFSymbol").tag(cameraType)
                        case .front:
                            Label("Front", image: "FF.SFSymbol").tag(cameraType)
                        case .wide:
                            Label("Wide", image: "1x.SFSymbol").tag(cameraType)
                        case .ultrawide:
                            Label("Ultrawide", image: "0.5x.SFSymbol").tag(cameraType)
                        }
                        
                    }
                    
                })
                Picker(selection: $numberOfLines, label: Text("Flash"), content: {
                    Label("3 Lines", systemImage: "rectangle.split.3x3").tag(3)
                    Label("2 Lines", systemImage: "rectangle.split.2x2").tag(2)
                    Label("Natural", systemImage: "rectangle").tag(0)
                })
                Picker(selection: $model.isFlashOn, label: Text("Flash Setting"), content: {
                    Label("Flash On", systemImage: "bolt").tag(true)
                    Label("Flash Off", systemImage: "bolt.slash").tag(false)
                })
                
                
                
            } label: {
                HStack {
                    Image("2.5x.SFSymbol")
                    Image(systemName: "bolt.fill")
                }.font(.body).padding(28).foregroundColor(.white)
            }.position(x: geometry.size.width - (geometry.size.width - (geometry.size.width + 73)/2)/2)
            .frame(height: 73)
            .onAppear {
                print("here")
                print(availableDeviceTypes())
            }
            
        

        }.frame(height: 73)
        }
    
    }
}


struct TitleButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeOut(duration: 0.2))
            .onChange(of: configuration.isPressed) { newValue in
                if newValue == true {
                    regularHaptic()
                } else {
                    regularHaptic()
                }
                
            }
    }
    
}

public func regularHaptic() {
    let generator = UIImpactFeedbackGenerator(style: .rigid)
    generator.impactOccurred()
}

