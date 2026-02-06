# UI 코드 생성 가이드

## 표현 상태 분리

CoreFlow 프레임워크는 시각적 표현 코드와 상태 코드를 분리하는 것을 지향합니다.
도메인 로직을 거칠 필요가 전혀 없는 상태가 아닌 이상, Reactor가 상태를 소유하고 전파해야 합니다.
도메인 로직을 거치지 않는 상태의 경우 다음과 같은 예시가 있습니다.
- 스크롤 정도에 따라 배경 투명도 변경
- 버튼 클릭시 하이라이팅 효과

## Low-level UI 타입

다음 조건을 만족하는 UI는 저수준 UI 타입으로 분류됩니다.
1. UI 레벨에서 로직을 가지지 않습니다. 예를 들어, 특정 버튼을 누르면 리스트가 표출되는 기능을 의미합니다.
2. 3개 이하의 기본 타입을 상태 업데이트시 사용합니다.
3. 방출 가능한 액션의 수는 3개 이하입니다.

저수준 UI가 될 수 있는 UI는 다음과 같습니다.
1. 탭 버튼
2. 텍스트 라벨
3. 체크 박스

### 상태

저수준 UI는 상태 타입을 별도로 가지지 않고 상태를 업데이트하는 별도의 메서드를 가집니다.
예시 코드는 아래와 같습니다.
```swift
func update(titleText: String) {
    self.label.text = titleText
}
```

### 액션

`CoreFlow` 프레임워크가 제공하는 퍼블리셔(UIButton+EP.swift)로 충분히 액션을 표현할 수 있는 경우 해당 퍼블리셔를 사용합니다.
두 개 이상의 액션을 표현하는 경우 `ActionSource` 프로토콜을 채택하거나 `ActionView`를 사용하여 액션 타입을 정의합니다.

## High-level UI 타입(Component)

저수준 UI가 아닌 UI클래스는 컴포넌트로 분류됩니다.
컴포넌트 클래스는 `Componentable` 프로토콜을 준수합니다.
해당 클래스는 내부적으로 저수준 UI 클래스들을 프로퍼티로 가지고 하위 UI들의 액션을 자신의 액션으로 치환하여 외부로 전달합니다.
다음과 같은 계층 구조를 가질 수 있습니다.

- Screen > Component > LowLevelView
- Screen > Component > Component > LowLevelView
- Screen > LowLevelView