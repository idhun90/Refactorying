//
//  SelectViewController.swift
//  RefactoryingHanger
//
//  Created by 도헌 on 2023/02/04.
//

import UIKit

struct Brand: Identifiable, Hashable {
    var id: String = UUID().uuidString
    var name: String
}

extension Array where Element == Brand {
    func indexOfCustomBrand(withID id: Brand.ID) -> Self.Index {
        guard let index = self.firstIndex(where: { $0.id == id } ) else {
            fatalError("no have maching brand")
        }
        return index
    }
    
    func brandOfName(withName name: String) -> Brand {
        guard let brand = self.first(where: { $0.name == name } ) else {
            guard let defaultBrand = self.first(where: { $0.name == "None" } ) else { fatalError("오류 발생")}
            return defaultBrand
        }
        return brand
    }
}

final class SelectBrandViewController: UIViewController {
    
    enum listSection: Int {
        case defaultList
        case customList
    }
    
    var defaultBrand = Brand(name: "None")
//    lazy var customBrands: [Brand] = [defaultBrand] {
//        didSet {
//            onchangeCustomBrands(customBrands)
//            print("customBrands didSet 작동")
//        }
//    }
    var customBrands: [Brand] {
        didSet {
            onchangeCustomBrands(customBrands)
        }
    }
    //lazy var selectedID = defaultBrand.id
    var selectedID: Brand.ID
    
    init(customBrands: [Brand], selectedID: Brand.ID) {
        self.customBrands = customBrands
        self.selectedID = selectedID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var onchange: ((String) -> Void) = { _ in }
    var onchangeCustomBrands: (([Brand]) -> Void) = { _ in }
    
    private typealias DataSource = UICollectionViewDiffableDataSource<listSection, Brand.ID>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<listSection, Brand.ID>
    
    let addTextField: UITextField = {
        let view = UITextField()
        view.placeholder = "Add Custom"
        view.backgroundColor = .secondarySystemGroupedBackground
        view.leftViewMode = .always
        view.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 44))
        view.layer.cornerRadius = 10
        view.clearButtonMode = .whileEditing
        view.autocapitalizationType = .none
        view.layer.shadowOpacity = 0.18
        view.layer.shadowOffset = CGSize.zero
        return view
    }()
    
    private var collectionView: UICollectionView!
    private var dataSource: DataSource!
    private var snapshot: Snapshot!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        configureCollectionView()
        configureUI()
        configureDataSource()
        applySnapshot()
        isModalInPresentation = true
    }

    private func configureUI() {
        addTextField.delegate = self
        view.addSubview(addTextField)
        
        addTextField.translatesAutoresizingMaskIntoConstraints = false
        let spacing: CGFloat = 10
        NSLayoutConstraint.activate([
            addTextField.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -spacing),
            addTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: spacing),
            addTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -spacing),
            addTextField.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self
        collectionView.keyboardDismissMode = .onDrag
        view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(greaterThanOrEqualTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func createLayout() -> UICollectionViewLayout {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        listConfiguration.trailingSwipeActionsConfigurationProvider = makeSwipeActions
        return UICollectionViewCompositionalLayout.list(using: listConfiguration)
    }
    
    private func makeSwipeActions(for indexPath: IndexPath?) -> UISwipeActionsConfiguration? {
        guard let indexPath = indexPath, let id = dataSource.itemIdentifier(for: indexPath) else { return nil }
        guard indexPath.section != 0 else { return nil }
        let deleteActionName = NSLocalizedString("Delete", comment: "Delete action title")
        let deleteAction = UIContextualAction(style: .destructive, title: deleteActionName) { [weak self] _, _, completion in
            self?.deleteBrand(withID: id)
            self?.applySnapshot()
            completion(false)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    private func configureDataSource() {
        let cellRegistraion = UICollectionView.CellRegistration<UICollectionViewListCell, Brand.ID> { [weak self] cell, indexPath, itemIdentifier in
            guard let self = self else { return }
            guard let section = listSection(rawValue: indexPath.section) else { return }
            var contentConfiguration = UIListContentConfiguration.valueCell()

            switch section {
            case .defaultList: contentConfiguration.text = self.defaultBrand.name
            case .customList: contentConfiguration.text = self.customBrand(withID: itemIdentifier).name
            }
            
            cell.contentConfiguration = contentConfiguration
            cell.accessories = itemIdentifier == self.selectedID ? [.checkmark(displayed: .always)] : []
            //cell.accessories = indexPath == self.selectedIndexPath ? [.checkmark(displayed: .always)] : []
            
            //❌ cell.accessories = cell.isSelected ? [.checkmark()] : []
            //❌ cell.accessories = self.customBrand(withID: itemIdentifier).isSelected ? [.checkmark(displayed: .always)] : []
            
//            ❌ var accessoris: [UICellAccessory] = []
//            if self.customBrands.contains(where: { $0.isSelected }) {
//                accessoris.append(.checkmark(displayed: .always))
//            }
//            cell.accessories = accessoris
        }
        
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistraion, for: indexPath, item: itemIdentifier)
        })
    }
    
    private func applySnapshot(reloading ids: [Brand.ID] = []) {
        snapshot = Snapshot()
        snapshot.appendSections([.defaultList, .customList])
        //snapshot.appendItems([defaultBrand.id], toSection: .defaultList)
        snapshot.appendItems([customBrandID(withName: "None")], toSection: .defaultList)
        //snapshot.appendItems((customBrands.filter { $0.id != defaultBrand.id }.map { $0.id }).reversed(), toSection: .customList) // 새로 추가되는 아이템이 맨 위로 가도록, added item to top cell
        snapshot.appendItems((customBrands.filter { $0.id != customBrandID(withName: "None") }.map { $0.id }).reversed(), toSection: .customList)
        if !ids.isEmpty {
            snapshot.reloadItems(ids)
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
extension SelectBrandViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        updateSelectedId(collectionView: collectionView, indexPath: indexPath)
        guard let id = dataSource.itemIdentifier(for: indexPath) else { return }
        print("selected:", customBrand(withID: id).name)
        onchange(customBrand(withID: id).name)

//        DispatchQueue.main.async {
//            self.dataSource.applySnapshotUsingReloadData(self.dataSource.snapshot())//no animation
//        }
//
        //✅ snapshot.reloadSections([.defaultList, .customList])
        //everyItem all checked
        //❌ dataSource.apply(dataSource.snapshot())
        //var snapshot = dataSource.snapshot()
        //❌ snapshot.reloadItems([id])
        //❌ snapshot.reconfigureItems([id])
        //dataSource.apply(snapshot, animatingDifferences: true)
        //❌ applySnapshot(reloading: [id])
        /*
         */
//        guard let id = dataSource.itemIdentifier(for: indexPath) else { return }
//        var brand = customBrand(withID: id)
//        brand.isSelected.toggle()
//        updateBrand(brand)
//        applySnapshot(reloading: [id])

//        switch section {
//        case .defaultList:
//            guard !defaultBrand.isSelected else { return }
//            var customBrands = customBrands.filter { $0.isSelected }
//            if !customBrands.isEmpty {
//                for index in 0...customBrands.count-1 {
//                    customBrands[index].isSelected.toggle()
//                    updateBrand(customBrands[index])
//                    applySnapshot(reloading: [customBrands[index].id])
//                }
//            }
//            defaultBrand.isSelected.toggle()
//            updateBrand(defaultBrand)
//            applySnapshot(reloading: [defaultBrand.id])
//        case .customList:
//            guard let id = dataSource.itemIdentifier(for: indexPath) else { return }
//            changeToggle(withID: id)
//        }
    }
    
    private func updateSelectedId(collectionView: UICollectionView, indexPath: IndexPath) {
        guard let currentSelectedId = dataSource.itemIdentifier(for: indexPath) else { return }
        if selectedID == currentSelectedId { return }
        selectedID = currentSelectedId
        
        DispatchQueue.main.async {
            self.dataSource.applySnapshotUsingReloadData(self.dataSource.snapshot())
        }

//        if self.selectedIndexPath == indexPath { return }
//        if let previousCell = collectionView.cellForItem(at: selectedIndexPath) as? UICollectionViewListCell {
//            previousCell.accessories = []
//        }
//        if let cell = collectionView.cellForItem(at: indexPath) as? UICollectionViewListCell {
//            cell.accessories = [.checkmark(displayed: .always)]
//        }
//        self.selectedIndexPath = indexPath
        
    }
    
    // not used
//    private func changeToggle(withID id: Brand.ID) {
//        var selectedBrand = customBrand(withID: id)
//        var anotherBrand = customBrands.filter { ($0.id != id)&&($0.isSelected) }
//        print(anotherBrand)
//        if !anotherBrand.isEmpty {
//            for index in 0...anotherBrand.count-1 {
//                if anotherBrand[index].isSelected {
//                    anotherBrand[index].isSelected.toggle()
//                    updateBrand(anotherBrand[index])
//                    applySnapshot(reloading: [anotherBrand[index].id])
//                }
//            }
//        }
//
//        if !selectedBrand.isSelected {
//            selectedBrand.isSelected.toggle()
//            updateBrand(selectedBrand)
//            applySnapshot(reloading: [id])
//        }
//    }

}

