function on.construction()
    toolpalette.enablePaste(true)
    toolpalette.register({
        {"Run", 
            {"Run code from clipboard", RunCodeClipboard}
        }
    })

    main()
end

function RunCodeClipboard()
    if not StdInStarted then
        return
    end

    local EvalStr = "runfile(\"clipboard\", 1);"
    StdInBuffer.Str = StdInBuffer.Str .. EvalStr
    BasicIOEvalInLines()
    StdInCursorPos = StdInCursorPos + string.len(EvalStr)

    on.enterKey()
    platform.window:invalidate()
end

function on.paste()
    RunCodeClipboard()
end

function on.charIn(char)
    if not StdInStarted then
        return
    end

    if string.len(StdInBuffer.Str) < 255 then
        StdInBuffer.Str = string.sub(StdInBuffer.Str, 1, StdInCursorPos) ..
            char .. string.sub(StdInBuffer.Str, StdInCursorPos + 1)
        BasicIOEvalInLines()
        StdInCursorPos = StdInCursorPos + 1
        platform.window:invalidate()
    end
end

function on.arrowKey(key)
    if not StdInStarted then
        return
    end

    if key == "left" then
        if StdInCursorPos > 0 then
            StdInCursorPos = StdInCursorPos - 1
            platform.window:invalidate()
        end
    elseif key == "right" then
        if StdInCursorPos < string.len(StdInBuffer.Str) then
            StdInCursorPos = StdInCursorPos + 1
            platform.window:invalidate()
        end
    elseif key == "up" then
        if StdInBrowsingHistoryPos > 1 then
            StdInBrowsingHistoryPos = StdInBrowsingHistoryPos - 1
            StdInBuffer.Str = BasicIOGetHistory(StdInBrowsingHistoryPos)
            BasicIOEvalInLines()
            StdInCursorPos = string.len(StdInBuffer.Str)
            platform.window:invalidate()
        end
    elseif key == "down" then
        if StdInBrowsingHistoryPos <= #StdInHistory then
            StdInBrowsingHistoryPos = StdInBrowsingHistoryPos + 1
            StdInBuffer.Str = BasicIOGetHistory(StdInBrowsingHistoryPos)
            BasicIOEvalInLines()
            StdInCursorPos = string.len(StdInBuffer.Str)
            platform.window:invalidate()
        end
    end
end

function on.enterKey()
    if not StdInStarted then
        return
    end

    StdInStarted = false
    coroutine.resume(Interactive)
end

function on.backspaceKey()
    if not StdInStarted then
        return
    end

    if string.len(StdInBuffer.Str) > 0 and StdInCursorPos > 0 then
        StdInBuffer.Str = string.sub(StdInBuffer.Str, 1, StdInCursorPos - 1) ..
            string.sub(StdInBuffer.Str, StdInCursorPos + 1)
        BasicIOEvalInLines()
        StdInCursorPos = StdInCursorPos - 1
        platform.window:invalidate()
    end
end

function on.paint(gc)
    gc:setFont("serif", "r", 10)

    local n = StdInBuffer.Lines - 1
    local Lines
    local StartPos = #StdOutBuffer

    while StartPos >= 1 do
        n = n + StdOutBuffer[StartPos].Lines
        StartPos = StartPos - 1
        if n >= 11 then
            break
        end
    end
    StartPos = StartPos + 1
    if n > 11 then
        Lines = n - 10
    else
        Lines = 1
    end

    local Xoff = 0
    local Yoff = 0

    local Line1Str = string.sub(StdOutBuffer[StartPos].Str, 38 * (Lines - 1) + 1)
    for c in string.gmatch(Line1Str, ".") do
        gc:drawString(c, 5 + Xoff, 5 + Yoff)
        Xoff = Xoff + 8
        if Xoff > 310 then
            Xoff = 0
            Yoff = Yoff + 18
        end
    end

    Yoff = Yoff + 18
    Xoff = 0
    for i = StartPos + 1, #StdOutBuffer do
        for c in string.gmatch(StdOutBuffer[i].Str, ".") do
            gc:drawString(c, 5 + Xoff, 5 + Yoff)
            Xoff = Xoff + 8
            if Xoff > 310 then
                Xoff = 0
                Yoff = Yoff + 18
            end
        end
        if i < #StdOutBuffer then
            Yoff = Yoff + 18
            Xoff = 0
        end
    end

    if StdInStarted then
        local BaseYOff = Yoff

        for c in string.gmatch(StdInBuffer.Str, ".") do
            gc:drawString(c, 5 + Xoff, 5 + Yoff)
            Xoff = Xoff + 8
            if Xoff > 310 then
                Xoff = 0
                Yoff = Yoff + 18
            end
        end

        local CursorLine = math.floor((StdOutBottomLineCharEnd + StdInCursorPos) / 39)
        local CursorLoc = StdOutBottomLineCharEnd + StdInCursorPos - 39 * CursorLine
        if CursorLine < 0 then
            CursorLine = 1
            CursorLoc = 0
        end

        gc:drawLine(5 + 8 * CursorLoc + 1, BaseYOff + 18 + 18 * CursorLine,
            5 + 8 * CursorLoc + 6, BaseYOff + 18 + 18 * CursorLine)
        gc:drawLine(5 + 8 * CursorLoc + 1, BaseYOff + 19 + 18 * CursorLine,
            5 + 8 * CursorLoc + 6, BaseYOff + 19 + 18 * CursorLine)
    end
