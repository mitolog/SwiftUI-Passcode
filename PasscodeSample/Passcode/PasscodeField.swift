import SwiftUI
import Foundation
import UIKit
import Combine

extension PasscodeField {
    static let Count: Int = 4
}

extension PasscodeField {
    struct Colors {
        var cursor: Color = Color.accentColor
        var underbarOn: Color = Color.accentColor
        var underbarOff: Color = Color.black
        var background: Color = Color.white
    }
}

struct PasscodeField: View {

    @Binding var resultText: String

    @State var isInFocus = true
    @State var current = 0
    @State var masks: [Bool] = Array(repeating: false, count: PasscodeField.Count)
    @State var prompts: [Bool] = Array(repeating: false, count: PasscodeField.Count)

    let keyboardCloseOnFillout: Bool
    let textAreaSize: CGSize
    let textFont: Font
    let colors: Colors
    let verticalPadding: CGFloat = 5
    let horizontalPadding: CGFloat = 15 // padding between each cells
    let underbarHeight: CGFloat = 4

    init(resultText: Binding<String>,
         keyboardCloseOnFillout: Bool = false,
         cellSize: CGSize = CGSize(width: 51, height: 60),
         textFont: Font = Font.system(size: 46),
         colors: Colors = Colors()
    ){
        _resultText = resultText
        self.keyboardCloseOnFillout = keyboardCloseOnFillout
        self.textAreaSize = cellSize
        self.textFont = textFont
        self.colors = colors
    }

    var body: some View {
        ZStack {
            HStack(spacing: 0){
                ForEach(0..<PasscodeField.Count, id: \.self){ index in
                    VStack(spacing: 0){
                        if (index == current){
                            // cursor
                            Rectangle()
                                .foregroundColor(colors.cursor)
                                .frame(width: 2,
                                       height: textAreaSize.height - verticalPadding * 2,
                                       alignment: .center)
                                .padding(.vertical, verticalPadding * 2)
                                .opacity(prompts[index] ? 0 : 1)
                                .animation(Animation.easeOut(duration: 0.65).repeatForever(),
                                           value: prompts[index])
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(10), execute: {
                                        prompts[index] = true
                                    })
                                }
                        } else if (index < resultText.count) {
                            // input number or mask
                            let strIndex = resultText.index(resultText.startIndex, offsetBy: index)
                            Text(masks[index] ? "●" : resultText[strIndex...strIndex])
                                .font(textFont)
                                .frame(width: textAreaSize.width,
                                       height: textAreaSize.height,
                                       alignment: .center)
                                .padding(.vertical, verticalPadding)
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
                                        masks[index] = true
                                    })
                                }
                                .onReceive(Just(resultText)) { newValue in
                                    let filtered = newValue.filter { "0123456789".contains($0) }
                                    if filtered != newValue {
                                        self.resultText = filtered
                                    }
                                }
                        } else {
                            // blank space
                            Spacer()
                                .frame(width: textAreaSize.width,
                                       height: textAreaSize.height,
                                       alignment: .center)
                                .padding(.vertical, verticalPadding)
                                .onAppear {
                                    masks[index] = false
                                    prompts[index] = false
                                }
                        }

                        // under bar
                        Rectangle()
                            .foregroundColor(index == current
                                             ? colors.underbarOn
                                             : colors.underbarOff)
                            .frame(width: textAreaSize.width, height: underbarHeight)
                    }.frame(width: textAreaSize.width,
                            height: textAreaSize.height + verticalPadding * 2 + underbarHeight)
                }.padding(.horizontal, horizontalPadding)
            }
            // Setting background color make all the HStack area tappable
            .background(colors.background)
            .onTapGesture {
                if !isInFocus {
                    isInFocus = true
                }
            }

            // Hidden TextField just to open keyboard and store resulting text
            // Use UITextField to make use of first responder on iOS14.
            LegacyTextField(
                text: $resultText,
                isFirstResponder: $isInFocus
            ) { $0.keyboardType = .numberPad }
            .frame(width: 0, height: 0)
            .foregroundColor(Color.clear)
            .background(Color.clear)
            .onChange(of: resultText) { value in
                current = value.count
                if (isInFocus && value.count >= PasscodeField.Count && keyboardCloseOnFillout){
                    isInFocus = false
                }
            }
        }
    }
}
