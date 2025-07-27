; AHK v2 — per-monitor scale

; Examples:
; SetScale(100)       ; set primary monitor to 100%
; SetScale(250, 2)    ; set monitor #2 to 250%

SetScale(scalePercent, monitorIndex := 1) {
    static ScaleValues := [100,125,150,175,200,225,250,300,350,400,450,500]
    static QDC_ONLY_ACTIVE_PATHS := 0x2

    ; find desired index
    idx := -1
    for i, v in ScaleValues {
        if (v = scalePercent) {
            idx := i - 1
            break
        }
    }
    if (idx < 0)
        return 0

    ; get buffer sizes for paths and modes
    pathCount := Buffer(4)
    modeCount := Buffer(4)
    if DllCall("user32\GetDisplayConfigBufferSizes"
        , "UInt", QDC_ONLY_ACTIVE_PATHS
        , "Ptr", pathCount
        , "Ptr", modeCount)
        return 0
    totalPaths := NumGet(pathCount, 0, "UInt")
    totalModes := NumGet(modeCount, 0, "UInt")
    if (monitorIndex < 1 || monitorIndex > totalPaths)
        return 0

    ; allocate buffers
    pathSize := 72, modeSize := 64
    pathBuf := Buffer(totalPaths * pathSize)
    modeBuf := Buffer(totalModes * modeSize)

    ; query active display config
    if DllCall("user32\QueryDisplayConfig"
        , "UInt", QDC_ONLY_ACTIVE_PATHS
        , "Ptr", pathCount
        , "Ptr", pathBuf
        , "Ptr", modeCount
        , "Ptr", modeBuf
        , "Ptr", 0)
        return 0

    ; extract adapter/source info
    offset := (monitorIndex - 1) * pathSize
    adapterLow  := NumGet(pathBuf, offset + 0, "UInt")
    adapterHigh := NumGet(pathBuf, offset + 4, "Int")
    sourceId    := NumGet(pathBuf, offset + 8, "UInt")

    ; GET (-3): retrieve min/max relative scale steps
    getPkt := Buffer(0x20)
    NumPut("Int", -3, getPkt, 0)
    NumPut("UInt", 0x20, getPkt, 4)
    NumPut("UInt", adapterLow, getPkt, 8)
    NumPut("Int", adapterHigh, getPkt, 12)
    NumPut("UInt", sourceId, getPkt, 16)
    if DllCall("user32\DisplayConfigGetDeviceInfo", "Ptr", getPkt)
        return 0
    minRel := NumGet(getPkt, 20, "Int")
    maxRel := NumGet(getPkt, 28, "Int")

    ; calculate relative index
    relIndex := idx - Abs(minRel)
    if (relIndex < minRel)
        relIndex := minRel
    if (relIndex > maxRel)
        relIndex := maxRel

    ; SET (-4): apply new scale
    setPkt := Buffer(0x18)
    NumPut("Int", -4, setPkt, 0)
    NumPut("UInt", 0x18, setPkt, 4)
    NumPut("UInt", adapterLow, setPkt, 8)
    NumPut("Int", adapterHigh, setPkt, 12)
    NumPut("UInt", sourceId, setPkt, 16)
    NumPut("Int", relIndex, setPkt, 20)
    if DllCall("user32\DisplayConfigSetDeviceInfo", "Ptr", setPkt)
        return 0

    ; notify shell and apps
    DllCall("user32\PostMessage", "Ptr", 0xFFFF, "UInt", 0x007E, "Ptr", 0, "Ptr", 0)
    DllCall("user32\PostMessage", "Ptr", 0xFFFF, "UInt", 0x001A, "Ptr", 0, "Ptr", 0)

    return 1
}
