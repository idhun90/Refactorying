//
//  DetailViewController + CellConfiguration.swift
//  RefactoryingHanger
//
//  Created by 도헌 on 2023/02/03.
//

import UIKit

/// 사용자가 더 많은 유형의 커스텀 Cell을 추가하면 CellRegistrationHandler를 다루기 어려워진다.
/// 따라서 해당 파일에 extension으로 따로 CellConfiguration을 분리해서 관리한다.

extension DetailViewController {
    func listConfiguration(for cell: UICollectionViewListCell, at row: Row) -> UIListContentConfiguration {
        var contentConfiguration = UIListContentConfiguration.valueCell()
        contentConfiguration.prefersSideBySideTextAndSecondaryText = true
        contentConfiguration.text = text(for: row)
        contentConfiguration.secondaryText = secondText(for: row)
        return contentConfiguration
    }
/// 특정 row에 대한 name 값 반환
    func secondText(for row: Row) -> String {
        switch row {
        case .name: return item.name
        case .category: return item.category
        case .brand: return item.brand
        case .size: return item.size ?? "-"
        case .color: return item.color ?? "-"
        case .price: return doubleConvertString(with: item.price)
        case .orderDate: return item.orderDate.formatted(date: .numeric, time: .omitted)
        }
    }
    
    private func doubleConvertString(with price: Double?) -> String {
        if let newPrice = price {
            return String(newPrice)
        } else {
            return "-"
        }
    }
    
    /// 특정 row에 대한 name 값 반환
    func text(for row: Row) -> String? {
        switch row {
        case .name: return Row.name.name
        case .category: return Row.category.name
        case .brand: return Row.brand.name
        case .size: return Row.size.name
        case .color: return Row.color.name
        case .price: return Row.price.name
        case .orderDate: return Row.orderDate.name
        }
    }
}
