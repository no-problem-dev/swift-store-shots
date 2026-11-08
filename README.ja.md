[English](./README.md) | 日本語

# StoreShots

本物のアプリの App Store のスクショを、1本の UI テストで全部の言語ぶん撮る。同じ補助をアプリごとに写さずに済む。

![Swift 6.2+](https://img.shields.io/badge/Swift-6.2+-orange.svg)
![iOS 17+](https://img.shields.io/badge/iOS-17+-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## 概要

- **切り出した画面でなく、アプリ全体を撮る。** デモデータでアプリを起動して撮るので、タブバー・状態バー・地図が利用者の見るとおりに写る
- **撮影のスクリプトとの約束は1つ。** ロケール・端末の言語・地域・端末の名前・書き出し先が `STORE_SHOTS_*` で届く。足りなければ止まり、全部の画像を違う言語で撮ることがない
- **`xcodebuild` が止まっても画像が残る。** 添付に加えて Mac のフォルダへ直接書くので、結果バンドルが書き終わらなくても集められる
- **待ちは失敗の理由を言う。** 何が出なかったかを名前で出すので、違う画面を撮って進むことがない
- **iPad の癖を吸収する。** 長押しに iPad のシミュレータの遅れを足し、タブが上に移ったときは名前で探す
- **XCTest だけに依存する。** UI テストに他の依存が入らない

## 使い方

```swift
import StoreShots
import XCTest

final class StoreShots: XCTestCase {
    @MainActor
    func test_storeShots() throws {
        let environment = try StoreShotEnvironment.current()
        let shooter = StoreShooter(self, environment: environment)
        let app = shooter.launch(arguments: ["-demo-data", environment.locale])

        app.buttons["home.add"].waitToAppear("the add button on Home")
        shooter.shoot("home")
    }
}
```

撮影のスクリプトから回す。スクリプトは端末ごとにシミュレータを用意し、ロケールごとに端末の言語を切り替え、
`STORE_SHOTS_*` を `TEST_RUNNER_STORE_SHOTS_*` として `xcodebuild` に渡し、集めた画像の大きさと枚数を確かめる。

## ドキュメント

API リファレンスは `Sources/*/*.docc/` の DocC（Xcode の Product › Build Documentation）。

## インストール

```swift
dependencies: [
    .package(url: "https://github.com/no-problem-dev/swift-store-shots.git", from: "1.0.0")
]
```

スクショを撮る UI テストのターゲットに `StoreShots` を足す。

## ライセンス

MIT。[LICENSE](./LICENSE) を参照。
