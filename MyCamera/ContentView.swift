//
//  ContentView.swift
//  MyCamera
//
//  Created by macmini on 2025/06/06.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    // 撮影した写真を保持する状態変数
    @State var captureImage: UIImage? = nil
    // 撮影画面(sheet)の開閉状態を管理
    @State var isShowSheet = false
    // フォトライブラリーで選択した写真を管理
    @State var photoPickerSelectedImage: PhotosPickerItem? = nil

    var body: some View {
        VStack {
            // スペース追加
            Spacer()
            // 「カメラを起動する」ボタン
            Button {
                // ボタンをタップしたときのアクション
                // カメラが利用可能かチェック
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    print("カメラを利用できます")
                    captureImage = nil
                    // カメラが利用できるなら、isShowSheetをtrue
                    isShowSheet.toggle()
                } else {
                    print("カメラを利用できません")
                }

            } label: {
                // テキスト表示
                Text("カメラを起動する")
                // 横幅いっぱい
                    .frame(maxWidth: .infinity)
                // 高さ50ポイント
                    .frame(height: 50)
                // 文字列をセンタリング指定
                    .multilineTextAlignment(.center)
                // 背景を青色に指定
                    .background(Color.blue)
                // 文字色を白色に指定
                    .foregroundStyle(Color.white)
            }
            .padding()
            // sheetを表示
            .sheet(isPresented: $isShowSheet) {
                // 撮影した写真がある→EffectViewを表示する
                if let captureImage {
                    EffectView(isShowSheet: $isShowSheet, captureImage: captureImage)
                } else {
                    // UIImagePickerController（写真撮影）を表示
                    ImagePickerView(isShowSheet: $isShowSheet, captureImage: $captureImage)
                }
            }

            // フォトライブラリーから選択する
            PhotosPicker(selection: $photoPickerSelectedImage, matching: .images,
                         preferredItemEncoding: .automatic, photoLibrary: .shared()){
                Text("フォトライブラリーから選択する")
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .multilineTextAlignment(.center)
                    .background(Color.blue)
                    .foregroundStyle(Color.white)
                    .padding()
            }

            // 選択した写真情報をもとに写真を取り出す
             .onChange(of: photoPickerSelectedImage, initial: true, { oldValue, newValue in
                 // 選択した写真があるとき
                 if let newValue {
                     Task {
                         // Data型で写真を取り出す
                         if let data = try? await newValue.loadTransferable(type: Data.self) {
                             // 写真があるとき
                             // 写真をcaptureImageに保存
                             captureImage = UIImage(data: data)
                         }
                     }
                 }
             })
        }
        // 撮影した写真を保持する状態変数が変化したら実行する
        .onChange(of: captureImage, initial: true, { oldValue, newValue in
            if let _ = newValue {
                // 撮影した写真がある→EffectViewを表示する
                isShowSheet.toggle()
            }
        })
    }
}

#Preview {
    ContentView()
}
