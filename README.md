# SetScale

AutoHotkey scripts that change the **per-monitor Windows display scale** via **DisplayConfig** device-info packets (undocumented types -3/-4). Works on Windows 10/11 and applies immediately (no sign-out), though some apps may need a restart.

## Supported scale steps

Windows exposes fixed steps. These scripts accept only the following values:

```
100, 125, 150, 175, 200, 225, 250, 300, 350, 400, 450, 500
```

### Notes

* **Monitor index** follows the order of **active paths**; this usually matches the order you see when pressing **Identify** in *Settings -> System -> Display*.
* The change is applied immediately for the target display. Some apps may need to be restarted to re-flow correctly.

## hotkeys (v2 example)

```ahk
#Requires AutoHotkey v2.0
; Cycle common steps on primary monitor with Alt+= / Alt+-
Steps := [100,125,150,175,200,225,250]
current := 1  ; start at 100% in this example

!=::
{
    global Steps, current
    current := (current < Steps.Length) ? current+1 : Steps.Length
    SetScale(Steps[current], 1)
}

!-::
{
    global Steps, current
    current := (current > 1) ? current-1 : 1
    SetScale(Steps[current], 1)
}
```

## Credits

* **imniko** - [SetDPI](https://github.com/imniko/SetDPI)
* **lihas** - [windows-DPI-scaling-sample](https://github.com/lihas/windows-DPI-scaling-sample)
