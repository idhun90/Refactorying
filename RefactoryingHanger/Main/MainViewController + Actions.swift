//
//  MainViewController + Actions.swift
//  RefactoryingHanger
//
//  Created by 도헌 on 2023/02/03.
//

import UIKit

extension MainViewController {
    
    @objc func tappedDoneButton(_ sender: ItemDoneButton) {
        guard let id = sender.id else { return }
        completeItem(withID: id)
    }
    
    @objc func tappedAddButton(_ sender: UIBarButtonItem) {
        print("Add Button Tapped")
        let item = Item(name: "", orderDate: Date.now)
        let vc = EditViewController()
        vc.sendEditingItem = { [weak self] item in
            self?.addItem(item)
            self?.applySnapshot()
        }
        vc.fetchItem(with: item)
        vc.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(tappedCancelButton(_:)))
        vc.navigationItem.title = NSLocalizedString("Add Item", comment: "Add Item view controller title")
        let nvc = UINavigationController(rootViewController: vc)
        present(nvc, animated: true)
    }
    
    @objc func tappedCancelButton(_ sender:UIBarButtonItem) {
        dismiss(animated: true)
    }
}

final class ItemDoneButton: UIButton {
    var id: Item.ID?
}
