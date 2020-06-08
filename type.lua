function TypeAdd(pc, Parser, ParentType, Base, ArraySize, Identifier, Sizeof, AlignBytes)
    NewType = VariableAlloc(pc, Parser, true)
    NewType.Base = Base
    NewType.ArraySize = ArraySize
    NewType.Sizeof = Sizeof
    NewType.AlignBytes = AlignBytes
    NewType.Identifier = Identifier
    NewType.Members = nil
    NewType.FromType = ParentType
    NewType.DerivedTypeList = nil
    NewType.OnHeap = true
    NewType.StaticQualifier = false
    NewType.Next = ParentType.DerivedTypeList
    ParentType.DerivedTypeList = NewType

    return NewType
end

function TypeGetMatching(pc, Parser, ParentType, Base, ArraySize, Identifier, AllowDuplicates)
    local Sizeof
    local AlignBytes
    local ThisType = ParentType.DerivedTypeList
    while (ThisType ~= nil and (ThisType.Base ~= Base or
        ThisType.ArraySize ~= ArraySize or ThisType.Identifier ~= Identifier)) do
        ThisType = ThisType.Next
    end

    if ThisType ~= nil then
        if AllowDuplicates then
            return ThisType
        else
            ProgramFail(Parser, "data type '%s' is already defined", Identifier.RawValue.Val)
        end
    end

    if Base == BaseType.TypePointer then
        Sizeof = 4
        AlignBytes = PointerAlignBytes
    elseif Base == BaseType.TypeArray then
        Sizeof = ArraySize * ParentType.Sizeof
        AlignBytes = ParentType.AlignBytes
    elseif Base == BaseType.TypeEnum then
        Sizeof = 4
        AlignBytes = IntAlignBytes
    else
        Sizeof = 0
        AlignBytes = 0
    end
    --print(Sizeof)

    return TypeAdd(pc, Parser, ParentType, Base, ArraySize, Identifier, Sizeof,
        AlignBytes)
end

function TypeStackSizeValue(Val)
    if Val ~= nil and Val.ValOnStack then
        return TypeSizeValue(Val, false)
    else
        return 0
    end
end

function TypeSizeValue(Val, Compact)
    if IS_INTEGER_NUMERIC(Val) and not Compact then
        return 4
    elseif Val.Typ.Base ~= BaseType.TypeArray then
        return Val.Typ.Sizeof
    else
        return Val.Typ.FromType.Sizeof * Val.Typ.ArraySize
    end
end

function TypeSize(Typ, ArraySize, Compact)
    if IS_INTEGER_NUMERIC_TYPE(Typ) and not Compact then
        return 4
    elseif Typ.Base ~= BaseType.TypeArray then
        return Typ.Sizeof
    else
        return Typ.FromType.Sizeof * ArraySize
    end
end

function TypeAddBaseType(pc, TypeNode, Base, Sizeof, AlignBytes)
    TypeNode.Base = Base
    TypeNode.ArraySize = 0
    TypeNode.Sizeof = Sizeof
    TypeNode.AlignBytes = AlignBytes
    TypeNode.Identifier = pc.StrEmpty
    TypeNode.Members = nil
    TypeNode.FromType = nil
    TypeNode.DerivedTypeList = nil
    TypeNode.OnHeap = false
    TypeNode.Next = pc.UberType.DerivedTypeList
    TypeNode.StaticQualifier = false
    pc.UberType.DerivedTypeList = TypeNode
end

