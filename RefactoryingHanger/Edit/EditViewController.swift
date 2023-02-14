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
        case list
        case fitAndSatisfaction
        case size
        case price
        case orderDate
        case urlAndNote
        
        //        var headerTitle: String {
        //            switch self {
        //            case .name: return NSLocalizedString("name", comment: "name section name")
        //            case .list: return NSLocalizedString("list", comment: "list section name")
        //            case .size: return NSLocalizedString("size", comment: "size section name")
        //            //case .color: return NSLocalizedString("color", comment: "color section name")
        //            case .price: return NSLocalizedString("price", comment: "price section name")
        //            case .orderDate: return NSLocalizedString("orderDate", comment: "orderDate section name")
        //            case .urlAndNote: return NSLocalizedString("urlAndNote", comment: "urlAndNote section name")
        //            }
        //        }
    }
    
    enum Row: Hashable {
        //case header(String)
        case editName(String)
        case editCategory(String)
        case editBrand(String)
        case editSize(String)
        case editColor(String)
        case editFit(String)
        case editPrice(Double?)
        case editOrderDate(Date)
        case editUrl(String)
        case editNote(String)
        
        var text: String {
            switch self {
                //case .header(_): return nil
            case .editName(_): return "Name"
            case .editCategory(_): return "Category"
            case .editBrand(_): return "Brand"
            case .editSize(_): return "Size"
            case .editColor(_): return "Color"
            case .editFit(_): return "Fit"
            case .editPrice(_): return "Price"
            case .editOrderDate(_): return "OrderDate"
            case .editUrl(_): return "URL"
            case .editNote(_): return "Note"
            }
        }
    }
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Row>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Row>
    
    private var collectionView: UICollectionView!
    private var dataSource: DataSource!
    private var snapshot: Snapshot!
    
    var item: Item
    var editingItem: Item {
        didSet {
            isModalInPresentation = item == editingItem ? false : true
        }
    }
    var sendEditingItem: ((Item) -> Void) = { _ in }
    var sendCustomCategorys: (([Category]) -> Void) = { _ in }
    var sendCustomBrands: (([Brand]) -> Void) = { _ in }
    var sendCustomColors: (([Color]) -> Void) = { _ in }
    var sendCustomFits: (([Fit]) -> Void) = { _ in }
    var sendCustomSizes: (([Size]) -> Void) = { _ in }
    
    var customCategorys: [Category] {
        didSet {
            sendCustomCategorys(customCategorys)
        }
    }
    var customBrands: [Brand] {
        didSet {
            sendCustomBrands(customBrands)
        }
    }
    var customColors: [Color] {
        didSet {
            sendCustomColors(customColors)
        }
    }
    var customFits: [Fit] {
        didSet {
            sendCustomFits(customFits)
        }
    }
    var customSizes: [Size] {
        didSet {
            sendCustomSizes(customSizes)
        }
    }
    
    private var isItemChanged = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationItem()
        configureCollectionView()
        configureDataSource()
        applySnapshot()
        modalInPresentationToggle()
    }
    
    init(item: Item, customCategorys: [Category], customBrands: [Brand], customColors: [Color], customFits: [Fit], customSizes: [Size]) {
        self.item = item
        self.editingItem = item
        self.customCategorys = customCategorys
        self.customBrands = customBrands
        self.customColors = customColors
        self.customFits = customFits
        self.customSizes = customSizes
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func modalInPresentationToggle() {
        isModalInPresentation = isItemChanged ? true : false
    }

    private func configureNavigationItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(tappedDoneButton))
    }
    
    @objc private func tappedDoneButton() {
        sendEditingItem(editingItem)
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
        let listConfiguration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        return UICollectionViewCompositionalLayout.list(using: listConfiguration)
    }
    
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Row>(handler: cellRegistrationHandler)
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        })
    }
    
    private func applySnapshot() {
        snapshot = Snapshot()
        snapshot.appendSections([.name, .list, .fitAndSatisfaction, .size, .price, .orderDate, .urlAndNote])
        snapshot.appendItems([.editName(editingItem.name)], toSection: .name)
        snapshot.appendItems([.editCategory(editingItem.category), .editBrand(editingItem.brand), .editColor(editingItem.color)], toSection: .list)
        snapshot.appendItems([.editFit(editingItem.fit)], toSection: .fitAndSatisfaction)
        snapshot.appendItems([.editSize(editingItem.size)], toSection: .size)
        snapshot.appendItems([.editPrice(editingItem.price)], toSection: .price)
        snapshot.appendItems([.editOrderDate(editingItem.orderDate)], toSection: .orderDate)
        snapshot.appendItems([.editUrl(editingItem.url), .editNote(editingItem.note)], toSection: .urlAndNote)
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
        case (.name, .editName(let name)):
            cell.contentConfiguration = textFieldConfiguration(for: cell, with: name, placeholder: Row.editName("").text, row: .editName(""))
        case (.list, .editCategory(let category)):
            cell.contentConfiguration = editListConfiguration(for: cell, with: category, at: .editCategory(""))
            cell.accessories = [.disclosureIndicator(displayed: .always)]
        case (.list, .editBrand(let brand)):
            cell.contentConfiguration = editListConfiguration(for: cell, with: brand, at: .editBrand(""))
            cell.accessories = [.disclosureIndicator(displayed: .always)]
        case (.list, .editColor(let color)):
            cell.contentConfiguration = editListConfiguration(for: cell, with: color, at: .editColor(""))
            cell.accessories = [.disclosureIndicator(displayed: .always)]
        case (.fitAndSatisfaction, .editFit(let fit)):
            cell.contentConfiguration = editListConfiguration(for: cell, with: fit, at: .editFit(""))
            cell.accessories = [.disclosureIndicator(displayed: .always)]
        case (.size, .editSize(let size)):
            cell.contentConfiguration = editListConfiguration(for: cell, with: size, at: .editSize(""))
            cell.accessories = [.disclosureIndicator(displayed: .always)]
        case (.price, .editPrice(let price)):
            if let price = price {
                cell.contentConfiguration = textFieldConfiguration(for: cell, with: String(price), placeholder: Row.editPrice(nil).text, row: .editPrice(nil))
            } else {
                cell.contentConfiguration = textFieldConfiguration(for: cell, with: nil, placeholder: Row.editPrice(nil).text, row: .editPrice(nil))
            }
        case (.orderDate, .editOrderDate(let date)):
            cell.contentConfiguration = datePickerConfiguration(for: cell, with: date)
        case (.urlAndNote, .editUrl(let url)):
            cell.contentConfiguration = textFieldConfiguration(for: cell, with: url, placeholder: Row.editUrl("").text, row: .editUrl(""))
        case (.urlAndNote, .editNote(let note)):
            cell.contentConfiguration = textViewConfiguration(for: cell, with: note)
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
            self?.editingItem.orderDate = date
            print("EditView - orderDate Changed")
        }
        return contentConfiguration
    }
    
    /// 1~16 TextFieldContentView.swift 확인
    /// 17. TextFieldContentView.Configuration를 반환하는 메소드 생성
    func textFieldConfiguration(for cell: UICollectionViewListCell, with title: String?, placeholder: String?, row: Row) -> TextFieldContentView.Configuration {
        var contentConfiguration = cell.textFieldConfiguration()
        contentConfiguration.text = title
        contentConfiguration.placeholder = placeholder
        contentConfiguration.textColor = configureTextFieldTextColor(row: row)
        contentConfiguration.keyboardType = configureTextFieldKeyboardType(row: row)
        contentConfiguration.onChange = { [weak self] text in
            switch row {
            case .editName(_):
                self?.editingItem.name = text
                print("EditView - name Changed")
            case .editPrice(_):
                self?.editingItem.price = self?.doubleConvertToString(with: text)
                print("EditView - price Changed")
            case .editUrl(_):
                self?.editingItem.url = text
                print("EditView - url Changed")
            default: fatalError("텍스트필드 클로저 문제 발생")
            }
        }
        return contentConfiguration
    }
    
    func textViewConfiguration(for cell: UICollectionViewListCell, with note: String) -> TextViewContentView.Configuration {
        var contentConfiguration = cell.TextViewConfiguration()
        contentConfiguration.text = configurePlaceholder(with: note)
        contentConfiguration.textColor = configureTextViewTextColor(with: note)
        contentConfiguration.onchange = { [weak self] note in
            self?.editingItem.note = note
            print("EditView - Note Changed")
        }
        return contentConfiguration
    }
    
    private func configurePlaceholder(with note: String) -> String {
        if note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Note"
        } else {
            return note
        }
    }
    private func configureTextViewTextColor(with note: String) -> UIColor? {
        if note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || note == "Note" {
            return .placeholderText
        } else {
            return .label
        }
    }
    private func configureTextFieldTextColor(row: Row) -> UIColor? {
        switch row {
        case .editName(_): return .label
        case .editPrice(_): return .label
        case .editUrl(_): return .link
        default: return nil
        }
    }
    private func configureTextFieldKeyboardType(row: Row) -> UIKeyboardType {
        switch row {
        case .editName(_): return .default
        case .editPrice(_): return .decimalPad
        case .editUrl(_): return .URL
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
        case .editName(_): return Row.editName("").text
        case .editCategory(_): return Row.editCategory("").text
        case .editBrand(_): return Row.editBrand("").text
        case .editSize(_): return Row.editSize("").text
        case .editColor(_): return Row.editColor("").text
        case .editFit(_): return Row.editFit("").text
        case .editPrice(_): return Row.editPrice(nil).text
        case .editOrderDate(_): return Row.editOrderDate(Date()).text
        case .editUrl(_): return Row.editUrl("").text
        case .editNote(_): return Row.editNote("").text
        }
    }
}

