function StringBaseMemcpy(DestStr, SourceStr, Length, CheckNullCharacter)
    local SourceOffset = SourceStr.Offset
    local DestOffset = DestStr.Offset

    local SrcPos
    if CheckNullCharacter then
        SrcPos = string.find(SourceStr.RawValue.Val, '\0', SourceOffset + 1)
        if SrcPos == nil then
            SrcPos = SourceOffset + Length
        elseif SrcPos - SourceOffset > Length then
            SrcPos = SourceOffset + Length
        end
    else
        SrcPos = SourceOffset + Length
    end

    local SourceText = string.sub(SourceStr.RawValue.Val, SourceOffset + 1, SrcPos)
    if string.len(SourceText) < Length then
        SourceText = SourceText .. string.rep("\0", Length - string.len(SourceText))
    end

    local DestText = string.sub(DestStr.RawValue.Val, 1, DestOffset) ..
        SourceText .. string.sub(DestStr.RawValue.Val, DestOffset + string.len(SourceText) + 1)
    DestText = string.sub(DestText, 1, string.len(DestStr.RawValue.Val))

    DestStr.RawValue.Val = DestText
end

function StringBaseMemcmp(Str1, Str2, Length, CheckNullCharacter)
    local Offset1 = Str1.Offset
    local Offset2 = Str2.Offset

    for i = 1, Length do
        local c1 = string.sub(Str1.RawValue.Val, Offset1 + i, Offset1 + i)
        local c2 = string.sub(Str2.RawValue.Val, Offset2 + i, Offset2 + i)

        if CheckNullCharacter and (c1 == '\0' or c2 == '\0') then
            break
        elseif c1 == '' or c2 == '' then
            break
        end

        if c1 > c2 then
            return 1
        elseif c1 < c2 then
            return -1
        end
    end

    return 0
end

function StringBaseStrcat(DestStr, SourceStr, Length)
    local SourceOffset = SourceStr.Offset
    local DestOffset = DestStr.Offset

    local ConcatText = string.sub(DestStr.RawValue.Val, DestOffset + 1,
        DestOffset + PointerStringLen(DestStr)) ..
        string.sub(SourceStr.RawValue.Val, SourceOffset + 1,
        SourceOffset + MIN(PointerStringLen(SourceStr), Length)) .. '\0'
    local DestText = string.sub(DestStr.RawValue.Val, 1, DestOffset) .. ConcatText ..
        string.sub(DestStr.RawValue.Val, DestOffset + string.len(ConcatText) + 1)
    DestText = string.sub(DestText, 1, string.len(DestStr.RawValue.Val))

    DestStr.RawValue.Val = DestText
end

function StringBaseStrstr(SourceStr, ValueText, Size, ReverseFind)
    local SourceOffset = SourceStr.Offset

    local FindText = string.sub(SourceStr.RawValue.Val, 1 + SourceOffset, Size + SourceOffset)
    if string.len(FindText) < Size then
        FindText = FindText .. string.rep('\0', Size - string.len(FindText))
    end
    local Pos
    if not ReverseFind then
        Pos = string.find(FindText, ValueText)
    else
        Pos = string.find(string.reverse(FindText), ValueText)
        if Pos then
            Pos = string.len(FindText) - Pos + 1
        end
    end

    return Pos
end

function StringBaseStrspn(Str1, Str2)
    local Text1 = PointerGetString(Str1)
    local Text2 = PointerGetString(Str2)

    local i = 0
    for c1 in string.gmatch(Text1, ".") do
        local Ok = false
        for c2 in string.gmatch(Text2, ".") do
            if c1 == c2 then
                Ok = true
                break
            end
        end
        if not Ok then
            return i
        end
        i = i + 1
    end

    return 0
end

function StringBaseStrcspn(Str1, Str2, NilIfNotFound)
    local Text1 = PointerGetString(Str1)
    local Text2 = PointerGetString(Str2)

    local i = 0
    for c1 in string.gmatch(Text1, ".") do
        for c2 in string.gmatch(Text2, ".") do
            if c1 == c2 then
                return i
            end
        end
        i = i + 1
    end

    if not NilIfNotFound then
        return 0
    else
        return nil
    end
end

-------------------

