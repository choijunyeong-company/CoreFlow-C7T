# CoreFlow

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange?style=flat-square)](https://img.shields.io/badge/Swift-6.0_6.1_6.2-Orange?style=flat-square)
[![Platforms](https://img.shields.io/badge/Platforms-iOS-yellowgreen?style=flat-square)](https://img.shields.io/badge/Platforms-macOS_iOS_tvOS_watchOS_vision_OS_Linux_Windows_Android-Green?style=flat-square)
[![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)

> **MCP Servers (Context7, etc.)**: For structured documentation guide, see [`llms.txt`](./llms.txt)

# How to use

Xcode 템플릿을 설치하면 CoreFlow 컴포넌트를 빠르게 생성할 수 있습니다.

1. 저장소를 다운로드하고 압축을 해제합니다.

2. tooling 디렉토리로 이동합니다.
```bash
cd CoreFlow/tooling
```

3. tooling 디렉토리 내부 설치 스크립트를 실행합니다.
```bash
./install-xcode-template.sh
```

설치 후 Xcode에서 **File → New → File...** (⌘N)을 선택하면 **CoreFlow** 템플릿을 사용할 수 있습니다.

# 해당 라이브러리를 만든 이유

해당 라이브러리는 iOS 애플리케이션 개발 시 아키텍처 결정의 복잡도를 최소화하기 위해 만들어졌습니다.
보통 애플리케이션 개발 시 다음과 같은 아키텍처들이 고려됩니다.

MVVM, MVC, MVVM-C, RIBs, TCA ..

각각의 아키텍처의 단점만을 서술해보겠습니다.

## MVVM, MVC

큰 생각 없이 시작하기 좋은 패턴들입니다.
하지만 프로젝트의 규모가 커질수록 책임이 과중된 객체들이 증가하게 되어 복잡한 코드베이스가 만들어지고 테스트도 어렵습니다.

## Coordinator

코디네이터는 일반적으로 `ViewController`의 내비게이션 책임을 담당하고, 기능 계층을 구성하는 역할을 수행합니다.
하지만 그 구조가 정형화되어 있지 못합니다.
예를 들어 특정 `Coordinator` 계층에 존재하는 객체에 접근하고 싶은 경우 다양한 방식이 가능합니다.
직접 해당 객체를 참조할 수 있고, `Coordinator` 계층을 이동하여 접근할 수도 있습니다.
이러한 자유로움은 때로는 협업 시 난처한 흐름을 만들고 유지보수하기 어려운 코드를 낳습니다.

## RIBs

가장 정형화된 패턴이라고 말할 수 있습니다.
하지만 너무 무겁습니다. 의존관계를 최소화하기 위해 많은 추상화가 존재합니다.
RIB 내부에서도 추상화된 객체들 간 소통을 위한 인터페이스를 구현한 후 소통을 시작할 수 있다는 점에서 복잡도와 공수가 큽니다.
그로 인한 러닝커브 역시 무시하지 못할 수준입니다.
RIBs는 `RxSwift`로 구현되어 있습니다. 검증된 라이브러리를 기반으로 하지만 장기적인 지원을 보장할 수 없습니다.
안정적인 구조와 강력한 추상화가 존재하지만, 공수가 많이 드는 아키텍처입니다.

## TCA

리듀서 컴포지션 등 기존 iOS 개발에서는 제공하지 않았던 새로운 패러다임을 제공합니다.
하지만 해당 라이브러리 개발자에게 지나치게 의존적이라는 점이 문제입니다.
수많은 매크로와 추상화 등은 사용자가 내부 동작을 이해하기 어렵게 합니다.
향후 지원 및 변동사항으로 인한 위험이 큰 라이브러리라고 생각합니다.

## 단점 해결

`CoreFlow`는 위에서 서술된 문제들을 해결하고자 만들었습니다.
- 정형화된 패턴과 구조를 제공하며 이해하기 쉽습니다.
- 과도한 추상화를 사용하지 않습니다. 객체 간 의존성 관리는 접근 지정자 사용을 지향합니다.
- `Combine`과 `Swift Concurrency` 기반으로 구현하여 장기적인 안정성이 높습니다.
- RIBs에서 제공하는 `LeakDetector`, `Workflow` 기능을 지원합니다.

# Features

<image src="./images/CoreFlow1.svg" width=300 />

CoreFlow는 세 가지 컴포넌트(Flow, Core, Screen)로 구성됩니다.
이 세 가지 요소로 구성된 집합을 `CoreFlow`라고 명칭합니다.

아래부터 각 구성요소에 대한 간략한 설명이 있습니다.
더 자세한 명세는 [docs](./docs/) 디렉터리 내부 문서를 참고해주세요.

## Flow

<image src="./images/CoreFlow2.svg" width=300 />

Flow 객체는 Core와 Screen 두 객체를 참조하며 트리 구성의 중심이 됩니다.
다른 Flow를 직접적으로 참조하는 주체로, 내비게이션 및 인터랙션을 연결합니다.

## Core

<image src="./images/CoreFlow3.svg" width=300 />

`CoreFlow`의 핵심적인 로직이 위치합니다.
이와 더불어 `CoreFlow`에 스크린이 존재하는 경우 `Reactor`의 역할도 수행합니다.
`Reactor` 패턴은 단방향 아키텍처를 기반으로 하는 디자인 패턴으로,
잘 알려진 프레임워크인 `ReactorKit`과 `TCA`를 참고하여 제작하였습니다.

## Screen

`Screen`은 `UIViewController`라고 생각하시면 됩니다.
`Core`의 상태를 구독하고 있으며, 뷰의 액션을 `Core`에 전달할 수 있습니다.

## Procedure (Workflow)

`Procedure`는 RIBs의 `Workflow`와 유사한 기능으로, 앱의 흐름을 단계별로 정의할 수 있습니다.
해당 기능을 사용하여 앱의 런칭플로우 및 딥링크 분석을 통한 흐름을 손쉽게 만들어낼 수 있습니다.
`Combine` 기반의 체이닝 API를 제공하여 복잡한 비동기 흐름을 선언적으로 표현할 수 있습니다.

### 사용 방법

1. `Procedure`를 상속받아 워크플로우를 정의합니다.
2. `onStep`을 체이닝하여 각 단계를 연결합니다.
3. `commit()`으로 워크플로우를 확정합니다.
4. `start()`로 실행합니다.

```swift
final class DefaultProcedure: Procedure<RootStepAction> {
    override init() {
        super.init()
        onStep { rootStepAction in
            rootStepAction.waitForOnboarding()
        }
        .onStep { rootStepAction, _ in
            rootStepAction.waitForLogin()
        }
        .onStep { rootStepAction, user in
            rootStepAction.presentMain(user: user)
        }
        .commit()
    }
}
```

### Step 프로토콜 정의

각 단계에서 실행할 액션을 프로토콜로 정의합니다.
각 메서드는 `AnyPublisher<(NextAction, Value), Never>`를 반환하여 다음 단계로 값을 전달합니다.

```swift
protocol RootStepAction {
    func waitForOnboarding() -> AnyPublisher<(RootStepAction, Void), Never>
    func waitForLogin() -> AnyPublisher<(RootStepAction, User), Never>
    func presentMain(user: User) -> AnyPublisher<(MainStepAction, Void), Never>
}
```

`StepAction` 프로토콜은 해당 흐름을 관장하는 `Core`가 채택하여 구현합니다.
`Core`는 이미 `router`를 통해 화면 전환을 제어하고, 자식 Flow의 `Listener`를 구현하여 완료 시점을 알 수 있으므로 `StepAction`의 역할을 수행하기에 가장 적합합니다(권장).

```swift
extension RootCore: RootStepAction {
    func waitForOnboarding() -> AnyPublisher<(RootStepAction, Void), Never> {
        router?.routeToOnboarding()
        return onboardingFinished
            .compactMap(\.self)
            .map { (self, ()) }
            .eraseToAnyPublisher()
    }

    func waitForLogin() -> AnyPublisher<(RootStepAction, User), Never> {
        router?.routeToLogin()
        return loginFinished
            .compactMap(\.self)
            .map { user in (self, user) }
            .eraseToAnyPublisher()
    }
}
```

### Core에서 Procedure 실행

```swift
final class RootCore: Core<RootAction, RootState, RootFlow> {
    override func reduce(state: inout RootState, action: RootAction) -> Effect<RootAction> {
        switch action {
        case .viewDidLoad:
            DefaultProcedure()
                .start(self)  // RootStepAction을 준수하는 self를 전달
                .store(in: &store)
            return .none
        }
    }
}
```

이 패턴을 사용하면 Onboarding → Login → Main과 같은 앱의 전체 흐름을 명확하게 정의하고 관리할 수 있습니다.

# Testing

`Reactor` 역할을 수행하는 `Core`의 경우 `Action`을 기반으로 결정된 최종 상태를 검증할 수 있습니다.

하나의 `Action`을 전송하더라도 `Core` 내부에서 `Effect`가 새로운 `Action`을 발행할 수 있습니다.
따라서 최종 상태가 결정되기까지 대기가 필요합니다.

<image src="./images/CoreFlow4.svg" width=400 />

`Action`을 전송한 이후 `exhaust()`을 호출하여 최종 상태 결정을 기다릴 수 있습니다.
해당 함수가 리턴된 이후 `currentState`로 최종 상태에 접근할 수 있습니다.

```swift
import Testing
@testable import YourApp
import CoreFlow

@MainActor
struct CoreTests {
    @Test
    func testActionFlow() async throws {
        // 1. Core 인스턴스 생성
        let sut = SutCore(initialState: .init(step: 0))

        // 2. 테스트 모드 활성화
        sut.enableTestMode()

        // 3. Action 전송
        sut.send(.step1)

        // 4. 모든 Effect가 완료될 때까지 대기
        try await sut.exhaust(timeout: 5)

        // 5. 최종 상태 검증
        #expect(sut.currentState.step == 4)
    }
}
```

### 테스트 대상 Core 예시

```swift
public final class SutCore: Core<SutAction, SutState> {
    public override func reduce(state: inout SutState, action: SutAction) -> Effect<SutAction> {
        switch action {
        case .step1:
            state.step = 1
            return .run { send in
                await send(.step2)  // Effect가 새로운 Action 발행
            }
        case .step2:
            state.step = 2
            return .run { send in
                await send(.step3)
            }
        case .step3:
            state.step = 3
            return .run { send in
                await send(.step4)
            }
        case .step4:
            state.step = 4
            return .none  // 최종 상태
        }
    }
}
```

위 예시에서 `.step1` 액션을 전송하면 Effect 체인을 통해 `.step2` → `.step3` → `.step4`까지 순차적으로 실행됩니다.
`exhaust()`은 모든 Effect가 완료되어 더 이상 진행 중인 작업이 없을 때 리턴됩니다.