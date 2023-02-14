//
//  Model.swift
//  RefactoryingHanger
//
//  Created by 도헌 on 2023/02/02.
//

import UIKit

struct Item: Equatable, Identifiable {
    /// 특정 아이템의 세부항목을 불러오거나 아이템을 편집할 때 고유한 값으로 추적하기 위한 용도, Identifiable 프로토콜 채택
    /// Identifiable을 채택하고 꼭 'id'라는 네이밍을 가진 UUID() 값이 존재해야함.
    var id: String = UUID().uuidString
    var name: String
    var category: String = "Outer"
    var brand: String = "None"
    var size: String = "None" // when choice accessories category, no have size
    var fit: String = "Regular"
    var color: String = "None"
    var price: Double? = nil
    var orderDate: Date
    var isComplete: Bool = false
    var url: String = ""
    var note: String = ""
}

extension Array where Element == Item { // 요소가 Item일 때의 조건 적용
    func indexOfItem(with id: Item.ID) -> Self.Index {
        guard let index = firstIndex(where: { $0.id == id }) else {
            fatalError("no have machting id")
        }
        return index
    }
}

extension Item {
    static var sampleData = [
        Item(name: "tee", category: "Top", brand: "apple", size: "S", orderDate: Date.now),
        Item(name: "bottom", category: "Bottom", brand: "google", size: "M", orderDate: Date.now),
        Item(name: "outer", category: "Outer", brand: "smasung", size: "M", orderDate: Date.now, isComplete: true),
        Item(name: "coat", category: "Outer", brand: "lg", size: "xs", orderDate: Date.now)
    ]
}
