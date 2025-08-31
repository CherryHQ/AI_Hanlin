//
//  MemoryArchiveView.swift
//  AI_Hanlin
//
//  Created by 哆啦好多梦 on 1/4/25.
//

import SwiftUI
import SwiftData

struct MemoryArchiveView: View {
    @Query(sort: [SortDescriptor(\MemoryArchive.timestamp, order: .reverse)]) private var memories: [MemoryArchive]
    @Query private var userInfos: [UserInfo] // 查询用户信息
    @Environment(\.modelContext) private var modelContext

    @State private var searchText: String = ""
    @State private var showClearAllAlert = false
    @State private var isFeedBack: Bool = false
    @State private var showMemorySheet = false
    @State private var memoryContent = ""
    @State private var memoryToEdit: MemoryArchive? = nil

    // 获取用户的 useMemory 状态（默认 true）
    private var memoryEnabledBinding: Binding<Bool> {
        Binding(
            get: { userInfos.first?.useMemory ?? true },
            set: { newValue in
                if let userInfo = userInfos.first {
                    userInfo.useMemory = newValue
                    try? modelContext.save()
                }
            }
        )
    }
    
    // 获取用户的 useCrossMemory 状态（默认 true）
    private var crossMemoryEnabledBinding: Binding<Bool> {
        Binding(
            get: { userInfos.first?.useCrossMemory ?? true },
            set: { newValue in
                if let userInfo = userInfos.first {
                    userInfo.useCrossMemory = newValue
                    try? modelContext.save()
                }
            }
        )
    }

