import Testing
import CoreFlow
@testable import Sample

@MainActor
struct SampleTests {
    @Test func example() async throws {
        // Given
        let sut = LoginCore(initialState: .init(isLoading: true))
        let testUser = User(name: "Test user")
        sut.service = StubLoginService(user: testUser)
        sut.enableTestMode()
        
        // When
        sut.send(.loginSection(.loginButtonTapped))
        try await sut.exhaust()
        
        // Then
        #expect(sut.currentState.isLoading == false)
        #expect(sut.currentState.logginUser == testUser)
    }
}
