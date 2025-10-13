import SwiftUI

// MARK: - 1. Model & Data (เหมือนเดิม)
struct TarotCard {
    let name: String
    let imageName: String
    let description: String
    let topic: String
}

let tarotDeck: [TarotCard] = [
    TarotCard(name: "The Fool", imageName: "figure.walk.motion", description: "การเริ่มต้นครั้งใหม่, การเดินทางที่ไม่คาดฝัน", topic: "ชีวิตโดยรวม"),
    TarotCard(name: "The Magician", imageName: "wand.and.stars", description: "พลังในการสร้างสรรค์, ความสามารถรอบด้าน", topic: "การงาน"),
    TarotCard(name: "The Lovers", imageName: "heart.fill", description: "ความรัก, ความสัมพันธ์, การตัดสินใจครั้งสำคัญ", topic: "ความรัก"),
    TarotCard(name: "The Star", imageName: "sparkles", description: "ความหวัง, แรงบันดาลใจ, การเยียวยา", topic: "สุขภาพ"),
    TarotCard(name: "Death", imageName: "skull", description: "การสิ้นสุดเพื่อเริ่มต้นใหม่, การเปลี่ยนแปลงครั้งใหญ่", topic: "ชีวิตโดยรวม"),
    TarotCard(name: "Strength", imageName: "flame.fill", description: "ความกล้าหาญ, พลังใจ, การควบคุมตนเอง", topic: "สุขภาพ"),
    TarotCard(name: "Wheel of Fortune", imageName: "circle.dashed", description: "โชคชะตา, การเปลี่ยนแปลง, วัฏจักรของชีวิต", topic: "การงาน")
]


// MARK: - 2. Main View (เหมือนเดิม)
struct TarotView: View {
    @EnvironmentObject var language: AppLanguage
    
    @State private var drawnCards: [TarotCard?] = [nil, nil, nil]
    @State private var isFlipped: [Bool] = [false, false, false]
    @State private var hasDrawn = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.white.opacity(0.5), Color.black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                BackButton()
                Spacer()
                VStack {
                    Text("🃏 " + language.localized("ดูดวงไพ่ทาโร่", "Tarot Reading"))
                        .font(.title).bold()
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.black)
                        .shadow(color: .white.opacity(1), radius: 10, y: 5)
                }
                
                VStack(spacing: 15) {
                    SingleCardView(
                        card: drawnCards[0],
                        isFlipped: $isFlipped[0],
                        topic: getTopic(for: 0),
                        cardSize: CGSize(width: 140, height: 180)
                    )
                    
                    HStack(spacing: 20) {
                        SingleCardView(
                            card: drawnCards[1],
                            isFlipped: $isFlipped[1],
                            topic: getTopic(for: 1),
                            cardSize: CGSize(width: 140, height: 180)
                        )
                        
                        SingleCardView(
                            card: drawnCards[2],
                            isFlipped: $isFlipped[2],
                            topic: getTopic(for: 2),
                            cardSize: CGSize(width: 140, height: 180)
                        )
                    }
                }
                
                Button(action: {
                    drawThreeCards()
                }) {
                    Label(
                        hasDrawn ? language.localized("ดูดวงอีกครั้ง", "Draw Again") : language.localized("เปิดไพ่ 3 ใบ", "Draw 3 Cards"),
                        systemImage: "wand.and.rays"
                    )
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: 300)
                    .background(hasDrawn ? Color.purple.gradient : Color.indigo.gradient)
                    .cornerRadius(20)
                    .shadow(color: .purple.opacity(0.5), radius: 10, y: 5)
                }
                
                Spacer()
            }
            .padding()
        }
    }
    
    // Functions (เหมือนเดิม)
    func getTopic(for index: Int) -> String {
        switch index {
        case 0: return language.localized("ความรัก", "Love")
        case 1: return language.localized("การงาน", "Work")
        case 2: return language.localized("สุขภาพ", "Health")
        default: return ""
        }
    }
    
    func drawThreeCards() {
        if hasDrawn {
            withAnimation {
                isFlipped = [false, false, false]
            }
            hasDrawn = false
            drawnCards = [nil, nil, nil]
        } else {
            drawnCards = Array(tarotDeck.shuffled().prefix(3))
            hasDrawn = true
            
            for i in 0..<3 {
                withAnimation(.linear(duration: 0.4).delay(1 * Double(i))) {
                    isFlipped[i] = true
                }
            }
        }
    }
}


// MARK: - 4. View สำหรับไพ่ 1 ใบ (เหมือนเดิม)
struct SingleCardView: View {
    let card: TarotCard?
    @Binding var isFlipped: Bool
    let topic: String
    let cardSize: CGSize
    
    var body: some View {
        ZStack {
            TarotCardFace(card: card, topic: topic, cardSize: cardSize)
                .opacity(isFlipped ? 1 : 0)
            
            TarotCardBack(cardSize: cardSize)
                .opacity(isFlipped ? 0 : 1)
        }
        .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
    }
}

// VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
// MARK: - [แก้ไข] 5. View สำหรับหน้าไพ่และหลังไพ่

struct TarotCardFace: View {
    let card: TarotCard?
    let topic: String
    let cardSize: CGSize
    
    var body: some View {
        ZStack {
            // พื้นหลัง
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(Color.black.opacity(0.8))
            
            // เนื้อหา
            VStack(spacing: 10) {
                Text(topic)
                    .font(.subheadline.bold())
                    .foregroundStyle(Color.yellow.gradient)
                
                if let card = card {
                    Image(systemName: card.imageName)
                        .font(.system(size: 40))
                        .foregroundStyle(.white)
                    
                    VStack {
                        Text(card.name.uppercased())
                            .font(.caption.bold())
                        Text(card.description)
                            .font(.footnote)
                            .italic()
                    }
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                } else {
                    Spacer()
                }
            }
            .padding(5)
        }
        .frame(width: cardSize.width, height: cardSize.height)
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .stroke(Color.purple.gradient, lineWidth: 5)
        )
        .shadow(color: .white.opacity(0.4), radius: 8, y: 5)
        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
    }
}

struct TarotCardBack: View {
    let cardSize: CGSize
    
    var body: some View {
        ZStack {
            // พื้นหลัง
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(Color.indigo.gradient)
            
            // สัญลักษณ์
            Image(systemName: "sparkle")
                .font(.system(size: 70))
                .foregroundStyle(Color.purple.gradient)
        }
        .frame(width: cardSize.width, height: cardSize.height)
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        .overlay(
            // เส้นขอบ (ใช้วิธีเดียวกับหน้าไพ่)
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .stroke(Color.purple.gradient, lineWidth: 5)
        )
        .shadow(color: .black.opacity(1), radius: 8, y: 5)
    }
}
