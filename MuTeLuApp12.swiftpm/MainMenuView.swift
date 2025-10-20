import SwiftUI
import CoreLocation
import MapKit

// MARK: - MainMenuView
struct MainMenuView: View {
    @Binding var showBanner: Bool
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var activityStore: ActivityStore // ใช้ activityStore
    var currentMember: Member? // รับ Member? มา (อาจเป็น nil ถ้าเป็น Guest)
    var flowManager: MuTeLuFlowManager
    
    var nearest: [(place: SacredPlace, distance: CLLocationDistance)]
    var topRated: [SacredPlace] // อันนี้คือ topILPlaces
    
    var checkProximityToSacredPlaces: () -> Void
    var locationManager: LocationManager
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // --- 👇 [แก้ไข] ส่ง currentMember ให้ GreetingHeaderCardPro ---
                GreetingHeaderCardPro(
                    member: currentMember, // ส่ง member? (อาจเป็น nil)
                    subtitle: language.localized("ยินดีต้อนรับ", "Welcome"), // เปลี่ยน Subtitle กลางๆ
                    // คำนวณแต้มบุญเฉพาะเมื่อ Login อยู่
                    meritPoints: currentMember != nil ? activityStore.totalMeritPoints(for: currentMember!.email) : 0,
                    onProfile: {} // Action นี้อาจจะไม่จำเป็นแล้ว
                )
                .environmentObject(language)
                // --- 👆 สิ้นสุด ---
                
                BannerStack(showBanner: $showBanner, currentMember: currentMember)
                    .environmentObject(language)
                
                PlaceSection(nearest: nearest, topRated: topRated, flowManager: flowManager)
                    .environmentObject(language)
                
                QuickActionsGrid(flowManager: flowManager)
                    .environmentObject(language)
            }
            .padding(.vertical, 16) // Padding บนล่างของ VStack หลัก
            // ไม่ต้องใส่ .padding(.horizontal) ที่นี่ เพราะ Component ลูกใส่เองแล้ว
        }
        .background(Color(.systemGroupedBackground))
        .onAppear { showBanner = true }
        .onChange(of: locationManager.userLocation) { oldValue, newValue in // ใช้ Syntax ใหม่
            checkProximityToSacredPlaces()
        }
    }
}

// MARK: - GreetingHeaderCardPro (แก้ไขสำหรับ Guest + Alert)
struct GreetingHeaderCardPro: View {
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flowManager: MuTeLuFlowManager
    var member: Member?
    var subtitle: String
    var meritPoints: Int = 0
    var onProfile: () -> Void
    
    // --- 👇 [เพิ่ม] State สำหรับควบคุม Alert ---
    @State private var showLoginPromptAlert = false
    @State private var wave = false
    // --- 👆 สิ้นสุด ---
    
