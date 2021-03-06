//
//  ShowItemsModels.swift
//  CSRecruitmentTest
//
//  Created by msm72 on 08.08.16.
//  Copyright (c) 2016 Monastyrskiy Sergey. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so you can apply
//  clean architecture to your iOS and Mac projects, see http://clean-swift.com
//

import UIKit

// MARK: - Data models
struct ShowItemsRequest {
    var searchText: String?
}


struct ShowItemsResponse {
    var items: [Item]
}


struct ShowItemsViewModel {
    struct DisplayedItem {
        var name: String
        var comment: String
        var imageURL: String
        var id: String
    }
    
    var displayedItems: [DisplayedItem]
}

