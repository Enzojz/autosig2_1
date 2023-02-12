local descEN = [[This mod automatizes the placing of signals.

Usage:
1. With mod loaded, there is an "AutoSig" option in the signal construction menu (show after placing the cursor over the track).
2. Toggle to state to "On" to enable the function
3. Set the "Signal Distance" to desired value 
4. Place a signal on the track, the mod will automatically create successive signals in the same directiom
5. The condition of creating is either of following
   i. in front of a switch or crossing
   ii. in front of a signal of the same direction
   iii. in front of a station/depot or other tracks where signals can not be placed

* This mod can be safely removed from gamesaves.

Changelog:
1.11
- Fix of dead loop of backward removing
- Added cost calculates (credit to phobos2077)
1.10
- Fix crash bug on track connected to depot
- Add signal removal function
- Add signal replacing function
1.9
- Intergration of AutoSig with into the construction menu
- Live with auto paralell tracks mod.
1.8
- Bugfix for signals created into construction.
1.7
- Rewrite based on new API functions.
]]

local descFR = [[Ce mod automatise le placement des signalisations.

Mode d’emploi :
1. Avec ce mod chargé, il aura l'option "AutoSig" dans le menu de construction des signaux (affiché après d'avoir poser le curseur sur la voie)
2. Cliquez sur l'indicateur, quand il affiche "Activé" c'est activé.
3. Cliquez sur "AutoSig" pour définir l'écart entre les signaux.
4. Pose une signale sur la voie, le mod automatise la création des signaux successives dans même la sens.
5. Condition de l'arrêt de création est :
   i. jusqu'à une aiguille ou jonction
   ii. jusqu'à l'autre signale de la même sens
   iii. jusqu'à une construction comme gare ou dêpot

* Ce mod pourrait être désactivé sans souci.

Changelog:
1.11
- Correction pour la boucle infinie lors la suppression en sens inverse.
- Ajoute de calculs de côute (crédité à phobos2077)
1.10
- Correction du bug de création des signaux vers dêpots.
- Ajout de fonction de suppression des signaux
- Ajout de fonction de remplacement des signaux
1.9
- Intrégration dans le menu de construction
- Fonctionne dans le même temps avec mod Voies ferrées parallèles.
1.8
- Correction du bug de création des signaux dans les constructions.
1.7
- Récriture avec la nouvelle API.
]]

local descCN = [[该模组能够自动在轨道上连续添加信号机

使用：
1.若模组开启，进入信号机放置模式，并且将光标置于轨道后，建造菜单中会出现“自动放置信号机”的选项。
2.点击“开启”或者“关闭”切换状态
3.点击“自动放置信号机”设置信号机间距
4.在轨道上放置一台信号机，模组会在信号机前方以设定距离连续放置新的信号机直到:
  i. 遇到另外一台同一方向的信号机
  ii. 遇到一个道岔
  iii. 遇到车站、车辆段等建筑物

更新记录：
1.11
- 修正了反向拆除信号机时的死循环
- 增加了费用的计算(感谢phobos2077)
1.10
- 修复了遇到轨道连接车辆段情况下时的崩溃错误
- 增加了快速拆除信号机功能
- 增加了快速替换信号机功能
1.9
- 将选项集成到了建造菜单中
- 支持同时开启平行轨道模组
1.8
- 修复了信号机建到车站内的错误。
1.7
- 以新版API重写了MOD。]]

local descTC = [[該模組能夠自動在軌道上連續添加號誌機

使用：
1.若模組開啟，進入信號機放置模式，並且將游標置於軌道後，建造功能表中會出現“自動放置信號機”的選項。
2.點擊“開啟”或者“關閉”切換狀態
3.點擊“自動放置號誌機”設置號誌機間距
4.在軌道上放置一台號誌機，模組會在號誌機前方以設定距離連續放置新的號誌機直到:
  i. 遇到另外一台同一方向的號誌機
  ii. 遇到一個道岔
  iii. 遇到車站、車輛段等建築物

* 該模組可以安全地從存檔中移除

更新記錄：
1.11
- 修正了反向拆除信號機時的死循環
- 增加了費用的計算(感謝phobos2077)
1.10
- 修復了遇到軌道連接車輛段情況下時的崩潰錯誤
- 增加了快速拆除信號機功能
- 增加了快速替換信號機功能
1.9
- 將選項集成到了建造功能表中
- 支持同時開啟平行軌道模組
1.8
- 修復了信號機建到車站內的錯誤。
1.7
- 以新版API重寫了MOD。]]


function data()
    return {
        en = {
            MOD_NAME = "Auto.Sig²",
            MOD_DESC = descEN,
            SIGNAL_DISTANCE = "Signal Spacing",
            AUTOSIG = "AutoSig",
            ON = "On",
            OFF = "Off",
            REPLACE = "Replace",
            REMOVE = "Remove",
            FORWARD = "Forward",
            BACKWARD = "Backward",
            METER = "m"
        },
        fr = {
            MOD_NAME = "Auto.Sig²",
            MOD_DESC = descFR,
            TITLE = "Auto.Sig",
            SIGNAL_DISTANCE = "Distance entre deux signaux",
            AUTOSIG = "AutoSig",
            OFF = "Désactivé",
            ON = "Activé",
            REPLACE = "Remplace",
            REMOVE = "Détruire",
            FORWARD = "Sens avant",
            BACKWARD = "Sens arrière",
            METER = "m"
        },
        zh_CN = {
            MOD_NAME = "自动放置信号机 2.0",
            MOD_DESC = descCN,
            SIGNAL_DISTANCE = "信号机间距",
            AUTOSIG = "自动放置信号机",
            ON = "开启",
            OFF = "关闭",
            REPLACE = "替换",
            REMOVE = "拆除",
            FORWARD = "前方",
            BACKWARD = "后方",
            METER = "米"
        },
        zh_TW = {
            MOD_NAME = "自動放置號誌機 2.0",
            MOD_DESC = descTC,
            SIGNAL_DISTANCE = "號誌機間距",
            AUTOSIG = "自動放置號誌機",
            ON = "開啟",
            OFF = "關閉",
            REPLACE = "替換",
            REMOVE = "拆除",
            FORWARD = "前方",
            BACKWARD = "後方",
            METER = "公尺"
        }


    }
end