    var body: some View {
        ZStack {
            backgroundView
            memoryListView
        }
        .navigationTitle("记忆档案")
        .searchable(text: $searchText, prompt: "搜索记忆")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showClearAllAlert = true
                }) {
                    Text("清空所有")
                }
            }
        }
        .alert("确定要清除所有记忆吗？", isPresented: $showClearAllAlert) {
            Button("取消", role: .cancel) {}
            Button("清除", role: .destructive, action: clearAllMemories)
        }
        .sheet(isPresented: $showMemorySheet) {
            NavigationView {
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [Color.hlBlue.opacity(0.2), Color.hlPurple.opacity(0.2)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    VStack(spacing: 12) {
                        TextEditor(text: $memoryContent)
                            .scrollContentBackground(.hidden)    // 隐藏默认滚动视图背景
                            .background(Color.clear)             // 背景设为透明
                            .foregroundColor(.hlBluefont)        // 文本颜色
                    }
                    .padding(.horizontal, 12)
                    .visualEffect { content, proxy in
                        content.hueRotation(Angle(degrees: proxy.frame(in: .global).origin.y / 20))
                    }
                }
                .navigationTitle("记忆编辑")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button {
                            isFeedBack.toggle()
                            showMemorySheet = false
                            memoryToEdit = nil
                            memoryContent = ""
                        } label: {
                            HStack {
                                Image(systemName: "xmark")
                                Text("取消")
                            }
                            .font(.caption)
                            .foregroundColor(.hlBluefont)
                            .padding(6)
                            .background(BlurView(style: .systemUltraThinMaterial))
                            .clipShape(Capsule())
                            .shadow(color: .hlBlue, radius: 1)
                        }
                        .sensoryFeedback(.impact, trigger: isFeedBack)
                    }
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button {
                            isFeedBack.toggle()
                            if let mem = memoryToEdit {
                                mem.content = memoryContent
                            } else {
                                let newMem = MemoryArchive(content: memoryContent, timestamp: Date())
                                modelContext.insert(newMem)
                            }
                            try? modelContext.save()
                            showMemorySheet = false
                            memoryToEdit = nil
                            memoryContent = ""
                        } label: {
                            HStack {
                                Image(systemName: "checkmark")
                                Text("保存")
                            }
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(6)
                            .background(.hlBlue)
                            .background(BlurView(style: .systemUltraThinMaterial))
                            .clipShape(Capsule())
                            .shadow(color: .hlBlue, radius: 1)
                        }
                        .sensoryFeedback(.impact, trigger: isFeedBack)
                    }
                }
            }
        }
    }

    private var backgroundView: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color.hlBlue.opacity(0.2), Color.hlPurple.opacity(0.2)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var filteredMemories: [MemoryArchive] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return memories }
        let lowerSearch = trimmed.lowercased()
        return memories.filter {
            let content = $0.content ?? ""
            let contentLower = content.lowercased()
            let contentPinyin = content.toPinyin().lowercased()
            return contentLower.contains(lowerSearch) || contentPinyin.contains(lowerSearch)
        }
    }

    private var memoryListView: some View {
        List {
            if searchText.isEmpty {
                // MARK: 信息提示区
                VStack(alignment: .center) {
                    Image(systemName: "archivebox")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.hlBluefont)
                        .padding()
                    
                    Text("记忆档案功能用于聊天，受支持的模型会自动在聊天时记住你的喜好并在需要的时候主动回忆这些喜好。")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding(.bottom)
                    
                    HStack {
                        Toggle("启用记忆功能", isOn: memoryEnabledBinding)
                            .tint(.hlBlue)
                    }
                    
//                    HStack {
//                        Toggle("启用跨聊天记忆", isOn: crossMemoryEnabledBinding)
//                            .tint(.hlBlue)
//                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .padding()
                .background(
                    BlurView(style: .systemThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: .hlBlue, radius: 1)
                )
                .visualEffect { content, proxy in
                    content.hueRotation(Angle(degrees: proxy.frame(in: .global).origin.y / 15))
                }
            }
            
            if memoryEnabledBinding.wrappedValue {
                ForEach(filteredMemories, id: \.id) { memory in
                    memoryCard(for: memory)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                deleteMemory(memory)
                            } label: {
                                Label("忘记", systemImage: "heart.slash")
                            }
                            .tint(Color(.hlRed))
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button {
                                memoryToEdit = memory
                                memoryContent = memory.content ?? ""
                                showMemorySheet = true
                            } label: {
                                Label("更新", systemImage: "arrow.trianglehead.clockwise.heart")
                            }
                            .tint(Color(.hlGreen))
                        }
                }
                
                Button(action: {
                    memoryToEdit = nil
                    memoryContent = ""
                    showMemorySheet = true
                }) {
                    VStack {
                        HStack {
                            Image(systemName: "arrow.up.heart")
                            Text("灌输新记忆")
                        }
                        .foregroundColor(.hlBluefont)
                        .padding()
                    }
                    .frame(maxWidth: .infinity)
                    .background(
                        BlurView(style: .systemThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(color: .hlBlue, radius: 1)
                    )
                    .visualEffect { content, proxy in
                        content.hueRotation(Angle(degrees: proxy.frame(in: .global).origin.y / 15))
                    }
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                
            } else {
                HStack {
                    Image(systemName: "heart.slash")
                    Text("记忆功能已关闭")
                }
                .foregroundColor(.hlBluefont)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .padding()
                .visualEffect { content, proxy in
                    content.hueRotation(Angle(degrees: proxy.frame(in: .global).origin.y / 15))
                }
            }
        }
        .listStyle(PlainListStyle())
    }

    private func memoryCard(for memory: MemoryArchive) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(highlightedContent(for: memory))
                    .foregroundColor(.primary)
                    .truncationMode(.tail)
            }
            .sensoryFeedback(.impact, trigger: isFeedBack)
            
            HStack {
                Spacer()
                Text(formattedDate(memory.timestamp))
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            BlurView(style: .systemThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: .hlBlue, radius: 1)
        )
        .visualEffect { content, proxy in
            content.hueRotation(Angle(degrees: proxy.frame(in: .global).origin.y / 15))
        }
    }

    private func highlightedContent(for memory: MemoryArchive) -> AttributedString {
        let content = memory.content ?? ""
        var attributed = AttributedString(content)
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedSearch.isEmpty else { return attributed }

        let lowerSearch = trimmedSearch.lowercased()
        let lowerContent = content.lowercased()
        let pinyin = content.toPinyin().lowercased()

        var matchFound = false

        var range = lowerContent.startIndex..<lowerContent.endIndex
        while let found = lowerContent.range(of: lowerSearch, options: .caseInsensitive, range: range) {
            let nsRange = NSRange(found, in: content)
            if let attrRange = Range(nsRange, in: attributed) {
                attributed[attrRange].foregroundColor = .hlBlue
            }
            range = found.upperBound..<lowerContent.endIndex
            matchFound = true
        }

        if !matchFound {
            if let pinyinRange = pinyin.range(of: lowerSearch, options: .caseInsensitive) {
                var mapping: [Range<Int>] = []
                var current = 0
                for char in content {
                    let pinyinChar = String(char).toPinyin()
                    let length = pinyinChar.count
                    mapping.append(current..<current+length)
                    current += length
                }
                let startOffset = pinyin.distance(from: pinyin.startIndex, to: pinyinRange.lowerBound)
                let endOffset = pinyin.distance(from: pinyin.startIndex, to: pinyinRange.upperBound)

                for (i, mapRange) in mapping.enumerated() {
                    if mapRange.overlaps(startOffset..<endOffset) {
                        let idx = content.index(content.startIndex, offsetBy: i)
                        let nsRange = NSRange(idx...idx, in: content)
                        if let attrRange = Range(nsRange, in: attributed) {
                            attributed[attrRange].foregroundColor = .hlBluefont
                        }
                    }
                }
            }
        }
        return attributed
    }

    private func deleteMemory(_ memory: MemoryArchive) {
        modelContext.delete(memory)
        try? modelContext.save()
    }

    private func clearAllMemories() {
        for memory in memories {
            modelContext.delete(memory)
        }
        try? modelContext.save()
    }
}
