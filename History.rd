To Do

= 2006.07.31
最新の PaletteWindowController に更新し、WindowVisibilityController を採用。

= 2006.07.26
実行タスクがエラーで終了？して、 pipe にデータを書き込めなくなると crash することがある。
* Xcode から起動すると、発生しない。
* 普通に起動しても、送り込むでデータ量が少なければ、発生しない。
* 普通に起動して、送り込むデータ量が多いときだけ発生する。
* 対処法がわからん
* signal SIGPIPE を受け取って終了していたようだ。signal SIGPIPE は無視するようにする。

= 2006.02.09
設定ダイアログが開かない。
実行タスクがエラーで終了？して、 pipe にデータを書き込めなくなると crash するようだ。

= 2005.10.09
	standardError も読み込んで行かないと途中で止まってしまうようだ。
	
= 2005.10.07
	なぜか、ScriptWindow.nib でのコネクションが切れまくっていた。
	version 2.0.2 は問題があり。
	Tiger での互換性を改善。
	
2005.09.08
	非同期にstandardInput に書き込むには thread を使うしかない？
	
2005.08.12
	環境変数は元々の値に対して置き換えちゃってよいのか。
		元々もとの値等ないようだ。
	progress Indicator を実装
	スクリプトファイルのファイルタイプの取得を実装
	Toolbar button の機能の実装
	Zoom button の動作の実装の仕方をちゃんとする。
	interface を作り込む
	環境変数設定パネルを製作終了
	
2005.08.07
	AlertManager の問題点（sheetwindow の取得方法が不完全）を解消した sheetManager を開発
	
2005.08.06
	ダイアログシートの取り扱いに悩む。
	Cocoa を覚えたからといって、問題の解決にはいたらない。
	今のやり方でもいいか・・・・
	もしくは、AlertManager をつかうか。

2005.08.04
	ScriputRunner を製作中