end

function IOAppendStdOutItem(StdOutItem, Str)
    StdOutItem.Str = StdOutItem.Str .. Str
    if string.len(StdOutItem.Str) == 0 then
        StdOutItem.Lines = 1
        StdOutBottomLineCharEnd = 0
    else
        StdOutItem.Lines = math.floor(string.len(StdOutItem.Str) / 39) + 1
        StdOutBottomLineCharEnd = string.len(StdOutItem.Str) % 39
    end
end

function BasicIOEvalInLines()
    if StdOutBottomLineCharEnd + string.len(StdInBuffer.Str) == 0 then
        StdInBuffer.Lines = 1
    else
        StdInBuffer.Lines = math.floor((StdOutBottomLineCharEnd + string.len(StdInBuffer.Str)) / 39) + 1
    end
end

function BasicIOGetHistory(Pos)
    if Pos > #StdInHistory then
        return ""
    else
        return StdInHistory[Pos]
    end
end

function BasicIOAddHistory(Str)
    table.insert(StdInHistory, Str)
    if #StdInHistory > 50 then
        table.remove(StdInHistory, 1)
    end
    StdInBrowsingHistoryPos = #StdInHistory + 1
end

function BasicIOGets()
    StdInStarted = true
    coroutine.yield()

    local StdInStr = StdInBuffer.Str
    BasicIOAddHistory(StdInStr)

    BasicIOPuts(StdInStr .. "\n")
    StdInBuffer.Str = ""
    StdInBuffer.Lines = 1
    StdInCursorPos = 0
    platform.window:invalidate()
    return StdInStr
end

function BasicIOPuts(Str)
    local FirstVisit = true

    for Line in string.gmatch(Str, "[^\r\n]+") do
        if FirstVisit then
            IOAppendStdOutItem(StdOutBuffer[#StdOutBuffer], Line)
            FirstVisit = false
        else
            local StdOutItem = {
                Str = "",
                Lines = 1
            }
            IOAppendStdOutItem(StdOutItem, Line)
            table.insert(StdOutBuffer, StdOutItem)
        end

        if #StdOutBuffer > 100 then
            table.remove(StdOutBuffer, 1)
        end
    end

    if string.sub(Str, -1) == "\n" or string.sub(Str, -1) == "\r" then
        local StdOutItem = {
            Str = "",
            Lines = 1
        }
        table.insert(StdOutBuffer, StdOutItem)
        if #StdOutBuffer > 100 then
            table.remove(StdOutBuffer, 1)
        end
    end
end

function BasicIOInit(pc, NoIOInit)
    if not NoIOInit then
        StdInBuffer = {
            Str = "",
            Lines = 1
        }
        StdInStarted = false
        StdInCursorPos = 0
        StdInHistory = {}
        StdInBrowsingHistoryPos = 1

        StdOutBuffer = {
            {
                Str = "",
                Lines = 1
            }
        }
        StdOutBottomLineCharEnd = 0
    end

    pc.CStdOut = {
        puts = function (Str)
            BasicIOPuts(Str)
        end
    }
end

function PlatformInit(pc)
    -- Empty function
end

function PlatformCleanup(pc)
    -- Empty function
end

function PlatformGetLine(MaxLen, Prompt)
    if Prompt ~= nil then
        BasicIOPuts(Prompt)
    end
    return BasicIOGets()
end

function PicocPlaformScanFile(pc, FileName)
    local SourceStr = clipboard.getText()

    if SourceStr ~= nil then
        local Leading = string.sub(SourceStr, 1, 2)
        if Leading == "#!" then
            SourceStr = string.gsub(SourceStr, Leading, "//")
        end

        local PCParse = coroutine.create(function()
            PicocParse(pc, FileName, SourceStr, string.len(SourceStr), true,
                GEnableDebugger)
        end)
        local Success, Err = coroutine.resume(PCParse)
        if Success then
            return true
        else
            if string.find(Err, "C Parsing Error") ~= nil then
                return false
            else
                error(Err)
            end
        end
    else
        return false
    end
end

function PlatformExit(pc, RetVal)
    pc.PicocExitValue = RetVal
    error("C Parsing Error")
end

function GetSystemCounter()
    return timer.getMilliSecCounter()
end

function main()
    math.randomseed(timer.getMilliSecCounter())

    local DontRunMain = false
    local PicoC = {}

    PicocInitialize(PicoC)

    PicocIncludeAllSystemHeaders(PicoC)
    Interactive = coroutine.create(function()
        PicocParseInteractive(PicoC)
    end)
    coroutine.resume(Interactive)
end