function TypeInit(pc)
    IntAlignBytes = 1
    PointerAlignBytes = 1

    pc.UberType.DerivedTypeList = nil
    TypeAddBaseType(pc, pc.IntType, BaseType.TypeInt, 4, IntAlignBytes)
    TypeAddBaseType(pc, pc.ShortType, BaseType.TypeShort, 2, 1)
    TypeAddBaseType(pc, pc.CharType, BaseType.TypeChar, 1, 1)
    TypeAddBaseType(pc, pc.LongType, BaseType.TypeLong, 4, 1)
    TypeAddBaseType(pc, pc.UnsignedIntType, BaseType.TypeUnsignedInt, 4, 1)
    TypeAddBaseType(pc, pc.UnsignedShortType, BaseType.TypeUnsignedShort, 2, 1)
    TypeAddBaseType(pc, pc.UnsignedLongType, BaseType.TypeUnsignedLong, 4, 1)
    TypeAddBaseType(pc, pc.UnsignedCharType, BaseType.TypeUnsignedChar, 1, 1)
    TypeAddBaseType(pc, pc.VoidType, BaseType.TypeVoid, 0, 1)
    TypeAddBaseType(pc, pc.FunctionType, BaseType.TypeFunction, 4, IntAlignBytes)
    TypeAddBaseType(pc, pc.MacroType, BaseType.TypeMacro, 4, IntAlignBytes)
    TypeAddBaseType(pc, pc.GotoLabelType, BaseType.TypeGotoLabel, 0, 1)
    TypeAddBaseType(pc, pc.FPType, BaseType.TypeFP, 8, 1)
    TypeAddBaseType(pc, pc.TypeType, BaseType.TypeType, 8, 1)
    pc.CharArrayType = TypeAdd(pc, nil, pc.CharType, BaseType.TypeArray, 0,
        pc.StrEmpty, 1, 1)
    pc.CharPtrType = TypeAdd(pc, nil, pc.CharType, BaseType.TypePointer, 0,
        pc.StrEmpty, 4, PointerAlignBytes)
    pc.CharPtrPtrType = TypeAdd(pc, nil, pc.CharPtrType, BaseType.TypeArray, 0,
        pc.StrEmpty, 4, PointerAlignBytes)
    pc.VoidPtrType = TypeAdd(pc, nil, pc.VoidType, BaseType.TypePointer, 0,
        pc.StrEmpty, 4, PointerAlignBytes)
end

function TypeCleanupNode(pc, Typ)
    local SubType, NextSubType
    local ListDepth = 0
    local LastSubType

    SubType = Typ.DerivedTypeList
    while SubType ~= nil do
        NextSubType = SubType.Next
        TypeCleanupNode(pc, SubType)

        if SubType.OnHeap then
            if SubType.Members ~= nil then
                VariableTableCleanup(pc, SubType.Members)
                SubType.Members = nil
            end

            if ListDepth == 0 then
                Typ.DerivedTypeList = nil
            else
                LastSubType.Next = nil
            end
        end

        LastSubType = SubType
        SubType = NextSubType
        ListDepth = ListDepth + 1
    end

    collectgarbage()
end

function TypeCleanup(pc)
    TypeCleanupNode(pc, pc.UberType)
end