extension SelectBrandViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text else { return false }

        if validationText(with: text) {
            customBrands.append(Brand(name: text.trimmingCharacters(in: .whitespaces))) // 앞뒤 공백만 제거, only remove left, trailing whitespace
            applySnapshot()
            print("Added:", text)
        }
        textField.text = nil
        return true
    }

    private func validationText(with text: String) -> Bool {
        let removedWhitespacesText = text.replacingOccurrences(of: " ", with: "") // 중복 검사를 위해 모든 공백 제거 removeAllspaceForTest
        let isEmpty = removedWhitespacesText.isEmpty // 모든 공백 제거 후 빈값인지 체크, checkIsEmpty
        let isDuplication = customBrands.contains(where: { $0.name.replacingOccurrences(of: " ", with: "").caseInsensitiveCompare(removedWhitespacesText) == .orderedSame})// 모든 공백 제거한 값끼리 대소문자 구분 없이 같은 값을 가지고 있는지 체크
        return !isEmpty && !isDuplication
        
    }
}

extension SelectBrandViewController {
    
    func fetchSelectedBrandID(name: String) {
        selectedID = customBrandID(withName: name)
    }

    private func customBrandID(withName name: String) -> Brand.ID {
        let brand = customBrands.brandOfName(withName: name)
        return brand.id
    }
    
    private func customBrand(withID id: Brand.ID) -> Brand {
        let index = customBrands.indexOfCustomBrand(withID: id)
        return customBrands[index]
    }
    
    private func updateBrand(_ brand: Brand) {
        let index = customBrands.indexOfCustomBrand(withID: brand.id)
        customBrands[index] = brand
        print("data updated")
    }
    
    private func deleteBrand(withID id: Brand.ID) {
        if selectedID == id {
            selectedID = customBrandID(withName: "None")
            onchange(customBrand(withID: customBrandID(withName: "None")).name)
        }
        let index = customBrands.indexOfCustomBrand(withID: id)
        print("deleted: \(customBrands[index].name)")
        customBrands.remove(at: index)
    }
}

