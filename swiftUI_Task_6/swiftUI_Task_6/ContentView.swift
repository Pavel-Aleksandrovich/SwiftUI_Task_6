//
//  ContentView.swift
//  swiftUI_Task_6
//
//  Created by pavel mishanin on 16/3/24.
//
import SwiftUI

enum LayoutType {
    case horizontal
    case diagonal
}

struct ContentView: View {
    
    @State private var layoutType: LayoutType = .horizontal
    @State private var numberOfItems = 10
    @State private var spacing: CGFloat = 5
    
    var body: some View {
        GeometryReader { proxy in
            let itemSize = getItemSize(layoutType: layoutType, screenSize: proxy.size, numberOfItems: numberOfItems, spacing: spacing)
            
            CustomLayout(layoutType: layoutType, spacing: spacing) {
                ForEach(0..<numberOfItems, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(.blue)
                        .frame(width: itemSize, height: itemSize)
                        .onTapGesture {
                            withAnimation {
                                switch layoutType {
                                case .horizontal: layoutType = .diagonal
                                case .diagonal: layoutType = .horizontal
                                }
                            }
                        }
                }
            }
        }
    }
}

struct CustomLayout: Layout {
    
    @State private var layoutType: LayoutType
    @State private var spacing: CGFloat
    
    init(layoutType: LayoutType, spacing: CGFloat) {
        self.layoutType = layoutType
        self.spacing = spacing
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        proposal.replacingUnspecifiedDimensions()
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard subviews.count > 1 else {
            let point = CGPoint(x: bounds.midX, y: bounds.midY)
            subviews.first?.place(at: point, anchor: .center, proposal: .unspecified)
            
            return
        }
        
        subviews.enumerated().forEach { index, subview in
            var point = CGPoint(x: 0, y: bounds.maxY)
            
            switch layoutType {
            case .horizontal:
                let itemSize = getItemSize(layoutType: layoutType, screenSize: bounds.size, numberOfItems: subviews.count, spacing: spacing)
                
                point.x += CGFloat(index) * (itemSize + spacing)
                point.y = bounds.midY
            case .diagonal:
                let itemSize = getItemSize(layoutType: layoutType, screenSize: bounds.size, numberOfItems: subviews.count, spacing: spacing)
                
                point.x += (CGFloat(index) * ((bounds.width - itemSize) / CGFloat(subviews.count - 1)))
                point.y -= itemSize * CGFloat(index)
            }
            
            subview.place(at: point, anchor: .bottomLeading, proposal: .unspecified)
        }
    }
    
    
}

private func getItemSize(layoutType: LayoutType, screenSize: CGSize, numberOfItems: Int, spacing: CGFloat) -> CGFloat {
    let itemSize: CGFloat
    switch layoutType {
    case .horizontal:
        let sideSize = screenSize.width
        itemSize = (sideSize - (spacing * CGFloat(numberOfItems - 1))) / CGFloat(numberOfItems)
    case .diagonal:
        let sideSize = screenSize.height
        itemSize = sideSize / CGFloat(numberOfItems)
    }
    
    return min(itemSize, screenSize.width, screenSize.height)
}