function TypeParseStruct(Parser, InitTyp, IsStruct)
    local MemberIdentifier
    local StructIdentifier
    local Token, Tok
    local MemberValue
    local pc = Parser.pc
    local LexValue
    local MemberType
    local Typ = InitTyp

    Token, LexValue = LexGetToken(Parser, LexValue, false)
    if Token == LexToken.TokenIdentifier then
        _, LexValue = LexGetToken(Parser, LexValue, true)
        StructIdentifier = LexValue.Val  -- Changed from LexValue.Val.Identifier
        Token, _ = LexGetToken(Parser, nil, false)
    else
        StructIdentifier = PlatformMakeTempName(pc, true)
    end

    local Base
    if IsStruct then
        Base = BaseType.TypeStruct
    else
        Base = BaseType.TypeUnion
    end
    Typ = TypeGetMatching(pc, Parser, Parser.pc.UberType,
        Base, 0, StructIdentifier, true)

    Token, _ = LexGetToken(Parser, nil, false)
    if Token ~= LexToken.TokenLeftBrace then
        return Typ
    end

    if pc.TopStackFrameId ~= 0 then
        ProgramFail(Parser, "struct/union definitions can only be globals")
    end

    LexGetToken(Parser, nil, true)
    Typ.Members = VariableAlloc(pc, Parser, true)
    Typ.Members.HashTable = {}
    TableInitTable(Typ.Members, Typ.Members.HashTable, STRUCT_TABLE_SIZE, true)

    repeat
        MemberType, MemberIdentifier, _ = TypeParse(Parser)
        if MemberType == nil or MemberIdentifier == nil then
            ProgramFail(Parser, "invalid type in struct")
        end

        MemberValue = VariableAllocValueAndData(pc, Parser, 4, false,
            nil, true)
        MemberValue.Typ = MemberType
        if IsStruct then
            PointerSetSignedOrUnsignedInt(MemberValue.Val, Typ.Sizeof)
            Typ.Sizeof = Typ.Sizeof + TypeSizeValue(MemberValue, true)
        else
            PointerSetSignedOrUnsignedInt(MemberValue.Val, 0)
            if MemberValue.Typ.Sizeof > Typ.Sizeof then
                Typ.Sizeof = TypeSizeValue(MemberValue, true)
            end
        end

        -- AlignBytes unused
        --[[
        if Typ.AlignBytes < MemberValue.Typ.AlignBytes then
            Typ.AlignBytes = MemberValue.Typ.AlignBytes
        end
        ]]

        if not TableSet(pc, Typ.Members, MemberIdentifier, MemberValue,
            Parser.FileName, Parser.Line, Parser.CharacterPos) then
            ProgramFail(Parser, "member '%s' already defined", MemberIdentifier)
        end

        Tok, _ = LexGetToken(Parser, nil, true)
        if Tok ~= LexToken.TokenSemicolon then
            ProgramFail(Parser, "semicolon expected")
        end

        Tok, _ = LexGetToken(Parser, nil, false)
    until Tok == LexToken.TokenRightBrace

    LexGetToken(Parser, nil, true)
    return Typ
end

-- StructName: AnyValue
function TypeCreateOpaqueStruct(pc, Parser, StructName, Size)
    local Typ = TypeGetMatching(pc, Parser, pc.UberType,
        BaseType.TypeStruct, 0, StructName, false)

    Typ.Members = VariableAlloc(pc, Parser, true)
    Typ.Members.HashTable = {}
    TableInitTable(Typ.Members, Typ.Members.HashTable,
        STRUCT_TABLE_SIZE, true)
    Typ.Sizeof = Size

    return Typ
end

function TypeParseEnum(Parser, InitTyp)
    local EnumValue = 0
    local EnumIdentifier
    local Token, Tok
    local LexValue
    local InitValue
    local pc = Parser.pc
    local Typ = InitTyp

    Token, LexValue = LexGetToken(Parser, LexValue, false)
    if Token == LexToken.TokenIdentifier then
        _, LexValue = LexGetToken(Parser, LexValue, true)
        EnumIdentifier = LexValue.Val   -- Changed from LexValue.Val.Identifier
        Token, _ = LexGetToken(Parser, nil, false)
    else
        EnumIdentifier = PlatformMakeTempName(pc, false)
    end

    TypeGetMatching(pc, Parser, pc.UberType, BaseType.TypeEnum, 0, EnumIdentifier,
        Token ~= LexToken.TokenLeftBrace)
    Typ = pc.IntType
    if Token ~= LexToken.TokenLeftBrace then
        if Typ.Members == nil then
            ProgramFail(Parser, "enum '%s' isn't defined", EnumIdentifier.RawValue.Val)
        end

        return Typ
    end

    if pc.TopStackFrameId ~= 0 then
        ProgramFail(Parser, "enum definitions can only be globals")
    end

    LexGetToken(Parser, nil, true)
    Typ.Members = pc.GlobalTable
    InitValue = VariableAllocValueFromType(pc, nil, pc.IntType, false, nil, true)
    PointerSetSignedOrUnsignedInt(InitValue.Val, EnumValue)
    repeat
        Tok, LexValue = LexGetToken(Parser, LexValue, true)
        if Tok ~= LexToken.TokenIdentifier then
            ProgramFail(Parser, "identifier expected")
        end

        EnumIdentifier = LexValue.Val    -- Changed from LexValue.Val.Identifier
        Tok, _ = LexGetToken(Parser, nil, false)
        if Tok == LexToken.TokenAssign then
            LexGetToken(Parser, nil, true)
            EnumValue = ExpressionParseInt(Parser)
        end

        PointerSetSignedOrUnsignedInt(InitValue.Val, EnumValue)
        VariableDefine(pc, Parser, EnumIdentifier, InitValue, nil, false)

        Token, _ = LexGetToken(Parser, nil, true)
        if Token ~= LexToken.TokenComma and Token ~= LexToken.TokenRightBrace then
            ProgramFail(Parser, "comma expected")
        end

        EnumValue = EnumValue + 1
    until Token ~= LexToken.TokenComma

    return Typ
