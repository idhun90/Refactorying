//
//  EditViewController.swift
//  RefactoryingHanger
//
//  Created by 도헌 on 2023/02/04.
//

import UIKit

final class EditViewController: UIViewController {
    
    enum Section: Int, Hashable {
        case name
        case category
        case brand
        case size
        case color
        case price
        case orderDate
        
        var headerTitle: String {
            switch self {
            case .name: return NSLocalizedString("name", comment: "name section name")
            case .category: return NSLocalizedString("category", comment: "category section name")
            case .brand: return NSLocalizedString("brand", comment: "brand section name")
            case .size: return NSLocalizedString("size", comment: "size section name")
            case .color: return NSLocalizedString("color", comment: "color section name")
            case .price: return NSLocalizedString("price", comment: "price section name")
            case .orderDate: return NSLocalizedString("orderDate", comment: "orderDate section name")
            }
        }
    }
    
    enum Row: Hashable {
        case header(String)
        case editName(String)
        case editCategory(String)
        case editBrand(String)
        case editSize(String?)
        case editColor(String?)
        case editPrice(Double?)
        case editOrderDate(Date)
        
        var text: String? {
            switch self {
            case .header(_): return nil
            case .editName(_): return "Name"
            case .editCategory(_): return "Category"
            case .editBrand(_): return "Brand"
            case .editSize(_): return "Size"
            case .editColor(_): return "Color"
            case .editPrice(_): return "Price"
            case .editOrderDate(_): return "OrderDate"
            }
        }
    }
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Row>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Row>
    
    private var collectionView: UICollectionView!
    private var dataSource: DataSource!
    private var snapshot: Snapshot!
    
    var item: Item?
    var editingItem: Item?
    var sendEditingItem: ((_ editingItem:Item) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationItem()
        configureCollectionView()
        configureDataSource()
        applySnapshot()
    }
    
    deinit {
        print("deinit EditViewController")
    }
    
    func fetchItem(with item: Item) {
        self.item = item
        editingItem = item
    }
    
    private func configureNavigationItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(tappedDoneButton))
    }
    
    @objc private func tappedDoneButton() {
        guard let editingItem = editingItem else { return }
        sendEditingItem?(editingItem)
        dismiss(animated: true)
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.delegate = self
        collectionView.keyboardDismissMode = .onDrag
        view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.0),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0)
        ])
    }
    
    private func createLayout() -> UICollectionViewLayout {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        listConfiguration.headerMode = .firstItemInSection
        return UICollectionViewCompositionalLayout.list(using: listConfiguration)
    }
    
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Row>(handler: cellRegistrationHandler)
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        })
    }
    
    private func applySnapshot() {
        guard let item = item else { return }
        snapshot = Snapshot()
        snapshot.appendSections([.name, .category, .brand, .size, .color, .price, .orderDate])
        snapshot.appendItems([.header(Section.name.headerTitle), .editName(item.name)], toSection: .name)
        snapshot.appendItems([.header(Section.category.headerTitle), .editCategory(item.category)], toSection: .category)
        snapshot.appendItems([.header(Section.brand.headerTitle), .editBrand(item.brand)], toSection: .brand)
        snapshot.appendItems([.header(Section.size.headerTitle), .editSize(item.size ?? "None")], toSection: .size)
        snapshot.appendItems([.header(Section.color.headerTitle), .editColor(item.color)], toSection: .color)
        snapshot.appendItems([.header(Section.price.headerTitle), .editPrice(item.price)], toSection: .price)
        snapshot.appendItems([.header(Section.orderDate.headerTitle), .editOrderDate(item.orderDate)], toSection: .orderDate)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func prepareForUpdate() {
        if editingItem != item {
            item = editingItem
        }
        applySnapshot()
    }
}

