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
                            FeedbackCard(onRestart: restart, userAnswers: userAnswers)
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
    let onRestart: () -> Void
    let userAnswers: [String]
    
    var body: some View {
        VStack(spacing: 20) {
            FeedbackView(userAnswers: userAnswers)
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

struct FeedbackView: View {
    let userAnswers: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your Perfect Outfit Suggestion")
                .font(.title3)
                .bold()
                .foregroundColor(.black)
            
            Text("• Occasion: \(userAnswers[0])")
                .font(.body)
                .bold()
                .foregroundColor(.black)
                .opacity(0.7)
            
            Text("• Preferred Color: \(userAnswers[1])")
                .font(.body)
                .bold()
                .foregroundColor(.black)
                .opacity(0.7)
            
            Text("• Weather Consideration: \(userAnswers[2])")
                .font(.body)
                .bold()
                .foregroundColor(.black)
                .opacity(0.7)
            
            Text("• Comfort vs Style: \(userAnswers[3])")
                .font(.body)
                .bold()
                .foregroundColor(.black)
                .opacity(0.7)
            
            Text("• Recommended Footwear: \(userAnswers[4])")
                .font(.body)
                .bold()
                .foregroundColor(.black)
                .opacity(0.7)
            
            Text("Suggested Look:")
                .font(.headline)
                .bold()
                .foregroundColor(.black)
            
            Text(generateOutfitSuggestion(occasion: userAnswers[0], color: userAnswers[1], weather: userAnswers[2], preference: userAnswers[3], footwear: userAnswers[4]))
                .font(.body)
                .foregroundColor(.black)
                .opacity(0.7)
            
         
        }
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


