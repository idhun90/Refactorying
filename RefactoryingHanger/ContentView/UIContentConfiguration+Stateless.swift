//
//  UIContentConfiguration+Stateless.swift
//  RefactoryingHanger
//
//  Created by 도헌 on 2023/02/03.
//

import UIKit

extension UIContentConfiguration {
    
    /// 1~3 TextFiledContentView에서 확인
    /// 4. UICOntentConfiguration 프로토콜을 준수하기 위해 makeContentView(), updated(for:) 필수 메소드를 구현해야 한다.
    /// update(for:) 메소드를 통해 UIContentConfiguration이 주어진 state(예: selected, normal, hilighted)에 설정된 configuration을 제공할 수 있다.
    /// 이번 프로젝트에서는 normal, highlighted, selected 모두 같은 cofiguration을 사용할 예정이다.
    func updated(for state: UIConfigurationState) -> Self {
        return self
    }
    
}