end

function TypeParseFront(Parser)
    local Unsigned = false
    local StaticQualifier = false
    local Token
    local Before = {}
    local LexerValue
    local VarValue
    local pc = Parser.pc
    local Typ = nil
    local IsStatic

    ParserCopy(Before, Parser)
    Token, LexerValue = LexGetToken(Parser, LexerValue, true)
    while (Token == LexToken.TokenStaticType or Token == LexToken.TokenAutoType or
        Token == LexToken.TokenRegisterType or Token == LexToken.TokenExternType) do
        if Token == LexToken.TokenStaticType then
            StaticQualifier = true
        end

        Token, LexerValue = LexGetToken(Parser, LexerValue, true)
    end

    IsStatic = StaticQualifier

    if Token == LexToken.TokenSignedType or Token == LexToken.TokenUnsignedType then
        local FollowToken
        FollowToken, LexerValue = LexGetToken(Parser, LexerValue, false)
        Unsigned = (Token == LexToken.TokenUnsignedType)

        if (FollowToken ~= LexToken.TokenIntType and FollowToken ~= LexToken.TokenLongType and
            FollowToken ~= LexToken.TokenShortType and FollowToken ~= LexToken.TokenCharType) then
            if Token == LexToken.TokenUnsignedType then
                Typ = pc.UnsignedIntType
            else
                Typ = pc.IntType
            end

            return true, Typ, IsStatic
        end

        Token, LexerValue = LexGetToken(Parser, LexerValue, true)
    end

    if Token == LexToken.TokenIntType then
        if Unsigned then
            Typ = pc.UnsignedIntType
        else
            Typ = pc.IntType
        end
    elseif Token == LexToken.TokenShortType then
        if Unsigned then
            Typ = pc.UnsignedShortType
        else
            Typ = pc.ShortType
        end
    elseif Token == LexToken.TokenCharType then
        if Unsigned then
            Typ = pc.UnsignedCharType
        else
            Typ = pc.CharType
        end
    elseif Token == LexToken.TokenLongType then
        if Unsigned then
            Typ = pc.UnsignedLongType
        else
            Typ = pc.LongType
        end
    elseif Token == LexToken.TokenFloatType or Token == LexToken.TokenDoubleType then
        Typ = pc.FPType
    elseif Token == LexToken.TokenVoidType then
        Typ = pc.VoidType
    elseif Token == LexToken.TokenStructType or Token == LexToken.TokenUnionType then
        if Typ ~= nil then
            ProgramFail(Parser, "bad type declaration")
        end
        Typ = TypeParseStruct(Parser, Typ, Token == LexToken.TokenStructType)
    elseif Token == LexToken.TokenEnumType then
        if Typ ~= nil then
            ProgramFail(Parser, "bad type declaration")
        end
        Typ = TypeParseEnum(Parser, Typ)
    elseif Token == LexToken.TokenIdentifier then
        VarValue = VariableGet(pc, Parser, LexerValue.Val)  -- Changed from LexerValue.Val.Identifier
        --print("TypedefDef:", LexerValue.Val.RawValue.Val, VarValue.Val.Ident)
        Typ = VarValue.Val.Typ  -- Val here points to Typ, not AnyValue type
    else
        ParserCopy(Parser, Before)
        return false, Typ, IsStatic
    end

    return true, Typ, IsStatic
