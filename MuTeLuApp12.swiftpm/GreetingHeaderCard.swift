import SwiftUI

struct GreetingHeaderCard: View {
    @Environment(\.colorScheme) private var scheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    let displayName: String?
    let displayEmail: String?
    let guestName: String
    let subtitle: String?
    
    @State private var wave = false
    
    private var isGuest: Bool { (displayEmail ?? "").isEmpty }
    private var effectiveName: String {
        if isGuest { return guestName }
        return (displayName?.isEmpty == false ? displayName! : guestName)
    }
    private var initial: String {
        if isGuest { return "G" }
        let base = (displayEmail ?? displayName ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return base.first.map { String($0).uppercased() } ?? "?"
    }
    
    var body: some View {
        ZStack {
            // ✅ เปลี่ยนจาก .ultraThinMaterial เป็น gradient เข้ม (แก้ปัญหาสีซีด)
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [.purple, .indigo],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 6)
                .frame(maxWidth: 600)
            
            HStack(spacing: 14) {
                Circle()
                    .fill(
                        LinearGradient(colors: [.blue, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 56, height: 56)
                    .overlay(
                        Text(initial)
                            .font(.title.bold())
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(timeGreeting())
                            .font(.title3.bold())
                            .foregroundColor(.white)
                        
                        Text("👋")
                            .rotationEffect(.degrees(wave ? 15 : -10), anchor: .bottomLeading)
                            .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: wave)
                    }
                    
                    Text(effectiveName)
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .padding(.horizontal)
        .onAppear { wave = true }
    }
    
    private func timeGreeting() -> String {
        let h = Calendar.current.component(.hour, from: Date())
        switch h {
        case 5..<12: return "สวัสดีตอนเช้า"
        case 12..<16: return "สวัสดีตอนบ่าย"
        case 16..<20: return "สวัสดีตอนเย็น"
        default: return "สวัสดี"
        }
    }
}
