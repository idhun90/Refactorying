//
//  AddViewController.swift
//  RefactoryingHanger
//
//  Created by 도헌 on 2023/02/02.
//

import UIKit


final class DetailViewController: UIViewController {

enum Section: Int, Hashable {
    case main
}

enum Row: Hashable {
    case name
    case category
    case brand
    case size
    case color
    case price
    case orderDate
    /// 1~16 TextFieldContentView.swift 확인
    /// 17. AddViewController + CellConfiguration.swift 확인
    /// 18.부터 편집 가능한 textField를 사용자 UI에 구현합니다.
    /// 먼저 편집 가능한 경우 나타나도록 Row에 case를 추가하고, editing snapshot에 항목을 추가합니다.
    /// 그런 다음 1~17에서 정의한 Configuration을 사용하여 편집 제품명 Cell을 구성합니다.
    /// 18.편집 모드에서 사용할 String 연관 값을 가진 case 생성

    var name: String {
        switch self {
        case .name: return "Name"
        case .category: return "Category"
        case .brand: return "Brand"
        case .size: return "Size"
        case .color: return "Color"
        case .price: return "Price"
        case .orderDate: return "OrderDate"
        }
    }
}
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Row>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Row>
    
    private var collectionView: UICollectionView!
    private var dataSource: DataSource!
    private var snapshot: Snapshot!
    
    var item: Item
    var editingItem: Item
    
    init(item: Item) { // 초기화 및 메인화면에서 화면 전환 시 값 전달
        self.item = item
        self.editingItem = item
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavibarItem()
        configureCollectionView()
        configureDataSource()
        applySnapshot()
    }

    private func configureNavibarItem() {
        navigationItem.title = "Detail"
        let rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(tappedEditButton))
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    @objc private func tappedEditButton() {
        let viewController = EditViewController()
        viewController.fetchItem(with: item)
        viewController.sendEditingItem = { [weak self] editingItem in
            self?.editingItem = editingItem
            self?.prepareForUpdate()
        }
        let nvc = UINavigationController(rootViewController: viewController)
        present(nvc, animated: true)
    }

    @objc private func tappedAddButton(_ sender: UIButton) {
        print("TappedAddButton")
    }
}

extension DetailViewController {
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: creatLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.delegate = self
        view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.0),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0)
        ])
    }
    
    private func creatLayout() -> UICollectionViewLayout {
        let listConfiguraiton = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        return UICollectionViewCompositionalLayout.list(using: listConfiguraiton)
    }
    
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Row>(handler: cellRegistrationHandler)
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, row in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: row)
        })
    }
    
    private func applySnapshot() {
        snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems([Row.name, Row.category, Row.brand, Row.size, Row.color, Row.price, Row.orderDate])
        dataSource.apply(snapshot)
    }
    
    private func prepareForUpdate() {
        if editingItem != item {
            item = editingItem
            print("item updated")
        }
        snapshot = dataSource.snapshot() // if use snapshot = Snaptshot(), reloadSection, reloadItems will be error And no use reloadItems the UI will not be changed
        //snapshot.reloadItems([Row.name])
        snapshot.reloadSections([.main])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}
//MARK: - CellRegistration
extension DetailViewController {
    private func cellRegistrationHandler(cell: UICollectionViewListCell, indexPath: IndexPath, row: Row) {
        cell.contentConfiguration = listConfiguration(for: cell, at: row)
    }
}

extension DetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}
