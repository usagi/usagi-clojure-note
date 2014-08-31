# 環境構築-leinの導入からClojureCLRの動作確認まで

## leiningen

Clojureのパッケージマネージャーも兼ねた統合開発コマンドラインツールみたいな何からしい。

- http://leiningen.org/

### install

- debian: https://packages.debian.org/search?keywords=leiningen&searchon=names&suite=all&section=all
    - wheezy 以降にはパッケージが存在。しかし、2013年で保守されなくなり旧すぎる。
- ubuntu: https://launchpad.net/leiningen
    - そのまま旧い。
- gentoo
    - clojure本体パッケージはあるけどleinは無い。

そういうわけで、仕方がないのでleinは手パッケージ管理する事に。
`~/opt/bin`は私の環境では実行パスを通してあるユーザーレベルのbin置き場。

そういうのをまだ用意していないなら`.zshrc`とか`.bashrc`に`export PATH=~/bin:$PATH`と書いて`mkdir ~/bin/`して用意すれば良い。用意直後のシェルでは`source .zshrc`などして`PATH`を有効化するのを忘れないように。

```zsh
cd ~/opt/bin
wget https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein
chmod +x lein
lein
```

最後の`lein`の初回実行で必要な`lein`自体に必要なインストールパッケージがダウンロードされ、`lein`を使用可能な状態になる。

執筆現在の最新版 Leiningen 2.4.3 が導入された。

```zsh
lein -v
```

> Leiningen 2.4.3 on Java 1.7.0_65 OpenJDK 64-Bit Server VM

さて、ここで不幸な事に、 lein-2.4.3 にはREPLというインタラクティブシェル機能の`println`周りでなにやら面倒なバグが発生しているらしい。

実際、`lein repl`としてJVMの例外を眺めたのち（この時点で既におかしい）、
`user=>`プロンプトに`(+ 1 2 3)`などはうまく結果を表示できるが、
`(println "hello")`などするとJVMが例外を吐いて仕事してくれない。

- http://stackoverflow.com/questions/25577671/leiningen-repl-issue
- https://github.com/technomancy/leiningen/issues/1625

誰かがこのノートを参考に試す際に、不幸にも 2.4.3 が最新かどうかは、
`wget`で初めに回収した`lein`を読むと冒頭に書いてあるし、
Leiningenのgithubリポジトリーのタグを覗いても分かる。

- https://github.com/technomancy/leiningen/releases

もし、 lein-2.4.3 を回避してlein-2.4.2を使いたい場合は、
`lein`の冒頭のバージョン定義を`2.4.3`から`2.4.2`と書き換えて
`lein`を実行するだけで良い。

問題が生じなければ`lein repl`でエラーなど表示されずに
`user=>`プロンプトが動作する。

なお、蛇足として lein-2.4.3 でも`lein repl`ではなく、
`clojure`コマンドを直接叩けば`println`も含め問題無く利用はできる。

> nREPL server started on port 53298 on host 127.0.0.1 - nrepl://127.0.0.1:53298
> REPL-y 0.3.1
> Clojure 1.6.0
>     Docs: (doc function-name-here)
>           (find-doc "part-of-name-here")
>   Source: (source function-name-here)
>  Javadoc: (javadoc java-object-or-class-here)
>     Exit: Control+D or (exit) or (quit)
>  Results: Stored in vars *1, *2, *3, an exception in *e
> 
> user=> 

`(+ 1 2 3)`、`(* 2 3 4)`、`(println "Clojure on JVM")` など試して
簡単な動作確認とできる。

`lein repl`の場合には`quit`、`exit`、`CTRL+D`で終了、
`clojure`コマンドの場合には`CTRL+C`で終了できる。

なお、`lein`関連のファイル群は`~/.lein`に入っていて、
これを削除すれば`lein`によって導入されたパッケージなどは全て消える。

### LeiningenCLR による .net/mono 対応

#### ClojureCLR の導入

- https://github.com/clojure/clojure-clr

ClojureCLRを導入しないとClojureはJVMでしか動かない。
悲しい。

- http://sourceforge.net/projects/clojureclr/files/

ここにビルド済みのバイナリーがあるので回収して実行可能にする。
Clojure本家よりClojureの言語バージョンが旧いのが残念。

執筆現在の最新版はClojure-1.5系の.net 4.0向けのReleaseバイナリーなので、
これを入手して後に`lein clr`コマンドから使えるように`CLJCLR15_40`環境変数をセットする。

