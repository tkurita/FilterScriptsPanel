To Do
* warninng を無くす。
* 公開
* manual の執筆

== 2014-08-29
* tooltips の充実 -- 済み
* ツールバーにヘルプボタン -- 済み
* Scripts/Templates フォルダの初期生成の確認 -- ok
* window の再表示 -- 済み
* mi が終了したら、自動的に終了することの確認 -- OK

== 2014-08-28
* ローカライズ -- 済み
* いらないファイルを削除する。 -- 済み
* +x と ' の場合にエラーが出る不具合の対応。 -- 済み
* 外部からの event への応答 -- 済み
* svn commit -- 済み
* AppleScriptKit.framework の削除 -- 済み
* ログインシェルでの実行 -- 済み
* 新規結果ウインドウのタイトル -- 済み
* SmartActivate によるプロセスきりかえ -- 済み
* window 位置の保存
  - Autosave を設定したのがいけなかったようだ。
* NSTreeController に insert するのではなく、model に insert しないと、model の parentNode が設定されない。 --済み
* toolbar ボタンの first responder target が機能しない。
  - FileTreeDataController を window の next responder にした。

== 2014-08-27
* 新規スクリプトの再実装 -- 済み
* conflict error action の処理はどうなる？
  - First Responder に接続した。
* ツールバーの実装 -- 済み
* doubleAction 時に発生した NSError をシートに表示する。--済み
* 結果を新規ウインドウで表示できるようにする。 -- 済み
* スクリプトの選択を User defaults に保存するようにする。--済み
  - binding だとなぜかうまくいかない。
* シェルスクリプトを実行できるようにする。 -- 済み

== 2013-12-22
* mi3 に対応。
自分自身の場所から mi3 or mi2 か判断する。
- 起動している mi からバージョンを取得すると、mi が起動していないとき、どうするのか？
- Finder から mi のアプリケーションファイルのを取得しても、現在起動している mi である保証は有るのか？
- FilterScriptsPanel が置かれている場所から mi の場所を類推するのが一番。

* マニュアルのアップデート

== 2006.07.31
最新の PaletteWindowController に更新し、WindowVisibilityController を採用。

== 2006.07.26
実行タスクがエラーで終了？して、 pipe にデータを書き込めなくなると crash することがある。
* Xcode から起動すると、発生しない。
* 普通に起動しても、送り込むでデータ量が少なければ、発生しない。
* 普通に起動して、送り込むデータ量が多いときだけ発生する。
* 対処法がわからん
* signal SIGPIPE を受け取って終了していたようだ。signal SIGPIPE は無視するようにする。

== 2006.02.09
設定ダイアログが開かない。
実行タスクがエラーで終了？して、 pipe にデータを書き込めなくなると crash するようだ。

== 2005.10.09
	standardError も読み込んで行かないと途中で止まってしまうようだ。
	
== 2005.10.07
	なぜか、ScriptWindow.nib でのコネクションが切れまくっていた。
	version 2.0.2 は問題があり。
	Tiger での互換性を改善。
	
== 2005.09.08
* 非同期にstandardInput に書き込むには thread を使うしかない？
	
== 2005.08.12
* 環境変数は元々の値に対して置き換えちゃってよいのか。
  - 元々もとの値等ないようだ。
* progress Indicator を実装
* スクリプトファイルのファイルタイプの取得を実装
* Toolbar button の機能の実装
* Zoom button の動作の実装の仕方をちゃんとする。
* interface を作り込む
* 環境変数設定パネルを製作終了
	
== 2005.08.07
* AlertManager の問題点（sheetwindow の取得方法が不完全）を解消した sheetManager を開発
	
== 2005.08.06
	ダイアログシートの取り扱いに悩む。
	Cocoa を覚えたからといって、問題の解決にはいたらない。
	今のやり方でもいいか・・・・
	もしくは、AlertManager をつかうか。

== 2005.08.04
* ScriputRunner を製作中