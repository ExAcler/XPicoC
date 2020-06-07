MAX_FORMAT = 80

function StdioOutPutc(OutCh, Stream)
    if Stream.FilePtr ~= nil then
        Stream.FilePtr.puts(OutCh)
        Stream.CharCount = Stream.CharCount + 1
    else
        -- Output to string to be implemented
    end
end

function StdioOutPuts(Str, Stream)
    if Stream.FilePtr ~= nil then
        Stream.FilePtr.puts(Str)
    else

    end
end

function StdioFprintfValue(Stream, Format, Value)
    if Stream.FilePtr ~= nil then
        local Str = string.format(Format, Value)
        Stream.FilePtr.puts(Str)
        Stream.CharCount = Stream.CharCount + string.len(Str)
    else

    end
end

function GET_FCHAR(Format, FPos)
    return string.sub(Format, FPos, FPos)
end

function StdioBasePrintf(Parser, Stream, StrOut, StrOutLen, Format, Args)
    local ArgCount = 0
    local ArgPos = Args.ParamStartStackId
    local FPos
    local OneFormatBuf = ""
    local OneFormatCount
    local ShowLong = false
    local ShowType
    local SOStream = {}
    local pc = Parser.pc
    local ThisArg = HeapGetStackNode(pc, ArgPos)

    if Format == nil then
        Format = "[null format]\n"
    end

    FPos = 1
    SOStream.FilePtr = Stream
    SOStream.StrOutPtr = StrOut
    SOStream.StrOutLen = StrOutLen
    SOStream.CharCount = 0

    while GET_FCHAR(Format, FPos) ~= '\0' and GET_FCHAR(Format, FPos) ~= '' do
        if GET_FCHAR(Format, FPos) == '%' then
            FPos = FPos + 1
            ShowType = nil
            OneFormatBuf = "%"
            OneFormatCount = 1

            repeat
                if GET_FCHAR(Format, FPos) == 'd' or GET_FCHAR(Format, FPos) == 'i' then
                    if ShowLong then
                        ShowLong = false
                        ShowType = pc.LongType
                    else
                        ShowType = pc.IntType
                    end
                elseif GET_FCHAR(Format, FPos) == 'u' then
                    if ShowLong then
                        ShowLong = 0
                        ShowType = pc.UnsignedLongType
                    end
                elseif GET_FCHAR(Format, FPos) == 'o' or GET_FCHAR(Format, FPos) == 'x' or
                    GET_FCHAR(Format, FPos) == 'X' then
                    ShowType = pc.IntType
                elseif GET_FCHAR(Format, FPos) == 'l' then
                    ShowLong = true
                elseif GET_FCHAR(Format, FPos) == 'e' or GET_FCHAR(Format, FPos) == 'E' then
                    ShowType = pc.FPType
                elseif GET_FCHAR(Format, FPos) == 'f' or GET_FCHAR(Format, FPos) == 'F' then
                    ShowType = pc.FPType
                elseif GET_FCHAR(Format, FPos) == 'g' or GET_FCHAR(Format, FPos) == 'G' then
                    ShowType = pc.FPType
                elseif GET_FCHAR(Format, FPos) == 'a' or GET_FCHAR(Format, FPos) == 'A' then
                    ShowType = pc.IntType
                elseif GET_FCHAR(Format, FPos) == 'c' then
                    ShowType = pc.IntType
                elseif GET_FCHAR(Format, FPos) == 's' then
                    ShowType = pc.CharPtrType
                elseif GET_FCHAR(Format, FPos) == 'p' then
                    ShowType = pc.VoidPtrType
                elseif GET_FCHAR(Format, FPos) == 'n' then
                    ShowType = pc.VoidType
                elseif GET_FCHAR(Format, FPos) == 'm' then
                    ShowType = pc.VoidType
                elseif GET_FCHAR(Format, FPos) == '%' then
                    ShowType = pc.VoidType
                elseif GET_FCHAR(Format, FPos) == '\0' or GET_FCHAR(Format, FPos) == '' then
                    ShowType = pc.VoidType
                end

                if GET_FCHAR(Format, FPos) ~= 'l' then
                    OneFormatBuf = OneFormatBuf .. GET_FCHAR(Format, FPos)
                    OneFormatCount = OneFormatCount + 1
                end

                if ShowType == pc.VoidType then
                    if GET_FCHAR(Format, FPos) == 'm' then
                        -- Not supported, ignored
                    elseif GET_FCHAR(Format, FPos) == '%' then
                        StdioOutPutc(GET_FCHAR(Format, FPos), SOStream)
                    elseif GET_FCHAR(Format, FPos) == '\0' then
                        StdioOutPutc(GET_FCHAR(Format, FPos), SOStream)
                    elseif GET_FCHAR(Format, FPos) == 'n' then
                        ArgPos = ArgPos + 1
                    end
                end

                FPos = FPos + 1
            until ShowType ~= nil or OneFormatCount >= MAX_FORMAT

            if ShowType ~= pc.VoidType then
                if ArgCount >= Args.NumArgs then
                    StdioOutPuts("XXX", SOStream)
                else
                    ArgPos = ArgPos + 1
                    ThisArg = HeapGetStackNode(pc, ArgPos)

                    if ShowType == pc.LongType then
                        if IS_NUMERIC_COERCIBLE(ThisArg) then
                            StdioFprintfValue(SOStream, OneFormatBuf, PointerGetSignedInt(ThisArg.Val))
                        else
                            StdioOutPuts("XXX", SOStream)
                        end
                    elseif ShowType == pc.UnsignedLongType then
                        if IS_NUMERIC_COERCIBLE(ThisArg) then
                            StdioFprintfValue(SOStream, OneFormatBuf, PointerGetUnsignedInt(ThisArg.Val))
                        else
                            StdioOutPuts("XXX", SOStream)
                        end
                    elseif ShowType == pc.IntType then
                        if IS_NUMERIC_COERCIBLE(ThisArg) then
                            StdioFprintfValue(SOStream, OneFormatBuf, ExpressionCoerceInteger(ThisArg))
                        else
                            StdioOutPuts("XXX", SOStream)
                        end
                    elseif ShowType == pc.FPType then
                        if IS_NUMERIC_COERCIBLE(ThisArg) then
                            if IS_NUMERIC_COERCIBLE(ThisArg) then
                                StdioFprintfValue(SOStream, OneFormatBuf, ExpressionCoerceFP(ThisArg))
                            else
                                StdioOutPuts("XXX", SOStream)
                            end
                        end
                    elseif ShowType == pc.CharPtrType then
                        if ThisArg.Typ.Base == BaseType.TypePointer then
                            local NewValue = PointerDereference(ThisArg.Val)
                            if NewValue == nil then
                                ProgramFail(Parser, "string expected")
                            end
                            StdioFprintfValue(SOStream, OneFormatBuf, PointerGetString(NewValue))
                        elseif ThisArg.Typ.Base == BaseType.TypeArray and
                            ThisArg.Typ.FromType.Base == BaseType.TypeChar then
                            StdioFprintfValue(SOStream, OneFormatBuf, PointerGetString(ThisArg.Val))
                        else
                            StdioOutPuts("XXX", SOStream)
                        end
                    elseif ShowType == pc.VoidPtrType then
                        -- No absolute addressing!
                        OneFormatBuf = string.gsub(OneFormatBuf, "%p", "%s")
                        if ThisArg.Typ.Base == BaseType.TypePointer then
                            StdioFprintfValue(SOStream, OneFormatBuf, "0xcccccccc")
                        elseif ThisArg.Typ.Base == BaseType.TypeArray then
                            StdioFprintfValue(SOStream, OneFormatBuf, "0xcccccccc")
                        else
                            StdioOutPuts("XXX", SOStream)
                        end
                    end

                    ArgCount = ArgCount + 1
                end
            end
        else
            StdioOutPutc(GET_FCHAR(Format, FPos), SOStream)
            FPos = FPos + 1
        end
    end

    return SOStream.CharCount
