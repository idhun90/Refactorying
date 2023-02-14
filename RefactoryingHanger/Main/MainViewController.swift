//
//  MainViewController.swift
//  RefactoryingHanger
//
//  Created by 도헌 on 2023/02/02.
//

import UIKit

final class MainViewController: UIViewController {
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Int, Item.ID>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Item.ID>
    
    private var collectionView: UICollectionView!
    private var datasource: DataSource!
    private var snapshot: Snapshot!
    
    var items: [Item] = []
    
    lazy var customCategorys: [Category] = [
        Category(name: "Outer"),
        Category(name: "Top"),
        Category(name: "Bottom"),
        Category(name: "Shoes"),
        Category(name: "Acc")
    ]
    
    lazy var customBrands: [Brand] = [Brand(name: "None")] {
        didSet {
            // if deleted already selected Brand
//            var newSnapshot = datasource.snapshot()
//            newSnapshot.reconfigureItems(items.map { $0.id })
//            datasource.apply(newSnapshot)
        }
    }
    
    lazy var customColors: [Color] = [Color(name: "None")]
    lazy var customSizes: [Size] = [Size(name: "None")]
    lazy var customFits: [Fit] = [
        Fit(name: "Slim"),
        Fit(name: "Regular"),
        Fit(name: "SemiOver"),
        Fit(name: "Over")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNaviItem()
        configureCollectionView()
        configureDataSource()
        applySnapshot()
    }

}

extension MainViewController {
    
    private func configureNaviItem() {
        navigationItem.title = "Main"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(tappedAddButton(_:)))
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self
        view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func createLayout() -> UICollectionViewLayout {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .grouped)
        listConfiguration.showsSeparators = false
        listConfiguration.trailingSwipeActionsConfigurationProvider = makeSwipeAction
        return UICollectionViewCompositionalLayout.list(using: listConfiguration)
    }
    
    private func makeSwipeAction(for indexPath: IndexPath?) -> UISwipeActionsConfiguration? {
        guard let indexPath = indexPath, let id = datasource.itemIdentifier(for: indexPath) else { return nil }
        let deleteActionTitle = NSLocalizedString("Delete", comment: "Delete Action Title")
        let deleteAction = UIContextualAction(style: .destructive, title: deleteActionTitle) { [weak self] _, _, completion in
            self?.deleteItem(withID: id)
            self?.applySnapshot()
            completion(false)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    private func configureDataSource() {
        
        let cellRegistration = UICollectionView.CellRegistration(handler: cellRegistrationHandler)
        
        datasource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        })
    }
    
    func applySnapshot(reloading ids: [Item.ID] = []) { /// 매개변수의 값을 빈배열로 설정하면 식별자를 제공하지 않고도 viewDidLoad()에서 호출할 수 있음.
        snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(items.map { $0.id })
        if !ids.isEmpty {
            snapshot.reloadItems(ids)
        }
        datasource.apply(snapshot)
    }
}

extension MainViewController {
    
    private func cellRegistrationHandler(cell: UICollectionViewListCell, indexPath: IndexPath, id: Item.ID) {
        let item = item(withID: id)
        
        ///Cell UI 설정
        var content = cell.defaultContentConfiguration()
        content.text = item.name
        content.secondaryText = item.brand + " • " + item.category + " • " + item.size
        //content.secondaryText = customBrands.brandOfName(withName: item.brand).name + " • " + item.orderDate.formatted(date: .numeric, time: .omitted)
        content.secondaryTextProperties.font = .preferredFont(forTextStyle: .caption1)
        cell.contentConfiguration = content
        
        /// Cell Custom Button 설정
        var doneButtonConfiguration = doneButtonConfiguration(for: item)
        doneButtonConfiguration.tintColor = .systemGreen
        cell.accessories = [.customView(configuration: doneButtonConfiguration), .disclosureIndicator(displayed: .always)]
        
        /// Cell BackgroundColor 설정
        var backgroundContent = UIBackgroundConfiguration.listGroupedCell()
        backgroundContent.backgroundColor = .systemGroupedBackground
        cell.backgroundConfiguration = backgroundContent
        
    }
    
