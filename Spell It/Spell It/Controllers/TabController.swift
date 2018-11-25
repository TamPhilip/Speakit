//
//  TabController.swift
//  Spell It
//
//  Created by Philip Tam on 2018-11-24.
//  Copyright © 2018 Spell It. All rights reserved.
//

import UIKit
import Material

class TabController: TabsController {
    open override func prepare() {
        super.prepare()
        tabBar.setLineColor(Color.orange.base, for: .selected) // or tabBar.lineColor = Color.orange.base
        
        tabBar.setTabItemsColor(Color.grey.base, for: .normal)
        tabBar.setTabItemsColor(Color.purple.base, for: .selected)
        tabBar.setTabItemsColor(Color.green.base, for: .highlighted)
        
        tabBar.tabItems.first?.setTabItemColor(Color.blue.base, for: .selected)
        //    let color = tabBar.tabItems.first?.getTabItemColor(for: .selected)
        
        //    tabBarAlignment = .top
        //    tabBar.tabBarStyle = .auto
        //    tabBar.dividerColor = nil
        //    tabBar.lineHeight = 5.0
        //    tabBar.lineAlignment = .bottom
        //    tabBar.backgroundColor = Color.blue.darken2
    }
}
