import SwiftUI
import Combine

enum ChatRole {
    case user
    case assistant
    case system
}

enum ChatMode {
    case vent
    case reframe
    case plan
    case gratitude
    case relationship
}

struct ChatMessage: Identifiable {
    let id: UUID
    let role: ChatRole
    let text: String
    let date: Date

    init(role: ChatRole, text: String, id: UUID = UUID(), date: Date = Date()) {
        self.role = role
        self.text = text
        self.id = id
        self.date = date
    }
}

final class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = [
        ChatMessage(role: .assistant, text: "Hey Drew — what’s on your mind today?")
    ]
    @Published var inputText: String = ""
    @Published var isThinking: Bool = false

    func send() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        messages.append(ChatMessage(role: .user, text: trimmed))
        inputText = ""

        // Placeholder response (swap this for a real AI call next)
        isThinking = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.messages.append(ChatMessage(role: .assistant, text: "Tell me more about that. What part feels the strongest right now?"))
            self.isThinking = false
        }
    }
}

struct ContentView: View {
    @StateObject private var vm = ChatViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(vm.messages) { msg in
                                MessageBubble(message: msg)
                                    .id(msg.id)
                            }

                            if vm.isThinking {
                                Text("Typing…")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 12)
                            }
                        }
                        .padding(.vertical, 12)
                    }
                    .onChange(of: vm.messages.count) { _, _ in
                        guard let last = vm.messages.last else { return }
                        withAnimation {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }

                Divider()

                HStack(spacing: 10) {
                    TextField("Type here…", text: $vm.inputText)
                        .textFieldStyle(.roundedBorder)

                    Button("Send") {
                        vm.send()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(vm.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || vm.isThinking)
                }
                .padding()
            }
            .navigationTitle("Therapy Buddy")
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}

private struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.role == .user { Spacer(minLength: 40) }

            Text(message.text)
                .padding(12)
                .background(message.role == .user ? Color.blue.opacity(0.15) : Color.gray.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .frame(maxWidth: 320, alignment: message.role == .user ? .trailing : .leading)
                .padding(.horizontal, 12)

            if message.role != .user { Spacer(minLength: 40) }
        }
    }
}
