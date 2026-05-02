//
//  CalculatorView.swift
//  CrisisPulse
//
//  Multi-step preparedness questionnaire that produces a personalized
//  supply checklist via SupplyEngine.
//

import SwiftUI

struct CalculatorView: View {
    @EnvironmentObject var app: AppState
    @State private var input = CalculatorInput()
    @State private var step: Step = .form
    @State private var result: [SupplyCategory] = []

    enum Step { case form, result }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.cpBackgroundTop.ignoresSafeArea()

                if step == .form {
                    formView
                } else {
                    resultView
                }
            }
            .navigationTitle(T("calc.title", app.language))
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private var formView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                section(T("calc.step.location", app.language)) {
                    TextField(T("calc.country.placeholder", app.language), text: $input.country)
                        .textFieldStyle(.roundedBorder)
                        .submitLabel(.done)
                }

                section(T("calc.step.housing", app.language)) {
                    Picker("", selection: $input.housing) {
                        ForEach(CalculatorInput.Housing.allCases) { h in
                            Text(app.language.hasPrefix("zh") ? h.labelZH : h.labelEN).tag(h)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                section(T("calc.step.household", app.language)) {
                    Stepper(value: $input.adults, in: 1...12) {
                        HStack {
                            Text(T("calc.adults", app.language))
                            Spacer()
                            Text("\(input.adults)").foregroundStyle(.white).fontWeight(.semibold)
                        }
                    }
                    Stepper(value: $input.children, in: 0...10) {
                        HStack {
                            Text(T("calc.children", app.language))
                            Spacer()
                            Text("\(input.children)").foregroundStyle(.white).fontWeight(.semibold)
                        }
                    }
                    Toggle(T("calc.infants", app.language), isOn: $input.hasInfants)
                    Toggle(T("calc.pets", app.language), isOn: $input.hasPets)
                    Toggle(T("calc.medical", app.language), isOn: $input.hasMedicalNeeds)
                }

                section(T("calc.step.duration", app.language)) {
                    HStack {
                        Slider(value: Binding(
                            get: { Double(input.months) },
                            set: { input.months = Int($0) }
                        ), in: 1...12, step: 1)
                        Text(String(format: T("calc.months", app.language), input.months))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 80, alignment: .trailing)
                    }
                }

                Button {
                    result = SupplyEngine.build(from: input)
                    withAnimation { step = .result }
                } label: {
                    Text(T("calc.generate", app.language))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.cpAccent, in: RoundedRectangle(cornerRadius: 12))
                }
                .padding(.top, 4)
            }
            .padding(20)
        }
    }

    private var resultView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text(T("calc.result.title", app.language))
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.top, 4)

                ForEach(result) { category in
                    categoryCard(category)
                }

                Text(T("calc.result.note", app.language))
                    .font(.system(size: 12))
                    .foregroundStyle(Color.cpTextSecondary)
                    .padding(.top, 4)

                HStack {
                    ShareLink(
                        item: shareText,
                        preview: SharePreview("Crisis Pulse — Supply Plan")
                    ) {
                        Label(T("calc.result.share", app.language), systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.cpAccent)

                    Spacer()

                    Button {
                        withAnimation { step = .form }
                    } label: {
                        Text(T("calc.back", app.language))
                            .foregroundStyle(Color.cpTextSecondary)
                    }
                }
                .padding(.top, 8)
            }
            .padding(20)
        }
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.cpTextPrimary)
            VStack(spacing: 10) { content() }
                .padding(14)
                .background(Color.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.06)))
        }
    }

    private func categoryCard(_ category: SupplyCategory) -> some View {
        let isZH = app.language.hasPrefix("zh")
        let title = isZH ? category.titleZh : category.title
        let tierText: String = {
            switch category.tier {
            case .red: return T("calc.result.tier.red", app.language)
            case .amber: return T("calc.result.tier.amber", app.language)
            case .blue: return T("calc.result.tier.blue", app.language)
            }
        }()
        let tierColor: Color = {
            switch category.tier {
            case .red: return Color.cpDanger
            case .amber: return Color.cpAmber
            case .blue: return Color.cpAccent
            }
        }()
        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: category.icon)
                    .foregroundStyle(tierColor)
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                Spacer()
                Text(tierText)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(tierColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(tierColor.opacity(0.12), in: Capsule())
            }
            ForEach(category.items) { item in
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(isZH ? item.nameZh : item.name)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                        Text(isZH ? item.rationaleZh : item.rationale)
                            .font(.system(size: 11))
                            .foregroundStyle(Color.cpTextSecondary)
                    }
                    Spacer(minLength: 4)
                    Text(item.quantity)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(tierColor)
                }
                .padding(.vertical, 4)
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.06)))
    }

    private var shareText: String {
        let isZH = app.language.hasPrefix("zh")
        var lines: [String] = ["Crisis Pulse — \(T("calc.result.title", app.language))"]
        for cat in result {
            lines.append("")
            lines.append("# \(isZH ? cat.titleZh : cat.title)")
            for item in cat.items {
                lines.append("• \(isZH ? item.nameZh : item.name) — \(item.quantity)")
            }
        }
        lines.append("")
        lines.append("https://crisispulse.org")
        return lines.joined(separator: "\n")
    }
}

#Preview {
    CalculatorView().environmentObject(AppState())
}
