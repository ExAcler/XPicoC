function StdlibBaseStrToNum(Str)
    local Len = string.len(Str)

    for i = Len, 1, -1 do
        local Span = string.sub(Str, 1, i)
        local Num = tonumber(Span)
        if Num then
            return Num, i
        end
    end

    return 0, 0
end

function StdlibAtof(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local Str = PointerDereference(Param[1].Val)
    if Str == nil then
        ProgramFail(Parser, "argument 1 of atof() must be a string")
    end

    local Val = tonumber(PointerGetString(Str))
    if Val == nil then
        Val = 0
    end

    PointerSetFP(ReturnValue.Val, Val)
end

function StdlibAtoi(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local Str = PointerDereference(Param[1].Val)
    if Str == nil then
        ProgramFail(Parser, "argument 1 of atoi() must be a string")
    end

    local Val = tonumber(PointerGetString(Str))
    if Val == nil then
        Val = 0
    else
        Val = math.floor(Val)
    end

    PointerSetSignedOrUnsignedInt(ReturnValue.Val, Val)
end

function StdlibAtol(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local Str = PointerDereference(Param[1].Val)
    if Str == nil then
        ProgramFail(Parser, "argument 1 of atol() must be a string")
    end

    local Val = tonumber(PointerGetString(Str))
    if Val == nil then
        Val = 0
    else
        Val = math.floor(Val)
    end

    PointerSetSignedOrUnsignedInt(ReturnValue.Val, Val)
end

function StdlibStrtod(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local Str = PointerDereference(Param[1].Val)
    if Str == nil then
        ProgramFail(Parser, "argument 1 of strtod() must be a string")
    end

    local Ptr = PointerDereference(Param[2].Val)

    local Val, Offset = StdlibBaseStrToNum(PointerGetString(Str))
    PointerSetFP(ReturnValue.Val, Val)
    if Ptr then
        PointerCopyPointer(Ptr, Param[1].Val)
        PointerMovePointer(Ptr, Offset)
    end
end

function StdlibStrtol(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local Str = PointerDereference(Param[1].Val)
    if Str == nil then
        ProgramFail(Parser, "argument 1 of strtol() must be a string")
    end

    local Ptr = PointerDereference(Param[2].Val)

    local Val, Offset = StdlibBaseStrToNum(PointerGetString(Str))
    PointerSetSignedOrUnsignedInt(ReturnValue.Val, math.floor(Val))
    if Ptr then
        PointerCopyPointer(Ptr, Param[1].Val)
        PointerMovePointer(Ptr, Offset)
    end
end

function StdlibStrtoul(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    StdlibStrtol(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
end

function StdlibMalloc(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local Length = PointerGetUnsignedInt(Param[1].Val)

    local MemSpace = VariableAllocValueAndData(Parser.pc, Parser, Length, false, nil, true)
    -- Ident > 0x7FFFFFFF for heap value
    MemSpace.Val.Ident = math.random(1, 0x7FFFFFFF) + 0x7FFFFFFF

    PointerReference(ReturnValue.Val, MemSpace.Val)
end

function StdlibCalloc(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local Num = PointerGetUnsignedInt(Param[1].Val)
    local Size = PointerGetUnsignedInt(Param[2].Val)

    local MemSpace = VariableAllocValueAndData(Parser.pc, Parser, Num * Size, false, nil, true)
    MemSpace.Val.Ident = math.random(1, 0x7FFFFFFF) + 0x7FFFFFFF

    PointerReference(ReturnValue.Val, MemSpace.Val)
end

function StdlibRealloc(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local Mem = PointerDereference(Param[1].Val)
    if Mem == nil then
        ProgramFail(Parser, "argument 1 of realloc() must be a valid pointer")
    end

    local Size = PointerGetUnsignedInt(Param[2].Val)

    if Mem.Ident < 0x80000000 then
        ProgramFail(Parser, "invalid pointer: was the memory block created by malloc()?")
    end

    Mem.RawValue.Val = string.rep("\000", Size)
    PointerCopyPointer(ReturnValue.Val, Param[1].Val)
end

function StdlibFree(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local Mem = PointerDereference(Param[1].Val)
    if Mem == nil then
        ProgramFail(Parser, "argument 1 of free() must be a valid pointer")
    end

    if Mem.Ident < 0x80000000 then
        ProgramFail(Parser, "invalid pointer: was the memory block created by malloc()?")
    end

    Mem.RawValue.Val = ""
    PointerCopyPointer(ReturnValue.Val, Param[1].Val)
end

function StdlibRand(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    PointerSetSignedOrUnsignedInt(ReturnValue.Val, math.random(0x7FFFFFFF))
end

function StdlibAbort(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    ProgramFail(Parser, "abort")
end

function StdlibExit(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local RetVal = PointerGetSignedInt(Param[1].Val)

    PlatformExit(Parser.pc, RetVal)
end

function StdlibAbs(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local Value = PointerGetSignedInt(Param[1].Val)

    PointerSetSignedOrUnsignedInt(ReturnValue.Val, math.abs(Value))
end

function StdlibLabs(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    StdlibAbs(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
end

StdlibFunctions = {
    {
        Func = StdlibAtof,
        Prototype = "float atof(char *);"
    },
    {
        Func = StdlibStrtod,
        Prototype = "float strtod(char *,char **);"
    },
    {
        Func = StdlibAtoi,
        Prototype = "int atoi(char *);"
    },
    {
        Func = StdlibAtol,
        Prototype = "int atol(char *);"
    },
    {
        Func = StdlibStrtol,
        Prototype = "int strtol(char *,char **,int);"
    },
    {
        Func = StdlibStrtoul,
        Prototype = "int strtoul(char *,char **,int);"
    },
    {
        Func = StdlibMalloc,
        Prototype = "void *malloc(int);"
    },
    {
        Func = StdlibCalloc,
        Prototype = "void *calloc(int,int);"
    },
    {
        Func = StdlibRealloc,
        Prototype = "void *realloc(void *,int);"
    },
    {
        Func = StdlibFree,
        Prototype = "void free(void *);"
    },
    {
        Func = StdlibRand,
        Prototype = "int rand();"
    },
    --{
    --    Func = StdlibSrand,
    --    Prototype = "void srand(int);"
    --},
    {
        Func = StdlibAbort,
        Prototype = "void abort();"
    },
    {
        Func = StdlibExit,
        Prototype = "void exit(int);"
    },
    {
        Func = StdlibAbs,
        Prototype = "int abs(int);"
    },
    {
        Func = StdlibLabs,
        Prototype = "int labs(int);"
    },
    {
        Func = nil,
        Prototype = nil
    }
}

function StdlibSetupFunc(pc)
    local DummyParser = {}
    DummyParser.pc = pc

    if not VariableDefined(pc, TableStrRegister(pc, "NULL")) then
        local Stdio_ZeroValue = VariableAllocAnyValue(4)
        VariableDefinePlatformVar(pc, DummyParser, "NULL", pc.IntType,
            Stdio_ZeroValue, false);
    end
end
