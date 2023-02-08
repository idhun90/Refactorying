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
        let vc = EditViewController()
        present(vc, animated: true)
    }
}

class ItemDoneButton: UIButton {
    var id: Item.ID?
}