end

function StdioPrintf(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local PrintfArgs = {}

    PrintfArgs.Param = Param
    PrintfArgs.NumArgs = NumArgs - 1
    PrintfArgs.ParamStartStackId = ParamStartStackId

    local NewValue = PointerDereference(Param[1].Val)
    if NewValue == nil then
        ProgramFail(Parser, "parameter 1 of printf() must be a string")
    end

    local Result
    Result = StdioBasePrintf(Parser, Parser.pc.CStdOut, nil, 0,
        PointerGetString(NewValue), PrintfArgs)
    PointerSetSignedOrUnsignedInt(ReturnValue.Val, Result)
end

StdioDefs = "\
typedef struct __va_listStruct va_list; \
typedef struct __FILEStruct FILE; \
"

StdioFunctions = {
    {
        Func = StdioPrintf,
        Prototype = "int printf(char *, ...);"
    },
    {
        Func = nil,
        Prototype = nil
    }
}

function StdioSetupFunc(pc)
    local StructFileType, FilePtrType
    local DummyParser = {}

    DummyParser.pc = pc

    StructFileType = TypeCreateOpaqueStruct(pc, DummyParser,
        TableStrRegister(pc, "__FILEStruct"), 216)

    FilePtrType = TypeGetMatching(pc, DummyParser, StructFileType, BaseType.TypePointer, 0,
        pc.StrEmpty, true)

    TypeCreateOpaqueStruct(pc, DummyParser, TableStrRegister(pc, "__va_listStruct"), 12)

    if not VariableDefined(pc, TableStrRegister(pc, "NULL")) then
        local Stdio_ZeroValue = VariableAllocAnyValue(4)
        VariableDefinePlatformVar(pc, DummyParser, "NULL", pc.IntType,
            Stdio_ZeroValue, false);
    end

    -- To be implemented
end
