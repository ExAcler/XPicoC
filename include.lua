function IncludeInit(pc)
    IncludeRegister(pc, "math.h", nil, MathFunctions, nil)
    IncludeRegister(pc, "stdio.h", StdioSetupFunc, StdioFunctions, StdioDefs)
    IncludeRegister(pc, "stdlib.h", StdlibSetupFunc, StdlibFunctions, nil)
    IncludeRegister(pc, "string.h", StringSetupFunc, StringFunctions, nil)
    
    IncludeRegister(pc, "console.h", nil, ConsoleFunctions, nil)
end

function IncludeCleanup(pc)
    local ThisInclude = pc.IncludeLibList

    while ThisInclude ~= nil do
        ThisInclude = ThisInclude.NextLib
    end

    pc.IncludeLibList = nil
    collectgarbage()
end

function IncludeRegister(pc, IncludeName, SetupFunction, FuncList, SetupCSource)
    NewLib = {}
    NewLib.IncludeName = TableStrRegister(pc, IncludeName)
    NewLib.SetupFunction = SetupFunction
    NewLib.FuncList = FuncList
    NewLib.SetupCSource = SetupCSource
    NewLib.NextLib = pc.IncludeLibList
    pc.IncludeLibList = NewLib
end

function PicocIncludeAllSystemHeaders(pc)
    local ThisInclude = pc.IncludeLibList

    while ThisInclude ~= nil do
        IncludeFile(pc, ThisInclude.IncludeName)
        ThisInclude = ThisInclude.NextLib
    end
end

function IncludeFile(pc, FileName)
    local LInclude = pc.IncludeLibList

    while LInclude ~= nil do
        if LInclude.IncludeName.RawValue.Val == FileName.RawValue.Val then
            if not VariableDefined(pc, FileName) then
                VariableDefine(pc, nil, FileName, nil, pc.VoidType, false)

                if LInclude.SetupFunction ~= nil then
                    LInclude.SetupFunction(pc)
                end

                if LInclude.SetupCSource ~= nil then
                    PicocParse(pc, FileName.RawValue.Val, LInclude.SetupCSource,
                        string.len(LInclude.SetupCSource), true, false)
                end

                if LInclude.FuncList ~= nil then
                    LibraryAdd(pc, LInclude.FuncList)
                end
            end

            return
        end
        LInclude = LInclude.NextLib
    end

    PicocPlaformScanFile(pc, FileName.RawValue.Val)
end