//MARK: - UICollectionViewDelegate
extension EditViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let row = dataSource.itemIdentifier(for: indexPath) else { return false }
        
        switch row {
        case .editCategory(_):
            let vc = SelectCategoryViewController(customCategorys: customCategorys, selectedID: customCategorys.categoryOfName(withName: editingItem.category).id)
            vc.onchangeCategory = { [weak self] category in
                self?.editingItem.category = category
                self?.applySnapshot()
                print("EditView - Category changed")
            }
            vc.onchangeCustomCategorys = { [weak self] customCategorys in
                self?.customCategorys = customCategorys
                print("EditView - customCategorys Array Changed")
            }
            navigationController?.pushViewController(vc, animated: true)
            return false
        case .editBrand(_):
            let vc = SelectBrandViewController(customBrands: customBrands, selectedID: customBrands.brandOfName(withName: editingItem.brand).id)
            vc.onchangeBrand = { [weak self] brand in
                self?.editingItem.brand = brand
                //self?.prepareForUpdate()
                self?.applySnapshot()
                print("EditView - Brand changed")
            }
            vc.onchangeCustomBrands = {[weak self] customBrands in
                self?.customBrands = customBrands
                print("EditView - customBrands Array Changed")
            }
            navigationController?.pushViewController(vc, animated: true)
            return false
        case .editColor(_):
            let vc = SelectColorViewController(customColors: customColors, selectedID: customColors.colorOfName(withName: editingItem.color).id)
            vc.onchangeColor = { [weak self] color in
                self?.editingItem.color = color
                self?.applySnapshot()
                print("EditView - Color changed")
            }
            vc.onchangeCustomColors = { [weak self] customColors in
                self?.customColors = customColors
                print("EditView - customColors Array Changed")
            }
            navigationController?.pushViewController(vc, animated: true)
            return false
        case .editFit(_):
            let vc = SelectFitViewController(customFits: customFits, selectedID: customFits.fitOfName(withName: editingItem.fit).id)
            vc.onchangeFit = { [weak self] fit in
                self?.editingItem.fit = fit
                self?.applySnapshot()
                print("EditView - Fit changed")
            }
            vc.onchangeCustomFits = { [weak self] customFits in
                self?.customFits = customFits
                print("EditView - customFits Array Changed")
            }
            navigationController?.pushViewController(vc, animated: true)
            return false
        case .editSize(_):
            let vc = SelectSizeViewController(customSizes: customSizes, selectedID: customSizes.sizeOfName(withName: editingItem.size).id)
            vc.onchangeSize = { [weak self] size in
                self?.editingItem.size = size
                self?.applySnapshot()
                print("EditView - Size changed")
            }
            vc.onchangeCustomSizes = { [weak self] customSizes in
                self?.customSizes = customSizes
                print("EditView - customSizes Array Changed")
            }
            navigationController?.pushViewController(vc, animated: true)
            return false
        default: return false
        }
    }
}