    private var isGuest: Bool { member == nil }
    private var displayName: String { /* ... (เหมือนเดิม) ... */
        isGuest ? language.localized("ผู้ใช้ทั่วไป", "Guest User") : (member?.fullName.isEmpty == false ? member!.fullName : (member?.email ?? ""))
    }
    private var displaySubtitle: String { /* ... (เหมือนเดิม) ... */
        isGuest ? language.localized("แตะเพื่อเข้าสู่ระบบ/สมัครสมาชิก", "Tap to Login / Register") : subtitle // <--- ปรับข้อความ Subtitle
    }
    private var initials: String { /* ... (เหมือนเดิม) ... */
        isGuest ? "G" : (member?.email ?? "?").emailInitials
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                // ... (Background Gradient และ Circles เหมือนเดิม) ...
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(LinearGradient(colors: [.purple.opacity(0.95), .indigo.opacity(0.9)],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                Circle().fill(Color.white.opacity(0.03)).frame(width: 160, height: 160).blur(radius: 20).offset(x: 140, y: -50)
                Circle().fill(Color.black.opacity(0.03)).frame(width: 120, height: 120).blur(radius: 18).offset(x: -140, y: 60)

                VStack(alignment: .leading, spacing: 14) {
                    HStack(alignment: .top, spacing: 12) {
                        // Avatar
                        ZStack {
                            Circle().fill(LinearGradient(colors: [.blue, .orange], startPoint: .topLeading, endPoint: .bottomTrailing))
                            Text(initials).font(.headline.bold()).foregroundStyle(.white)
                        }
                        .frame(width: 56, height: 56)
                        .overlay(Circle().stroke(.white.opacity(0.8), lineWidth: 2))

                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 8) {
                                Text(timeGreeting())
                                    .font(.title3.weight(.bold))
                                    .foregroundStyle(.white)
                                Text("👋")
                                    .rotationEffect(.degrees(wave ? 15 : -10), anchor: .bottomLeading)
                                    .animation(.easeInOut(duration: 1)
                                        .repeatForever(autoreverses: true), value: wave)
                            }

                            Text(displayName)
                                .font(.headline)
                                .foregroundStyle(.white.opacity(0.92))

                            Text(isGuest ? language.localized("กำลังใช้งานในโหมด Guest", "Currently in Guest Mode") : subtitle)
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.8))

                            if isGuest {
                                Button(language.localized("เข้าสู่ระบบ", "Login")) {
                                    showLoginPromptAlert = true
                                }
                                .font(.title3.weight(.bold))
                                .foregroundColor(.yellow)
                                .underline()
                            }
                        }
                        Spacer()
                    }
                    // Pills (แสดงเฉพาะตอน Login)
                    if !isGuest {
                        HStack(spacing: 8) {
                            if let email = member?.email, !email.isEmpty {
                                Pill(icon: "envelope.fill", text: email, bg: .black).lineLimit(1).truncationMode(.middle)
                            }
                            Pill(icon: "star.fill", text: language.localized("แต้มบุญ", "Merit") + " \(meritPoints)", bg: .orange)
                        }
                    }
                }
                .padding(16)
            } // End ZStack
            .overlay(/* ... Stroke ... */ RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(.white.opacity(0.08), lineWidth: 1))
            .shadow(/* ... Shadow ... */ color: .black.opacity(0.12), radius: 10, y: 6)
            .padding(.horizontal)
        }
        .onAppear { wave = true }
        // --- 👇 [เพิ่ม] Alert Modifier ---
        .alert(language.localized("เข้าสู่ระบบ / สมัครสมาชิก", "Login / Register"), isPresented: $showLoginPromptAlert) {
            Button(language.localized("ไปที่หน้า Login", "Go to Login")) {
                flowManager.exitGuestMode() // เรียก Action ที่จะพาไปหน้า Login
            }
            Button(language.localized("ยกเลิก", "Cancel"), role: .cancel) {}
        } message: {
            Text(language.localized("คุณต้องการไปที่หน้าเข้าสู่ระบบหรือสมัครสมาชิกหรือไม่?", "Do you want to go to the login or registration page?"))
        }
        // --- 👆 สิ้นสุด ---
    }

    // MARK: - Helpers
    private func timeGreeting() -> String {
        let h = Calendar.current.component(.hour, from: Date())
        switch h {
        case 5..<12:  return language.localized("สวัสดีตอนเช้า", "Good Morning")
        case 12..<16: return language.localized("สวัสดีตอนบ่าย", "Good Afternoon")
        case 16..<20: return language.localized("สวัสดีตอนเย็น", "Good Evening")
        default:      return language.localized("สวัสดี", "Hello") // หรือ "Good Night" ถ้าต้องการ
        }
    }
}
// MARK: - PlaceSection (รวม NearYou + TopReviews - แก้ไข Subtitle IL)
private struct PlaceSection: View {
    @EnvironmentObject var language: AppLanguage
    var nearest: [(place: SacredPlace, distance: CLLocationDistance)]
    var topRated: [SacredPlace] // อันนี้คือ topILPlaces
    var flowManager: MuTeLuFlowManager
    
    @State private var selectedTab = 0
    @State private var pageNear = 0
    @State private var pageTop  = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("", selection: $selectedTab) {
                Text(language.localized("อยู่ใกล้คุณ", "Near You")).tag(0)
                Text(language.localized("ยอดนิยม (IL)", "Top Rated (IL)")).tag(1) // ชื่อ Tab ถูกต้องแล้ว
            }
            .pickerStyle(.segmented)
            .padding(.horizontal) // เพิ่ม Padding ให้ Picker
            