    private func item(withID id: Item.ID) -> Item {
        let index = items.indexOfItem(with: id)
        return items[index]
    }
    
    /// 수정된 아이템을 받고, 해당 아이템 id 값으로 인덱스를 조회하여 업데이트된 내용을 갱신해주는 메소드
    private func updateItem(_ item: Item) {
        let index = items.indexOfItem(with: item.id)
        items[index] = item
    }
    
    func completeItem(withID id: Item.ID) {
        var item = item(withID: id)
        item.isComplete.toggle()
        updateItem(item) // 버튼 클릭 -> 데이터 변경된 정보 갱신
        print("checked, buttonState: \(item.isComplete)")
        /// 데이터는 변하지만 UI는 변하지 않음 -> 스냅샷 새로 갱신해야 한다.
        applySnapshot(reloading: [id]) /// 여전히 UI가 변하지 않는다. UI를 업데이트하려면 스냅샷의 reloadItem(_:) 메소드를 호출하여 사용자가 변경한 아이템을 스냅샷에 알려야한다.
    }
    
    func addItem(_ item: Item) {
        items.append(item)
    }
    
    func deleteItem(withID id: Item.ID) {
        let index = items.indexOfItem(with: id)
        items.remove(at: index)
    }
    
    func pushViewController(withID id: Item.ID, withCustomCategory: [Category], withCustomBrands: [Brand], withCustomColors: [Color], withCustomFits: [Fit] , withCustomSizes: [Size]) {
        let item = item(withID: id)
        let vc = DetailViewController(item: item, customCategorys: withCustomCategory, customBrands: withCustomBrands, customColors: withCustomColors, customFits: withCustomFits, customSizes: withCustomSizes) { [weak self] item in
            self?.updateItem(item)
            self?.applySnapshot(reloading: [item.id])
            print("MainView - item Changed(Edit)")
        }
        vc.onchangeCustomCategorys = { [weak self] customCategorys in
            self?.customCategorys = customCategorys
            print("MainView - customCategorys Array Changed(Edit)")
        }
        vc.onchangeCustomBrands = { [weak self] customBrands in
            self?.customBrands = customBrands
            print("MainView - customBrands Array Changed(Edit)")
        }
        vc.onchangeCustomColors = { [weak self] customColors in
            self?.customColors = customColors
            print("MainView - customColors Array Changed(Edit)")
        }
        vc.onchangeCustomFits = { [weak self] customFits in
            self?.customFits = customFits
            print("MainView - customFits Array Changed(Edit)")
        }
        vc.onchangeCustomSizes = { [weak self] customSizes in
            self?.customSizes = customSizes
            print("MainView - customSizes Array Changed(Edit)")
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension MainViewController {
    
    /// Cell Custom Button 설정
    private func doneButtonConfiguration(for item: Item) -> UICellAccessory.CustomViewConfiguration {
        let symbolName = item.isComplete ? "checkmark.circle.fill" : "checkmark.circle"
        let symbolConfiguration = UIImage.SymbolConfiguration(textStyle: .title1)
        let image = UIImage(systemName: symbolName, withConfiguration: symbolConfiguration)
        let button = ItemDoneButton()
        button.addTarget(self, action: #selector(tappedDoneButton(_:)), for: .touchUpInside)
        button.id = item.id
        button.setImage(image, for: .normal)
        return UICellAccessory.CustomViewConfiguration(customView: button, placement: .leading(displayed: .always))
    }
}

extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        ///indexPath를 활용하지 않고 id 값으로 아이템을 추적한다.
        let id = items[indexPath.item].id
        pushViewController(withID: id,
                           withCustomCategory: customCategorys,
                           withCustomBrands: customBrands,
                           withCustomColors: customColors,
                           withCustomFits: customFits,
                           withCustomSizes: customSizes)
        print(id)
    }
}
