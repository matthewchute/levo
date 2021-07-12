//
//  ActivityGraph.swift
//  levo
//
//  Created by Antonio Kim on 2021-07-12.
//

import SwiftUI

struct ActivityGraph: View {
    var logs: [ActivityLog]
    @Binding var selectedIndex: Int
    
    init(logs: [ActivityLog], selectedIndex: Binding<Int>) {
        self._selectedIndex = selectedIndex
        self.logs = logs
    }
    
    var body: some View {
        drawGrid()
            .overlay(drawActivityLine(logs: logs))
    }
}

// x, y, z, gyro, gyro, gyro, angle, angle, angle x 2
func drawGrid() -> some View {
    VStack(spacing: 0) {
        Color.black.frame(height:1, alignment: .center)
        HStack(spacing: 0) {
            Color.clear
                .frame(width: 8, height: 300)
            ForEach(0..<11) { i in
                Color.black.frame(width: 1, height: 300, alignment: .center)
                Spacer()
            }
            Color.black.frame(width: 1, height: 300, alignment: .center)
            Color.clear
                .frame(width:8, height:300)
        }
        Color.black.frame(height:1, alignment: .center)
    }
}

func drawActivityLine(logs: [ActivityLog]) -> some View {
    GeometryReader { geo in
        Path { p in
            let maxNum = logs.reduce(0) { (res, log) -> Double in
                return max(res, log.distance)
            }

            let scale = geo.size.height / CGFloat(maxNum)
            var index: CGFloat = 0

            p.move(to: CGPoint(x: 8, y: geo.size.height - (CGFloat(logs[0].distance) * scale)))

            for _ in logs {
                if index != 0 {
                    p.addLine(to: CGPoint(x: 8 + ((geo.size.width - 16) / 11) * index, y: geo.size.height - (CGFloat(logs[Int(index)].distance) * scale)))
                }
                index += 1
            }
        }
        .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round, miterLimit: 80, dash: [], dashPhase: 0))
        .foregroundColor(Color(red: 251/255, green: 82/255, blue: 0))
    }
} 

struct ActivityGraph_Previews: PreviewProvider {
    static var previews: some View {
        ActivityGraph(logs: ActivityTestData.testData, selectedIndex: .constant(3))
            .padding()
    }
}
