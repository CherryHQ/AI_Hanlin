//
//  SettingsView.swift
//  AI_HLY
//
//  Created by 哆啦好多梦 on 10/2/25.
//

import SwiftUI
import SwiftData
import SafariServices

struct SettingsView: View {
    
    @State private var isPushed: Bool = false  // 监听是否进入子页面
    @State private var showSafariGuide: Bool = false
    @State private var showSafariCost: Bool = false
    
    @Query var apiKeys: [APIKeys]
    @Query var searchKeys: [SearchKeys]
    
    var body: some View {
        
        let noAPIKeys = apiKeys
            .filter { $0.company != "LOCAL" }
            .allSatisfy { $0.key?.isEmpty ?? true }
        
        let noSearchKeys = searchKeys
            .allSatisfy { $0.key?.isEmpty ?? true }
        
        NavigationStack {
            List {
                Section(header: Text("个性化")) {
                    NavigationLink(destination: UserInfoView().onAppear { isPushed = true }.onDisappear { isPushed = false }.toolbar(.hidden, for: .tabBar)) {
                        Label("用户信息", systemImage: "person")
                    }
                    NavigationLink(destination: PromptRepoView().onAppear { isPushed = true }.onDisappear { isPushed = false}.toolbar(.hidden, for: .tabBar)) {
                        Label("提示词库", systemImage: "tray.full")
                    }
                    NavigationLink(destination: MemoryArchiveView().onAppear { isPushed = true }.onDisappear { isPushed = false}.toolbar(.hidden, for: .tabBar)) {
                        Label("记忆档案", systemImage: "archivebox")
                    }
                    NavigationLink(destination: TranslationDicView().onAppear { isPushed = true }.onDisappear { isPushed = false}.toolbar(.hidden, for: .tabBar)) {
                        Label("翻译词典", systemImage: "character.book.closed")
                    }
                }
                if noAPIKeys {
                    Section {
                        Text("指引：点击下方“模型”中的“模型密钥”设置大模型密钥和厂商的启用状态")
                            .font(.caption)
                            .foregroundColor(.hlBluefont)
                    }
                }
                Section(header: Text("模型")) {
                    NavigationLink(destination: APIKeysView().onAppear { isPushed = true }.onDisappear { isPushed = false }.toolbar(.hidden, for: .tabBar)) {
                        Label("模型密钥", systemImage: "key.2.on.ring")
                    }
                    NavigationLink(destination: SelectEmbeddingModelView().onAppear { isPushed = true }.onDisappear { isPushed = false }.toolbar(.hidden, for: .tabBar)) {
                        Label("向量模型", systemImage: "compass.drawing")
                    }
                    NavigationLink(destination: SelectOptimizationModelView().onAppear { isPushed = true }.onDisappear { isPushed = false }.toolbar(.hidden, for: .tabBar)) {
                        Label("优化模型", systemImage: "hammer")
                    }
                    NavigationLink(destination: SelectTTSModelView().onAppear { isPushed = true }.onDisappear { isPushed = false }.toolbar(.hidden, for: .tabBar)) {
                        Label("语音模型", systemImage: "waveform")
                    }
                }
                if noSearchKeys {
                    Section {
                        Text("指引：点击下方“工具”中的“联网搜索”设置搜索引擎密钥和需要使用的搜索引擎")
                            .font(.caption)
                            .foregroundColor(.hlBluefont)
                    }
                }
                Section(header: Text("工具")) {
                    NavigationLink(destination: SearchSettingView().onAppear { isPushed = true }.onDisappear { isPushed = false }.toolbar(.hidden, for: .tabBar)) {
                        Label("联网搜索", systemImage: "magnifyingglass")
                    }
                    NavigationLink(destination: KnowledgeSettingView().onAppear { isPushed = true }.onDisappear { isPushed = false }.toolbar(.hidden, for: .tabBar)) {
                        Label("知识背包", systemImage: "backpack")
                    }
                    NavigationLink(destination: CanvasSettingView().onAppear { isPushed = true }.onDisappear { isPushed = false }.toolbar(.hidden, for: .tabBar)) {
                        Label("信息画布", systemImage: "pencil.and.outline")
                    }
                    NavigationLink(destination: MapSettingView().onAppear { isPushed = true }.onDisappear { isPushed = false }.toolbar(.hidden, for: .tabBar)) {
                        Label("地图规划", systemImage: "map")
                    }
                    NavigationLink(destination: WeatherSettingView().onAppear { isPushed = true }.onDisappear { isPushed = false }.toolbar(.hidden, for: .tabBar)) {
                        Label("天气查询", systemImage: "cloud.sun")
                    }
                    NavigationLink(destination: CalendarSettingView().onAppear { isPushed = true }.onDisappear { isPushed = false }.toolbar(.hidden, for: .tabBar)) {
                        Label("日历提醒", systemImage: "calendar")
                    }
                    NavigationLink(destination: HealthSettingView().onAppear { isPushed = true }.onDisappear { isPushed = false }.toolbar(.hidden, for: .tabBar)) {
                        Label("健康生活", systemImage: "heart")
                    }
                    NavigationLink(destination: CodeSettingView().onAppear { isPushed = true }.onDisappear { isPushed = false }.toolbar(.hidden, for: .tabBar)) {
                        Label("代码执行", systemImage: "apple.terminal")
                    }
                }
                Section(header: Text("帮助")) {
                    Button(action: {
                        showSafariGuide = true
                    }) {
                        Label {
                            Text("软件指南")
                                .foregroundColor(.primary)
                        } icon: {
                            Image(systemName: "text.rectangle.page")
                        }
                    }
                    Button(action: {
                        showSafariCost = true
                    }) {
                        Label {
                            Text("成本参考")
                                .foregroundColor(.primary)
                        } icon: {
                            Image(systemName: "creditcard")
                        }
                    }
                }
                Section(header: Text("通用")) {
                    Button(action: openLanguageSettings) {
                        Label {
                            Text("语言设置")
                                .foregroundColor(.primary)
                        } icon: {
                            Image(systemName: "globe")
                        }
                    }
                    NavigationLink(destination: FeedBackView().onAppear { isPushed = true }.onDisappear { isPushed = false }.toolbar(.hidden, for: .tabBar)) {
                        Label("触感反馈", systemImage: "iphone.gen3.radiowaves.left.and.right")
                    }
                }
                Section(header: Text("软件")) {
                    NavigationLink(destination: SoftwareIntroView().onAppear { isPushed = true }.onDisappear { isPushed = false }.toolbar(.hidden, for: .tabBar)) {
                        Label("软件介绍", systemImage: "text.book.closed")
                    }
                    NavigationLink(destination: UpdateNotesView().onAppear { isPushed = true }.onDisappear { isPushed = false }.toolbar(.hidden, for: .tabBar)) {
                        Label("更新说明", systemImage: "newspaper")
                    }
                    NavigationLink(destination: VersionInfoView().onAppear { isPushed = true }.onDisappear { isPushed = false }.toolbar(.hidden, for: .tabBar)) {
                        Label("软件信息", systemImage: "info.circle")
                    }
                    NavigationLink(destination: ContactUsView().onAppear { isPushed = true }.onDisappear { isPushed = false }.toolbar(.hidden, for: .tabBar)) {
                        Label("联系我们", systemImage: "envelope")
                    }
                }
            }
            .navigationTitle("设置")
            .onChange(of: isPushed) {
                NotificationCenter.default.post(name: .hideTabBar, object: isPushed)  // 发送通知，控制TabBar显示/隐藏
            }
            .safeAreaInset(edge: .bottom) { // 额外填充底部一个灰色区域
                Color(.clear)
                    .frame(height: 70)
            }
        }
        .fullScreenCover(isPresented: $showSafariGuide) {
            SafariView(url: URL(string: "https://docs.qq.com/aio/DT2pMUFRVWVNsZmtj")!)
                .background(BlurView(style: .systemThinMaterial))
                .edgesIgnoringSafeArea(.all)
        }
        .fullScreenCover(isPresented: $showSafariCost) {
            SafariView(url: URL(string: "https://docs.qq.com/smartsheet/DT3dzT1JlSFVvU05n?viewId=vUQPXH&tab=db_KULEGz")!)
                .background(BlurView(style: .systemThinMaterial))
                .edgesIgnoringSafeArea(.all)
        }
    }
    
    /// 打开系统的“语言与地区”设置
    private func openLanguageSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else {
            return
        }
        UIApplication.shared.open(url)
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        print("加载的 URL: \(url.absoluteString)") // 调试日志
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
