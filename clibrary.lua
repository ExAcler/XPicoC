function LibraryInit(pc)
    pc.VersionString = TableStrRegister(pc, PICOC_VERSION)
    VariableDefinePlatformVar(pc, nil, "PICOC_VERSION", pc.CharPtrType,
        pc.VersionString, false)
end

function LibraryAdd(pc, FuncList)
    local Parser = {}
    local Count = 1
    local Identifier
    local ReturnType
    local NewValue
    local Tokens
    local IntrinsicName = TableStrRegister(pc, "c library")

    while FuncList[Count].Prototype ~= nil do
        Tokens, _ = LexAnalyse(pc, IntrinsicName, FuncList[Count].Prototype,
            string.len(FuncList[Count].Prototype))
        LexInitParser(Parser, pc, FuncList[Count].Prototype, Tokens,
            IntrinsicName, true, false)
        ReturnType, Identifier, _ = TypeParse(Parser)
        NewValue = ParseFunctionDefinition(Parser, ReturnType, Identifier)
        NewValue.Val.FuncDef.Intrinsic = FuncList[Count].Func
        Count = Count + 1
    end
end

function PrintType(Typ, Stream)
    if Typ.Base == BaseType.TypeVoid then
        PrintStr("void", Stream)
    elseif Typ.Base == BaseType.TypeInt then
        PrintStr("int", Stream)
    elseif Typ.Base == BaseType.TypeShort then
        PrintStr("short", Stream)
    elseif Typ.Base == BaseType.TypeChar then
        PrintStr("char", Stream)
    elseif Typ.Base == BaseType.TypeLong then
        PrintStr("long", Stream)
    elseif Typ.Base == BaseType.TypeUnsignedInt then
        PrintStr("unsigned int", Stream)
    elseif Typ.Base == BaseType.TypeUnsignedShort then
        PrintStr("unsigned short", Stream)
    elseif Typ.Base == BaseType.TypeUnsignedLong then
        PrintStr("unsigned long", Stream)
    elseif Typ.Base == BaseType.TypeUnsignedChar then
        PrintStr("unsigned char", Stream)
    elseif Typ.Base == BaseType.TypeFP then
        PrintStr("double", Stream)
    elseif Typ.Base == BaseType.TypeFunction then
        PrintStr("function", Stream)
    elseif Typ.Base == BaseType.TypeMacro then
        PrintStr("macro", Stream)
    elseif Typ.Base == BaseType.TypePointer then
        if Typ.FromType ~= nil then
            PrintType(Typ.FromType, Stream)
        end
        PrintCh('*', Stream)
    elseif Typ.Base == BaseType.TypeArray then
        PrintType(Typ.FromType, Stream)
        PrintCh('[', Stream)
        if Typ.ArraySize ~= 0 then
            PrintSimpleInt(Typ.ArraySize, Stream)
        end
        PrintCh(']', Stream)
    elseif Typ.Base == BaseType.TypeStruct then
        PrintStr("struct ", Stream)
        PrintStr(Typ.Identifier.RawValue.Val, Stream)
    elseif Typ.Base == BaseType.TypeUnion then
        PrintStr("union ", Stream)
        PrintStr(Typ.Identifier.RawValue.Val, Stream)
    elseif Typ.Base == BaseType.TypeEnum then
        PrintStr("enum ", Stream)
        PrintStr(Typ.Identifier.RawValue.Val, Stream)
    elseif Typ.Base == BaseType.TypeGotoLabel then
        PrintStr("goto label ", Stream)
    elseif Typ.Base == BaseType.TypeType then
        PrintStr("type ", Stream)
    end
end

function PrintCh(OutCh, Stream)
    Stream.puts(OutCh)
end

function PrintSimpleInt(Num, Stream)
    Stream.puts(string.format("%d", Num))
end

function PrintStr(Str, Stream)
    Stream.puts(Str)
end

function PrintFP(Num, Stream)
    Stream.puts(string.format("%f", Num))
end
