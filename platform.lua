PICOC_VERSION = "v2.3.2"

GLOBAL_TABLE_SIZE = 97
STRING_TABLE_SIZE = 97
STRING_LITERAL_TABLE_SIZE = 97
RESERVED_WORD_TABLE_SIZE = 97
PARAMETER_MAX = 256
LINEBUFFER_MAX = 256
LOCAL_TABLE_SIZE = 11
STRUCT_TABLE_SIZE = 11

INTERACTIVE_PROMPT_STATEMENT = "picoc> "
INTERACTIVE_PROMPT_LINE = "     > "

INTERACTIVE_HEAD_STATEMENT = [[
Lua-PicoC v2.3.2  Copyright (c) 2009-2020 Jimmy Lin, Zik Saleeba, Joseph Poirier
]]

function PicocInitialize(pc, NoIOInit)
    pc.GlobalTable = {}
    pc.GlobalHashTable = {}
    pc.LexUseStatementPrompt = false
    pc.ReservedWordTable = {}
    pc.ReservedWordHashTable = {}
    pc.StringLiteralTable = {}
    pc.StringLiteralHashTable = {}
    pc.PicocExitValue = 0
    pc.UberType = {
        Base = 0,
        ArraySize = 0,
        Sizeof = 0,
        AlignBytes = 0,
        OnHeap = false,
        StaticQualifier = false
    }
    pc.IntType = {}
    pc.ShortType = {}
    pc.CharType = {}
    pc.LongType = {}
    pc.UnsignedIntType = {}
    pc.UnsignedShortType = {}
    pc.UnsignedLongType = {}
    pc.UnsignedCharType = {}
    pc.FPType = {}
    pc.VoidType = {}
    pc.TypeType = {}
    pc.FunctionType = {}
    pc.MacroType = {}
    pc.EnumType = {}
    pc.GotoLabelType = {}
    pc.BreakpointTable = {}
    pc.BreakpointHashTable = {}
    pc.BreakpointCount = 0
    pc.DebugManualBreak = false
    pc.BigEndian = false
    pc.LittleEndian = false
    pc.StringTable = {}
    pc.StringHashTable = {}
    pc.StructTempName = "^s0000"
    pc.EnumTempName = "^e0000"
    PlatformInit(pc)
    BasicIOInit(pc, NoIOInit)
    HeapInit(pc)
    TableInit(pc)
    VariableInit(pc)
    LexInit(pc)
    TypeInit(pc)
    IncludeInit(pc)
    LibraryInit(pc)

    --DebugInit(pc)
end

function PicocCleanup(pc)
    --DebugCleanup(pc)

    IncludeCleanup(pc)
    ParseCleanup(pc)
    LexCleanup(pc)
    VariableCleanup(pc)
    TypeCleanup(pc)
    TableStrFree(pc)
    HeapCleanup(pc)
    PlatformCleanup(pc)
end

CALL_MAIN_NO_ARGS_RETURN_VOID = "main();"
CALL_MAIN_WITH_ARGS_RETURN_VOID = "main(__argc,__argv)"
CALL_MAIN_NO_ARGS_RETURN_INT = "__exit_value = main();"
CALL_MAIN_WITH_ARGS_RETURN_INT = "__exit_value = main(__argc,__argv);"

