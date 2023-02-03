//
//  AddViewController.swift
//  RefactoryingHanger
//
//  Created by 도헌 on 2023/02/02.
//

import UIKit

enum Section: Int, Hashable {
    /// viewing Mode
    case main
    /// editing Mode
    case name
    case category
    case brand
    case size
    case color
    case price
    case orderDate
    
    ///편집 모드일 때 헤더 타이틀 사용 목적(editing Mode section title)
    var name: String {
        switch self {
        case .main: return ""
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
    case header(String) // 연관값이 String 타입의 헤더 (편집 모드일 때 사용됨), 연관값을 헤더로 표기한다.
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
    case editName(String)
    case editCategory(String)
    case editBrand(String)
    case editSize(String?)
    case editColor(String?)
    case editPrice(Double?)
    case editOrderDate(Date)
    
    var name: String? {
        switch self {
        case .name: return "Name"
        case .category: return "Category"
        case .brand: return "Brand"
        case .size: return "Size"
        case .color: return "Color"
        case .price: return "Price"
        case .orderDate: return "OrderDate"
        default: return nil
        }
    }
}

final class AddViewController: UIViewController {
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Row>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Row>
    
    private var collectionView: UICollectionView!
    private var dataSource: DataSource!
    private var snapshot: Snapshot!
    
    var item: Item
    
    init(item: Item) { // 초기화 및 메인화면에서 화면 전환 시 값 전달
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationItem()
        configureCollectionView()
        configureDataSource()
        updateSnapshotForViewing()
        //dump(item)
    }
    
    private func configureNavigationItem() {
        navigationItem.rightBarButtonItem = editButtonItem
    }
    
    //MARK: - 편집 모드 토글
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
            print("Editing Mode")
            updateSnapshotForEditing() // 스냅샷 갱신으로 UI 전환
        } else {
            print("Viewing Mode")
            updateSnapshotForViewing() // // 스냅샷 갱신으로 UI 전환
        }
    }
    
    @objc private func tappedAddButton(_ sender: UIButton) {
        print("TappedAddButton")
    }
}

extension AddViewController {
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
        var listConfiguraiton = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        listConfiguraiton.headerMode = .firstItemInSection
        return UICollectionViewCompositionalLayout.list(using: listConfiguraiton)
    }
    
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Row>(handler: cellRegistrationHandler)
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, row in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: row)
        })
    }
    
    private func updateSnapshotForViewing() {
        snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems([Row.header(""), Row.name, Row.category, Row.brand, Row.size, Row.color, Row.price, Row.orderDate], toSection: .main)
        dataSource.apply(snapshot)
    }
    
    /// 인덱스를 통해 섹션 번호 생성
    /// 디테일 화면 일 때는 모든 아이템이 0 섹션에 표시되고
    /// 편집 모드일 때는 각각 섹션 1, 2, 3 ... 으로 구분됨.
    private func section(for indexPath: IndexPath) -> Section {
        /// isEditing은 시스템에서 기본 제공하는 Bool타입 프로퍼티
        /// edittingButton을 통해 isEditing을 토글할 수 있고, setEdting(_: animaited:) 메소드를 통해서도 isEditng을 전환시킬 수 있다.
        let sectionNumber = isEditing ? indexPath.section + 1 : indexPath.section
        //print("sectionNumber", sectionNumber)
        guard let section = Section(rawValue: sectionNumber) else {
            fatalError("no have matching section Number ")
        }
        //print("해당 section", section)
        return section
    }
}
//MARK: - CellRegistration
extension AddViewController {
    private func cellRegistrationHandler(cell: UICollectionViewListCell, indexPath: IndexPath, row: Row) {
        let section = section(for: indexPath) // 디테일 모드, 편집 모드에 따른 분기 처리를 위한 용도
        //print(section)
        //print(#function)
        switch (section, row) {
        case (_, .header(let title)): // 모든 섹션에 헤더 타이틀 cell 적용 // let 설정을 하지 않아서 계속 오류 발생했던 것
            cell.contentConfiguration = headerConfiguration(for: cell, with: title)
        case (.main, _):
            cell.contentConfiguration = listConfiguration(for: cell, at: row)
        ///20. (.name, editName(let title)에 대한 case 및 titleConfiguration 적용
        case (.name, .editName(let name)):
            cell.contentConfiguration = titleConfiguration(for: cell, with: name, placeholder: "name")
        case (.category, .editCategory(let category)):
            cell.contentConfiguration = editListConfiguration(for: cell, with: category, at: .category)
            cell.accessories = [.disclosureIndicator(displayed: .always)]
        case (.brand, .editBrand(let brand)):
            cell.contentConfiguration = editListConfiguration(for: cell, with: brand, at: .brand)
            cell.accessories = [.disclosureIndicator(displayed: .always)]
        case (.size, .editSize(let size)):
            cell.contentConfiguration = editListConfiguration(for: cell, with: size, at: .size)
            cell.accessories = [.disclosureIndicator(displayed: .always)]
        case (.color, .editColor(let color)):
            cell.contentConfiguration = titleConfiguration(for: cell, with: color, placeholder: "color")
        case (.price, .editPrice(let price)):
            if let price = price {
                cell.contentConfiguration = titleConfiguration(for: cell, with: String(price), placeholder: "price")
            } else {
                cell.contentConfiguration = titleConfiguration(for: cell, with: nil, placeholder: "price")
            }
        case (.orderDate, .editOrderDate(let date)):
            cell.contentConfiguration = datePickerConfiguration(for: cell, with: date)
        default:
            fatalError("error (section, row)")
        }
    }
}

//MARK: - 편집 모드 일 때(Editing Mode)
extension AddViewController {
    
    private func updateSnapshotForEditing() {
        //print(#function)
        var snapshot = Snapshot()
        snapshot.appendSections([.name, .category, .brand, .size, .color, .price, .orderDate])
        /// 1~16 TextFieldContentView.swift 확인
        /// 17. AddViewController + CellConfiguration.swift 확인
        /// 18. AddViewController.swift 확인
        /// 19. 18번에서 생성한 case, .name section에 추가
        snapshot.appendItems([.header(Section.name.name), .editName(item.name)], toSection: .name)
        snapshot.appendItems([.header(Section.category.name), .editCategory(item.category)], toSection: .category)
        snapshot.appendItems([.header(Section.brand.name), .editBrand(item.brand)], toSection: .brand)
        snapshot.appendItems([.header(Section.size.name), .editSize(item.size ?? "None")], toSection: .size) //code 198, what difference? what is parameter?
        snapshot.appendItems([.header(Section.color.name), .editColor(item.color)], toSection: .color)
        snapshot.appendItems([.header(Section.price.name), .editPrice(item.price)], toSection: .price)
        snapshot.appendItems([.header(Section.orderDate.name), .editOrderDate(item.orderDate)], toSection: .orderDate)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
}

extension AddViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isEditing {
            guard let row = dataSource.itemIdentifier(for: indexPath) else { return }
            switch row {
            case .editCategory(_): showSelectView()
            case .editBrand(_): showSelectView()
            case .editSize(_): showSelectView()
            default: print("nothing")
            }
        }
    }
    
    private func showSelectView() {
        let viewController = SelectViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
}
