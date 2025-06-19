//
//  EffectView.swift
//  MyCamera
//
//  Created by macmini on 2025/06/12.
//

import SwiftUI

struct EffectView: View {
    // エフェクト編集画面(sheet)の開閉状態を管理
    @Binding var isShowSheet: Bool
    // 撮影した写真
    let captureImage: UIImage
    // 表示する写真
    @State var showImage: UIImage?

    // フィルタ名を列挙した配列
    // 0. モノクロ
    // 1. Chrome
    // 2. Fade
    // 3. Instant
    // 4. Noir
    // 5. Process
    // 6. Tonal
    // 7. Transfer
    // 8. SepiaTone
    let filterArray = ["CIPhotoEffectMono",
                       "CIPhotoEffectChrome",
                       "CIPhotoEffectFade",
                       "CIPhotoEffectInstant",
                       "CIPhotoEffectNoir",
                       "CIPhotoEffectProcess",
                       "CIPhotoEffectTonal",
                       "CIPhotoEffectTransfer",
                       "CICepiaTone",
    ]
    @State var filterSelectNumber = 0

    var body: some View {
        // 縦方向にレイアウト
        VStack {
            Spacer()

            if let showImage {
                // 表示する写真がある場合は画面に表示
                Image(uiImage: showImage)
                // リサイズする
                    .resizable()
                // アスペクト比を維持して画面内表示
                    .scaledToFit()
            }
            Spacer()

            // 「エフェクト」ボタン
            Button {
                // ボタンをタップしたときのアクション
                // フィルタを指定
                let filterName = filterArray[filterSelectNumber]
                // 次回に適用するフィルタを決めておく
                filterSelectNumber += 1
                if filterSelectNumber == filterArray.count {
                    filterSelectNumber = 0
                }
                // 元々の画像の回転角度を取得
                let rotate = captureImage.imageOrientation
                // UIImage形式の画像をCIImage形式に変換
                let inputImage = CIImage(image: captureImage)

                // フィルタ名を指摘してCIFilterのインスタンスを取得
                guard let effectFilter = CIFilter(name: filterName) else {
                    return
                }
                // フィルタ加工のパラメータを初期化
                effectFilter.setDefaults()
                // インスタンスにフィルタ加工する元画像を設定
                effectFilter.setValue(inputImage, forKey: kCIInputImageKey)
                // フィルタ加工を行う情報を生成
                guard let outputImage = effectFilter.outputImage else {
                    return
                }

                // CIContextのインスタンスを取得
                let ciContext = CIContext(options: nil)
                // フィルタ加工後の画像をCIContext上に描画し、
                // 結果をcgImageとしてCGImage形式の画像を取得
                guard let cgImage = ciContext.createCGImage(outputImage, from: outputImage.extent) else {
                    return
                }

                // フィルタ加工後の画像をCGImage形式から
                // UIImage形式に変更。その際に回転角度を指定
                showImage = UIImage(
                    cgImage: cgImage,
                    scale: 1.0,
                    orientation: rotate
                )


            } label: {
                Text("エフェクト")
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .multilineTextAlignment(.center)
                    .background(Color.blue)
                    .foregroundStyle(Color.white)
            }
            .padding()

            // 「シェア」ボタン
            if let showImage {
                let shareImage = Image(uiImage: showImage)
                ShareLink(item: shareImage, subject: nil, message: nil,
                          preview: SharePreview("Photo", image: shareImage)) {
                    Text("シェア")
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .multilineTextAlignment(.center)
                        .background(Color.blue)
                        .foregroundStyle(Color.white)
                }
                          .padding()
            }

            // 「閉じる」ボタン
            Button {
                // エフェクト編集画面を閉じる
                isShowSheet.toggle()
            } label: {
                Text("閉じる")
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .multilineTextAlignment(.center)
                    .background(Color.blue)
                    .foregroundStyle(Color.white)
            }
            .padding()
        }
        .onAppear {
            showImage = captureImage
        }
    }
}

#Preview {
    EffectView(
        isShowSheet: .constant(true),
        captureImage: UIImage(named: "preview_use")!
    )
}