function StringStrcpy(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local DestStr = PointerDereference(Param[1].Val)
    if DestStr == nil then
        ProgramFail(Parser, "argument 1 of strcpy() must be a string")
    end

    local SourceStr = PointerDereference(Param[2].Val)
    if SourceStr == nil then
        ProgramFail(Parser, "argument 2 of strcpy() must be a string")
    end

    local SourceOffset = SourceStr.Offset
    local DestOffset = DestStr.Offset

    local SrcPos = string.find(SourceStr.RawValue.Val, '\0', SourceOffset + 1)
    local SourceText = string.sub(SourceStr.RawValue.Val, SourceOffset + 1, SrcPos)
    if SrcPos == nil then
        SourceText = SourceText .. "\0"
    end

    local DestText = string.sub(DestStr.RawValue.Val, 1, DestOffset) ..
        SourceText .. string.sub(DestStr.RawValue.Val, DestOffset + string.len(SourceText) + 1)
    DestText = string.sub(DestText, 1, string.len(DestStr.RawValue.Val))

    DestStr.RawValue.Val = DestText
    PointerCopyPointer(ReturnValue.Val, Param[1].Val)
end

function StringStrncpy(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local DestStr = PointerDereference(Param[1].Val)
    if DestStr == nil then
        ProgramFail(Parser, "argument 1 of strncpy() must be a string")
    end

    local SourceStr = PointerDereference(Param[2].Val)
    if SourceStr == nil then
        ProgramFail(Parser, "argument 2 of strncpy() must be a string")
    end

    local Length = PointerGetUnsignedInt(Param[3].Val)

    StringBaseMemcpy(DestStr, SourceStr, Length, true)
    PointerCopyPointer(ReturnValue.Val, Param[1].Val)
end

function StringStrcmp(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local Str1 = PointerDereference(Param[1].Val)
    if Str1 == nil then
        ProgramFail(Parser, "argument 1 of strcmp() must be a string")
    end

    local Str2 = PointerDereference(Param[2].Val)
    if Str2 == nil then
        ProgramFail(Parser, "argument 2 of strcmp() must be a string")
    end

    local Result = StringBaseMemcmp(Str1, Str2, MIN(PointerStringLen(Str1), PointerStringLen(Str2)), true)
    PointerSetSignedOrUnsignedInt(ReturnValue.Val, Result)
end

function StringStrncmp(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local Str1 = PointerDereference(Param[1].Val)
    if Str1 == nil then
        ProgramFail(Parser, "argument 1 of strncmp() must be a string")
    end

    local Str2 = PointerDereference(Param[2].Val)
    if Str2 == nil then
        ProgramFail(Parser, "argument 2 of strncmp() must be a string")
    end

    local Length = PointerGetUnsignedInt(Param[3].Val)

    local Result = StringBaseMemcmp(Str1, Str2, Length, true)
    PointerSetSignedOrUnsignedInt(ReturnValue.Val, Result)
end

function StringStrcat(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local DestStr = PointerDereference(Param[1].Val)
    if DestStr == nil then
        ProgramFail(Parser, "argument 1 of strncat() must be a string")
    end

    local SourceStr = PointerDereference(Param[2].Val)
    if SourceStr == nil then
        ProgramFail(Parser, "argument 2 of strncat() must be a string")
    end

    StringBaseStrcat(DestStr, SourceStr, PointerStringLen(SourceStr))
    PointerCopyPointer(ReturnValue.Val, Param[1].Val)
end

function StringStrncat(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local DestStr = PointerDereference(Param[1].Val)
    if DestStr == nil then
        ProgramFail(Parser, "argument 1 of strncat() must be a string")
    end

    local SourceStr = PointerDereference(Param[2].Val)
    if SourceStr == nil then
        ProgramFail(Parser, "argument 2 of strncat() must be a string")
    end

    local Length = PointerGetUnsignedInt(Param[3].Val)

    StringBaseStrcat(DestStr, SourceStr, Length)
    PointerCopyPointer(ReturnValue.Val, Param[1].Val)
end

function StringStrlen(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local SourceStr = PointerDereference(Param[1].Val)
    if SourceStr == nil then
        ProgramFail(Parser, "argument 1 of strlen() must be a string")
    end

    local Result = PointerStringLen(SourceStr)
    PointerSetSignedOrUnsignedInt(ReturnValue.Val, Result)
end

function StringMemset(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local DestStr = PointerDereference(Param[1].Val)
    if DestStr == nil then
        ProgramFail(Parser, "argument 1 of memset() must be a valid pointer")
    end

    local Value = PointerGetUnsignedChar(Param[2].Val)
    local Size = PointerGetUnsignedInt(Param[3].Val)

    local DestOffset = DestStr.Offset

    local DestText = string.sub(DestStr.RawValue.Val, 1, DestOffset) ..
        string.rep(string.char(Value), Size) ..
        string.sub(DestStr.RawValue.Val, DestOffset + Size + 1)
    DestText = string.sub(DestText, 1, string.len(DestStr.RawValue.Val))

    DestStr.RawValue.Val = DestText
    PointerCopyPointer(ReturnValue.Val, Param[1].Val)
end

function StringMemcpy(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local DestStr = PointerDereference(Param[1].Val)
    if DestStr == nil then
        ProgramFail(Parser, "argument 1 of memcpy() must be a valid pointer")
    end

    local SourceStr = PointerDereference(Param[2].Val)
    if SourceStr == nil then
        ProgramFail(Parser, "argument 2 of memcpy() must be a valid pointer")
    end

    local Length = PointerGetUnsignedInt(Param[3].Val)

    StringBaseMemcpy(DestStr, SourceStr, Length, false)
    PointerCopyPointer(ReturnValue.Val, Param[1].Val)
end

function StringMemcmp(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local Str1 = PointerDereference(Param[1].Val)
    if Str1 == nil then
        ProgramFail(Parser, "argument 1 of memcmp() must be a valid pointer")
    end

    local Str2 = PointerDereference(Param[2].Val)
    if Str2 == nil then
        ProgramFail(Parser, "argument 2 of memcmp() must be a valid pointer")
    end

    local Length = PointerGetUnsignedInt(Param[3].Val)

    local Result = StringBaseMemcmp(Str1, Str2, Length, false)
    PointerSetSignedOrUnsignedInt(ReturnValue.Val, Result)
end

function StringMemmove(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    StringMemcpy(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
end

function StringMemchr(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local SourceStr = PointerDereference(Param[1].Val)
    if SourceStr == nil then
        ProgramFail(Parser, "argument 1 of memchr() must be a valid pointer")
    end

    local Value = PointerGetUnsignedChar(Param[2].Val)
    local Size = PointerGetUnsignedInt(Param[3].Val)

    local Pos = StringBaseStrstr(SourceStr, string.char(Value), Size, false)

    if Pos then
        PointerCopyPointer(ReturnValue.Val, Param[1].Val)
        PointerMovePointer(ReturnValue.Val, Pos - 1)
    else
        PointerSetNull(ReturnValue.Val)
    end
end

function StringStrchr(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local SourceStr = PointerDereference(Param[1].Val)
    if SourceStr == nil then
        ProgramFail(Parser, "argument 1 of strchr() must be a string")
    end

    local Value = PointerGetUnsignedChar(Param[2].Val)

    local Pos = StringBaseStrstr(SourceStr, string.char(Value),
        PointerStringLen(SourceStr) + 1, false)

    if Pos then
        PointerCopyPointer(ReturnValue.Val, Param[1].Val)
        PointerMovePointer(ReturnValue.Val, Pos - 1)
    else
        PointerSetNull(ReturnValue.Val)
    end
end

function StringStrrchr(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local SourceStr = PointerDereference(Param[1].Val)
    if SourceStr == nil then
        ProgramFail(Parser, "argument 1 of strrchr() must be a string")
    end

    local Value = PointerGetUnsignedChar(Param[2].Val)

    local Pos = StringBaseStrstr(SourceStr, string.char(Value),
        PointerStringLen(SourceStr) + 1, true)

    if Pos then
        PointerCopyPointer(ReturnValue.Val, Param[1].Val)
        PointerMovePointer(ReturnValue.Val, Pos - 1)
    else
        PointerSetNull(ReturnValue.Val)
    end
end

function StringStrspn(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local Str1 = PointerDereference(Param[1].Val)
    if Str1 == nil then
        ProgramFail(Parser, "argument 1 of strspn() must be a string")
    end

    local Str2 = PointerDereference(Param[2].Val)
    if Str2 == nil then
        ProgramFail(Parser, "argument 2 of strspn() must be a string")
    end

    local Result = StringBaseStrspn(Str1, Str2)
    PointerSetSignedOrUnsignedInt(ReturnValue.Val, Result)
end

function StringStrcspn(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local Str1 = PointerDereference(Param[1].Val)
    if Str1 == nil then
        ProgramFail(Parser, "argument 1 of strspn() must be a string")
    end

    local Str2 = PointerDereference(Param[2].Val)
    if Str2 == nil then
        ProgramFail(Parser, "argument 2 of strspn() must be a string")
    end

    local Result = StringBaseStrcspn(Str1, Str2, false)
    PointerSetSignedOrUnsignedInt(ReturnValue.Val, Result)
end

function StringStrpbrk(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local Str1 = PointerDereference(Param[1].Val)
    if Str1 == nil then
        ProgramFail(Parser, "argument 1 of strspn() must be a string")
    end

    local Str2 = PointerDereference(Param[2].Val)
    if Str2 == nil then
        ProgramFail(Parser, "argument 2 of strspn() must be a string")
    end

    local Pos = StringBaseStrcspn(Str1, Str2, true)
    if Pos then
        PointerCopyPointer(ReturnValue.Val, Param[1].Val)
        PointerMovePointer(ReturnValue.Val, Pos)
    else
        PointerSetNull(ReturnValue.Val)
    end
end

function StringStrstr(Parser, ReturnValue, Param, NumArgs, ParamStartStackId)
    local SourceStr = PointerDereference(Param[1].Val)
    if SourceStr == nil then
        ProgramFail(Parser, "argument 1 of strstr() must be a string")
    end

    local Value = PointerDereference(Param[2].Val)
    if Value == nil then
        ProgramFail(Parser, "argument 2 of strstr() must be a string")
    end

    local Pos = StringBaseStrstr(SourceStr, PointerGetString(Value),
        PointerStringLen(SourceStr), false)

    if Pos then
        PointerCopyPointer(ReturnValue.Val, Param[1].Val)
        PointerMovePointer(ReturnValue.Val, Pos - 1)
    else
        PointerSetNull(ReturnValue.Val)
    end
end

StringFunctions = {
    {
        Func = StringMemcpy,
        Prototype = "void *memcpy(void *,void *,int);"
    },
    {
        Func = StringMemmove,
        Prototype = "void *memmove(void *,void *,int);"
    },
    {
        Func = StringMemchr,
        Prototype = "void *memchr(char *,int,int);"
    },
    {
        Func = StringMemcmp,
        Prototype = "int memcmp(void *,void *,int);"
    },
    {
        Func = StringMemset,
        Prototype = "void *memset(void *,int,int);"
    },
    {
        Func = StringStrcat,
        Prototype = "char *strcat(char *,char *);"
    },
    {
        Func = StringStrncat,
        Prototype = "char *strncat(char *,char *,int);"
    },
    {
        Func = StringStrchr,
        Prototype = "char *strchr(char *,int);"
    },
    {
        Func = StringStrrchr,
        Prototype = "char *strrchr(char *,int);"
    },
    {
        Func = StringStrcmp,
        Prototype = "int strcmp(char *,char *);"
    },
    {
        Func = StringStrncmp,
        Prototype = "int strncmp(char *,char *,int);"
    },
    {
        Func = StringStrcpy,
        Prototype = "char *strcpy(char *,char *);"
    },
    {
        Func = StringStrncpy,
        Prototype = "char *strncpy(char *,char *,int);"
    },
    {
        Func = StringStrlen, 
        Prototype = "int strlen(char *);"
    },
    {
        Func = StringStrspn,
        Prototype = "int strspn(char *,char *);"
    },
    {
        Func = StringStrcspn,
        Prototype = "int strcspn(char *,char *);"
    },
    {
        Func = StringStrpbrk,
        Prototype = "char *strpbrk(char *,char *);"
    },
    {
        Func = StringStrstr,
        Prototype = "char *strstr(char *,char *);"
    },
    --{
    --    Func = StringStrtok,
    --    Prototype = "char *strtok(char *,char *);"
    --},
    {
        Func = nil,
        Prototype = nil
    }
}

function StringSetupFunc(pc)
    local DummyParser = {}
    DummyParser.pc = pc

    if not VariableDefined(pc, TableStrRegister(pc, "NULL")) then
        local Stdio_ZeroValue = VariableAllocAnyValue(4)
        VariableDefinePlatformVar(pc, DummyParser, "NULL", pc.IntType,
            Stdio_ZeroValue, false);
    end
end
