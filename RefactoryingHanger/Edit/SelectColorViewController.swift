//
//  SelectColorViewController.swift
//  RefactoryingHanger
//
//  Created by 도헌 on 2023/02/13.
//

import UIKit

struct Color: Identifiable, Hashable {
    var id: String = UUID().uuidString
    var name: String
}

extension Array where Element == Color {
    func indexOfCustomColor(withID id: Color.ID) -> Self.Index {
        guard let index = self.firstIndex(where: { $0.id == id } ) else {
            fatalError("no have maching color")
        }
        return index
    }
    
    func colorOfName(withName name: String) -> Color {
        guard let color = self.first(where: { $0.name == name } ) else {
            guard let defaultColor = self.first(where: { $0.name == "None" } ) else { fatalError("오류 발생")}
            return defaultColor
        }
        return color
    }
}

final class SelectColorViewController: UIViewController {
    
    enum listSection: Int {
        case defaultList
        case customList
    }
    
    var customColors: [Color] {
        didSet {
            onchangeCustomColors(customColors)
        }
    }
    
    var selectedID: Color.ID
    var onchangeColor: ((String) -> Void) = { _ in }
    var onchangeCustomColors: (([Color]) -> Void) = { _ in }
    
    init(customColors: [Color], selectedID: Color.ID) {
        self.customColors = customColors
        self.selectedID = selectedID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private typealias DataSource = UICollectionViewDiffableDataSource<listSection, Color.ID>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<listSection, Color.ID>
    
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
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
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
            self?.deleteColor(withID: id)
            self?.applySnapshot()
            completion(false)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    private func configureDataSource() {
        let cellRegistraion = UICollectionView.CellRegistration<UICollectionViewListCell, Color.ID> { [weak self] cell, indexPath, itemIdentifier in
            guard let self = self else { return }
            guard let section = listSection(rawValue: indexPath.section) else { return }
            var contentConfiguration = UIListContentConfiguration.valueCell()

            switch section {
            case .defaultList: contentConfiguration.text = self.customColors.colorOfName(withName: "None").name
            case .customList: contentConfiguration.text = self.customColor(withID: itemIdentifier).name
            }
            
            cell.contentConfiguration = contentConfiguration
            cell.accessories = itemIdentifier == self.selectedID ? [.checkmark(displayed: .always)] : []
        }
        
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistraion, for: indexPath, item: itemIdentifier)
        })
    }
    
    private func applySnapshot(reloading ids: [Color.ID] = []) {
        snapshot = Snapshot()
        snapshot.appendSections([.defaultList, .customList])
        snapshot.appendItems([customColorID(withName: "None")], toSection: .defaultList)
        snapshot.appendItems((customColors.filter { $0.id != customColorID(withName: "None") }.map { $0.id }).reversed(), toSection: .customList)
        if !ids.isEmpty {
            snapshot.reloadItems(ids)
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
extension SelectColorViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        updateSelectedId(collectionView: collectionView, indexPath: indexPath)
        guard let id = dataSource.itemIdentifier(for: indexPath) else { return }
        print("selected:", customColor(withID: id).name)
        onchangeColor(customColor(withID: id).name)
    }
    
    private func updateSelectedId(collectionView: UICollectionView, indexPath: IndexPath) {
        guard let currentSelectedId = dataSource.itemIdentifier(for: indexPath) else { return }
        if selectedID == currentSelectedId { return }
        selectedID = currentSelectedId
        
        var newSnapshot = dataSource.snapshot()
        newSnapshot.reconfigureItems(customColors.map { $0.id })
        dataSource.apply(newSnapshot, animatingDifferences: false)
    }
}

extension SelectColorViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text else { return false }

        if validationText(with: text) {
            customColors.append(Color(name: text.trimmingCharacters(in: .whitespaces))) // 앞뒤 공백만 제거, only remove left, trailing whitespace
            applySnapshot()
            print("Added:", text)
        }
        textField.text = nil
        return true
    }

    private func validationText(with text: String) -> Bool {
        let removedWhitespacesText = text.replacingOccurrences(of: " ", with: "") // 중복 검사를 위해 모든 공백 제거 removeAllspaceForTest
        let isEmpty = removedWhitespacesText.isEmpty // 모든 공백 제거 후 빈값인지 체크, checkIsEmpty
        let isDuplication = customColors.contains(where: { $0.name.replacingOccurrences(of: " ", with: "").caseInsensitiveCompare(removedWhitespacesText) == .orderedSame})// 모든 공백 제거한 값끼리 대소문자 구분 없이 같은 값을 가지고 있는지 체크
        return !isEmpty && !isDuplication
        
    }
}

extension SelectColorViewController {

    private func customColorID(withName name: String) -> Color.ID {
        let color = customColors.colorOfName(withName: name)
        return color.id
    }
    
    private func customColor(withID id: Color.ID) -> Color {
        let index = customColors.indexOfCustomColor(withID: id)
        return customColors[index]
    }

    private func deleteColor(withID id: Color.ID) {
        if selectedID == id {
            selectedID = customColorID(withName: "None")
            onchangeColor(customColor(withID: customColorID(withName: "None")).name)
            
            var newSnapshot = dataSource.snapshot()
            newSnapshot.reconfigureItems(customColors.map { $0.id })
            dataSource.apply(newSnapshot, animatingDifferences: false)

        }
        let index = customColors.indexOfCustomColor(withID: id)
        print("deleted: \(customColors[index].name)")
        customColors.remove(at: index)
    }
}

