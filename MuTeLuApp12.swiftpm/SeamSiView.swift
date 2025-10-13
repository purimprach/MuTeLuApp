import SwiftUI
import AVFoundation

struct SeamSiView: View {
    @EnvironmentObject var language: AppLanguage
    @State private var isShaking = false
    @State private var showResult = false
    @State private var selectedFortune: SeamSiFortune?
    @State private var fortuneNumber: Int?
    
    // State สำหรับ Animation ของไม้เซียมซี
    @State private var stickRotation: Double = 0
    @State private var stickOffsetY: CGFloat = 0
    
    var body: some View {
        ZStack {
            // MARK: - 1. เพิ่มพื้นหลังไล่ระดับสี
            LinearGradient(
                colors: [Color.red.opacity(0.2), Color.yellow.opacity(0.2), Color.gray.opacity(0.1)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                BackButton()
                
                Text("🧧 \(language.localized("เซียมซี", "SeamSi"))")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                // MARK: - 2. ปรับปรุง Animation ของไม้เซียมซี
                ZStack {
                    // กระบอกเซียมซี (ใช้ SF Symbol แทน)
                    Image(systemName: "cylinder.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 250)
                        .foregroundStyle(Color.red.gradient.opacity(0.8))
                        .rotation3DEffect(.degrees(isShaking ? 5 : -5), axis: (x: 0, y: 1, z: 0))
                        .animation(.easeInOut(duration: 0.1).repeatCount(12, autoreverses: true), value: isShaking)
                    
                    // ไม้เซียมซีที่ตกออกมา
                    if showResult {
                        Image(systemName: "line.diagonal")
                            .font(.system(size: 120, weight: .heavy))
                            .foregroundStyle(Color.yellow.gradient)
                            .shadow(color: .black.opacity(0.2), radius: 3, y: 3)
                            .rotationEffect(.degrees(stickRotation))
                            .offset(y: stickOffsetY)
                            .transition(.offset(y: -200).combined(with: .opacity))
                            .onAppear {
                                withAnimation(.easeOut(duration: 0.6)) {
                                    stickRotation = Double.random(in: 80...100)
                                    stickOffsetY = 150
                                }
                            }
                    }
                }
                
                Spacer()
                
                // MARK: - 3. แสดงผลลัพธ์ในกรอบที่สวยขึ้น
                if showResult, let fortune = selectedFortune, let number = fortuneNumber {
                    VStack(spacing: 12) {
                        Text(language.localized("ใบที่ \(number)", "No. \(number)"))
                            .font(.title2.bold())
                            .foregroundColor(.primary)
                        
                        Text(language.localized(fortune.th, fortune.en))
                            .multilineTextAlignment(.center)
                            .font(.body)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
                    }
                    .padding(.horizontal)
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
                }
                
                Spacer()
                
                // MARK: - 4. ปรับปรุงปุ่มกด
                Button {
                    shakeSticks()
                } label: {
                    Label(language.localized("เขย่าเซียมซี", "Shake the Sticks"), systemImage: "wave.3.forward")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: 300)
                        .background(Color.red.gradient)
                        .cornerRadius(20)
                        .shadow(color: .red.opacity(0.4), radius: 8, y: 4)
                        .scaleEffect(isShaking ? 1.05 : 1.0)
                }
                .disabled(isShaking) // ป้องกันการกดซ้ำขณะเขย่า
                
                Spacer(minLength: 20)
            }
            .padding()
        }
    }
    
    // MARK: - Functions
    
    func shakeSticks() {
        // Reset ค่าก่อนเริ่ม
        withAnimation {
            showResult = false
            isShaking = true
        }
        
        playSound("shake.mp3") // (สมมติว่าคุณมีไฟล์เสียงนี้)
        
        // หลังจากเขย่าเสร็จ
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            let index = Int.random(in: 1...25)
            selectedFortune = seamSiFortunes[index - 1]
            fortuneNumber = index
            
            withAnimation {
                isShaking = false
                showResult = true
            }
            playSound("drop.mp3") // (สมมติว่าคุณมีไฟล์เสียงนี้)
        }
    }
    
    func playSound(_ name: String) {
        // ฟังก์ชันนี้เหมือนเดิม
        guard let url = Bundle.main.url(forResource: name, withExtension: nil) else { return }
        var player: AVAudioPlayer?
        player = try? AVAudioPlayer(contentsOf: url)
        player?.play()
    }
}

struct SeamSiFortune {
    let th: String
    let en: String
}