            if selectedTab == 0 { // Near You Tab
                if nearest.isEmpty {
                    EmptyStateView(icon: "location.slash.fill", text: language.localized("กำลังค้นหาสถานที่ใกล้คุณ...", "Finding places near you..."))
                        .frame(maxWidth: .infinity, minHeight: 160).padding(.horizontal)
                } else {
                    TabView(selection: $pageNear) {
                        ForEach(Array(nearest.prefix(3).enumerated()), id: \.offset) { idx, item in
                            PlaceCard(
                                title: language.localized(item.place.nameTH, item.place.nameEN),
                                subtitle: language.localized("🚙  ห่าง \(formatDistance(item.distance))", "🚙  \(formatDistance(item.distance, locale: Locale(identifier: "en_US"))) away"),
                                buttonTitle: language.localized("รายละเอียดสถานที่", "View details"),
                                buttonAction: { flowManager.navigateTo(.sacredDetail(place: item.place)) }
                            )
                            .padding(.bottom, 22).tag(idx)
                            .padding(.horizontal) // เพิ่ม Padding ให้ Card
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic)).frame(height: 190)
                }
            } else { // Top Rated (IL) Tab
                if topRated.isEmpty {
                    EmptyStateView(icon: "star.slash.fill", text: language.localized("ไม่พบสถานที่แนะนำ", "No recommended places found"))
                        .frame(maxWidth: .infinity, minHeight: 160).padding(.horizontal)
                } else {
                    TabView(selection: $pageTop) {
                        ForEach(Array(topRated.prefix(3).enumerated()), id: \.offset) { idx, place in
                            PlaceCard(
                                title: language.localized(place.nameTH, place.nameEN),
                                // --- 👇 [แก้ไข] แสดง Tag แทน Rating สำหรับ IL ---
                                subtitle: place.tags.prefix(2).joined(separator: ", ") + (place.tags.count > 2 ? "..." : ""),
                                // --- 👆 สิ้นสุด ---
                                buttonTitle: language.localized("รายละเอียดสถานที่", "View details"),
                                buttonAction: { flowManager.navigateTo(.sacredDetail(place: place)) }
                            )
                            .padding(.bottom, 22).tag(idx)
                            .padding(.horizontal) // เพิ่ม Padding ให้ Card
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic)).frame(height: 190)
                }
            }
        }
        .animation(.easeInOut, value: selectedTab)
    }
    // formatDistance function (เหมือนเดิม)
    private func formatDistance(_ meters: CLLocationDistance, locale: Locale = Locale(identifier: "th_TH")) -> String {
        let f = MKDistanceFormatter(); f.unitStyle = .abbreviated; f.locale = locale
        return f.string(fromDistance: meters)
    }
}

// MARK: - PlaceCard (เหมือนเดิม)
private struct PlaceCard: View {
    let title: String
    let subtitle: String
    let buttonTitle: String
    let buttonAction: () -> Void
    
    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("🕍")
                    Text(title)
                        .font(.subheadline).bold()
                        .foregroundStyle(Color(.label))
                        .lineLimit(2)
                }
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                PrimaryButton(title: buttonTitle, color: .purple, action: buttonAction)
            }
        }
    }
}

// MARK: - EmptyStateView (เหมือนเดิม)
private struct EmptyStateView: View {
    let icon: String
    let text: String
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon).font(.title2).foregroundStyle(.secondary)
            Text(text).font(.footnote).foregroundStyle(.secondary)
        }.frame(maxWidth: .infinity).padding().background(Color(.secondarySystemBackground)).clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: - Banner stack (เพิ่ม Padding)
private struct BannerStack: View {
    @Binding var showBanner: Bool
    @EnvironmentObject var language: AppLanguage
    var currentMember: Member?
    
    var body: some View {
        VStack(spacing: 12) {
            if showBanner {
                DailyBannerView(member: currentMember)
                    .environmentObject(language)
            }
        }
        .padding(.horizontal) // เพิ่ม Padding ให้ Banner
    }
}

