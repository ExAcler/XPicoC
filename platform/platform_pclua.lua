function BasicIOInit(pc)
    pc.CStdOut = {
        puts = function (Str)
            io.write(Str)
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
        io.write(Prompt)
    end

    return io.read()
end

function PlatformReadFile(pc, FileName)
    local InFile

    InFile = io.open(FileName, "r")
    if InFile == nil then
        ProgramFailNoParser(pc, "can't read file %s\n", FileName)
    end

    ReadText = InFile:read("a")
    if string.len(ReadText) == 0 then
        ProgramFailNoParser(pc, "can't read file %s\n", FileName)
    end

    InFile:close()

    if string.sub(ReadText, 1, 1) == '#' and string.sub(ReadText, 2, 2) == '!' then
        local Pos
        Pos, Pos = string.find(ReadText, "\r")
        if Pos == nil then
            Pos = string.len(ReadText)
        end
        ReadText = string.gsub(string.sub(ReadText, 1, Pos - 1), "")
    end

    return ReadText
end

function PicocPlaformScanFile(pc, FileName)
    local SourceStr = PlatformReadFile(pc, FileName)

    if SourceStr ~= nil then
        local Leading = string.sub(SourceStr, 1, 2)
        if Leading == "#!" then
            SourceStr = string.gsub(SourceStr, Leading, "//")
        end
    end

    PicocParse(pc, FileName, SourceStr, string.len(SourceStr), true,
        GEnableDebugger)
end

function PlatformExit(pc, RetVal)
    pc.PicocExitValue = RetVal
    --error("C Parsing Error")
    os.exit(RetVal)
end

function GetSystemCounter()
    return os.clock()
end

function main()
    -- function main
    math.randomseed(os.time())
    a = os.clock()
    t = 0

    ParamCount = 1
    DontRunMain = false
    PicoC = {}
    argc = #arg + 1

    if argc < 2 or arg[ParamCount] == "-h" then
        io.write(PICOC_VERSION .. "  \n" ..
            "Format:\n\n" ..
            "> picoc <file1.c>... [- <arg1>...]     : run a program, calls main() as the entry point\n" ..
            "> picoc -s <file1.c>... [- <arg1>...]  : run a script, runs the program without calling main()\n" ..
            "> picoc -i                             : interactive mode, Ctrl+d to exit\n" ..
            "> picoc -c                             : copyright info\n" ..
            "> picoc -h                             : this help message\n")
        return 0
    end

    if arg[ParamCount] == "-c" then
        return 0
    end

    PicocInitialize(PicoC)

    if arg[ParamCount] == "-s" then
        DontRunMain = true
        --PicocIncludeAllSystemHeaders(PicoC)
        ParamCount = ParamCount + 1
    end

    if argc > ParamCount and arg[ParamCount] == "-i" then
        PicocIncludeAllSystemHeaders(PicoC)
        PicocParseInteractive(PicoC)
    else
        while ParamCount < argc and arg[ParamCount] ~= "-" do
            PicocPlaformScanFile(PicoC, arg[ParamCount])
            ParamCount = ParamCount + 1
        end

        if not DontRunMain then
            ArgV = {}
            for i = ParamCount, argc do
                table.insert(ArgV, arg[i])
            end
            PicocCallMain(PicoC, #ArgV, ArgV)
        end
    end

    print(os.clock() - a)
    print(t)

    PicocCleanup(PicoC)
    return PicoC.PicocExitValue
end

return main()
