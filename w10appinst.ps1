<#
    w10appinst
    Copyright (C) 2016 pseudo-hacks.com

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#>

#requires -version 3.0

$DebugPreference = "SilentlyContinue"
#$DebugPreference = "Continue"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Web

<# variables #>

$software_name = "w10appinst"
$mutexObject = New-Object System.Threading.Mutex($false, $software_name)
if (-not $mutexObject.WaitOne(0, $false)) {
    [System.Windows.Forms.MessageBox]::Show("既に起動されています", "確認 - " + $software_name, "OK", "Error")
    exit
}
function safe_exit {
    try {
        $script:mutexObject.ReleaseMutex()
        $script:mutexObject.Close()
    } catch { }
    exit
}

$list = @(
	,@{ tab_name = 'インターネット'
       ;tab_id = 'Internet'
	   ;groups = @(
			,@{ group_name = 'Webブラウズ'
               ;group_id = 'Web'
			   ;apps = @(
					,@{ name = 'Mozilla Firefox'; package = 'Firefox'; description = ''; }
					,@{ name = 'Google Chrome'; package = 'GoogleChrome'; description = ''; }
					,@{ name = 'Chromium'; package = 'chromium'; description = ''; }
					,@{ name = 'Opera'; package = 'Opera'; description = ''; }
					,@{ name = 'Cyberfox'; package = 'cyberfox'; description = 'Webブラウザ'; }
					,@{ name = 'Flash Playerプラグイン'; package = 'flashplayerplugin'; description = ''; }
					,@{ name = 'Microsoft Silverlight'; package = 'silverlight'; description = ''; }
			   )
			}
			,@{ group_name = 'メール'
               ;group_id = 'Mail'
			   ;apps = @(
					,@{ name = 'Mozilla Thunderbird'; package = 'thunderbird'; description = '電子メールクライアント'; }
			   )
			}
			,@{ group_name = 'コミュニケーション'
               ;group_id = 'Communication'
			   ;apps = @(
					,@{ name = 'Skype'; package = 'skype'; description = '電話・ビデオチャット'; }
					,@{ name = 'Pidgin'; package = 'pidgin'; description = 'インスタントメッセンジャー'; }
			   )
			}
			,@{ group_name = 'オンラインストレージ'
               ;group_id = 'OnlineStorage'
			   ;apps = @(
					,@{ name = 'Dropbox'; package = 'dropbox'; description = ''; }
					,@{ name = 'Google Drive'; package = 'googledrive'; description = ''; }
			   )
			}
			,@{ group_name = 'サーバー・ネットワーク'
               ;group_id = 'Network'
			   ;apps = @(
					,@{ name = 'WinSCP'; package = 'winscp.install'; description = 'SCPクライアント'; }
					,@{ name = 'Putty'; package = 'putty'; description = 'リモートログオンクライアント'; }
					,@{ name = 'UltraVNC'; package = 'ultravnc'; description = 'VNCクライアント'; }
					,@{ name = 'TightVNC'; package = 'tightvnc'; description = 'VNCクライアント'; }
					,@{ name = 'Nmap'; package = 'nmap'; description = 'セキュリティスキャナ'; }
					,@{ name = 'FileZilla'; package = 'filezilla'; description = 'FTPクライアント'; }
					,@{ name = 'FileZilla Server'; package = 'filezilla.server'; description = 'FTPサーバー'; }
					,@{ name = 'qBittorrent'; package = 'qbittorrent'; description = 'BitTorrentクライアント'; }
					,@{ name = 'TeamViewer'; package = 'teamviewer'; description = 'リモートPC操作'; }
					,@{ name = 'ownCloud Windows Client'; package = 'owncloud'; description = 'ownCloudクライアント'; }
					,@{ name = 'Wireshark'; package = 'wireshark'; description = 'プロトコル解析'; }
					,@{ name = 'WinPcap'; package = 'WinPcap '; description = 'パケットドライバー'; }
			   )
			}
	   )
	}
	,@{ tab_name = 'デスクトップ'
       ;tab_id = 'Desktop'
	   ;groups = @(
			,@{ group_name = 'オフィス'
               ;group_id = 'Office'
			   ;apps = @(
					,@{ name = 'LibreOffice'; package = 'libreoffice'; description = ''; }
			   )
			}
			,@{ group_name = 'PDF・電子書籍'
               ;group_id = 'PDF'
			   ;apps = @(
					,@{ name = 'Adobe Acrobat Reader DC'; package = 'adobereader'; description = ''; }
					,@{ name = 'Kindle for PC'; package = 'kindle'; description = ''; }
					,@{ name = 'Calibre'; package = 'calibre'; description = '電子書籍管理'; }
					,@{ name = 'Sumatra PDF'; package = 'sumatrapdf'; description = 'PDF・電子書籍リーダー'; }
			   )
			}
			,@{ group_name = 'テキストエディタ'
               ;group_id = 'Editor'
			   ;apps = @(
					,@{ name = 'Notepad++'; package = 'notepadplusplus.install'; description = ''; }
					,@{ name = 'Atom'; package = 'atom';  description = ''; }
					,@{ name = 'Sublime Text 3'; package = 'sublimetext3.packagecontrol'; description = ''; }
					,@{ name = 'Sublime Text 2'; package = 'sublimetext2'; description = ''; }
					,@{ name = 'Visual Studio Code'; package = 'visualstudiocode'; description = ''; }
					,@{ name = 'TeraPad'; package = 'terapad'; description = ''; }
			   )
			}
			,@{ group_name = 'メモ管理・アイデア整理'
               ;group_id = 'Memo'
			   ;apps = @(
					,@{ name = 'Evernoteクライアント'; package = 'Evernote'; description = ''; }
					,@{ name = 'Kobito'; package = 'kobito'; description = 'Markdownメモ'; }
					,@{ name = 'Freeplane'; package = 'freeplane'; description = 'マインドマッピング・知識管理'; }
			   )
			}
			,@{ group_name = '仮想環境'
               ;group_id = 'VM'
			   ;apps = @(
					,@{ name = 'VirtualBox'; package = 'virtualbox'; description = 'x86仮想PC'; }
					,@{ name = 'VirtualBox Extension Pack'; package = 'virtualbox.extensionpack'; description = ''; }
					,@{ name = 'Vagrant'; package = 'vagrant'; description = '仮想環境構築ツール'; }
			   )
			}
			,@{ group_name = '地理・天文'
               ;group_id = 'Simulator'
			   ;apps = @(
					,@{ name = 'Google Earth'; package = 'googleearth'; description = 'バーチャル地球儀'; }
					,@{ name = 'Celestia'; package = 'celestia'; description = '3D天体シミュレーター'; }
					,@{ name = 'Stellarium'; package = 'stellarium'; description = '3Dプラネタリウム'; }
			   )
			}
			,@{ group_name = 'その他'
               ;group_id = 'Others'
			   ;apps = @(
					,@{ name = 'Google日本語入力'; package = 'googlejapaneseinput'; description = '日本語入力システム'; }
					,@{ name = 'Everything'; package = 'Everything'; description = 'ローカルファイル検索'; }
					,@{ name = 'NexusFont'; package = 'nexusfont.install'; description = 'フォント管理'; }
					,@{ name = 'WinMerge 日本語版'; package = 'winmerge-jp'; description = 'ファイルの比較とマージ'; }
					,@{ name = 'Bz Editor'; package = 'bzeditor'; description = 'バイナリエディタ'; }
					,@{ name = 'grepWin'; package = 'grepwin'; description = '正規表現検索・置換'; }
					,@{ name = 'CDBurnerXP'; package = 'cdburnerxp'; description = 'CD/DVD/BD書き込み'; }
					,@{ name = 'Greenshot'; package = 'greenshot'; description = 'スクリーンショットツール'; }
					,@{ name = 'Steam'; package = 'steam'; description = 'ゲームプラットフォーム'; }
			   )
			}
	   )
	}
	,@{ tab_name = 'システム'
       ;tab_id = 'System'
	   ;groups = @(
			,@{ group_name = 'アプリケーション管理'
               ;group_id = 'Application'
			   ;apps = @(
					,@{ name = 'Chocolatey GUI'; package = 'ChocolateyGUI'; description = 'ChocolateyのGUIフロントエンド'; }
			   )
			}
			,@{ group_name = 'パフォーマンス改善・トラブルシューティング'
               ;group_id = 'Maintainance'
			   ;apps = @(
					,@{ name = 'CCleaner'; package = 'ccleaner'; description = 'システムクリーナー'; }
					,@{ name = 'CCEnhancer'; package = 'ccenhancer'; description = 'CCleaner強化ツール'; }
					,@{ name = 'Sysinternals'; package = 'sysinternals'; description = 'トラブルシューティングツール集'; }
					,@{ name = 'Glary Utilities (Free)'; package = 'glaryutilities-free'; description = 'パフォーマンス改善'; }
					,@{ name = 'Windows Repair'; package = 'windowsrepair'; description = 'Windowsを修復'; }
			   )
			}
			,@{ group_name = '入力カスタマイズ'
               ;group_id = 'Input'
			   ;apps = @(
					,@{ name = 'AutoHotkey'; package = 'autohotkey.install'; description = 'ホットキー設定'; }
			   )
			}
			,@{ group_name = 'プロセス管理'
               ;group_id = 'Process'
			   ;apps = @(
					,@{ name = 'Process Hacker'; package = 'processhacker.install'; description = 'プロセスビューワ'; }
					,@{ name = 'Process Explorer'; package = 'procexp'; description = 'プロセスビューワ'; }
			   )
			}
			,@{ group_name = 'ファイル操作'
               ;group_id = 'File'
			   ;apps = @(
					,@{ name = 'Directory Monitor'; package = 'directorymonitor'; description = 'フォルダーの監視'; }
					,@{ name = 'Duplicate File Finder'; package = 'duplicatefilefinder'; description = '重複ファイル検索'; }
					,@{ name = 'Bulk Rename Utility'; package = 'bulkrenameutility.install'; description = 'ファイル名一括変更'; }
					,@{ name = 'Recuva'; package = 'recuva'; description = '削除ファイル復元'; }
					,@{ name = 'DropIt'; package = 'dropit'; description = 'ファイル操作自動化アシスタント'; }
					,@{ name = 'WinDirStat'; package = 'windirstat'; description = 'フォルダごとに使用容量を分析'; }
			   )
			}
			,@{ group_name = 'バックアップ・復元'
               ;group_id = 'Process'
			   ;apps = @(
					,@{ name = 'CloneApp'; package = 'cloneapp'; description = 'OS・アプリの設定をバックアップ・復元'; }
					,@{ name = 'ClashPlan'; package = 'crashplan'; description = 'オンラインバックアップ'; }
			   )
			}
			,@{ group_name = 'ディスク管理'
			   ;apps = @(
					,@{ name = 'CrystalDiskInfo'; package = 'crystaldiskinfo'; description = 'ディスク動作状況表示'; }
					,@{ name = 'CrystalDiskMark'; package = 'crystaldiskmark'; description = 'ディスクベンチマーク'; }
					,@{ name = 'AOMEI Partition Assistant'; package = 'partitionassistant'; description = 'パーティション管理'; }
					,@{ name = 'Partition Wizard Free Edition'; package = 'partitionwizard'; description = 'パーティション管理'; }
			   )
			}
			,@{ group_name = 'その他'
			   ;apps = @(
					,@{ name = 'Classic Shell'; package = 'classic-shell'; description = 'スタートメニューなどをカスタマイズ'; }
					,@{ name = 'Unchecky'; package = 'unchecky'; description = '不要ソフトのインストールを阻止'; }
					,@{ name = 'RegShot'; package = 'regshot'; description = 'レジストリ変更確認'; }
					,@{ name = '7+ Taskbar Tweaker'; package = '7-taskbar-tweaker'; description = 'タスクバーをカスタマイズ'; }
					,@{ name = 'Malwarebytes Anti-Malware'; package = 'malwarebytes'; description = 'マルウェア検出・駆除'; }
					,@{ name = 'Defraggler'; package = 'defraggler'; description = 'デフラグ'; }
					,@{ name = 'Virtual CloneDrive'; package = 'virtualclonedrive'; description = '仮想CD/DVD/BD'; }
					,@{ name = 'NSSM'; package = 'nssm'; description = '任意のアプリをサービス化'; }
					,@{ name = 'VeraCrypt'; package = 'veracrypt'; description = 'ディスク暗号化'; }
					,@{ name = 'Ext2Fsd'; package = 'ext2fsd'; description = 'ext3/4ファイルシステムドライバ'; }
			   )
			}
	   )
	}
	,@{ tab_name = '画像・動画・音楽'
       ;tab_id = 'Media'
	   ;groups = @(
			,@{ group_name = '画像'
			   ;apps = @(
					,@{ name = 'IrfanView'; package = 'irfanview'; description = '高速な画像ビューワー'; }
					,@{ name = 'IrfanView PlugIns'; package = 'irfanviewplugins'; description = 'IrfanViewプラグイン'; }
					,@{ name = 'paint.net'; package = 'paint.net'; description = '画像編集・加工'; }
					,@{ name = 'GIMP'; package = 'gimp'; description = '画像編集・加工'; }
					,@{ name = 'OptiPNG'; package = 'optipng'; description = 'png画像最適化'; }
					,@{ name = 'ImageMagick'; package = 'imagemagick.app'; description = '画像操作コマンド'; }
					,@{ name = 'ExifTool'; package = 'exiftool'; description = '画像メタ情報編集コマンド'; }
					,@{ name = 'Screenpresso'; package = 'screenpresso'; description = '多機能なスクリーンキャプチャ'; }
					,@{ name = 'WinShot'; package = 'winshot'; description = '軽快なスクリーンキャプチャ'; }
					,@{ name = 'LibreCAD'; package = 'librecad'; description = '2次元CAD'; }
			   )
			}
			,@{ group_name = '動画'
			   ;apps = @(
					,@{ name = 'VLCメディアプレイヤー'; package = 'vlc'; description = 'メディアプレイヤー'; }
					,@{ name = 'MPC-HC'; package = 'mpc-hc'; description = 'メディアプレイヤー'; }
					,@{ name = 'HandBrake'; package = 'handbrake.install'; description = '動画変換GUI'; }
					,@{ name = 'ffmpeg'; package = 'ffmpeg'; description = '動画変換コマンド'; }
					,@{ name = 'Shotcut'; package = 'shotcut'; description = '動画編集'; }
					,@{ name = 'K-Lite Codec Pack Full'; package = 'k-litecodecpackfull '; description = 'コーデック集'; }
					,@{ name = 'win-youtube-dl'; package = 'win-youtube-dl'; description = 'YouTube動画ダウンローダー'; }
					,@{ name = 'Blender'; package = 'blender'; description = '3DCGアニメーション作成'; }
			   )
			}
			,@{ group_name = '音楽'
			   ;apps = @(
					,@{ name = 'iTunes'; package = 'itunes'; description = ''; }
					,@{ name = 'AIMP'; package = 'aimp'; description = '音楽プレイヤー'; }
					,@{ name = 'foobar2000'; package = 'foobar2000'; description = '音楽プレイヤー'; }
					,@{ name = 'Audacity'; package = 'audacity'; description = 'オーディオファイルエディター'; }
			   )
			}
	   )
	}
	,@{ tab_name = '圧縮・解凍'
       ;tab_id = 'Archiver'
	   ;groups = @(
			,@{ group_name = ''
			   ;apps = @(
					,@{ name = '7zip'; package = '7zip.install'; description = '高圧縮率のファイルアーカイバ'; }
					,@{ name = 'PeaZip'; package = 'peazip'; description = '150以上のファイル形式をサポート'; }
					,@{ name = 'Lhaplus'; package = 'lhaplus'; description = ''; }
					,@{ name = '+Lhaca'; package = 'lhaca'; description = ''; }
					,@{ name = 'WinRAR'; package = 'winrar'; description = 'RAR形式に対応するファイルアーカイバ'; }
					,@{ name = 'LessMSI'; package = 'lessmsi'; description = 'MSIファイルの解凍'; }
			   )
			}
	   )
	}
	,@{ tab_name = 'ランタイム'
       ;tab_id = 'Runtime'
	   ;groups = @(
			,@{ group_name = ''
			   ;apps = @(
					,@{ name = 'Microsoft Visual C++ 2015 再配布可能パッケージ'; package = 'vcredist2015'; }
					,@{ name = 'Microsoft Visual C++ 2013 再配布可能パッケージ'; package = 'vcredist2013'; }
					,@{ name = 'Microsoft Visual C++ 2012 再配布可能パッケージ'; package = 'vcredist2012'; }
					,@{ name = 'Microsoft Visual C++ 2010 再配布可能パッケージ'; package = 'vcredist2010'; }
					,@{ name = 'Microsoft Visual C++ 2008 再配布可能パッケージ'; package = 'vcredist2008'; }
					,@{ name = 'Microsoft Visual C++ 2005 再配布可能パッケージ'; package = 'vcredist2005'; }
					,@{ name = '.NET Framework 4.6.1'; package = 'DotNet4.6.1'; description = ''; }
					,@{ name = '.NET Framework 4.6'; package = 'DotNet4.6'; description = ''; }
					,@{ name = '.NET Framework 4.5.2'; package = 'DotNet4.5.2'; description = ''; }
					,@{ name = '.NET Framework 4.5.1'; package = 'DotNet4.5.1'; description = ''; }
					,@{ name = '.NET Framework 4.5'; package = 'DotNet4.5'; description = ''; }
					,@{ name = '.NET Framework 4.0'; package = 'DotNet4.0'; description = ''; }
					,@{ name = '.NET Framework 3.5'; package = 'DotNet3.5'; description = ''; }
					,@{ name = 'Java SE Runtime Environment'; package = 'jre8'; description = ''; }
					,@{ name = 'DirectX 9'; package = 'directx'; description = ''; }
					,@{ name = 'Adobe AIR'; package = 'adobeair'; description = ''; }
			   )
			}
	   )
	}
	,@{ tab_name = 'コマンドラインツール'
       ;tab_id = 'Cmd'
	   ;groups = @(
			,@{ group_name = ''
			   ;apps = @(
					,@{ name = 'Clink'; package = 'clink'; description = 'コマンドプロンプト機能強化'; }
					,@{ name = 'Bind Tools'; package = 'bind-toolsonly'; description = 'DNS関連ツール'; }
					,@{ name = 'Sudo'; package = 'Sudo'; description = 'コマンドラインから管理者として実行'; }
					,@{ name = 'wget'; package = 'wget'; description = 'ファイルダウンロード'; }
					,@{ name = 'cURL'; package = 'curl'; description = 'さまざまなプロトコルでファイルを転送'; }
					,@{ name = 'Vim'; package = 'vim'; description = 'コマンドライン環境で広く使われているエディタ'; }
					,@{ name = 'Ghostscript'; package = 'ghostscript.app'; description = 'PostScriptなどのインタプリター'; }
			   )
			}
	   )
	}
	,@{ tab_name = 'UNIXツール'
       ;tab_id = 'Unix'
	   ;groups = @(
			,@{ group_name = ''
			   ;apps = @(
					,@{ name = 'MSYS2'; package = 'msys2'; description = 'GNU/Linuxライク環境'; }
					,@{ name = 'MinGW'; package = 'mingw'; description = 'GNU/Linuxライク環境'; }
					,@{ name = 'Cygwin'; package = 'cygwin'; description = 'GNU/Linuxライク環境'; }
					,@{ name = 'cyg-get'; package = 'cyg-get'; description = 'Cygwinパッケージインストールコマンド'; }
					,@{ name = 'MobaXTerm'; package = 'MobaXTerm'; description = 'Xサーバ／SSHクライアントなど'; }
					,@{ name = 'ConEmu'; package = 'ConEmu'; description = 'コンソールエミュレーター'; }
					,@{ name = 'Cmder'; package = 'cmder.portable'; description = 'コンソールエミュレーター'; }
					,@{ name = 'NYAGOS'; package = 'nyagos'; description = 'コマンドラインシェル'; }
			   )
			}
	   )
	}
	,@{ tab_name = '開発'
       ;tab_id = 'Develop'
	   ;groups = @(
			,@{ group_name = '言語'
			   ;apps = @(
					,@{ name = 'Python'; package = 'python';  description = 'スクリプト言語'; }
					,@{ name = 'Python 2'; package = 'python2';  description = 'スクリプト言語'; }
					,@{ name = 'Ruby'; package = 'ruby';  description = 'スクリプト言語'; }
					,@{ name = 'Ruby Development Kit'; package = 'ruby2.devkit'; description = 'Ruby開発キット'; }
					,@{ name = 'Strawberry Perl'; package = 'strawberryperl'; description = 'スクリプト言語'; }
					,@{ name = 'PHP'; package = 'php'; description = 'スクリプト言語'; }
					,@{ name = 'AutoIt'; package = 'autoit'; description = 'BASIC風スクリプト言語'; }
					,@{ name = 'PowerShell Community Extensions (PSCX)'; package = 'pscx'; description = ''; }
					,@{ name = 'Pester'; package = 'pester'; description = 'Powershell用テストフレームワーク'; }
					,@{ name = 'Java Development Kit'; package = 'jdk'; }
			   )
			}
			,@{ group_name = '統合開発環境'
			   ;apps = @(
					,@{ name = 'Visual Studio 2015 Community'; package = 'visualstudio2015community'; description = ''; }
					,@{ name = 'Eclipse'; package = 'eclipse'; description = ''; }
			   )
			}
			,@{ group_name = 'バージョン管理'
			   ;apps = @(
					,@{ name = 'Subversion for Windows'; package = 'svn'; description = '集中型バージョン管理システム'; }
					,@{ name = 'TortoiseSVN'; package = 'tortoisesvn'; description = 'Subversionクライアント'; }
					,@{ name = 'Git '; package = 'git.install';  description = '分散型バージョン管理システム'; }
					,@{ name = 'TortoiseGit'; package = 'tortoisegit'; description = 'シェルエクステンションとして動作するGitクライアント'; }
					,@{ name = 'posh-git'; package = 'poshgit'; description = 'PowershellでGitコマンドを入力補完'; }
					,@{ name = 'SourceTree'; package = 'sourcetree'; description = 'Gitクライアント'; }
					,@{ name = 'Git Extensions'; package = 'gitextensions'; description = 'GIT グラフィカルUI'; }
					,@{ name = 'Mercurial'; package = 'hg'; description = '分散型バージョン管理システム'; }
			   )
			}
			,@{ group_name = 'データベース関連'
			   ;apps = @(
					,@{ name = 'SQLite'; package = 'sqlite'; description = 'SQLデータベースエンジン'; }
					,@{ name = 'SQLite Shell'; package = 'sqlite.shell'; description = 'SQLite用コマンドラインシェル'; }
					,@{ name = 'SQLite Analyzer'; package = 'sqlite.analyzer'; description = 'SQLiteデータベースファイル解析'; }
					,@{ name = 'DB Browser for SQLite'; package = 'sqlitebrowser'; description = ''; }
					,@{ name = 'LINQPad'; package = 'linqpad'; description = ''; }
			   )
			}
			,@{ group_name = 'その他'
			   ;apps = @(
					,@{ name = 'PhantomJS'; package = 'phantomjs'; description = 'WebブラウザなしでJavascriptを実行'; }
					,@{ name = 'Node.js'; package = 'nodejs.install'; description = 'サーバーサイドJavascript環境'; }
					,@{ name = 'Fiddler'; package = 'fiddler'; description = 'デバッグ用Webプロキシ'; }
					,@{ name = 'NAnt'; package = 'nant'; description = '.NET ビルドツール'; }
					,@{ name = 'Apache Maven'; package = 'maven'; description = 'ソフトウェアプロジェクト管理'; }
					,@{ name = 'CMake'; package = 'cmake'; description = 'ビルド自動化ツール'; }
			   )
			}
	   )
	}
)


