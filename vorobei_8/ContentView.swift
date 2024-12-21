//
//  ContentView.swift
//  vorobei_8
//
//  Created by Raman Liukevich on 20/12/2024.
//

import SwiftUI

struct ContentView: View {

    @State private var progress: CGFloat = 0.99

    var body: some View {

        ZStack {
            Image(.template)
                .resizable()
                .scaledToFill()
                .frame(height: 1060)
                .blur(radius: 6)
                .contrast(0.9)
                .saturation(0.7)

            StretchySlider(
                symbol: .init(
                    icon: "wand.and.rays",
                    tint: .yellow,
                    font: .system(size: 50, weight: .medium),
                    padding: 20),
                sliderProgress: $progress
            )
            .frame(width: 120.0, height: 280.0)
        }
        .ignoresSafeArea()
    }

}

struct StretchySlider: View {

    var symbol: Symbol?
    @Binding var sliderProgress: CGFloat

    @State var dragOffset = 0.0
    @State var lastDragOffset = 0.0
    @State var progress = 0.5

    var body: some View {
        GeometryReader {
            let size = $0.size
            let height = size.height
            let progressValue = (max(progress, .zero)) * height

            ZStack(alignment: .bottom) {
                Rectangle()
                    .background(
                        .ultraThinMaterial,
                        in: Rectangle()
                    )

                Rectangle()
                    .fill(.white)
                    .frame(width: nil, height: progressValue)

                if let symbol, symbol.display {
                    Image(systemName: symbol.icon, variableValue: progress)
                        .font(symbol.font)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.black, .orange)

                        .padding(symbol.padding)
                        .frame(width: size.width,
                               height: size.height,
                               alignment: symbol.alignment)
                        .offset(y: 1)
                        .rotationEffect(Angle(degrees: 0))
                }
            }
            .clipShape(.rect(cornerRadius: 40))
            .contentShape(.rect(cornerRadius: 40))
            .optionalSizingModifiers(size: size, progress: progress, height: height)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged {
                        let translation = $0.translation
                        let movement = -translation.height + lastDragOffset
                        dragOffset = movement
                        calculateProgress(with: height)
                    }
                    .onEnded { _ in
                        withAnimation(.smooth) {
                            dragOffset = dragOffset > height ? height : (dragOffset < 0 ? 0 : dragOffset)
                            calculateProgress(with: height)
                        }

                        lastDragOffset = dragOffset
                    }
            )
            .frame(maxWidth: size.width,
                   maxHeight: size.height,
                   alignment: progress < 0 ? .top : .bottom)
            .onChange(of: sliderProgress, initial: true) { oldValue, newValue in
                guard sliderProgress != progress, (sliderProgress > 0 && sliderProgress < 1.0) else { return }

                progress = max(min(sliderProgress, 1.0), .zero)
                dragOffset = progress * height
                lastDragOffset = dragOffset
            }
            .accentColor(Color.blue)
        }
        .onChange(of: progress) { oldValue, newValue in
            sliderProgress = max(min(progress, 1.0), .zero)
        }
    }

    func calculateProgress(with height: CGFloat) {
        let topAndTrailingExcessOffsets = height + (dragOffset - height) * 0.035
        let bottomAndLeadingExcessOffsets = dragOffset < 0 ? (dragOffset * 0.035) : dragOffset

        let progressvalue = (dragOffset > height ? topAndTrailingExcessOffsets : bottomAndLeadingExcessOffsets) / height
        progress = progressvalue

    }
}

fileprivate extension View {
    @ViewBuilder
    func optionalSizingModifiers(size: CGSize, progress: CGFloat, height: CGFloat) -> some View {

        let topAndTrailingScale = 1 - (progress - 1) * 1.8
        let bottomAndLeadingScale = 1 + (progress) * 1.8
        self
            .frame(height: progress < 0 ? size.height + (-progress * size.height) : nil)
            .scaleEffect(
                x: progress > 1 ? topAndTrailingScale : (progress < 0 ? bottomAndLeadingScale : 1),
                y: 1,
                anchor: progress < 0 ? .top : .bottom
            )
    }
}

struct Symbol {
    var icon: String
    var tint: Color
    var font: Font
    var padding: CGFloat
    var display: Bool = true
    var alignment: Alignment = .center
}

#Preview {
    ContentView()
}