end

function TypeParseBack(Parser, FromType)
    local Token, Tok
    local Before = {}

    ParserCopy(Before, Parser)
    Token, _ = LexGetToken(Parser, nil, true)
    if Token == LexToken.TokenLeftSquareBracket then
        Tok, _ = LexGetToken(Parser, nil, false)
        if Tok == LexToken.TokenRightSquareBracket then
            LexGetToken(Parser, nil, true)
            return TypeGetMatching(Parser.pc, Parser,
                TypeParseBack(Parser, FromType), BaseType.TypeArray, 0,
                Parser.pc.StrEmpty, true)
        else
            local OldMode = Parser.Mode
            local ArraySize
            Parser.Mode = RunMode.RunModeRun
            ArraySize = ExpressionParseInt(Parser)
            Parser.Mode = OldMode

            Tok, _ = LexGetToken(Parser, nil, true)
            if Tok ~= LexToken.TokenRightSquareBracket then
                ProgramFail(Parser, "']' expected")
            end

            return TypeGetMatching(Parser.pc, Parser,
                TypeParseBack(Parser, FromType), BaseType.TypeArray, ArraySize,
                Parser.pc.StrEmpty, true)
        end
    else
        ParserCopy(Parser, Before)
        return FromType
    end
end

function TypeParseIdentPart(Parser, BasicTyp)
    local Done = false
    local Token, Tok
    local LexValue
    local Before = {}
    local Typ = BasicTyp
    local Identifier = Parser.pc.StrEmpty

    while not Done do
        ParserCopy(Before, Parser)
        Token, LexValue = LexGetToken(Parser, LexValue, true)
        if Token == LexToken.TokenOpenBracket then
            if Typ ~= nil then
                ProgramFail(Parser, "bad type declaration")
            end

            Typ, Identifier, _ = TypeParse(Parser)
            Tok, _ = LexGetToken(Parser, nil, true)
            if Tok ~= LexToken.TokenCloseBracket then
                ProgramFail(Parser, "')' expected")
            end
        elseif Token == LexToken.TokenAsterisk then
            if Typ == nil then
                ProgramFail(Parser, "bad type declaration")
            end

            Typ = TypeGetMatching(Parser.pc, Parser, Typ, BaseType.TypePointer, 0,
                Parser.pc.StrEmpty, true)
        elseif Token == LexToken.TokenIdentifier then
            if Typ == nil or Identifier ~= Parser.pc.StrEmpty then
                ProgramFail(Parser, "bad type declaration")
            end

            Identifier = LexValue.Val    -- Changed from LexValue.Val.Identifier
            Done = true
        else
            ParserCopy(Parser, Before)
            Done = true
        end
    end

    if Typ == nil then
        ProgramFail(Parser, "bad type declaration")
    end

    if Identifier ~= Parser.pc.StrEmpty then
        Typ = TypeParseBack(Parser, Typ)
    end

    return Typ, Identifier
end

function TypeParse(Parser)
    local BasicType
    local Typ, Identifier, IsStatic

    _, BasicType, IsStatic = TypeParseFront(Parser)
    Typ, Identifier = TypeParseIdentPart(Parser, BasicType)

    return Typ, Identifier, IsStatic
end

function TypeIsForwardDeclared(Parser, Typ)
    if Typ.Base == BaseType.TypeArray then
        return TypeIsForwardDeclared(Parser, Typ.FromType)
    end

    if ((Typ.Base == BaseType.TypeStruct or Typ.Base == BaseType.TypeUnion) and
        Typ.Members == nil) then
        return true
    end

    return false
end
