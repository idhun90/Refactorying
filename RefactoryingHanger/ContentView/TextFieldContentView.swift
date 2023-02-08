//
//  TextFieldContentView.swift
//  RefactoryingHanger
//
//  Created by 도헌 on 2023/02/03.
//

import UIKit

final class TextFieldContentView: UIView, UIContentView { /// 5. UIConteontView 프로토콜 채택
    ///8. UIContentConfiguration를 준수하는 Configuration 구조체 생성
    ///TextFieldContentView.Configuration type을 통해 우리는 content와 view를 커스텀할 것이다. (viewModel 역할?)
    struct Configuration: UIContentConfiguration {
        
        var text: String? = "" ///9. 빈 문자열 프로퍼티 생성, 우리가 사용할 모든 프로퍼티를 이 곳에 설정하면 되는 것 같다.
        var placeholder: String?
        var keyboardType: UIKeyboardType = .default
        var onChange: (String) -> Void = { _ in }
        
        /// 9. UIContentConfiguration 프로토콜 준수를 위해 makeContentView() 구현, update 메소드는 4번 참조.
        /// makeContentView 메소드는 초기화할 때 반환한다.
        
        func makeContentView() -> UIView & UIContentView {
            return TextFieldContentView(self) /// 10. self는 TextFieldContentView.Configuration type이다. TextFieldContentView의 이니셜라이저(9번)는 UIContentConfiguration을 받고, 이 안에는 8번 구조체에 포함된 텍스트 필드 콘텐츠를 나타내는 text 문자열이 있다.
        }
    }
    
    /// 1. textField 인스턴스 생성
    let textField = UITextField()
    var configuration: UIContentConfiguration { /// 6. UIContentView 프로토콜 준수
        didSet { /// 14. configuration이 변경될 때마다 현재 상태를 반영하도록 UI를 계속 업데이트해야 한다.
            configure(configuration: configuration)
        }
    }
    
    /// 2. intrinsicContentSize 재정의
    /// 시스템은 UIView의 모든 subClass에 고유 콘텐츠 크기(표시 내용에 따라 결정되는 너비와 높이)를 할당한다
    /// 예를 들어 Label의 고유 콘텐츠 크기는 표시하는 텍스트 크기를 기반으로 한다.
    /// intrinsicContentSize를 재정의하여 높이를 accessible control 가능한 최소 크기를 44 포인트로 정의
    /// 이 프로퍼티를 설정하면 custom View가 preferred size를 레이아웃 시스템에 전달할 수 있다(?)
    override var intrinsicContentSize: CGSize {
        CGSize(width: 0, height: 44)
    }
    
    /// 3. Create an initializer -> 7번 과정을 위해 주석 처리
    /// 텍스트필드 UI 및 속성 정의
//    init() {
//        super.init(frame: .zero)
//        addCommonSubView(textField)
//        textField.clearButtonMode = .whileEditing
//    }
    
    /// 7. configuration 초기화
    init(_ configuration: UIContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        addCommonSubView(textField)
        textField.clearButtonMode = .whileEditing
        textField.autocapitalizationType = .none
        textField.addTarget(self, action: #selector(didChange(_:)), for: .editingChanged)
    }
    
    /// 4. UIContentConfiguration 프로토콜 필수 메서드 구현 (UIContentConfiguration+Stateless.swift)
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 11. ContentConfiguration은 사용자 UI가 앱의 state와 동기화되도록 유지하는데 도움이 된다.
    /// configuration 프로퍼티가 변경될 때마다 사용자 UI를 업데이트하여 title TextField의 상태와 사용자 UI가 동기화 상태를 유지하도록 할 것이다.
    /// 그런 다음 DetailViewController+CellConfiguration.swift에 확장하여 편집 모드일 때 제품명 textFiled와 페어링을 이루는 textField configuration을 반환하는 함수를 포함할 것이다.
    
    func configure(configuration: UIContentConfiguration) {
        guard let configuration = configuration as? Configuration else { return } /// 12. TextFieldContentView.Configuration으로 캐스팅해서 프로퍼티 접근 -> 텍스트필드에 연결될 수 있도록 text 프로퍼티가 configuration에 존재해야 한다. (9번)
        /// 13. configuration에서 textField.text 값을 업데이트한다.
        textField.text = configuration.text
        textField.placeholder = configuration.placeholder
        textField.keyboardType = configuration.keyboardType
    }
    
    @objc private func didChange(_ sender: UITextField) {
        guard let configuration = configuration as? TextFieldContentView.Configuration else { return }
        configuration.onChange(sender.text ?? "")
    }
}

/// 15. 커스텀한 TextFieldView와 페어링할 custom Configuration을 리턴하도록 UICollectionViewListCell 익스텐션에서 메소드를 만든다.
extension UICollectionViewListCell {
    func textFieldConfiguration() -> TextFieldContentView.Configuration {
        TextFieldContentView.Configuration() /// 16. 새로운 TextFieldContentView.Configuration을 반환
        ///17. AddViewController + CellConfiguration.swfit 확인
    }
}
