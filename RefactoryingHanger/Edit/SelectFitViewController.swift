//
//  SelectFitViewController.swift
//  RefactoryingHanger
//
//  Created by 도헌 on 2023/02/14.
//

import UIKit

struct Fit: Identifiable, Hashable {
    var id: String = UUID().uuidString
    var name: String
}

extension Array where Element == Fit {
    func indexOfCustomFit(withID id: Fit.ID) -> Self.Index {
        guard let index = self.firstIndex(where: { $0.id == id } ) else {
            fatalError("no have maching fit")
        }
        return index
    }
    
    func fitOfName(withName name: String) -> Fit {
        guard let category = self.first(where: { $0.name == name } ) else {
            guard let defaultCategory = self.first(where: { $0.name == "Regular" } ) else { fatalError("오류 발생")}
            return defaultCategory
        }
        return category
    }
}

final class SelectFitViewController: UIViewController {
    
    enum listSection: Int {
        case defaultList
        case customList
    }
    
    var customFits: [Fit] {
        didSet {
            onchangeCustomFits(customFits)
        }
    }
    
    var selectedID: Fit.ID
    var onchangeFit: ((String) -> Void) = { _ in }
    var onchangeCustomFits: (([Fit]) -> Void) = { _ in }
    
    init(customFits: [Fit], selectedID: Fit.ID) {
        self.customFits = customFits
        self.selectedID = selectedID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private typealias DataSource = UICollectionViewDiffableDataSource<listSection, Fit.ID>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<listSection, Fit.ID>
    
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
            self?.deleteFit(withID: id)
            self?.applySnapshot()
            completion(false)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    private func configureDataSource() {
        let cellRegistraion = UICollectionView.CellRegistration<UICollectionViewListCell, Fit.ID> { [weak self] cell, indexPath, itemIdentifier in
            guard let self = self else { return }
            var contentConfiguration = UIListContentConfiguration.valueCell()
            contentConfiguration.text = self.customFit(withID: itemIdentifier).name
            cell.contentConfiguration = contentConfiguration
            cell.accessories = itemIdentifier == self.selectedID ? [.checkmark(displayed: .always)] : []
        }
        
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistraion, for: indexPath, item: itemIdentifier)
        })
    }
    
    private func applySnapshot(reloading ids: [Fit.ID] = []) {
        snapshot = Snapshot()
        snapshot.appendSections([.defaultList, .customList])
        snapshot.appendItems([customFitID(withName: "Slim"), customFitID(withName: "Regular"), customFitID(withName: "SemiOver"), customFitID(withName: "Over")], toSection: .defaultList)

        snapshot.appendItems((customFits.filter { ($0.id != customFitID(withName: "Slim")) && ($0.id != customFitID(withName: "Regular")) && ($0.id != customFitID(withName: "SemiOver")) && ($0.id != customFitID(withName: "Over")) }.map { $0.id }).reversed(), toSection: .customList)
        if !ids.isEmpty {
            snapshot.reloadItems(ids)
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
extension SelectFitViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        updateSelectedId(collectionView: collectionView, indexPath: indexPath)
        guard let id = dataSource.itemIdentifier(for: indexPath) else { return }
        print("selected:", customFit(withID: id).name)
        onchangeFit(customFit(withID: id).name)

    }
    
    private func updateSelectedId(collectionView: UICollectionView, indexPath: IndexPath) {
        guard let currentSelectedId = dataSource.itemIdentifier(for: indexPath) else { return }
        if selectedID == currentSelectedId { return }
        selectedID = currentSelectedId
        
        var newSnapshot = dataSource.snapshot()
        newSnapshot.reconfigureItems(customFits.map { $0.id })
        dataSource.apply(newSnapshot, animatingDifferences: false)
    }
}

extension SelectFitViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text else { return false }

        if validationText(with: text) {
            customFits.append(Fit(name: text.trimmingCharacters(in: .whitespaces))) // 앞뒤 공백만 제거, only remove left, trailing whitespace
            applySnapshot()
            print("Added:", text)
        }
        textField.text = nil
        return true
    }

    private func validationText(with text: String) -> Bool {
        let removedWhitespacesText = text.replacingOccurrences(of: " ", with: "") // 중복 검사를 위해 모든 공백 제거 removeAllspaceForTest
        let isEmpty = removedWhitespacesText.isEmpty // 모든 공백 제거 후 빈값인지 체크, checkIsEmpty
        let isDuplication = customFits.contains(where: { $0.name.replacingOccurrences(of: " ", with: "").caseInsensitiveCompare(removedWhitespacesText) == .orderedSame})// 모든 공백 제거한 값끼리 대소문자 구분 없이 같은 값을 가지고 있는지 체크
        return !isEmpty && !isDuplication
        
    }
}

extension SelectFitViewController {

    private func customFitID(withName name: String) -> Fit.ID {
        let fit = customFits.fitOfName(withName: name)
        return fit.id
    }
    
    private func customFit(withID id: Fit.ID) -> Fit {
        let index = customFits.indexOfCustomFit(withID: id)
        return customFits[index]
    }

    private func deleteFit(withID id: Fit.ID) {
        if selectedID == id {
            selectedID = customFitID(withName: "Regular")
            onchangeFit(customFit(withID: customFitID(withName: "Regular")).name)
            
            var newSnapshot = dataSource.snapshot()
            newSnapshot.reconfigureItems(customFits.map { $0.id })
            dataSource.apply(newSnapshot, animatingDifferences: false)

        }
        let index = customFits.indexOfCustomFit(withID: id)
        print("deleted: \(customFits[index].name)")
        customFits.remove(at: index)
    }
}