let seamSiFortunes: [SeamSiFortune] = [
    SeamSiFortune(
        th: "วันนี้คือวันแห่งโอกาสใหม่ ความพยายามที่คุณทุ่มเทจะเริ่มเห็นผลลัพธ์ อย่าละท้อกลางทาง เพราะความสำเร็จกำลังรออยู่",
        en: "Today is a day of new opportunities. The effort you've been investing will begin to bear fruit. Don’t give up now — success is just ahead."
    ),
    SeamSiFortune(
        th: "แม้ทางข้างหน้าจะมีอุปสรรค แต่หากคุณมีสติและความอดทน ทุกอย่างจะคลี่คลายด้วยดีในเวลาที่เหมาะสม",
        en: "Though the path ahead may have obstacles, patience and mindfulness will help you overcome them in due time."
    ),
    SeamSiFortune(
        th: "จงมั่นใจในตัวเอง ความสงบในใจจะนำพาคำตอบที่คุณตามหา",
        en: "Believe in yourself. Inner peace will guide you to the answers you seek."
    ),
    SeamSiFortune(
        th: "โชคดีจะมาถึงคุณผ่านผู้สูงวัยหรือผู้มีบุญคุณ อย่าลืมแสดงความกตัญญู",
        en: "Good fortune will come to you through elders or benefactors. Don’t forget to show your gratitude."
    ),
    SeamSiFortune(
        th: "อย่ากลัวการเปลี่ยนแปลง มันคือก้าวแรกของการเติบโต",
        en: "Don’t fear change — it is the first step of growth."
    ),
    SeamSiFortune(
        th: "การกระทำเล็ก ๆ ที่ทำด้วยใจจะนำผลใหญ่ที่เกินคาด",
        en: "Small deeds done with sincerity can yield great results."
    ),
    SeamSiFortune(
        th: "ความรักของคุณกำลังได้รับการทดสอบ หากผ่านไปได้จะยิ่งแข็งแกร่ง",
        en: "Your relationship is being tested. If you endure, it will grow stronger."
    ),
    SeamSiFortune(
        th: "จังหวะชีวิตกำลังจะเปลี่ยน อย่าปล่อยให้ความลังเลขัดขวางคุณ",
        en: "Life's rhythm is shifting. Don’t let hesitation hold you back."
    ),
    SeamSiFortune(
        th: "สิ่งที่คุณคิดว่าเล็กน้อย อาจกลายเป็นจุดเปลี่ยนสำคัญของชีวิต",
        en: "What seems insignificant today may become a major turning point in your life."
    ),
    SeamSiFortune(
        th: "การให้อภัยไม่ใช่การยอมแพ้ แต่เป็นการปลดปล่อยตัวคุณเอง",
        en: "Forgiveness is not defeat — it's freedom for your soul."
    ),
    SeamSiFortune(
        th: "คุณกำลังอยู่ในเส้นทางที่ถูกต้อง จงเดินต่อด้วยความตั้งใจ",
        en: "You are on the right path. Continue walking with determination."
    ),
    SeamSiFortune(
        th: "คนที่คุณคาดไม่ถึงจะเข้ามาเปลี่ยนแปลงบางสิ่งในชีวิตคุณ",
        en: "Someone unexpected will enter your life and bring change."
    ),
    SeamSiFortune(
        th: "เวลานี้คือช่วงเวลาที่ดีในการเริ่มต้นสิ่งใหม่ ๆ",
        en: "Now is a good time to begin something new."
    ),
    SeamSiFortune(
        th: "คำพูดที่จริงใจจะสร้างสายสัมพันธ์ที่ยั่งยืน",
        en: "Honest words will build lasting connections."
    ),
    SeamSiFortune(
        th: "ความฝันของคุณใกล้ความจริงมากกว่าที่คุณคิด",
        en: "Your dreams are closer to reality than you realize."
    ),
    SeamSiFortune(
        th: "อย่าหมดหวังกับความพ่ายแพ้ มันคือครูที่ดีที่สุด",
        en: "Don’t lose hope from failure — it is the best teacher."
    ),
    SeamSiFortune(
        th: "มีคนแอบชื่นชมคุณอยู่ หมั่นทำดีต่อไป",
        en: "Someone admires you quietly. Keep doing good things."
    ),
    SeamSiFortune(
        th: "คุณมีพลังมากกว่าที่คุณคิด ใช้มันอย่างมีสติ",
        en: "You are stronger than you think — use your strength mindfully."
    ),
    SeamSiFortune(
        th: "ช่วงนี้เหมาะกับการเรียนรู้ทักษะใหม่ ๆ ที่จะเป็นประโยชน์ในอนาคต",
        en: "Now is a great time to learn new skills that will serve you later."
    ),
    SeamSiFortune(
        th: "หากคุณลังเล ให้ฟังเสียงหัวใจ มันจะไม่พาคุณผิดทาง",
        en: "If you're in doubt, listen to your heart — it will not lead you astray."
    ),
    SeamSiFortune(
        th: "การเดินทางจะนำมาซึ่งประสบการณ์ที่ล้ำค่า",
        en: "A journey will bring valuable experiences."
    ),
    SeamSiFortune(
        th: "โชคของคุณจะเปลี่ยนจากร้ายเป็นดีในไม่ช้า",
        en: "Your luck will soon shift from bad to good."
    ),
    SeamSiFortune(
        th: "การพูดน้อยแต่คิดมากจะช่วยให้คุณรอดพ้นจากปัญหา",
        en: "Speaking less but thinking more will help you avoid trouble."
    ),
    SeamSiFortune(
        th: "ให้เวลากับตัวเองในการพักผ่อน จิตใจที่สงบจะคิดได้ชัดเจน",
        en: "Give yourself time to rest. A calm mind sees clearly."
    ),
    SeamSiFortune(
        th: "ความสำเร็จอาจมาช้ากว่าที่คิด แต่อย่าทิ้งความเชื่อมั่น",
        en: "Success may come later than expected, but don’t lose faith."
    )
]
