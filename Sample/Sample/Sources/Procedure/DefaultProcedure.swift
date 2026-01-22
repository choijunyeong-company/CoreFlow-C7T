import CoreFlow

/// 앱 실행 시 워크플로우를 정의하는 Procedure입니다.
///
/// `init()`에서 `onStep`과 `finalStep`을 체이닝하여 워크플로우를 구성합니다.
/// 1. waitForLogin: 로그인 완료를 대기
/// 2. routeToMain: 메인 화면으로 이동
final class LaunchProcedure: Procedure<RootProcedureStep>, @unchecked Sendable {
    override init() {
        super.init()
        // 첫 번째 Step: 로그인 완료를 대기
        onStep { rootStep in
            rootStep.waitForLogin()
        }
        // 마지막 Step: 이전 Step에서 전달된 user 데이터로 메인 화면 이동
        .finalStep { rootStep, user in
            rootStep.routeToMain(user: user)
        }
    }
}
