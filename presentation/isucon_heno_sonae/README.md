# ISUCONとリアルISUCONへの備え

@kazuph

## 自己紹介
### 自己紹介

主に使ってるアイコン

![left](https://dl.dropboxusercontent.com/u/6615196/praykazuph.png)
![right](https://dl.dropboxusercontent.com/u/6615196/realkazuph.jpeg)

### 自己紹介

- @kazuph
- 新潟出身
    - 研究: 脳科学/進化論的最適化
- YAPC/Tokyo App Aword(Unity Game)/NASA Hackathon/WebRTC Hackathon
- 最近勉強してるやつ
    - Rails/Golang/iBeacon/IoT/Docker/Elasticserch/kibana/ fluentd/Norikra/capistrano
- 新規事業部に所属していて事業判断・営業・テレアポ・外注管理からAWS化まで幅広く担当していました。

### 自己紹介: 作成してるIoTプロダクト

![akerun](http://i.gyazo.com/b0b9e9c5ec836b223de7d0fd9b92a0af.png)

### 今日は

- Webサービスにおける測定と改善の話
- ISUCONと某ブログサービス=リアルISUCONを戦う上で身につけた知識もあるよ

## 前提

### ISUCONとリアルISUCON

- ISUCON
    - お題となるWebサービスを決められたレギュレーションの中で限界まで高速化を図るチューニングバトル

![isucon](http://i.gyazo.com/1dfaf515f4460d2a73aa03d8634fb701.png)

### ISUCONとリアルISUCON

- リアルISUCON
    - (当時)6, 7年前から稼働していたB2B向けブログサービス
    - 季節性のあるブログが多く、ピーク時はLA200くらいになって表示不可になることが多かった
    - 僕がLA200とかはどうにかして、その後120秒とかかかる部分を先輩社員と一緒に改善したりしました

## それら過去のISUCONを振り返る

### ISUCON振り返り
- 出場した時のお題
    - チケット販売サイトの高速化
    - 【予選】gist風アプリの高速化
- 参考
    - [#isucon 2013に参加してきた＞＜](http://kazuph.hateblo.jp/entry/2013/10/07/001944)
    - [チームルンバとして #isucon2 に参加してきた！](http://kazuph.hateblo.jp/entry/2012/11/04/023002)

### ISUCON振り返り

- ボトルネックの測定すること自体が意外に困難
    - 測定自体に一定の実力が必要
    - 測定後に正しく判断するのも実力が必要
    - 測定を自動化するのにもｒｙ
    - 時間は8時間、思ってるよりも全然ない
- 理想
    - ボトルネック測定→それを解決する最低限の修正
    - ひらすらそのサイクルの高速化

### リアルISUCON振り返り

- 社内オンプレサーバーという制約
    - AWSなど使ってなかったので、サーバーの調達すぐには困難だった
- 作業
    - 基本的には上司につき調査やチューニングなどの実作業は１人で行った
- 自分の実力不足
    - 急いで書籍を購入し2, 3日くらいで全部読んだ

### 読んだ書籍
- [[Web開発者のための]大規模サービス技術入門](http://www.amazon.co.jp/Web%E9%96%8B%E7%99%BA%E8%80%85%E3%81%AE%E3%81%9F%E3%82%81%E3%81%AE-%E5%A4%A7%E8%A6%8F%E6%A8%A1%E3%82%B5%E3%83%BC%E3%83%93%E3%82%B9%E6%8A%80%E8%A1%93%E5%85%A5%E9%96%80-%E2%80%95%E3%83%87%E3%83%BC%E3%82%BF%E6%A7%8B%E9%80%A0%E3%80%81%E3%83%A1%E3%83%A2%E3%83%AA%E3%80%81OS%E3%80%81DB%E3%80%81%E3%82%B5%E3%83%BC%E3%83%90-PRESS-plus%E3%82%B7%E3%83%AA%E3%83%BC%E3%82%BA/dp/4774143073)
- [[24時間365日] サーバ/インフラを支える技術](http://www.amazon.co.jp/24%E6%99%82%E9%96%93365%E6%97%A5-%E3%82%A4%E3%83%B3%E3%83%95%E3%83%A9%E3%82%92%E6%94%AF%E3%81%88%E3%82%8B%E6%8A%80%E8%A1%93-%E2%80%BE%E3%82%B9%E3%82%B1%E3%83%BC%E3%83%A9%E3%83%93%E3%83%AA%E3%83%86%E3%82%A3%E3%80%81%E3%83%8F%E3%82%A4%E3%83%91%E3%83%95%E3%82%A9%E3%83%BC%E3%83%9E%E3%83%B3%E3%82%B9%E3%80%81%E7%9C%81%E5%8A%9B%E9%81%8B%E7%94%A8-PRESS-plus%E3%82%B7%E3%83%AA%E3%83%BC%E3%82%BA/dp/4774135666/ref=sr_1_2?s=books&ie=UTF8&qid=1407219254&sr=1-2&keywords=%E3%82%B5%E3%83%BC%E3%83%90%E3%83%BC%E3%80%80%E3%82%A4%E3%83%B3%E3%83%95%E3%83%A9%E3%80%80)
- [Mobageを支える技術 ~ソーシャルゲームの舞台裏~](http://www.amazon.co.jp/Mobage%E3%82%92%E6%94%AF%E3%81%88%E3%82%8B%E6%8A%80%E8%A1%93-~%E3%82%BD%E3%83%BC%E3%82%B7%E3%83%A3%E3%83%AB%E3%82%B2%E3%83%BC%E3%83%A0%E3%81%AE%E8%88%9E%E5%8F%B0%E8%A3%8F~-WEB-PRESS-plus/dp/4774151114/ref=sr_1_1?s=books&ie=UTF8&qid=1407219349&sr=1-1&keywords=web+db+dena)

![sicon](http://i.gyazo.com/519da7060ad8938cba157d46bb7f6496.png)
![sicon](http://i.gyazo.com/97180536f65a491cd0c2f68ec0014e94.png)
![sicon](http://i.gyazo.com/ec0aca6583c3cca6b66432308adc93af.png)

## 実際の作業
## ここからはごちゃまぜです

### 0. ログだし

- nginx
    - LTSVとかお好みで
    - 基本的にはURLに対するレスポンス時間、回数
    - ISUCONではstatus codeも確認した
    - 自前で集計用ワンライナーなどを書く
        - もちろんワンライナーじゃなくてもいいｗ

### 0. ログだし

- nginx
    - [レポート用ソース](https://gist.github.com/kazuph/25d83b19af2e4b5b1dcd)

``` sh
# LTSVなログ前提
LOG_BASE=/home/isucon/tmp

# stat url
URL_STAT=`cat $LOG_BASE/access.log | perl -F"\t" -anle '{($key = $F[3]) =~ s/(req:|HTTP\/1\.1)//g;$key =~ s/[0-9]//g;$key =~ s/ //g;$key =~ s/\//\//g;$c{$key}++;$t{$key}+=substr($F[8],6,5)}END{for(keys %t){print int($t{$_})." ".int($t{$_}/$c{$_}*1000)." ".$c{$_}. " $_";}}' | sort -nr | tee tmp/nginx-repo.txt.${DATE}`
echo "sum sec  ave msec  count  URL"
echo "$URL_STAT" | while read timesum timeave count url; do
    echo "$timesum  $timeave  $count  $url"
done
```

### 0. ログだし

- nginx
    - 結果

```
sum[sec] ave[msec] count URL
1128    1939    582     GET/
69      43      1598    GET/memo/
63      50      1247    GET/recent/
34      147     234     GET/mypage
2       9       234     POST/memo
1       0       1528    GET/js/jquery.min.js
1       0       1528    GET/css/bootstrap.min.css
0       3       234     POST/signin
0       2       234     POST/signout
```

### 0. ログだし
- app(sinatraやKossy)
    - アプリがactionごとの時間を出してくれると嬉しいが
        - CatalystはdebugモードだとActionごとの実行時間を出してくれて便利
    - そうじゃない場合はTime.nowなどを仕込んで解決する
    - Perlは時間測定、query周りでいいのがそろってる印象

### 0. ログだし
- mysql
    - スローログ
        - 例えば以下をmy.cnfに書いて再起動
```my.cnf
[mysqld]
slow_query_log=ON
slow_query_log_file=/tmp/mysql-slow.log
long_query_time=0 #出力する秒数, 0秒なのですべて
```

### 0. ログだし
- mysql
    - スローログ
        - pt-query-digestを使うと便利
        - EXPLAINもしてくれる

```
pt-query-digest tmp/mysql-slow.log --explain h=localhost, u=isucon --database=isucon | tee tmp/ptqd.log
```

[実行結果](https://gist.githubusercontent.com/kazuph/32aca1d3618495cce750/raw/b7a8af012d46873f16682ccbf8bbd0533442f370/ptqd.txt)

### 0. ログだし
- ログを出すことでのパフォーマンス劣化は初期の時点では完全に誤差。おしみなく出した方がいい。
- もちろん本番では注意！

### 1. 底上げ

- 自分の得意な言語への変更
    - 過去2回はPerl、今はRubyで検討中
    - 近年はRubyの方がPerlよりも初期値が速い
        - 最終値からすると誤差だけど
- MySQLのパラメータ見直し
    - [mysqltuner.pl](http://mysqltuner.pl)
    - [mymemcheck.rb](https://gist.github.com/kazuph/c460681d4fa37b944a3e)
    - 前回のISUCONは少し性能が上がった

### 2. ボトルネック探し

- コマンドレベル
    - w ← (僕は重いサーバーに入ったらまず打ちます)
    - htop/top
    - dstat -v (vmstat)
        - 主にリソース系
        - 時間ごとのプロセスのTOP占有率もみたいなぁ
            - IOならiotopが便利
- ログレベル(繰り返し)

### 3. 可視化・自動化
- この辺はできたらいいなぁって話
- ベンチマーク中に影響を与えないようにする
    - dstat を10秒に１回とかにするとか
- ログはfluentdでバッチ転送
    - 転送後は何世代か残して消す（容量がすぐなくなる）
    - クライアントはGoogleSpreadsheetがいいかなと思ってる笑
- capでベンチマークから自動実行
    - [capistrano 3 をできるだけシンプル〜](http://qiita.com/kazuph/items/deeaa7d3f9889674d7fe)

### 3. 可視化・自動化
- NewRelicもいいよ！
- できれば導入したいやつ
    - [Fluent Dashboard＋Norikra](http://qiita.com/kazunori279/items/6329df57635799405547)
![center](http://i.giflike.com/sLgJtW9.gif)

### 4. 禁断のパワーに挑戦したい

- handlersocket！！！
    - INSERT部分がボトルネックになったときに導入したい！
- nginx_lua！！！
    - appに行ったら負けかな！？
    - 直接mysql・redisなどのデータを返却する
- golang！！！
    - そもそもが速い！！！
- etc...

## 名言によるまとめ

## 推測するな、測定せよ

## ご清聴ありがとうございました
