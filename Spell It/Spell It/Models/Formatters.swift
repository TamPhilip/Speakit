//
//  BarChartDaysFornatter.swift
//  Spell It
//
//  Created by Philip Tam on 2018-11-24.
//  Copyright © 2018 Spell It. All rights reserved.
//

import Foundation
import Charts

class BarChartXAxisFormatter: IAxisValueFormatter {
    
    var dayOfWeeks: [Int]
    
    init(dayOfWeeks: [Int]) {
        self.dayOfWeeks = dayOfWeeks.reversed()
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let index = self.dayOfWeeks[Int(value)]
        
        switch index {
        case 0:
            return "Mon"
        case 1:
            return "Tue"
        case 2:
            return "Wed"
        case 3:
            return "Thu"
        case 4:
            return "Fri";
        case 5:
            return "Sat"
        case 6:
            return "Sun"
        default:
            return ""
            
        }
    }
}


class LineXAxisFormatter: IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        
        switch value {
        case 0:
            return "Mon"
        case 1:
            return "Tue"
        case 2:
            return "Wed"
        case 3:
            return "Thu"
        case 4:
            return "Fri";
        case 5:
            return "Sat"
        case 6:
            return "Sun"
        default:
            return ""
            
        }
    }
}


class MonthFormatter: IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        switch value {
        case 0:
            return "Jan"
        case 1:
            return "Feb"
        case 2:
            return "Mar"
        case 3:
            return "Apr"
        case 4:
            return "May";
        case 5:
            return "Jun"
        case 6:
            return "Jul"
        case 7:
            return "Aug"
        case 8:
            return "Sep"
        case 9:
            return "Oct"
        case 10:
            return "Nov"
        case 11:
            return "Dec"
        default:
            return ""
            
        }
    }
}



class BarChartValueFormatter: IValueFormatter {
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        return String(Int(value))
    }
}