function appinst_form {
    $Form = New-Object System.Windows.Forms.Form    
    $Form.Size = New-Object System.Drawing.Size(1, 1) 
    $Form.AutoSize = $true 
    $Form.FormBorderStyle = "FixedSingle"
    $Form.MaximizeBox = $false
    $Form.text = $software_name

    $OKButton = New-Object System.Windows.Forms.Button
    $OKButton.Location = New-Object System.Drawing.Point(183, 470)
    $OKButton.Size = New-Object System.Drawing.Size(280, 24)
    $OKButton.Text = "アプリのインストール／アンインストールを実行する"
    $OKButton.Add_Click(
        {
            $add_apps = @()
            $del_apps = @()
            foreach ( $page in $list ) {
                foreach ( $group in $page['groups'] ) {
                    foreach ( $app in $group['apps'] ) {
                        if ( $app['installed'] -eq $false ) {
                            if ( $app['checkbox'].Checked -eq $true ) {
                                $add_apps += $app
                            }
                        } else {
                            if ( $app['checkbox'].Checked -eq $false ) {
                                $del_apps += $app
                            }
                        }
                    }
                }
            }

            $FormB = New-Object System.Windows.Forms.Form
            $FormB.AutoSize = $true 
            $FormB.FormBorderStyle = "FixedSingle"
            $FormB.MaximizeBox = $false
            $FormB.Text = "確認 -" + $software_name
            $FormB.Owner = $Form

            $LabelB = New-Object System.Windows.Forms.Label
            $LabelB.Location = '8, 16'
            $LabelB.Size = '460, 30'
            if ( ($add_apps.Length + $del_apps.Length) -gt 0 ) {
                $LabelB.Text = "実行内容を確認してください。"
            }
            $FormB.Controls.Add($LabelB)

            $TextB = New-Object System.Windows.Forms.TextBox
            $TextB.Location = '4, 50'
            $TextB.Size = '454, 400'
            $TextB.Multiline = $True
            $TextB.ReadOnly = $true
            if ( $add_apps.Length -gt 0 ) {
                $TextB.Text += "以下のアプリをインストールします。`r`n"
                foreach ( $app in $add_apps ) {
                    $TextB.Text += ("`t" + $app['name'] + "`r`n")
                }
                $TextB.Text += "`r`n"
            } else {
                $TextB.Text += "新たにインストールするアプリはありません。`r`n`r`n"
            }
            if ( $del_apps.Length -gt 0 ) {
                $TextB.Text += "以下のアプリをアンインストールします。`r`n"
                foreach ( $app in $del_apps ) {
                    $TextB.Text += ("`t" + $app['name'] + "`r`n")
                }
                $TextB.Text += "`n"
            } else {
                $TextB.Text += "アンインストールするアプリはありません。"
            }
            $FormB.Controls.Add($TextB)

            $OKButtonB = New-Object System.Windows.Forms.Button
            $OKButtonB.Location = '280, 470'
            $OKButtonB.Size = '86, 24'
            $OKButtonB.Text = "OK"
            $OKButtonB.TabIndex = 0
            $OKButtonB.Add_Click(
                {                  
                    if ( $add_apps.Length -gt 0 ) {
                        $command = "$choco_exe_path install -y "
                        foreach ( $app in $add_apps ) {
                            $command += ($app['package'] + ' ')
                        }
                        Start-Process 'powershell' -ArgumentList ('-Command "' + $command + '; pause"') -Wait
                    }

                    if ( $del_apps.Length -gt 0 ) {
                        $command = "$choco_exe_path uninstall -y "
                        foreach ( $app in $del_apps ) {
                            $command += ($app['package'] + ' ')
                        }
                        Start-Process 'powershell' -ArgumentList ('-Command "' + $command + '; pause"') -Wait
                    }

                    update_installed_packages
                    foreach ( $page in $list ) {
                        foreach ( $group in $page['groups'] ) {
                            foreach ( $app in $group['apps'] ) {
                                if ( $script:installed_packages.Contains($app['package'].ToLower()) ) {
                                    $app['installed'] = $true
                                } else {
                                    $app['installed'] = $false
                                }
            				    $app['checkbox'].Checked = $app['installed']
            			    }
            		    }
	                }
                    $FormB.Close()
                }
            )
            $FormB.Controls.Add($OKButtonB)

            $CancelButtonB = New-Object System.Windows.Forms.Button
            $CancelButtonB.Location = '376, 470'
            $CancelButtonB.Size = '86, 26'
            $CancelButtonB.Text = "キャンセル"
            $CancelButtonB.TabIndex = 1
            $CancelButtonB.Add_Click(
                {
                    $FormB.Close()
                }
            )
            $FormB.Controls.Add($CancelButtonB)

            $FormB.ShowDialog() | Out-Null
        }
    )
    $Form.Controls.Add($OKButton)

    <#
    $CancelButton = New-Object System.Windows.Forms.Button
    $CancelButton.Location = New-Object System.Drawing.Point(376, 470)
    $CancelButton.Size = New-Object System.Drawing.Size(86, 26)
    $CancelButton.Text = "キャンセル"
    $CancelButton.Add_Click(
        {
            $text = "インストールせずに終了してよろしいですか？"
            $caption = "確認 - " + $software_name
            $buttonsType = "OKCancel"
            $iconType = "Question"
            $result = [System.Windows.Forms.MessageBox]::Show($text, $caption, $buttonsType, $iconType)
            if ( $result -eq 'OK' ) {
                $Form.Close()
            }
        }
    )
    $Form.Controls.Add($CancelButton)
    #>

    $TabControl = New-object System.Windows.Forms.TabControl
    $TabControl.Multiline = $True
    $TabControl.Location = New-Object System.Drawing.Point(3, 3)
    $TabControl.Size = New-Object System.Drawing.Size(460, 464)
    $Form.Controls.Add($TabControl)

    foreach ( $page in $list ) {
        $Tab = New-Object System.Windows.Forms.TabPage
        $Tab.UseVisualStyleBackColor = $True
        $Tab.Text = $page['tab_name']
        $TabControl.Controls.Add($Tab)

        $MessageLabel = New-Object System.Windows.Forms.Label
        $MessageLabel.Location = '4, 6'
        $MessageLabel.Size = '435, 32'
        $MessageLabel.Text = "インストールするアプリのチェックをオンにし、ウィンドウ下部のボタンをクリックしてください。`r`nチェックをオフにしたアプリはアンインストールされます。"
        $Tab.Controls.Add($MessageLabel)

        $Panel = New-Object System.Windows.Forms.Panel
        $Panel.Location = '8, 40'
        $Panel.Size = '440, 340'
        $Panel.AutoScroll = $true
        $Tab.Controls.Add($Panel)

        $offset = 0
        foreach ( $group in $page['groups'] ) {
            if ( $group['group_name'] -and ($group['group_name'] -ne '') ) {
                $Label = New-Object System.Windows.Forms.Label
                $Label.Location = New-Object System.Drawing.Point(0, $offset)
                $Label.Size = New-Object System.Drawing.size(400, 22)
                $Label.Text = $group['group_name']
                $offset += 24
                $Panel.Controls.Add($Label)
            }
            foreach ( $app in $group['apps'] ) {
                $CheckBox = New-Object System.Windows.Forms.Checkbox
                $CheckBox.Location = New-Object System.Drawing.Point(8, $offset)
                $CheckBox.Size = New-Object System.Drawing.size(290, 22)
                $CheckBox.Text = $app['name']
                if ( $app['description'] ) {
                    $CheckBox.Text += (" （" + $app['description'] + "）")
                }
                if ( $script:installed_packages.Contains($app['package'].ToLower()) ) {
                    $app['installed'] = $true
                } else {
                    $app['installed'] = $false
                }
                $CheckBox.Checked = $app['installed']
                $Panel.Controls.Add($Checkbox)
                $app['checkbox'] = $Checkbox

                $SearchButton = New-Object System.Windows.Forms.Button
                $SearchButton.Location = New-Object System.Drawing.Point(320, $offset)
                $SearchButton.Size = New-Object System.Drawing.size(80, 22)
                $SearchButton.Text = "Web検索"

                $SearchText = New-Object System.Windows.Forms.TextBox
                $SearchText.Text = $app['name']
                $SearchText.Parent = $SearchButton
                $SearchText.Hide()

                $SearchButton.Add_Click(
                    {
                        $url = ("http://www.google.co.jp/search?hl=ja&q=" + [Web.HttpUtility]::UrlEncode($this.Controls[0].Text))
                        Start-Process -FilePath $url
                    }
                )
                $Panel.Controls.Add($SearchButton)

                $offset += 24
            }
            $offset += 16
        }
    }

    <# 一括アップグレード #>
    $UpgradePage = New-Object System.Windows.Forms.TabPage
    $UpgradePage.UseVisualStyleBackColor = $True
    $UpgradePage.Text = "一括アップグレード"
    $TabControl.Controls.Add($UpgradePage)

    $UpgradeButton = New-Object System.Windows.Forms.Button
    $UpgradeButton.Location = New-Object System.Drawing.Point(48, 150)
    $UpgradeButton.Size = New-Object System.Drawing.Size(355, 26)
    $UpgradeButton.Text = "インストール済みアプリの一括アップグレードを行う"
    $UpgradeButton.Add_Click(
        {
            $command = "$choco_exe_path upgrade -y all"
            Start-Process 'powershell' -ArgumentList ('-Command "' + $command + '; pause"') -Wait
        }
    )
    $UpgradePage.Controls.Add($UpgradeButton)

    $UpgradeLabel = New-Object System.Windows.Forms.Label
    $UpgradeLabel.Location = '48, 200'
    $UpgradeLabel.Size = '355, 80'
    $UpgradeLabel.Text = "インストール済みアプリの新しいバージョンが利用可能かをチェックし、可能ならばアップグレードを行います。`r`nアップグレードの対象となるのは、Chocolateyでインストールされたアプリだけです。"
    $UpgradePage.Controls.Add($UpgradeLabel)

    <# About #>
    $AboutPage = New-Object System.Windows.Forms.TabPage
    $AboutPage.UseVisualStyleBackColor = $True
    $AboutPage.Text = "About"
    $TabControl.Controls.Add($AboutPage)

    $AppNameLabel = New-Object System.Windows.Forms.Label
    $AppNameLabel.Location = '150, 20'
    $AppNameLabel.Size = '260, 24'
  	$AppNameLabel.Text = $software_name
    $AppNameLabel.Font = New-Object System.Drawing.Font("Courier New", 16, [System.Drawing.FontStyle]::Bold)
    $AboutPage.Controls.Add($AppNameLabel)

    $CopyrightLabel = New-Object System.Windows.Forms.Label
    $CopyrightLabel.Location = '70, 50'
    $CopyrightLabel.Size = '400, 24'
  	$CopyrightLabel.Text = 'Copyright © 2016 pseudo-hacks.com All Rights Reserved.'
    $AboutPage.Controls.Add($CopyrightLabel)

    $LinkLabel = New-Object System.Windows.Forms.LinkLabel
    $LinkLabel.Location = '100, 76'
    $LinkLabel.Size = '300, 24'
    $LinkLabel.LinkColor = "BLUE"
    $LinkLabel.ActiveLinkColor = "RED"
    $LinkLabel.Text = 'http://www.pseudo-hacks.com/w10appinst/'
    $LinkLabel.add_Click({[system.Diagnostics.Process]::start('http://www.pseudo-hacks.com/w10appinst/')}) 
    $AboutPage.Controls.Add($LinkLabel)

    $LicenseTextBox = New-Object System.Windows.Forms.TextBox
    $LicenseTextBox.Location = '8, 110'
    $LicenseTextBox.Size = '435, 180'
    $LicenseTextBox.Multiline = $true
    $LicenseTextBox.Text = "This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>."
    $LicenseTextBox.ReadOnly = $true
    $AboutPage.Controls.Add($LicenseTextBox)

    $CustomButton = New-Object System.Windows.Forms.Button
    $CustomButton.Location = New-Object System.Drawing.Point(8, 300)
    $CustomButton.Size = New-Object System.Drawing.Size(435, 26)
    $CustomButton.Text = "Windows 10プライバシー対策＆簡単設定アプリ「w10custom」を起動する"
    $CustomButton.Add_Click(
        {
          Start-Job { iex -Command ('$invoked_from = "' + $software_name + '";' + ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/pseudo-hacks/w10custom/master/w10custom.ps1'))) }
        }
    )
    $AboutPage.Controls.Add($CustomButton)
    if ( ($invoked_from -eq 'w10custom') -or ([Environment]::OSVersion.Version.Major -ne 10) ) {
        $CustomButton.Enabled = $false
    }

    $FontInstButton = New-Object System.Windows.Forms.Button
    $FontInstButton.Location = New-Object System.Drawing.Point(8, 330)
    $FontInstButton.Size = New-Object System.Drawing.Size(435, 26)
    $FontInstButton.Text = "フリーフォント一括インストールアプリ「w10fontinst」を起動する"
    $FontInstButton.Add_Click(
        {
          Start-Job { iex -Command ('$invoked_from = "' + $software_name + '";' + ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/pseudo-hacks/w10FontInst/master/w10fontinst.ps1'))) }
        }
    )
    $AboutPage.Controls.Add($FontInstButton)
    if ( $invoked_from -eq 'w10fontinst' ) {
        $FontInstButton.Enabled = $false
    }

    $Form.ShowDialog() | Out-Null
}

$choco_exe_path = ''
function check_choco {
    if ( $env:ChocolateyInstall ) {
        $script:choco_exe_path = Join-Path $env:ChocolateyInstall "\bin\choco.exe"
        if ( !(Test-Path $choco_exe_path -PathType Leaf) ) {
            $script:choco_exe_path = ''
        }
    }
}

function install_choco {
    $text = "本アプリを利用するにはChocolateyのインストールが必要です。`r`nインストールを開始してよろしいですか？"
    $caption = "確認 - " + $software_name
    $buttonsType = "OKCancel"
    $iconType = "Question"
    $result = [System.Windows.Forms.MessageBox]::Show($text, $caption, $buttonsType, $iconType)
    if ( $result -eq 'Cancel' ) {
        safe_exit
    }
    iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
    check_choco
    if ( $script:choco_exe_path -eq '' ) {
        $text = "Chocolateyのインストールに失敗しました。"
        $caption = "エラー - " + $software_name
        $buttonsType = "OK"
        $iconType = "Error"
        [System.Windows.Forms.MessageBox]::Show($text, $caption, $buttonsType, $iconType)
        safe_exit
    }
}

$installed_packages = @()
function update_installed_packages {
    $script:installed_packages.Clear()
    & $choco_exe_path list -lo -r | Set-Variable -Name 'choco_list_lo'
    foreach( $s in $choco_list_lo -split "`r`n" ){
	    $script:installed_packages += $s.Substring(0, $s.IndexOf('|')).ToLower()
    }
}

function disclaimer {
    $text = "このソフトウェアは、GNU General Public Licenseバージョン3 (GPLv3)のもと提供されています。`n" +
            "このソフトウェアは無保証であり、どのようなトラブルが発生しても著作権者は責任を負わないものとします。`n" +
            "このソフトウェアの著作権やライセンスについての詳細は、起動後に「About」タブを参照してください。" +
            "`n`n" +
            "このソフトウェアは、個人利用のWindows PCを対象としています。組織の管理下にあるPCでは、想定通りに動作しない可能性があります。"
    $caption = "確認 - " + $software_name
    $buttonsType = "OKCancel"
    $iconType = "Question"
    $result = [System.Windows.Forms.MessageBox]::Show($text, $caption, $buttonsType, $iconType)
    if ( $result -ne 'OK' ) {
        safe_exit
    }
}

function check_admin {
    if ( ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator") -eq $false ) {
        $text = "標準ユーザーとして実行されています。管理者ユーザーとして実行する必要があります。"
        $caption = "確認 - " + $software_name
        $buttons = "OK"
        $icon = "Error"
        $default_button = "Button1"
        [System.Windows.Forms.MessageBox]::Show($text, $caption, $buttons, $icon, $default_button) | Out-Null
        safe_exit
    }
}

#メインルーチン

disclaimer
check_admin
check_choco
if ( $choco_exe_path -eq '' ) {
    install_choco
}
update_installed_packages
appinst_form
safe_exit