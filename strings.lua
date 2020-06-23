local descEN = [[This mod automatizes the placing of signals.

Usage:
1. With mod loaded, there is an "AutoSig" label at the bottom bar of the screen, after it the state "On" or "Off" is indicated.
2. Toggle to state to "On" to enable the function
3. Set the "Signal Distance" to desired value 
4. Place a signal on the track, the mod will automatically create successive signals in the same directiom
5. The condition of creating is either of following
   i. in front of a switch or crossing
   ii. in front of a signal of the same direction
   iii. in front of a station/depot or other tracks where signals can not be placed

* This mod can be safely removed from gamesaves.

Stay strong and united before COVID-19!

Changelog:
1.8
- Bugfix for signals created into construction.
1.7
- Rewrite based on new API functions.
]]

local descFR = [[Ce mod automatise le placement des signalisations.

Mode d’emploi :
1. Avec ce mod chargé, il aura une libéllé "AutoSig" en bas d'écran, puis "Activé" ou "Désactivé" pour indiquer son état
2. Cliquez sur l'indicateur, quand il affiche "Activé" c'est activé.
3. Cliquez sur "AutoSig" pour définir l'écart entre les signaux.
4. Pose une signale sur la voie, le mod automatise la création des signaux successives dans même la sens.
5. Condition de l'arrêt de création est :
   i. jusqu'à une aiguille ou jonction
   ii. jusqu'à l'autre signale de la même sens
   iii. jusqu'à une construction comme gare ou dêpot

* Ce mod pourrait être désactivé sans souci.

Restons prudents! #COVID-19

Changelog:
1.8
- Correction du bug de création des signaux dans les constructions.
1.7
- Récriture avec la nouvelle API.
]]

local descCN = [[该模组能够自动在轨道上连续添加信号机

使用：
1.若模组开启，屏幕最下方的信息条中显示“自动放置信号机”的标签，后面有标签表示该功能是否开启。
2.点击“开启”或者“关闭”切换状态
3.点击“自动放置信号机”设置信号机间距
4.在轨道上放置一台信号机，模组会在信号机前方以设定距离连续放置新的信号机直到:
  i. 遇到另外一台同一方向的信号机
  ii. 遇到一个道岔
  iii. 遇到车站、车辆段等建筑物

更新记录：
1.8
- 修复了信号机建到车站内的错误。
1.7
- 以新版API重写了MOD。]]

local descTC = [[該模組能夠自動在軌道上連續添加號誌機

使用：
1.若模組開啟，螢幕最下方的資訊條中顯示“自動放置號誌機”的標籤，後面有標籤表示該功能是否開啟。
2.點擊“開啟”或者“關閉”切換狀態
3.點擊“自動放置號誌機”設置號誌機間距
4.在軌道上放置一台號誌機，模組會在號誌機前方以設定距離連續放置新的號誌機直到:
  i. 遇到另外一台同一方向的號誌機
  ii. 遇到一個道岔
  iii. 遇到車站、車輛段等建築物

* 該模組可以安全地從存檔中移除

更新記錄：
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
            METER = "m"
        },
        zh_CN = {
            MOD_NAME = "自动放置信号机 2.0",
            MOD_DESC = descCN,
            SIGNAL_DISTANCE = "信号机间距",
            AUTOSIG = "自动放置信号机",
            ON = "开启",
            OFF = "关闭",
            METER = "米"
        },
        zh_TW = {
            MOD_NAME = "自動放置號誌機 2.0",
            MOD_DESC = descTC,
            SIGNAL_DISTANCE = "號誌機間距",
            AUTOSIG = "自動放置號誌機",
            ON = "開啟",
            OFF = "關閉",
            METER = "公尺"
        }


    }
end
