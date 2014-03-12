# 最近俺の中でWebRTCが熱いと話題に！wwwwwwwwwww

2014 3/12

株式会社GaiaX Kazuhiro Homma (@kazuph)

#section

## Whoami

<img style="width:200px;height:200px" src="./images/kazuph.png"/>

- @kazuph / 本間 和弘(Kazuhiro Homma)
- Web & SmartPhone Engineer / 株式会社ガイアックス
- [社内でCPAN Authorになろうハッカソンを開催しました！！](http://kazuph.hateblo.jp/entry/2013/06/16/235744)
- [Vimのsnippetについてあまり知らなかったので設定してみたら便利過ぎてつらい](http://kazuph.hateblo.jp/entry/2012/11/28/105633)
- 最近rebuildfmにはまってるのでもし懇親会で話せたら

## Whoami
スキル

- iPhone/Android/API同時開発
- 社内リアルISUCON(コンテンツキャッシュ・クエリ改善・アーキテクチャの変更…)
- 他にも改善系を勝手にやってました
    - 構築をansible化
    - グラフをGrowthForecast/HRForecast/Yohoushiで作成
    - PhantomJSでレンダリング含めたサイトのレスポンス測定

## Whoami
そういえば一昨年の素数戦争の企画と運用をやってました

![primewars](./images/primewars.jpg)

ガイアックス × CodeIQ

[Yapc::Asia2012::素数戦争(PrimeWars)](http://yapc.pjeuler.com/dir/yapc2012)

今日は素数の話をしてくれる人がいて楽しみ！(・∀・)

## Whoami
[去年はVimの発表をしました〜](http://yapcasia.org/2013/talk/show/cc936cac-e238-11e2-8767-0fa16aeab6a4)

<img style="height:55%" src="https://scontent-b.xx.fbcdn.net/hphotos-ash4/t1/1234396_666350153384821_1293058392_n.jpg"/>

### よろしくお願いします！

/#section

## 今日話す内容

-> 最初はAnsibleの話を考えていた

-> 自分の中の賞味期限が切れたので

##### 今日はWebRTCの話をします！
## Agenda
- WebRTCとは？
- 使ってみる！
- WebRTCの可能性

#### WebRTCとは？

### ビデオチャットって何をつかってますか？

- 自分の達の開発スタイル
    - 福岡エンジニア１人と東京にエンジニア１人、営業１人という組合せで開発
    - 会わずにTODOだけ共有して作業と精神的にもつらい
    - SkypeかLINEで常に繋ぎっぱなしにしてコミュニケーション
        - 話さないときもつないでる

##### 最近まではもっぱらSkypeかLINE

![skype](https://fbcdn-sphotos-h-a.akamaihd.net/hphotos-ak-prn1/t31/p843x403/1492137_716579588361877_1540450441_o.jpg)

### イケてないところ

- Skype
    - 動画や音声が乱れる
    - 複数人の画面共有が有料
- LINE
    - Skypeよりも動画は綺麗だが重い時がある
    - 画面共有ができない＞＜

##### なかなかイケてる<br />ビデオチャットツールって<br />ないなぁ(´・ω・｀)
##### そこで登場したのが
##### 突然のWebRTC

![vmux](https://scontent-b.xx.fbcdn.net/hphotos-ash3/t1/578981_579894275430228_1006323660_n.jpg)

※この画像は [vmux](https://vmux.co/) 使用時のもの

### WebRTCのイケてるところ

- ブラウザだけで完結している
- 動画と音声が綺麗
- 画面共有ができるサービスもある（[apprear.in](https://appear.in/)）
- コーディングの内容も共有できるサービスもある（[codassium.com](http://codassium.com/)）
- オープンソースのサービスがある（[vmux](https://vmux.co/)）

### いつから盛り上がったのか？
- WebRTC自体が立ち上がり始めたのが2011年ごろ
- ChromeとFirefox同士でWebRTCでビデオチャットができるようになったのが2013/2/5
- オプションなしでChromeの安定版で使えるようになったのが2013/5/21日のv27から
- [IDEA\*IDEA](http://www.ideaxidea.com/archives/2014/03/video_chat.html)でまとめられたのが2014/3/4日
    - それ前後でネットで実用レベルのビデオチャットが流行り始めた

### WebRTCを使うための最低限の知識

- 基本はブラウザ間でのP2P
    - カメラの映像を送るために処理能力の高いサーバーを設置する必要はない
    - ただしそれはP2Pを確立したあとの話
- 接続を確立するために以下の2台のサーバーが必要
    - ICEサーバー
        - NAT越えをするために必要
        - 大手が用意してくれているものがある
            - google: stun.l.google.com:19302
            - Mozilla: stun.services.mozilla.com
            - SkyWay: stun.skyway.io:3478
    - Signalingサーバー
        - 自前で用意(WebSocketが使われることが多い模様)

### 試してみる

- 時間はないので詳しい説明は端折ります＞＜
- [単純にVideoChatするだけのサンプル](https://github.com/kazuph/RTCPeerConnectionSample)
    - [全体で300行くらいのJSファイルで実現](https://github.com/kazuph/RTCPeerConnectionSample/blob/master/js/application.js)
    - [OSSのpeerjsならさらに短く50行くらい](https://github.com/peers/peerjs/blob/master/examples/videochat/index.html)

### WebRTCの可能性

- JSでできることによって敷居がだいぶ下がった
- 気軽にビデオチャットチャットのできるサービスが今後増えそう
- ＋αで様々な可能性(顔認識やJSによる柔軟なUI)
- Androidでも利用可能

### Enjoy WebRTC!

### 参考URL
- [WebRTCを仕組みから実装までやってみる](http://blog.wnotes.net/blog/article/webrtc-beginning)
- [WebRTCのオープンソースソフトウェアまとめ](http://qiita.com/atskimura/items/97b2cc04e19781f4a4e6)
- [WebRTCで変わるWebの未来](http://www.qcontokyo.com/data_2013/ToruYoshikawa_QConTokyo2013.pdf)
- [サンプル](https://github.com/ysugimoto/RTCPeerConnectionSample)
- [peerjs(OSS)](https://github.com/peers/peerjs)

