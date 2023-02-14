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
        let vc = EditViewController(item: item, customCategorys: customCategorys, customBrands: customBrands, customColors: customColors, customFits: customFits, customSatisfactions: customSatisfactions, customSizes: customSizes)
        vc.sendEditingItem = { [weak self] item in
            self?.addItem(item)
            self?.applySnapshot()
            print("MainView - Item Changed(Add)")
        }
        vc.sendCustomCategorys = { [weak self] customCategorys in
            self?.customCategorys = customCategorys
            print("MainView - customCategorys Array Changed(Add)")
        }
        vc.sendCustomBrands = { [weak self] customBrands in
            self?.customBrands = customBrands
            print("MainView - customBrands Array Changed(Add)")
        }
        vc.sendCustomColors = { [weak self] customColors in
            self?.customColors = customColors
            print("MainView - customColors Array Changed(Add)")
        }
        vc.sendCustomFits = { [weak self] customFits in
            self?.customFits = customFits
            print("MainView - customFits Array Changed(Add)")
        }
        vc.sendCustomSatisfactions = { [weak self] customSatisfactions in
            self?.customSatisfactions = customSatisfactions
            print("MainView - customSatisfactions Array Changed(Add)")
        }
        vc.sendCustomSizes = { [weak self] customSizes in
            self?.customSizes = customSizes
            print("MainView - customSizes Array Changed(Add)")
        }
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