// MARK: - Pill (เหมือนเดิม)
private struct Pill: View {
    var icon: String; var text: String; var bg: Color
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon).symbolRenderingMode(.palette).foregroundStyle(.white, .white.opacity(0.4))
            Text(text).foregroundStyle(.white).font(.footnote.weight(.semibold))
        }.padding(.horizontal, 10).padding(.vertical, 6).background(bg.opacity(0.01)).clipShape(Capsule())
    }
}

// MARK: - Card (เหมือนเดิม)
struct Card<Content: View>: View {
    @Environment(\.colorScheme) private var scheme; let content: Content; init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View {
        VStack(alignment: .leading, spacing: 8) { content }.padding().frame(maxWidth: .infinity).background(Color(.secondarySystemBackground)).cornerRadius(16).overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(.separator), lineWidth: 0.5)).shadow(color: .black.opacity(scheme == .dark ? 0.15 : 0.25), radius: scheme == .dark ? 4 : 8, x: 0, y: 3)
    }
}

// MARK: - PrimaryButton (เหมือนเดิม)
private struct PrimaryButton: View {
    let title: String; let color: Color; let action: () -> Void
    var body: some View {
        Button(action: action) { Text(title).fontWeight(.bold).frame(maxWidth: .infinity).padding(.vertical, 9).background(color.opacity(0.95)).foregroundColor(.white).clipShape(RoundedRectangle(cornerRadius: 12)) }
    }
}

// MARK: - StarRatingView (เหมือนเดิม)
struct StarRatingView: View {
    let rating: Double; let maxStars: Int = 5; let showText: Bool = true
    var body: some View {
        HStack(spacing: 6) { HStack(spacing: 2) { ForEach(0..<maxStars, id: \.self) { i in let t = Double(i)+1; if rating>=t { Image(systemName: "star.fill") } else if rating>=t-0.5 { Image(systemName: "star.leadinghalf.filled") } else { Image(systemName: "star") } } }.foregroundStyle(.orange).symbolRenderingMode(.hierarchical).font(.caption); if showText { Text(String(format: "(%.1f / 5)", min(max(rating,0),5))).font(.caption).foregroundStyle(.secondary) } }
    }
}

// MARK: - Quick actions grid (เพิ่ม Padding)
private struct QuickActionsGrid: View {
    @EnvironmentObject var language: AppLanguage
    let flowManager: MuTeLuFlowManager
    private var items: [(th: String, en: String, icon: String, screen: MuTeLuScreen)] {
        [("ค้นหาตามหมวด", "Category Search", "magnifyingglass.circle.fill", .categorySearch),("วันสำคัญและวัดที่เหมาะกับวันนี้","Today's Events & Temples","wand.and.stars",.recommenderForYou),("แนะนำสถานที่ศักดิ์สิทธิ์รอบจุฬาฯ","Sacred Places around Chula","building.columns", .recommendation),("ทำนายเบอร์โทร","Phone Fortune","phone.circle", .phoneFortune),("คะแนนแต้มบุญ","Merit Points","star.circle", .meritPoints),("สีเสื้อประจำวัน","Shirt Color","tshirt", .shirtColor),("เลขทะเบียนรถ","Car Plate Number","car", .carPlate),("เลขที่บ้าน","House Number","house", .houseNumber),("ดูดวงไพ่ทาโร่","Tarot Reading","suit.club", .tarot),("เซียมซี","Fortune Sticks","scroll", .seamSi),("คาถาประจำวัน","Daily Mantra","sparkles", .mantra),("เกร็ดความรู้","Knowledge","book.closed", .knowledge),("เกมส่งเสริมวัฒนธรรม", "Cultural Games", "gift.fill", .gameMenu)]
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(items.indices, id: \.self) { i in
                    let it = items[i];
                    MenuButton(titleTH: it.th, titleEN: it.en, image: it.icon, screen: it.screen)
                        .environmentObject(language)
                        .environmentObject(flowManager)
                }
            }
        }
        .padding(.horizontal) // เพิ่ม Padding ให้ Grid
    }
}
