import SwiftUI
import Factory

protocol GreetingServiceProtocol {
    func greet() -> String
}

class GreetingService: GreetingServiceProtocol {
    func greet() -> String { "Hello from Factory DI!" }
}

extension Container {
    var greetingService: Factory<GreetingServiceProtocol> {
        Factory(self) { GreetingService() }
    }
}

struct FactoryView: View {
    @Injected(\.greetingService) var service
    var body: some View {
        VStack(spacing: 16) {
            Text("Factory DI").font(.headline)
            Text(service.greet())
        }
        .navigationTitle("Factory")
    }
}
