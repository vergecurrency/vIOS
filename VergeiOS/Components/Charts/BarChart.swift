//
//  BarChart.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 13/09/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import SwiftUI

struct BarChart: View {
    let data: [[Double]] = [
        [1, 23],
        [2, 24],
        [3, 65],
        [4, 55],
        [5, 34],
        [6, 53],
        [7, 24]
    ]
    
    var lowest: Double {
        return data.min { a, b in
            a[1] < b[1]
        }![1]
    }
    
    var highest: Double {
        return data.max { a, b in
            a[1] < b[1]
        }![1]
    }
    
    var range: Range<Double> {
        return lowest..<highest
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 2) {
            ForEach(data, id: \.self) { item in
                HStack {
                    ChartBarElement(fillPercentage: self.calculateFillPercentage(of: item[1], range: self.range))
                        .foregroundColor(.blue)
                        .layoutPriority(1)
                }
            }
        }
    }
    
    func calculateFillPercentage(of value: Double, range: Range<Double>) -> Double {
        return ((value - range.lowerBound)) / (range.upperBound - range.lowerBound)
    }
}

struct ChartBarElement: Shape {
    var fillPercentage: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let height = CGFloat(fillPercentage) * rect.size.height
        let width = rect.size.width > 8 ? rect.size.width * 0.4 : rect.size.width
        
        path.addRoundedRect(in: CGRect(
            x: (rect.size.width / 2) - (width / 2),
            y: rect.size.height - height,
            width: width,
            height: height
        ), cornerSize: CGSize(width: 5, height: 5))
        
        return path
    }
}

struct BarChart_Previews: PreviewProvider {
    static var previews: some View {
        BarChart()
            .frame(width: 200, height: 100, alignment: .center)
    }
}
