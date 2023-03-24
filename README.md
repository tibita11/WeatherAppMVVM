# WeatherAppMVVM
Alamofireを使用して、OpenWeatherAPIから情報を取得するサンプルアプリ。

構成はMVVMで、RxSwiftを使用しています。
## 1. サンプル概要
現在地または千代田区のデータがデフォルトで表示されるようになっています。

キーワードや現在地から地名を探して、保存しておくことが可能です。
### 1-1. OpenWeatherAPIを使用する際の注意点
OpenWeatherAPIへの登録が必須になります。

登録後に下記コマンドを実行して、APIを自分の環境に設定してください。
```
$ make apikey APIKEY={OpenWeather apikey}
```
### 1-2. 画面キャプチャ
![WeatherAppMVVM 001](https://user-images.githubusercontent.com/108079580/227418516-b6aa6593-62ad-49c6-807f-9fe1861ca617.jpeg)
## 2. 実装ポイント(UI面)
### 2-1. 地名を表示したタブ
登録されている地名の数に応じて、タブ数が変動するように実装しました。

スライドでの動きや、タップによる動きに応じてラベルを動かし、視覚的にわかりやすく工夫しました。

### 2-2. シンプルなレイアウト
現在の天気と、3時間毎の天気が分かりやすく、触りたくなるレイアウトを意識しました。

色やフォントについても落ち着いたものを使用しました。
## 3. 実装ポイント(技術面)
### 3-1. RxSwiftを使用したMVVM構成
MVVMで作成した理由は、下記になります。

・FatVCにならないように

・リアクティブにデータが反映できるように
### 3-2. RxDataSourcesを使用してTableViewとCollectionViewを実装
TableView、CollectionViewの操作をより分かりやすく書くために、RxDataSourcesを使用しました。
### 3-3. Alamofire, Codableを使用したAPI接続
簡単で、より実績があるAlamofireを使用しました。
### 3-4. Kingfisherを使用した画像キャッシュ
URLから取得した画像をキャッシュするため、Kingfisherを使用しました。

その他のライブラリも確認しましたが、更新頻度や実績などからKingfisherを使用しました。
### 3-5. 複雑なUIについては、カスタムViewで別々に作成
一つのStoryboardでなく、カスタムViewで分けることで修正を容易にしました。
### 3-6. PageViewControllerを使用したページング
PageViewControllerとCollectionViewを使用して、タブ画面を作成しています。
### 3-7. CoreLocationのCLLocationManagerを使用した現在地取得
許可されている、許可されていない、設定が変更されたなどのケースに合わせた処理を実装しています。

拒否されている場合などについては、設定画面に促すアラートを表示しています。
### 3-8. MapKitのMKLocalSearchCompleterを使用したサジェスト機能
キーワードが入力された場合の、サジェスト機能を実装しています。
### 3-9. Geocoderを使用した経度緯度取得
検索された場所については、経度緯度を取得した上で、APIにリクエストをしています。
### 3-10. Realmを使用したデータの永続化
データ永続化についてはRealmを使用しました。

Realmを使用した理由は、下記になります。

・ローカル環境でのみ保存したい

・リアクティブに反映できる機能が欲しい(RxRealmを用いた機能)