extension EditViewController {
    private func cellRegistrationHandler(cell: UICollectionViewListCell, indexPath: IndexPath, row: Row) {
        guard let section = Section(rawValue: indexPath.section) else { return }
        switch (section, row) {
        case (_, .header(let title)):
            cell.contentConfiguration = headerConfiguration(for: cell, with: title)
        case (.name, .editName(let name)):
            cell.contentConfiguration = textFieldConfiguration(for: cell, with: name, placeholder: Row.editName("").text, row: .editName(""))
        case (.category, .editCategory(let category)):
            cell.contentConfiguration = editListConfiguration(for: cell, with: category, at: .editCategory(""))
            cell.accessories = [.disclosureIndicator(displayed: .always)]
        case (.brand, .editBrand(let brand)):
            cell.contentConfiguration = editListConfiguration(for: cell, with: brand, at: .editBrand(""))
            cell.accessories = [.disclosureIndicator(displayed: .always)]
        case (.size, .editSize(let size)):
            cell.contentConfiguration = editListConfiguration(for: cell, with: size, at: .editSize(nil))
            cell.accessories = [.disclosureIndicator(displayed: .always)]
        case (.color, .editColor(let color)):
            cell.contentConfiguration = textFieldConfiguration(for: cell, with: color, placeholder: Row.editColor(nil).text, row: .editColor(nil))
        case (.price, .editPrice(let price)):
            if let price = price {
                cell.contentConfiguration = textFieldConfiguration(for: cell, with: String(price), placeholder: Row.editPrice(nil).text, row: .editPrice(nil))
            } else {
                cell.contentConfiguration = textFieldConfiguration(for: cell, with: nil, placeholder: Row.editPrice(nil).text, row: .editPrice(nil))
            }
        case (.orderDate, .editOrderDate(let date)):
            cell.contentConfiguration = datePickerConfiguration(for: cell, with: date)
        default:
            fatalError("error (section, row)")
        }
    }
}

extension EditViewController {

    func editListConfiguration(for cell: UICollectionViewListCell, with value: String?, at row: Row) -> UIListContentConfiguration {
        var contentConfiguration = UIListContentConfiguration.valueCell()
        contentConfiguration.text = text(for: row)
        contentConfiguration.secondaryText = value
        return contentConfiguration
    }
    
    func headerConfiguration(for cell: UICollectionViewListCell, with title: String) -> UIListContentConfiguration {
        var contentConfiguration = cell.defaultContentConfiguration()
        contentConfiguration.text = title
        return contentConfiguration
    }
    
    func datePickerConfiguration(for cell: UICollectionViewListCell, with Date: Date) -> DatePickerContentView.Configuration {
        var contentConfiguration = cell.DatePickerContentConfiguration()
        contentConfiguration.date = Date
        contentConfiguration.onchange = { [weak self] date in
            self?.editingItem?.orderDate = date
        }
        return contentConfiguration
    }
    
    /// 1~16 TextFieldContentView.swift 확인
    /// 17. TextFieldContentView.Configuration를 반환하는 메소드 생성
    func textFieldConfiguration(for cell: UICollectionViewListCell, with title: String?, placeholder: String?, row: Row) -> TextFieldContentView.Configuration {
        var contentConfiguration = cell.textFieldConfiguration()
        contentConfiguration.text = title
        contentConfiguration.placeholder = placeholder
        contentConfiguration.keyboardType = keyboardType(row: row)
        contentConfiguration.onChange = { [weak self] text in
            switch row {
            case .editName(_):
                self?.editingItem?.name = text
            case .editColor(_):
                self?.editingItem?.color = text
            case .editPrice(_):
                self?.editingItem?.price = self?.doubleConvertToString(with: text)
            default: fatalError("텍스트필드 클로저 문제 발생")
            }
        }
        return contentConfiguration
    }
    private func keyboardType(row: Row) -> UIKeyboardType {
        switch row {
        case .editName(_): return .default
        case .editColor(_): return .default
        case .editPrice(_): return .decimalPad
        default: fatalError("TextField KeyboardType Erorr")
        }
    }
    
    private func doubleConvertToString(with text: String) -> Double? {
        if let converted = Double(text) {
            return converted
        } else {
            return nil
        }
        
    }
    

    func text(for row: Row) -> String? {
        switch row {
        case .header(_): return nil
        case .editName(_): return Row.header("").text
        case .editCategory(_): return Row.editCategory("").text
        case .editBrand(_): return Row.editBrand("").text
        case .editSize(_): return Row.editSize(nil).text
        case .editColor(_): return Row.editColor(nil).text
        case .editPrice(_): return Row.editPrice(nil).text
        case .editOrderDate(_): return Row.editOrderDate(Date()).text
        }
    }
}

//MARK: - UICollectionViewDelegate
extension EditViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let row = dataSource.itemIdentifier(for: indexPath) else { return false }
        
        switch row {
        case .editCategory(_):
            showNextView()
            return false
        case .editBrand(_):
            let vc = SelectBrandViewController()
            vc.onchange = { [weak self] brand in
                self?.editingItem?.brand = brand
                self?.prepareForUpdate()
                print("Brand changed")
            }
            navigationController?.pushViewController(vc, animated: true)
            return false
        case .editSize(_):
            showNextView()
            return false
        default: return false
        }
    }
    
    private func showNextView() {
        navigationController?.pushViewController(SelectBrandViewController(), animated: true)
    }
}
