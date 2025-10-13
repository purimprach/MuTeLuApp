import SwiftUI

// MARK: - Main Game View
struct OfferingGameView: View {
    @StateObject private var viewModel = OfferingGameViewModel()
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flow: MuTeLuFlowManager
    
    // State สำหรับ Animation และ Alert
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var showExitAlert = false // 👈 [เพิ่ม] State สำหรับ Alert ยืนยันออกจากเกม
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.orange.opacity(0.2), Color.yellow.opacity(0.2), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // [แก้ไข] ส่ง Binding สำหรับ showExitAlert เข้าไป
                GameHeader(viewModel: viewModel, showExitAlert: $showExitAlert)
                
                BasketView(viewModel: viewModel)
                
                ItemSelectionView(viewModel: viewModel)
                
                GameControlsView(
                    viewModel: viewModel,
                    showSuccessAlert: $showSuccessAlert,
                    showErrorAlert: $showErrorAlert,
                    errorMessage: $errorMessage
                )
            }
        }
        .alert(language.localized("ยินดีด้วย!", "Congratulations!"), isPresented: $showSuccessAlert) {
            Button("OK") {
                viewModel.goToNextLevel()
                if viewModel.isGameFinished {
                    flow.currentScreen = .gameMenu
                }
            }
        } message: {
            Text(language.localized("คุณจัดของได้ถูกต้องและผ่านด่านนี้!", "You have prepared the offerings correctly and passed this level!"))
        }
        .alert(language.localized("ลองใหม่อีกครั้ง", "Try Again"), isPresented: $showErrorAlert) {
            Button("OK") {}
        } message: {
            Text(errorMessage)
        }
        // 👇 [เพิ่ม] Alert สำหรับยืนยันการออกจากเกม
        .alert(language.localized("ออกจากเกม?", "Quit Game?"), isPresented: $showExitAlert) {
            Button(language.localized("ยืนยัน", "Confirm"), role: .destructive) {
                // Action: กลับไปที่หน้าเมนูเกม
                flow.currentScreen = .gameMenu
            }
            Button(language.localized("ยกเลิก", "Cancel"), role: .cancel) {}
        } message: {
            Text(language.localized("คุณต้องการออกจากเกมใช่หรือไม่", "Are you sure you want to quit the game?"))
        }
    }
}


// MARK: - Game Components

struct GameHeader: View {
    @ObservedObject var viewModel: OfferingGameViewModel
    @EnvironmentObject var language: AppLanguage
    @Binding var showExitAlert: Bool // 👈 [เพิ่ม] รับ Binding เข้ามา
    
    var body: some View {
        VStack(spacing: 8) {
            // 👇 [เพิ่ม] ปุ่มย้อนกลับ/ออกจากเกม
            HStack {
                Button(action: {
                    showExitAlert = true // แสดง Alert เมื่อกด
                }) {
                    Label(language.localized("ย้อนกลับ", "Back"), systemImage: "chevron.left")
                }
                .tint(.red) // ทำให้ปุ่มเป็นสีแดง
                Spacer()
            }
            
            Text(language.localized("ด่านที่ \(viewModel.currentLevel + 1): จัดของใส่บาตร", "Level \(viewModel.currentLevel + 1): Prepare Offerings"))
                .font(.title2.bold())
                .foregroundStyle(Color.orange.gradient)
            
            Text(language.localized("งบประมาณ: \(viewModel.currentOfferingLevel.budget) บาท", "Budget: \(viewModel.currentOfferingLevel.budget) Baht"))
                .font(.headline)
            
            ProgressView(value: Double(viewModel.usedBudget), total: Double(viewModel.currentOfferingLevel.budget))
                .progressViewStyle(LinearProgressViewStyle(tint: viewModel.isOverBudget ? .red : .orange))
                .scaleEffect(x: 1, y: 2, anchor: .center)
                .padding(.horizontal)
            
            Text(language.localized("ใช้ไปแล้ว: \(viewModel.usedBudget) บาท", "Spent: \(viewModel.usedBudget) Baht"))
                .font(.subheadline)
                .foregroundColor(viewModel.isOverBudget ? .red : .secondary)
        }
        .padding()
    }
}

// โค้ดส่วนที่เหลือ (BasketView, ItemSelectionView, GameControlsView) เหมือนเดิม ไม่ต้องแก้ไข
struct BasketView: View {
    @ObservedObject var viewModel: OfferingGameViewModel
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.yellow.opacity(0.1))
                .frame(height: 150)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.orange.opacity(0.5), style: StrokeStyle(lineWidth: 2, dash: [10]))
                )
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(viewModel.basket) { item in
                        VStack {
                            Text(item.emoji)
                                .font(.largeTitle)
                            Text(item.name)
                                .font(.caption)
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .onTapGesture {
                            withAnimation {
                                viewModel.removeItem(item)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .padding(.horizontal)
    }
}

struct ItemSelectionView: View {
    @ObservedObject var viewModel: OfferingGameViewModel
    
    let columns = [GridItem(.adaptive(minimum: 100))]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(sampleOfferingItems) { item in
                    Button(action: {
                        withAnimation {
                            viewModel.addItem(item)
                        }
                    }) {
                        ItemCard(item: item)
                    }
                }
            }
            .padding()
        }
    }
}

struct ItemCard: View {
    let item: OfferingItem
    
    var body: some View {
        VStack {
            Text(item.emoji)
                .font(.largeTitle)
                .padding(10)
                .background(Color.yellow.opacity(0.2))
                .clipShape(Circle())
            Text(item.name)
                .font(.headline)
            Text("฿\(item.price)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

struct GameControlsView: View {
    @ObservedObject var viewModel: OfferingGameViewModel
    @EnvironmentObject var language: AppLanguage
    @Binding var showSuccessAlert: Bool
    @Binding var showErrorAlert: Bool
    @Binding var errorMessage: String
    
    var body: some View {
        HStack {
            Button(action: {
                withAnimation {
                    viewModel.resetBasket()
                }
            }) {
                Label(language.localized("ล้างตะกร้า", "Reset"), systemImage: "arrow.uturn.backward.circle")
                    .fontWeight(.bold)
            }
            .buttonStyle(.bordered)
            .tint(.red)
            
            Button(action: {
                let (success, message) = viewModel.checkResult()
                if success {
                    showSuccessAlert = true
                } else {
                    errorMessage = language.localized(message.th, message.en)
                    showErrorAlert = true
                }
            }) {
                Label(language.localized("ถวาย", "Offer"), systemImage: "checkmark.circle.fill")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
        }
        .padding()
    }
}