function PicocCallMain(pc, argc, argv)
    local FuncValue

    if not VariableDefined(pc, TableStrRegister(pc, "main")) then
        ProgramFailNoParser(pc, "main() is not defined")
    end

    FuncValue = VariableGet(pc, nil, TableStrRegister(pc, "main"))
    if FuncValue.Typ.Base ~= BaseType.TypeFunction then
        ProgramFailNoParser(pc, "main is not a function - can't call it")
    end

    if FuncValue.Val.FuncDef.NumParams ~= 0 then
        local ArgcValue = VariableAllocAnyValue(4)
        PointerSetSignedOrUnsignedInt(ArgcValue, argc)
        VariableDefinePlatformVar(pc, nil, "__argc", pc.IntType,
            ArgcValue, false)

        local ArgvArrayValue = VariableAllocAnyValue(4 * #argv)
        for _, v in ipairs(argv) do
            local Arg = tostring(v)
            local Len = string.len(Arg)
            local ArgNValue = VariableAllocAnyValue(Len)
            ArgNValue.RawValue.Val = Arg

            PointerReference(ArgvArrayValue, ArgNValue)
            ArgvArrayValue.Offset = ArgvArrayValue.Offset + 4
        end
        ArgvArrayValue.Offset = 0

        VariableDefinePlatformVar(pc, nil, "__argv", pc.CharPtrPtrType,
            ArgvArrayValue, false)
    end

    if FuncValue.Val.FuncDef.ReturnType == pc.VoidType then
        if FuncValue.Val.FuncDef.NumParams == 0 then
            PicocParse(pc, "startup", CALL_MAIN_NO_ARGS_RETURN_VOID,
                string.len(CALL_MAIN_NO_ARGS_RETURN_VOID), true,
                GEnableDebugger)
        else
            PicocParse(pc, "startup", CALL_MAIN_WITH_ARGS_RETURN_VOID,
                string.len(CALL_MAIN_WITH_ARGS_RETURN_VOID), true,
                GEnableDebugger)
        end
    else
        local ExitValue = VariableAllocAnyValue(4)
        PointerSetSignedOrUnsignedInt(ExitValue, pc.PicocExitValue)
        VariableDefinePlatformVar(pc, nil, "__exit_value", pc.IntType,
            ExitValue, true)

        if FuncValue.Val.FuncDef.NumParams == 0 then
            PicocParse(pc, "startup", CALL_MAIN_NO_ARGS_RETURN_INT,
                string.len(CALL_MAIN_NO_ARGS_RETURN_INT), true,
                GEnableDebugger)
        else
            PicocParse(pc, "startup", CALL_MAIN_WITH_ARGS_RETURN_INT,
                string.len(CALL_MAIN_WITH_ARGS_RETURN_INT), true,
                GEnableDebugger)
        end
    end
end

function PrintSourceTextErrorLine(Stream, FileName, SourceText, Line, CharacterPos)
    local LineCount
    local CCount
    local LinePos
    local CPos

    if SourceText ~= nil then
        LinePos = 1
        LineCount = 1
        local GotChar = string.sub(SourceText, LinePos, LinePos)
        while GotChar ~= "" and LineCount < Line do
            if GotChar == '\n' then
                LineCount = LineCount + 1
            end
            LinePos = LinePos + 1
            GotChar = string.sub(SourceText, LinePos, LinePos)
        end

        CPos = LinePos
        GotChar = string.sub(SourceText, CPos, CPos)
        while GotChar ~= "\n" and GotChar ~= "" do
            PrintCh(GotChar, Stream)
            CPos = CPos + 1
            GotChar = string.sub(SourceText, CPos, CPos)
        end
        PrintCh("\n", Stream)

        CPos = LinePos
        GotChar = string.sub(SourceText, CPos, CPos)
        CCount = 0
        while (GotChar ~= '\n' and GotChar ~= "" and
            (CCount < CharacterPos or CPos == ' ')) do
            if GotChar == '\t' then
                PrintCh('\t', Stream)
            else
                PrintCh(' ', Stream)
            end

            CPos = CPos + 1
            CCount = CCount + 1
        end
    else
        for CC = 0, CharacterPos + string.len(INTERACTIVE_PROMPT_STATEMENT) do
            PrintCh(' ', Stream)
        end
    end
    PlatformPrintf(Stream, "^\n%s:%d:%d ", FileName.RawValue.Val, Line, CharacterPos)
end

function ProgramFail(Parser, Message, ...)
    local arg = {...}
    if Parser.SourceText then
        PrintSourceTextErrorLine(Parser.pc.CStdOut, Parser.FileName,
            Parser.SourceText, Parser.Line, Parser.CharacterPos)
    else
        ProgramFailNoParser(Parser.pc, Message, ...)
        return
    end
    PlatformVPrintf(Parser.pc.CStdOut, Message, arg)
    PlatformPrintf(Parser.pc.CStdOut, "\n")
    PlatformExit(Parser.pc, 1)
end

function ProgramFailNoParser(pc, Message, ...)
    local arg = {...}
    PlatformVPrintf(pc.CStdOut, Message, arg)
    PlatformPrintf(pc.CStdOut, "\n")
    PlatformExit(pc, 1)
end

function AssignFail(Parser, Format, Type1, Type2, Num1, Num2, FuncName, ParamNo)
    Stream = Parser.pc.CStdOut

    PrintSourceTextErrorLine(Parser.pc.CStdOut, Parser.FileName,
        Parser.SourceText, Parser.Line, Parser.CharacterPos)
    if FuncName == nil then
        PlatformPrintf(Stream, "can't %s ", "assign")
    else
        PlatformPrintf(Stream, "can't %s ", "set")
    end

    if Type1 ~= nil then
        PlatformPrintf(Stream, Format, Type1, Type2)
    else
        PlatformPrintf(Stream, Format, Num1, Num2)
    end

    if FuncName ~= nil then
        PlatformPrintf(Stream, " in argument %d of call to %s()", ParamNo,
            FuncName.RawValue.Val)
    end

    PlatformPrintf(Stream, "\n")
    PlatformExit(Parser.pc, 1)
end

function LexFail(pc, Lexer, Message, ...)
    local arg = {...}
    PrintSourceTextErrorLine(pc.CStdOut, Lexer.FileName,
        Lexer.SourceText, Lexer.Line, Lexer.CharacterPos)
    PlatformVPrintf(pc.CStdOut, Message, arg)
    PlatformPrintf(pc.CStdOut, "\n")
    PlatformExit(pc, 1)
end

function PlatformPrintf(Stream, Format, ...)
    local arg = {...}
    PlatformVPrintf(Stream, Format, arg)
end

function PlatformVPrintf(Stream, Format, Args)
    local FPos = 1
    local ArgPos = 1
    local GotChar = string.sub(Format, FPos, FPos)
    local Arg

    while GotChar ~= "" do
        if GotChar == '%' then
            FPos = FPos + 1
            GotChar = string.sub(Format, FPos, FPos)
            Arg = Args[ArgPos]
            if Arg ~= nil then
                if GotChar == 's' then
                    PrintStr(Args[ArgPos], Stream)
                    ArgPos = ArgPos + 1
                elseif GotChar == 'd' then
                    PrintSimpleInt(Args[ArgPos], Stream)
                    ArgPos = ArgPos + 1
                elseif GotChar == 'c' then
                    PrintCh(Args[ArgPos], Stream)
                    ArgPos = ArgPos + 1
                elseif GotChar == 't' then
                    PrintType(Args[ArgPos], Stream)
                    ArgPos = ArgPos + 1
                elseif GotChar == 'f' then
                    PrintFP(Args[ArgPos], Stream)
                    ArgPos = ArgPos + 1
                elseif GotChar == '%' then
                    PrintCh(Args[ArgPos], Stream)
                elseif GotChar == '' then
                    FPos = FPos - 1
                end
            end
        else
            PrintCh(GotChar, Stream)
        end

        FPos = FPos + 1
        GotChar = string.sub(Format, FPos, FPos)
    end
end

function PlatformMakeTempName(pc, IsStruct)
    local CPos = 6
    local TempNameBuffer

    if IsStruct then
        TempNameBuffer = pc.StructTempName
    else
        TempNameBuffer = pc.EnumTempName
    end

    while CPos > 2 do
        if string.sub(TempNameBuffer, CPos, CPos) < '9' then
            TempNameBuffer = string.sub(TempNameBuffer, 1, CPos - 1) ..
                string.char(string.byte(string.sub(TempNameBuffer, CPos, CPos)) + 1) ..
                string.sub(TempNameBuffer, CPos + 1)

            if IsStruct then
                pc.StructTempName = TempNameBuffer
            else
                pc.EnumTempName = TempNameBuffer
            end

            return TableStrRegister(pc, TempNameBuffer)
        else
            TempNameBuffer = string.sub(TempNameBuffer, 1, CPos - 1) ..
                "0" .. string.sub(TempNameBuffer, CPos + 1)
            CPos = CPos - 1
        end
    end

    return TableStrRegister(pc, TempNameBuffer)
end