```
mkdir ~/opt/ClojureCLR
cd ~/opt/ClojureCLR
wget http://downloads.sourceforge.net/project/clojureclr/clojure-clr-1.5.0-Release-4.0.zip
unzip clojure-clr-1.5.0-Release-4.0.zip
echo 'export CLJCLR15_40=~/opt/ClojureCLR/Release' >> ~/.zshrc
```

最後の`echo`は`CLJCLR15_40`という環境変数を`.zshrc`にセットする意味なので、
適宜に環境に併せて読み替えて欲しい。

また、このあと`lein clr`での設定をするが、`CLJCLR15_40`は、
Clojure-1.4系の.net 4.0向けのClojureCLRを使う場合には`CLJCLR14_40`など、
数値部分は適宜に置き換えると良い。（ただの変数なのだけど）

### LeiningenCLR による ClojureCLR の使用

```zsh
cd /tmp
lein new lein-clr hoge
```

`lein`には便利なプラグインシステムが備わっていて、
本体機能以外にも多くの拡張機能を使える。
初回使用時に必要なパッケージは自動的に導入される。

`lein new lein-clr hoge`により、新たに`hoge`というディレクトリーと
プロジェクトファイルが生成されている。

```zsh
cd hoge
cat project.clj
```

さて、執筆現在の LeiningenCLR-0.2.1 では ClojureCLR-1.4.1 を想定していて、
こちらもやや旧い設定が自動生成される状態になっている。

ClojureCLR-1.5.0用に設定を書き換えておく。
`diff -c project.backup project`の結果を貼っておく。

```diff
*** project.clj.backup  2014-08-31 21:04:44.633109226 +0900
--- project.clj 2014-08-31 21:12:07.121094952 +0900
***************
*** 7,16 ****
    :warn-on-reflection true
    :min-lein-version "2.0.0"
    :plugins [[lein-clr "0.2.1"]]
!   :clr {:cmd-templates  {:clj-exe   [[?PATH "mono"] [CLJCLR14_40 %1]]
                           :clj-dep   [[?PATH "mono"] ["target/clr/clj/Debug 4.0" %1]]
!                          :clj-url   "http://sourceforge.net/projects/clojureclr/files/clojure-clr-1.4.1-Debug-4.0.zip/download"
!                          :clj-zip   "clojure-clr-1.4.1-Debug-4.0.zip"
                           :curl      ["curl" "--insecure" "-f" "-L" "-o" %1 %2]
                           :nuget-ver [[?PATH "mono"] [*PATH "nuget.exe"] "install" %1 "-Version" %2]
                           :nuget-any [[?PATH "mono"] [*PATH "nuget.exe"] "install" %1]
--- 7,16 ----
    :warn-on-reflection true
    :min-lein-version "2.0.0"
    :plugins [[lein-clr "0.2.1"]]
!   :clr {:cmd-templates  {:clj-exe   [[?PATH "mono"] [CLJCLR15_40 %1]]
                           :clj-dep   [[?PATH "mono"] ["target/clr/clj/Debug 4.0" %1]]
!                          :clj-url   "http://sourceforge.net/projects/clojureclr/files/clojure-clr-1.5.0-Debug-4.0.zip/download"
!                          :clj-zip   "clojure-clr-1.5.0-Debug-4.0.zip"
                           :curl      ["curl" "--insecure" "-f" "-L" "-o" %1 %2]
                           :nuget-ver [[?PATH "mono"] [*PATH "nuget.exe"] "install" %1 "-Version" %2]
                           :nuget-any [[?PATH "mono"] [*PATH "nuget.exe"] "install" %1]
```

このプロジェクトのディレクトリーの中に居る状態で、

```zsh
lein clr repl
```

とすると、.net 4.0 の Clojure REPL 処理系が動作する。

> true
> user=> 

`(+ 1 2 3 )`、`(println "Clojure on .net/mono-4.0")`などして動作確認すると良い。

また、 .net の備える標準機能群は既に利用可能な状態になっている。

- https://sites.google.com/site/clojurejapanesedocumentation/home/reference/java-interop

JVMの場合のドキュメントを参考に類推。その通りで通用した。

```clojure
(System.Console/WriteLine "Hello System.Console.WriteLine from Clojure!)
```

`名前空間/メソッド名 実引数1 実引数2 ..`と言った具合で呼び出せる。
さようならJVM、あなたに用事なんて無かったの(╹◡╹)

なお、`lein clr repl`の終了は`CTRL+D`で行う。

### 他のプラグインの存在

- https://github.com/technomancy/leiningen/wiki/Plugins

ここに一覧が載っているのでにゃんにゃんする。

