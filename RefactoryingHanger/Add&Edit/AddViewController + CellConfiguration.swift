//
//  AddViewController + CellConfiguration.swift
//  RefactoryingHanger
//
//  Created by 도헌 on 2023/02/03.
//

import UIKit

/// 사용자가 더 많은 유형의 커스텀 Cell을 추가하면 CellRegistrationHandler를 다루기 어려워진다.
/// 따라서 해당 파일에 extension으로 따로 CellConfiguration을 분리해서 관리한다.

extension AddViewController {
    func listConfiguration(for cell: UICollectionViewListCell, at row: Row) -> UIListContentConfiguration {
        var contentConfiguration = UIListContentConfiguration.valueCell()
        contentConfiguration.prefersSideBySideTextAndSecondaryText = true
        contentConfiguration.text = text(for: row)
        contentConfiguration.secondaryText = secondText(for: row)
        return contentConfiguration
    }
    
    func headerConfiguration(for cell: UICollectionViewListCell, with title: String) -> UIListContentConfiguration {
        var contentConfiguration = cell.defaultContentConfiguration()
        contentConfiguration.text = title
        return contentConfiguration
    }
    
    /// 1~16 TextFieldContentView.swift 확인
    /// 17. TextFieldContentView.Configuration를 반환하는 메소드 생성
    func titleConfiguration(for cell: UICollectionViewListCell, with title: String?, placeholder: String?) -> TextFieldContentView.Configuration {
        var contentConfiguration = cell.textFieldConfiguration()
        contentConfiguration.text = title
        contentConfiguration.placeholder = placeholder
        return contentConfiguration
    }
    
    /// 특정 row에 대한 name 값 반환
    func secondText(for row: Row) -> String? {
        switch row {
        case .name: return item.name
        case .category: return item.category
        case .brand: return item.brand
        case .color: return item.color ?? "-"
        case .price: return String(item.price ?? 0)
        case .orderDate: return item.orderDate.formatted(date: .numeric, time: .omitted)
        default: return nil // header case는 Nil이 되도록
        }
    }
    
    /// 특정 row에 대한 name 값 반환
    func text(for row: Row) -> String? {
        switch row {
        case .name: return Row.name.name
        case .category: return Row.category.name
        case .brand: return Row.brand.name
        case .color: return Row.color.name
        case .price: return Row.price.name
        case .orderDate: return Row.orderDate.name
        default: return nil // header case는 Nil이 되도록
        }
    }
}
