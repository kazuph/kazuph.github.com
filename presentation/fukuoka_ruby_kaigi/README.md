# みんなでProjectEuler in Ruby
@kazuph

2012/12/01

#### 自己紹介
### ID:kazuph
### 「かずふ」って<br />読みます
### 2年目
## Vimの記事を書いたり
![hatebu](img/hatebu.png "hagebu")

## Vim読書会に行ってdisられてきたりしている
![vim4](img/vim4.png "vim4")
### Vimが大好きな<br />スマフォエンジニアです！
### 続きは懇親会で！

### 突然ですが皆さん
### ProjectEulerって<br />知ってますか？
### しーん
## ProjectEulerとは
> 挑戦的な数学/コンピュータのプログラミング問題集で、ほとんどの問題はコンピュータとプログラミングの能力が必要とされる。

[出展：ProjectEuler本家サイト](http://projecteuler.net)

### ふーん
### じゃあ
## 「お姉さん」は知ってますか！？
![oneesan](./img/oneesan.jpg)

[出展：『フカシギの数え方』 おねえさんといっしょ！ みんなで数えてみよう！ ](http://www.youtube.com/watch?v=Q4gTV4r0zRs)

### ( ･\`ω･´)/
### つまるところ
### ProjectEulerとは
## こういう問題をたくさん解くサイト
![oneesan](./img/kazoeruna.jpg)

### こんな問題が<br />400問以上
### お姉さんに見せたら<br />大変なことに！？
### これ以上お姉さんに数えさせちゃいけない！！
## こんなことになってしまう前に！
![tomenaide](./img/tomenaide.jpg)

### きれいなお姉さんは<br />救いたいですか？
# みんなでProjectEuler in Ruby
@kazuph

2012/12/01

### もとい
# Rubyでお姉さん<br />（複数人）<br />を救った話
@kazuph

2012/12/01


## はい
と言うことで、ここからはまったく「お姉さん」とは関係なく、会社のみんなでProjectEulerを解いてみた話をします。

## Start Euler
とある部長がSkypeで出題したのが発端
-> ↓
-> みんなが解答をSkypeであげまくる
-> ↓
-> みんなが解いたソースを自分のリポジトリに上げ始めた
-> ↓
-> Facebookグループで解いた宣言！→レビュー

## めんどくさくて
![fb_jenkis](./img/fb_jenkins.jpg)

### 翌週からJenkinsさん<br />雇われてた(^q^)

## こんなん
![pjeuler](./img/pjeulercom.png)

## Euler System
* githubにpushするだけの簡単操作
* コミットすると実行結果と時間を更新
* 問題ごとに実行速度順にランキングして表示
* 現在ではRubyに加えて、Perl、PHP、Javascript、Pythonなどの言語に対応

### そんな感じで楽しい<br />「ぷろおい！」生活が<br />始まる

#### Problem 1
## Problem 1
> 10未満の自然数のうち,  3 もしくは 5 の倍数になっているものは 3,  5,  6,  9 の4つがあり,  これらの合計は 23 になる.
> 同じようにして,  1000 未満の 3 か 5 の倍数になっている数字の合計を求めよ.

> 3 + 5 + 6 + 9 = 23

[出展：ProjectEuler 問題1](http://odz.sakura.ne.jp/projecteuler/index.php?cmd=read&page=Problem%201)

### 当時のSkypeでの解答

## 某春◯さんの解答
```
#!/usr/bin/env ruby
# encoding: UTF-8

total = 0
(1..1000).each do |num|
  if num % 3 == 0 || num % 5 == 0
    total += num
  end
end
p total
```

## PHPerさんの解答
```
<?php
//3の倍数
$total = 0;
for($n = 1 ; 3 * $n < 1000 ; $n++){
    $total += 3 * $n;
}

//5の倍数
for($n = 1 ; 5 * $n < 1000 ; $n++){
    //3の倍数は除く
    if( $n%3 != 0 )$total += 5 * $n;
}

echo $total;
```

## Perlerさんの解答
```
my $res = 0;
map { $res += ( $_ % 3 && $_ % 5 ) ? 0 : $_ } 1..999;
say $res;
```

## ワンライナー

* 春◯さん②

```
$ perl -e '$a; for(1..1000){unless($_%3&&$_%5){$a+=$_}};print "$a"'
```

* 僕

```
$ perl -le 'print eval(join "+",(grep{!($_%3)||!($_%5)}1..(1e3-1)))'
```

* PHPerの方②

```
$sum = 0;for($i=0;$i<1000;$i++)if($i%3===0||$i%5===0) $sum+=$i;
```

* Rubyistの人

```
((0...1000).step(3).to_a | (0...1000).step(5).to_a).inject(0){|s, i|s+=i}
```

## Perl6
* 僕

```
perl6 -e 'say [+] (1..999).grep({!($_%3)||!($_%5)})'
```

-> 出題された瞬間からPerl6を勉強したいって思って勉強して
-> その日にPerl6のビルドをして解答しました

### 人によって書き方が<br />たくさんある！
### こんな感じで社内で<br />盛り上がりました！

### 更にEuelr Systemができてからの投稿
## ここからはスピードとの戦いです

```
#!/usr/bin/env ruby
def sum (max, num1, num2)
  return (1..(max - 1)).select {|n|n % num1 == 0 || n % num2 == 0}.inject(&:+)
end
p sum(1000, 3, 5)
```

## ループを変更
ループはeachが速い

```
# p (1..999).select {|n| n % 3 == 0 || n % 5 == 0}.inject(&:+)
total = 0
(1..999).each{|n| total += n if n % 3 == 0 || n % 5 == 0}
p total
```

## CTOのズルい一投
数学的に解く

```
m = 1000; a1 = 3; a2 = 5
m = m - 1; a3 = a1 * a2; b1 = (m / a1).to_i; b2 = (m / a2).to_i; b3 = (m / a3).to_i
p (b1 * (b1 + 1) * a1 + b2 * (b2 + 1) * a2 - b3 * (b3 + 1) * a3) / 2
```

### ループしたら負け

### ならば！

## 演算コストを極める
「+」「-」「*」「/」を減らす

```
p( (999.div(3) * (3 + 999) + 999.div(5) * (5 + 995) - 999.div(15) * (15 + 990)) / 2)

```

## Win!

```
m = 1000; a1 = 3; a2 = 5
m = m - 1; a3 = a1 * a2; b1 = (m / a1).to_i; b2 = (m / a2).to_i; b3 = (m / a3).to_i
p (b1 * (b1 + 1) * a1 + b2 * (b2 + 1) * a2 - b3 * (b3 + 1) * a3) / 2

# Time: 0.12 msec
```

```
p( (999.div(3) * (3 + 999) + 999.div(5) * (5 + 995) - 999.div(15) * (15 + 990)) / 2)

# Time: 0.05 msec
```

#### Problem 7
## Problem 7
> 素数を小さい方から6つ並べると 2,  3,  5,  7,  11,  13 であり,  6番目の素数は 13 である.
> 10001 番目の素数を求めよ.

[出展：ProjectEuler 問題7](http://odz.sakura.ne.jp/projecteuler/index.php?cmd=read&page=Problem%207)
### 素数の問題
### はい、そうです
### require 'prime'がありますね
(or require 'mathn')
## require 'prime'

```
require 'prime'

i = 2
j = 1

loop do
    if i.prime?
        j += 1
    end
    if j > 10001
        break
    end
    i += 1
end
puts i
```

## require 'mathn' (こっちが推奨？)

```
require 'mathn'
i = 1
cnt = 0
while i += 1
  if Prime.instance.prime?(i)
    cnt += 1
    if cnt == 10001
      break
    end
  end
end
p i
```

### これでは味気なさすぎる
## 6k±1
```
#!/usr/bin/env ruby
# coding : utf-8
require 'prime'
max = 10001
primes = [2, 3, 5]
n=0
loop do
  break if primes.size > 10001
  n+=1
  prime = 6*n+1
  primes << prime if prime.prime?
  prime +=4
  primes << prime if prime.prime?
end
p primes[max-1]
```

### アルゴリズムを工夫してこそのEuler

### そしてさらに高みを求めるのもEuler
### require 'prime'？
### 貧弱、貧弱！

### アルゴリズムを極める

```
max = 10001
def prime?(num, ary)
  ary.each do |n|
    break if n * n  > num
    return false if num % n == 0
  end
  return true
end
n = 0
prime_ary = [2, 3, 5]
while  prime_ary.count < max
  n += 1
  prime = 6 * n + 1
  if prime?(prime, prime_ary)
    prime_ary.push(prime)
  end
  prime += 4
  if prime?(prime, prime_ary)
    prime_ary.push(prime)
  end
end
p prime_ary[-1]
```

### ベンチ結果
* prime 3575.42 msec
* mathn 3445.56 msec
* 6k±1 2767.65 msec
* 素    223.41 msec
https://github.com/takyam-git/pjeuler/tree/master/scripts/007


### 素数を制するものが
### オイラーを制す！！
### ⬆Facebookのそのままの画像でもいいかも
### いいね！が全くつかない驚き！
### 他のいいねがたくさんついてる画像
### そんなこんなでオイラーで熱いバトルを繰り広げていた時
### 僕
### 「僕は素数の戦争が見てみたい」
### 素数戦争勃発！！
### ⬆アスキーアート
### アスキーアート
### あれ？
### まぁ、いっか
### 熱いバトル
### だんさんのちんかいとう
### パイソンのちんかいとう
### 僕はひっそりと真ん中付近にいました
### 世界は広い
### 最後によかったことまとめ
### パフォーマンスを意識してプログラミングをできるようになった
### 他の言語で開発している人を巻き込んでRubyでやったので、言葉が通じるようになった
### 逆にまったく見についていないことは、
### 全くオブジェクティブな書き方が見についてない
### Rubyでワンライナーが気持ちよすぎて逆にキモい
### システム変更の余地あり
### 課題
### もっとオブジェクティブに書いた方が良いような問題でやる
### TDDで書くようにする
### TDD導入など
### みなさんも会社でオイラーやって見るといいかも知れませんね
### エンジョイオイラーライフ
### さんきゅう
### 完













### 全206カ国
### 総参加者25万人
### 全問題数403問(増殖中)
### お姉さんも403人！
## なんでこうなった？
* Clean Coderに触発される
* 仕事はパフォーマンス(本番)
* プロのプログラマーは練習をする

<img style="width:30%;float:right;" src="./img/cleancoder.jpg" alt="cleancoder">

### プロのプログラマーは練習をする
## 朝練風景(写経中)
![asaren](./img/asaren.jpg)


## 写経教材
* [TDD Perl](http://assets.en.oreilly.com/1/event/12/Practical%20Test-driven%20Development%20Presentation.pdf)

<img style="width:45%;float:left;" src="./img/tddperl.jpg" alt="cleancoder">
<img style="width:44%;float:left;margin-left:20px;" src="./img/tddperl-code.jpg" alt="cleancoder">

## そうだRubyにしよう！
![picon](./img/picon.jpg)

