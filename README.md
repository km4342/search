Spotify API で 楽曲検索
==
Spotify API を使って、アーティストからアルバムの情報を検索してみます。

![search.gif](https://qiita-image-store.s3.amazonaws.com/0/255326/c8372348-efb9-c338-52dd-6b5d7afa990e.gif)


環境
- OS macOS 10.12.6
- xcode 9.2
- swift 4.0.3
- Alamofire 4.7.1

# Alamofireのインストール

CocoaPodsのインストール

```
$ gem install cocoapods
```

プロジェクトのディレクトリに移動して

```
$ pod init
```

を実行。podfile が作成されるので、以下のように編集します。

```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'Alamofire'
end
```
最後に

```
$ pod install
```
を実行して Alamofire のインストールは完了です。xcode を一旦閉じて、`(projectname).xcworkspace` を開きます。

# Spotify API をコール


### Client ID と Client Seacret の取得
API を利用するためにはSpotifyアカウントを作成し、[My Dashboad](https://beta.developer.spotify.com/dashboard/login) からアプリケーションの登録が必要です。

"CREATE CLIENT ID" から、必要事項を記入すると、アプリケーション認証に必要な "Client ID" と "Client Seacret" が以下のように表示されるので控えておきます。

![2018-05-15 23.28.23.png](https://qiita-image-store.s3.amazonaws.com/0/255326/e5aa2def-c911-3e27-d149-1adbf8839a45.png)



### アプリケーションの認証とアクセストークンの取得
アプリケーションの認証には、全部で3つの方法が [公式ドキュメント](https://beta.developer.spotify.com/documentation/general/guides/authorization-guide/#client-credentials-flow) にて提供されています。今回は最も単純な "Client Credential Flow" を使って認証を行います。

まずは, 先ほど取得した "Client ID" と "Client Seacret" を Base64 でエンコーディングした値を取得します。

```
$ echo -n {client ID}:{Client Secret} | base64
```

出力値 `Y2I2ZmM2Mj...NzA2Mzk=` を控えておきます。

次に、Alamofire の `request` メソッドを使ってAPIへのアクセスに必要なアクセストークンの取得を行います。

```swift

import Alamofire
```
ここで、`Cannot load underlying module for 'Alamofire'` のエラーが出るがビルドすると消えるので無視します。

リクエストの送信先URLを定義。

```swift

let tokenURL = "https://accounts.spotify.com/api/token"
```

先ほど取得したエンコーディングされた "Client ID" と "Client Seacret" の値からヘッダーを定義。

```swift

let basicHeader: HTTPHeaders = ["Authorization" : "Basic Y2I2ZmM2Mj...NzA2Mzk="]
```

パラメータを定義。

```swift

let parameters: Parameters = ["grant_type" : "client_credentials"]
```

`request`メソッドによりリクエストの送信を行い、結果をJSONで受け取ります。

```swift

Alamofire.request(tokenURL, method: .post, parameters: parameters, headers: basicHeader).responseJSON(completionHandler: {
            response in

            var tokenJSON = try! JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! [String : AnyObject]
            var token = tokenJSON["access_token"] as! String

        })
```

`tokenJSON`は以下のようになっており、上記のコードでは API へのアクセスに必要な `access_token` のみを取り出しています。


```
["scope": , "token_type": Bearer, "access_token": BQB79...zPaE, "expires_in": 3600]
```


### Spotify API からアルバム情報の取得
アクセストークンを使って、API へ指定したアーティストのアルバムについての情報をリクエストします。

アクセストークンからヘッダーを定義。

```swift

let access_token: HTTPHeaders = ["Authorization" : "Bearer \(token)"]
```

検索用のリクエストを定義。

```swift

let searchURL = "https://api.spotify.com/v1/search?q=john%20mayer&type=album&limit=20"
```

?以降は`q=hoge%20hoge`で検索のキーワードを指定、`type={track, artist, album, playlist}`で検索の種類を指定（今回はアルバムを選択）、`limit=20`で表示する数の上限を指定しています。

今回は John Mayer のアルバムを最大20件取得するようにリクエストの送信を行いました。

```swift

Alamofire.request(searchURL, headers:access_token).responseJSON(completionHandler: {
        response in

        var searchJSON = try! JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! [String : AnyObject]
    })
```


`searchJSON`は以下のような構成になっています。


```
["albums": {
    href = "https://api.spotify.com/v1/search?query=john+mayer&type=album&offset=0&limit=20";
    items =     (
                {
            "album_type" = album;
            artists =             (
                                {
                    "external_urls" =                     {
                        spotify = "https://open.spotify.com/artist/0hE...xO14";
                    };
                    href = "https://api.spotify.com/v1/artists/0hE...xO14";
                    id = 0hE...xO14;
                    name = "John Mayer";
                    type = artist;
                    uri = "spotify:artist:0hE...xO14";
                }
            );
            "available_markets" =             (
                AD,
                AR,
                ...
                US,
                UY,
                ZA
            );
            "external_urls" =             {
                spotify = "https://open.spotify.com/album/4Dg...TaYBb";
            };
            href = "https://api.spotify.com/v1/albums/4Dg...aYBb";
            id = 4Dgxy95K9BWkDUvQPTaYBb;
            images =             (
                                {
                    height = 640;
                    url = "https://i.scdn.co/image/132...a2c1";
                    width = 640;
                },
                                {
                    height = 300;
                    url = "https://i.scdn.co/image/dac...55e9";
                    width = 300;
                },
                                {
                    height = 64;
                    url = "https://i.scdn.co/image/098...35a7";
                    width = 64;
                }
            );
            name = "Where the Light Is: John Mayer Live In Los Angeles";
            "release_date" = 2008;
            "release_date_precision" = year;
            type = album;
            uri = "spotify:album:4Dg...aYBb";
        }, ...
    };

        limit = 20;
        next = "https://api.spotify.com/v1/search?query=john+mayer&type=album&offset=20&limit=20";
        offset = 0;
        previous = "<null>";
        total = 209;
        }]
```

受け取ったデータからアルバムのタイトル`name`とアートワーク`image`を取り出します。

```swift
if let albums = searchJSON["albums"] as? [String : AnyObject] {
    if let items = albums["items"] {
        for i in 0..<items.count{
            let item = (items as! NSArray)[i] as! [String : AnyObject]
            // album title
            let name = item["name"] as! String
            // album artwork
            let image = (item["images"] as! NSArray)[0] as! NSDictionary
            let imageURL = URL(string: image["url"] as! String)
            let imageData = NSData(contentsOf: imageURL!)
            let mainImage = UIImage(data: imageData! as Data)
        }
    }
}
```

その他リクエストの詳細な送信方法については [こちら](https://beta.developer.spotify.com/documentation/web-api/reference/search/search/) を参考に。

# StoryBoardでアルバム情報の表示

### 画面遷移の設定

検索したアルバム一覧は、TableViewで表示します。 `Main.storyboard` を開いて、"Table View Controller" と "Navigation Controller"を配置します。

![2018-05-17 16.53.42.png](https://qiita-image-store.s3.amazonaws.com/0/255326/ab00e3bd-eb49-c967-7945-11df574c565a.png)


"Navigation Controller" から ctrl を押しながら "Table View Controller" に接続し、 "Root View Controller" を選択します。

![2018-05-17 16.57.34.png](https://qiita-image-store.s3.amazonaws.com/0/255326/a1f4bfcc-b311-4198-1632-74f4bbb077b9.png)


検索した結果を詳しく見るウィンドウを作成します。 "Table View Controller" の cell から、 "View Controller" に接続し、 "Show" を選択します。

![2018-05-17 17.02.28.png](https://qiita-image-store.s3.amazonaws.com/0/255326/697358e5-1f2e-1ec3-69c1-5f1f436e2855.png)


### Table View Controller で検索ビューを作成
アルバムアートワークを表示する "Image View", アルバムタイトルを表示する "Label", 検索用の "Text Field" をそれぞれいい感じに配置します。

![2018-05-17 17.26.43.png](https://qiita-image-store.s3.amazonaws.com/0/255326/7bf6ca87-1afd-6c6a-07a2-8fa31c6faaaa.png)


大きさを固定します。Image View と Label は "aspect ratio" を固定し、"Text Field"は以下の項目で左右幅を固定します。

![2018-05-17 17.30.49.png](https://qiita-image-store.s3.amazonaws.com/0/255326/c56da14e-eebc-a8bb-8b85-fc6fd60d2331.png)


位置を固定します。Image View と Label について空白(space to constrain)の固定と縦位置の固定(center vertical in constrain)を行いました。

さらに、"Table View Cell" の Identifier を "Cell" と設定します。

![2018-05-17 21.35.38.png](https://qiita-image-store.s3.amazonaws.com/0/255326/113e0819-3cbf-902d-d794-85398f5bc4f3.png)



最後に、 Image View と Label のタグをそれぞれ "1" と "2" に設定します。

![2018-05-17 17.57.56.png](https://qiita-image-store.s3.amazonaws.com/0/255326/23b01f12-8a0a-9079-6eaf-18460af958ad.png)

ここまで終わったら、次は `ViewController.swift`を編集していきます。 基本的には、前回の内容を関数化したものが主となっています。 追加点としては

- アルバム情報を格納する構造体`struct post`
- 検索用のアクション`@IBAction func search`
- TableView の cellを更新する関数`func tableView`

です。

```ViewController.swift

import UIKit
import Alamofire

struct post {
    let mainImage: UIImage!
    let name: String!
}

class TableViewController: UITableViewController, UITextFieldDelegate {

    var posts = [post]()

    let tokenURL = "https://accounts.spotify.com/api/token"

    let basicHeader: HTTPHeaders = ["Authorization" : "Basic Y2I2ZmM2Mj...NzA2Mzk="]

    let parameters: Parameters = ["grant_type" : "client_credentials"]

    typealias JSONStandard = [String : AnyObject]

    @IBAction func search(_ sender: UITextField) {
        if sender.text!.isEmpty {
            return
        }
        else{
        var searchKey: String = sender.text as! String
        if let key = searchKey.range(of: " "){
            searchKey.replaceSubrange(key, with: "%20")
        }

        let searchURL = "https://api.spotify.com/v1/search?q=\(searchKey)&type=album&limit=20"

        posts.removeAll()
        callAlamo(url: searchURL)

        }
    }

    func getAccessToken(Token: Data) -> HTTPHeaders{
        var tokenJSON = try! JSONSerialization.jsonObject(with: Token, options: .mutableContainers) as! JSONStandard
        let token = tokenJSON["access_token"] as! String
        let access_token: HTTPHeaders = ["Authorization" : "Bearer \(token)"]

        return access_token
    }

    func callAlamo(url: String) {
        Alamofire.request(self.tokenURL, method: .post, parameters: parameters, headers: basicHeader).responseJSON(completionHandler: {
            tokens in
            Alamofire.request(url, headers: self.getAccessToken(Token: tokens.data!)).responseJSON(completionHandler: {
                response in
                self.parseData(JSONData: response.data!)
            })
        })
    }

    func parseData(JSONData: Data){
        do{
            var searchJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! JSONStandard

            if let albums = searchJSON["albums"] as? JSONStandard {
                if let items = albums["items"] {
                    for i in 0..<items.count{
                        let item = (items as! NSArray)[i] as! JSONStandard
                        // album title
                        let name = item["name"] as! String
                        // album artwork
                        let image = (item["images"] as! NSArray)[0] as! NSDictionary
                        let imageURL = URL(string: image["url"] as! String)
                        let imageData = NSData(contentsOf: imageURL!)
                        let mainImage = UIImage(data: imageData! as Data)

                        posts.append(post.init(mainImage: mainImage, name: name))

                        self.tableView.reloadData()
                    }
                }
                }
        }catch{
            print(error)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")

        let mainImageView = cell?.viewWithTag(1) as! UIImageView
        mainImageView.image = posts[indexPath.row].mainImage

        let mainLabel = cell?.viewWithTag(2) as! UILabel
        mainLabel.text = posts[indexPath.row].name

        return cell!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
```
検索用のアクションは、"Text Field"から ctrl を押しながら引っ張ってきて、以下のように設定しました。

![2018-05-17 18.51.26.png](https://qiita-image-store.s3.amazonaws.com/0/255326/ca83dd8f-651a-68dc-999b-76d31a9ad3eb.png)


`Main.storyboard` に戻って、 "Custom Class" を "TableViewController"に設定します。これで、検索用のビューが完成しました。

### View Controller でアルバムビューを作成
検索ビューから選択したアルバムを大きく表示する画面を作成します。

"Image View" を画面いっぱいに配置し、"Content mode" を "Aspect Fill" に設定します。

![2018-05-17 23.15.22.png](https://qiita-image-store.s3.amazonaws.com/0/255326/961af463-a607-8496-8aeb-7b82ff069960.png)


"Visual Effect View with Blur" も同様に配置します。これで、背景がぼやけていい感じになります。

背景ができたら、アルバムアートワークを表示する "Image View" と アルバムタイトルを表示する "Label"を配置します。

![2018-05-17 23.25.13.png](https://qiita-image-store.s3.amazonaws.com/0/255326/90325d67-ed1e-084d-1278-f097938cf83b.png)


配置が終わったら、プロジェクト内に `AudioVC.swift` を新規作成し、以下のように編集を行います。

```AudioVC.swift

import UIKit

class AudioVC: UIViewController{
    @IBOutlet var backgroung: UIImageView!
    @IBOutlet var mainImageView: UIImageView!
    @IBOutlet var songTitle: UILabel!

    var image = UIImage()
    var mainSongTitle = String()

    override func viewDidLoad() {
        songTitle.text = mainSongTitle
        backgroung.image = image
        mainImageView.image = image
    }
}
```

編集が終わったら、Custom Class を "AudioVC" に設定し、`@IBOutlet` をそれぞれ接続します。

さらに、`ViewController.swift` に、以下の関数を追加します。

```ViewController.swift

override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let indexPath = self.tableView.indexPathForSelectedRow?.row

    let vc = segue.destination as! AudioVC

    vc.image = posts[indexPath!].mainImage
    vc.mainSongTitle = posts[indexPath!].name
}
```

上記のコードでは、検索ビューで選択したアルバムの情報を、AudioVCクラスで定義した `image` と `mainSongTitle` に反映させています。

# まとめ

以上ですべての工程が完了です。今回はアルバムのアートワークとタイトルを表示するだけですが、JSONデータの中にある情報をもっと引っ張ってみたり、プレイヤーと組み合わせてみるともっと楽しいと思います。
