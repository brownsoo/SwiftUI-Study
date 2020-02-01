//
//  ContentView.swift
//  SwiftUI_study
//
//  Created by hanhyonsoo on 2020/02/01.
//  Copyright © 2020 HSL. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var lastDelta: CGFloat = 1.0
    @State var scale: CGFloat = 1.0
    @State var draged: CGSize = .zero
    @State var prevDraged: CGSize = .zero
    @State var tapPoint: CGPoint = .zero
    @State var isTapped: Bool = false
    
    var body: some View {
        let magnify = MagnificationGesture(minimumScaleDelta: 0.2)
            .onChanged { (value: MagnificationGesture.Value) in
                let resolvedDelta = value / self.lastDelta
                self.lastDelta = value
                let newScale = self.scale * resolvedDelta
                self.scale = min(2.5, max(0.8, newScale))
                
                print("delta=\(value) resolvedDelta=\(resolvedDelta)  newScale=\(newScale)")
        }.onEnded { value in
            // without this the next gesture will be broken
            self.lastDelta = 1.0
            print("lastDelta=\(self.lastDelta)")
        }
        
        let gestureTap = TapGesture(count: 2).onEnded({
            self.isTapped = !self.isTapped
        })
        
        let gestureDrag = DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .onChanged { (value) in
                self.tapPoint = value.startLocation
                self.draged = CGSize(width: value.translation.width + self.prevDraged.width, height: value.translation.height + self.prevDraged.height)
        }
        
        
        return
            GeometryReader { geo in
                Image("dooli")
                    .resizable().scaledToFit().animation(.default)
                    .offset(self.draged)
                    .scaleEffect(self.scale)
                    .scaleEffect(self.isTapped ? 2 : 1, anchor: UnitPoint(x: self.tapPoint.x / geo.frame(in: .global).maxX, y: self.tapPoint.y / geo.frame(in: .global).maxY))
                    .gesture(gestureTap.simultaneously(with:
                        gestureDrag.onEnded { (value) in
                            let parentWidth = geo.frame(in: .global).maxX
                            let parentHeight = geo.frame(in: .global).maxY
                            let offset = CGSize(width: parentWidth * self.scale - parentWidth / 2,
                                                height: parentHeight * self.scale - parentHeight / 2)
                            let newDraged = CGSize(width: self.draged.width * self.scale,
                                                   height: self.draged.height * self.scale)
                            var resolved = CGSize()
                            if newDraged.width > offset.width {
                                resolved.width = offset.width / self.scale
                            } else if newDraged.width < -offset.width {
                                resolved.width = -offset.width / self.scale
                            } else {
                                resolved.width = value.translation.width + self.prevDraged.width
                            }
                            if newDraged.height > offset.height {
                                resolved.height = offset.height / self.scale
                            } else if newDraged.width < -offset.width {
                                resolved.height = -offset.height / self.scale
                            } else {
                                resolved.height = value.translation.height + self.prevDraged.height
                            }
                            self.draged = resolved
                            self.prevDraged = resolved
                        }
                    ))
                    .gesture(magnify)
            }
            .frame(height: 300)
            .clipped()
            .background(Color.gray)
            .gesture(magnify)
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
