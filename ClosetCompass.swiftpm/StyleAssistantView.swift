import SwiftUI

struct StyleAssistantView: View {
    @State private var messages: [Message] = []
    @State private var currentQuestionIndex = 0
    @State private var userAnswers: [String] = []
    @State private var hasStartedConversation = false
    
    let questions = [
        "What's the occasion?",
        "What's your favorite color?",
        "What's the weather like?",
        "Do you prefer comfort or style?",
        "What type of footwear do you like?"
    ]

    let options = [
        ["Casual", "Formal", "Party", "Workout", "Business"],
        ["Red", "Blue", "Green", "Black", "White", "Pastel", "Bold Colors"],
        ["Sunny", "Rainy", "Cold", "Hot", "Windy"],
        ["Comfort", "Style", "Both"],
        ["Sneakers", "Boots", "Heels", "Loafers", "Sandals"]
    ]

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(messages.indices, id: \.self) { index in
                            ChatBubble(message: messages[index])
                        }
                        if currentQuestionIndex < questions.count {
                            OptionsGrid(options: options[currentQuestionIndex], action: handleAnswer)
                                .transition(.opacity)
                        }
                        if currentQuestionIndex >= questions.count {
                            FeedbackCard(feedback: generateFeedback(), onRestart: restart)
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) { _ in
                    scrollToBottom(proxy: proxy)
                }
            }
        }
        .navigationTitle("Style Assistant")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
        .onAppear {
            if !hasStartedConversation {
                startConversation()
                hasStartedConversation = true
            }
        }
    }
    
    private func startConversation() {
        addBotMessage("Welcome to your personal style assistant! 👕")
        addBotQuestion(questions[currentQuestionIndex])
    }
    
    private func handleAnswer(_ answer: String) {
        addUserMessage(answer)
        userAnswers.append(answer)
        
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                addBotQuestion(questions[currentQuestionIndex])
            }
        } else {
            currentQuestionIndex += 1
        }
    }
    
    private func generateFeedback() -> String {
        let occasion = userAnswers[0]
        let color = userAnswers[1]
        let weather = userAnswers[2]
        let preference = userAnswers[3]
        let footwear = userAnswers[4]
        
        return """
        🌟 Your Perfect Outfit Suggestion
            
        • Occasion: \(occasion)
        • Preferred Color: \(color)
        • Weather Consideration: \(weather)
        • Comfort vs Style: \(preference)
        • Recommended Footwear: \(footwear)
            
        Suggested Look:
        \(generateOutfitSuggestion(occasion: occasion, color: color, weather: weather, preference: preference, footwear: footwear))
            
        👕 Tap below to start over!
        """
    }
    
    private func generateOutfitSuggestion(occasion: String, color: String, weather: String, preference: String, footwear: String) -> String {
        var outfit = ""

        switch occasion {
        case "Casual":
            outfit = "\(color) comfy t-shirt with relaxed-fit jeans"
        case "Formal":
            outfit = "\(color) well-fitted blazer with dress pants"
        case "Party":
            outfit = "\(color) stylish top with sleek trousers"
        case "Workout":
            outfit = "\(color) activewear with breathable fabric"
        case "Business":
            outfit = "\(color) button-up shirt with chinos"
        default:
            outfit = "A trendy mix of \(color) shades"
        }
        
        if preference == "Comfort" {
            outfit += ", paired with a cozy sweater"
        } else if preference == "Style" {
            outfit += ", accessorized with a statement belt"
        }
        
        outfit += " and matching \(footwear.lowercased())."

        return outfit
    }

    private func restart() {
        withAnimation {
            currentQuestionIndex = 0
            userAnswers.removeAll()
            messages.removeAll()
            startConversation()
        }
    }
    
    private func addUserMessage(_ text: String) {
        withAnimation {
            messages.append(Message(text: text, isUser: true, isQuestion: false))
        }
    }
    
    private func addBotMessage(_ text: String) {
        withAnimation {
            messages.append(Message(text: text, isUser: false, isQuestion: false))
        }
    }
    
    private func addBotQuestion(_ text: String) {
        withAnimation {
            messages.append(Message(text: text, isUser: false, isQuestion: true))
        }
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        guard !messages.isEmpty else { return }
        proxy.scrollTo(messages.count - 1, anchor: .bottom)
    }
}

struct ChatBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                Text(message.text)
                    .padding(12)
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.black)
                    .cornerRadius(15)
                    .contextMenu {
                        Button("Copy") {
                            UIPasteboard.general.string = message.text
                        }
                    }
            } else {
                Text(message.text)
                    .padding(12)
                    .background(message.isQuestion ? Color.black : Color(.secondarySystemBackground))
                    .foregroundColor(message.isQuestion ? .white : .primary)
                    .cornerRadius(15)
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

struct OptionsGrid: View {
    let options: [String]
    let action: (String) -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            ForEach(options, id: \.self) { option in
                Button(option) {
                    action(option)
                }
                .buttonStyle(OptionButtonStyle())
            }
        }
        .padding(.horizontal)
    }
}

struct OptionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(configuration.isPressed ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
            )
            .foregroundColor(.primary)
    }
}

struct FeedbackCard: View {
    let feedback: String
    let onRestart: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text(feedback)
                .font(.body)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(15)
            
            Button("Start New Session") {
                onRestart()
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding()
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.black)
            .foregroundColor(.white)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}
