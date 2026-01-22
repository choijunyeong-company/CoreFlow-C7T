import Testing
import CoreFlow
@testable import Sample

@MainActor
struct SampleTests {
    init() {
        ServiceLocator.shared.register(
            LoginService.self,
            object: { _ in
                StubLoginService()
            }
        ).inObjectScope(.transient)
    }

    @Test func example() async throws {
        // Given
        let sut = LoginCore(initialState: .init(isLoading: true))
        sut.enableTestMode()
        
        // When
        sut.send(.loginButtonTapped)
        try await sut.exhaust()
        
        // Then
        #expect(sut.currentState.isLoading == false)
    }
}
