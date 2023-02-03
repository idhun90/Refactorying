//
//  SelectViewController.swift
//  RefactoryingHanger
//
//  Created by 도헌 on 2023/02/04.
//

import UIKit

final class SelectViewController: UIViewController {
    
    enum listSection: Int {
        case defaultList
        case add
    }
    
    private typealias DataSource = UICollectionViewDiffableDataSource<listSection, String>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<listSection, String>
    
    private var collectionView: UICollectionView!
    private var dataSource: DataSource!
    private var snapshot: Snapshot!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        configureCollectionView()
        configureDataSource()
        applySnapshot()
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
        let listConfiguration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        return UICollectionViewCompositionalLayout.list(using: listConfiguration)
    }
    
    private func configureDataSource() {
        let cellRegistraion = UICollectionView.CellRegistration<UICollectionViewListCell, String> { cell, indexPath, itemIdentifier in
            guard let section = listSection(rawValue: indexPath.section) else { return }
            var contentConfiguration = UIListContentConfiguration.valueCell()
            contentConfiguration.text = itemIdentifier
            switch section {
            case .defaultList:
                contentConfiguration.textProperties.alignment = .natural
                cell.accessories = [.checkmark()]
        
            case .add:
                contentConfiguration.textProperties.alignment = .center
                contentConfiguration.textProperties.color = .link
                cell.accessories = []
            }
            cell.contentConfiguration = contentConfiguration
        }
        
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistraion, for: indexPath, item: itemIdentifier)
        })
    }
    
    private func applySnapshot() {
        snapshot = Snapshot()
        snapshot.appendSections([.defaultList, .add])
        snapshot.appendItems(["None"], toSection: .defaultList)
        snapshot.appendItems(["Add Custom"], toSection: .add)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
extension SelectViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
    }
}
