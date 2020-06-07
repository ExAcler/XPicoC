function IsAlpha(c)
    return (c >= 'a' and c <= 'z') or (c >= 'A' and c <= 'Z')
end

function IsDigit(c)
    return c >= '0' and c <= '9'
end

function IsSpace(c)
    return c == ' ' or c == '\t' or c == '\n' or c == '\v' or c == '\f' or c == '\r'
end

function IsAlNum(c)
    return IsAlpha(c) or IsDigit(c)
end

function IsCidstart(c)
    return IsAlpha(c) or c == '_' or c == '#'
end

function IsCident(c)
    return IsAlNum(c) or c == '_'
end

function IS_HEX_ALPHA_DIGIT(c)
    return (c >= 'a' and c <= 'f') or (c >= 'A' and c <= 'F')
end

function IS_BASE_DIGIT(c, b)
    local digit_end, dec
    if b < 10 then
        digit_end = b - 1
    else
        digit_end = 9
    end
    dec = tostring(digit_end)

    local is_base_digit, is_hex_digit
    is_base_digit = (c >= '0' and c <= dec)

    if b > 10 then
        is_hex_digit = IS_HEX_ALPHA_DIGIT(c)
    else
        is_hex_digit = false
    end

    return is_base_digit or is_hex_digit
end

function GET_BASE_DIGIT(c)
    if c <= '9' then
        return string.byte(c) - string.byte('0')
    else
        if c <= 'F' then
            return string.byte(c) - string.byte('A') + 10
        else
            return string.byte(c) - string.byte('a') + 10
        end
    end
end

function NEXTIS(c, x, y, NextChar, Lexer)
    if NextChar == c then
        LEXER_INC(Lexer)
        return x
    else
        return y
    end
end

function NEXTIS3(c, x, d, y, z, NextChar, Lexer)
    if NextChar == c then
        LEXER_INC(Lexer)
        return x
    else
        return NEXTIS(d, y, z, NextChar, Lexer)
    end
end

function NEXTIS4(c, x, d, y, e, z, a, NextChar, Lexer)
    if NextChar == c then
        LEXER_INC(Lexer)
        return x
    else
        return NEXTIS3(d, y, e, z, a, NextChar, Lexer)
    end
end

function NEXTIS3PLUS(c, x, d, y, e, z, a, NextChar, Lexer)
    if NextChar == c then
        LEXER_INC(Lexer)
        return x
    else
        if NextChar == d then
            if GET_LEXER_CHAR_AT(Lexer, Lexer.Pos + 1) == e then
                LEXER_INCN(Lexer, 2)
                return z
            else
                LEXER_INC(Lexer)
                return y
            end
        else
            return a
        end
    end
end

function NEXTISEXACTLY3(c, d, y, z, NextChar, Lexer)
    if NextChar == c and GET_LEXER_CHAR_AT(Lexer, Lexer.Pos + 1) == d then
        LEXER_INCN(Lexer, 2)
        return y
    else
        return z
    end
end

function LEXER_INC(l)
    l.Pos = l.Pos + 1
    l.CharacterPos = l.CharacterPos + 1
end

function LEXER_INCN(l, n)
    l.Pos = l.Pos + n
    l.CharacterPos = l.CharacterPos + n
end

TOKEN_DATA_OFFSET = 2
MAX_CHAR_VALUE = 255

function GET_LEXER_CHAR(l)
    return string.sub(l.SourceText, l.Pos, l.Pos)
end

function GET_LEXER_CHAR_AT(l, p)
    return string.sub(l.SourceText, p, p)
end

function GET_LEXER_STR_FROM(l, f)
    return string.sub(l.SourceText, f)
end

function CHAR_AT(s, p)
    return string.sub(s, p, p)
end

function GET_PARSING(ps)
    return ps.ParsingTokens[ps.Pos]
end

function GET_PARSING_AT(ps, p)
    return ps.ParsingTokens[p]
end

ReservedWords = {
    {
        Word = "#define",
        Token = LexToken.TokenHashDefine
    },
    {
        Word = "#else",
        Token = LexToken.TokenHashElse
    },
    {
        Word = "#endif",
        Token = LexToken.TokenHashEndif
    },
    {
        Word = "#if",
        Token = LexToken.TokenHashIf
    },
    {
        Word = "#ifdef",
        Token = LexToken.TokenHashIfdef
    },
    {
        Word = "#ifndef",
        Token = LexToken.TokenHashIfndef
    },
    {
        Word = "#include",
        Token = LexToken.TokenHashInclude
    },
    {
        Word = "auto",
        Token = LexToken.TokenAutoType
    },
    {
        Word = "break",
        Token = LexToken.TokenBreak
    },
    {
        Word = "case",
        Token = LexToken.TokenCase
    },
    {
        Word = "char",
        Token = LexToken.TokenCharType
    },
    {
        Word = "continue",
        Token = LexToken.TokenContinue
    },
    {
        Word = "default",
        Token = LexToken.TokenDefault
    },
    {
        Word = "delete",
        Token = LexToken.TokenDelete
    },
    {
        Word = "do",
        Token = LexToken.TokenDo
    },
    {
        Word = "double",
        Token = LexToken.TokenDoubleType
    },
    {
        Word = "else",
        Token = LexToken.TokenElse
    },
    {
        Word = "enum",
        Token = LexToken.TokenEnumType
    },
    {
        Word = "extern",
        Token = LexToken.TokenExternType
    },
    {
        Word = "float",
        Token = LexToken.TokenFloatType
    },
    {
        Word = "for",
        Token = LexToken.TokenFor
    },
    {
        Word = "goto",
        Token = LexToken.TokenGoto
    },
    {
        Word = "if",
        Token = LexToken.TokenIf
    },
    {
        Word = "int",
        Token = LexToken.TokenIntType
    },
    {
        Word = "long",
        Token = LexToken.TokenLongType
    },
    {
        Word = "new",
        Token = LexToken.TokenNew
    },
    {
        Word = "register",
        Token = LexToken.TokenRegisterType
    },
    {
        Word = "return",
        Token = LexToken.TokenReturn
    },
    {
        Word = "short",
        Token = LexToken.TokenShortType
    },
    {
        Word = "signed",
        Token = LexToken.TokenSignedType
    },
    {
        Word = "sizeof",
        Token = LexToken.TokenSizeof
    },
    {
        Word = "static",
        Token = LexToken.TokenStaticType
    },
    {
        Word = "struct",
        Token = LexToken.TokenStructType
    },
    {
        Word = "switch",
        Token = LexToken.TokenSwitch
    },
    {
        Word = "typedef",
        Token = LexToken.TokenTypedef
    },
    {
        Word = "union",
        Token = LexToken.TokenUnionType
    },
    {
        Word = "unsigned",
        Token = LexToken.TokenUnsignedType
    },
    {
        Word = "void",
        Token = LexToken.TokenVoidType
    },
    {
        Word = "while",
        Token = LexToken.TokenWhile
    }
}

function LexInit(pc)
    local Size = #ReservedWords

    TableInitTable(pc.ReservedWordTable, pc.ReservedWordHashTable,
        Size, true)
    for Count = 1, Size do
        TableSet(pc, pc.ReservedWordTable,
            TableStrRegister(pc, ReservedWords[Count].Word),
            ReservedWords[Count], nil, 0, 0)
    end

    LexResetLexValue(pc)
end

function LexResetLexValue(pc)
    pc.LexValue = {}
    pc.LexValue.Typ = nil
    pc.LexValue.Val = {
        RawValue = {
            Val = "\000\000\000\000\000\000\000\000"
        },
        Offset = 0,
        RefOffsets = {},
        Pointer = {},
    }
    --setmetatable(pc.LexValue.Val.Pointer, { __mode = "v" })

    pc.LexValue.LValueFrom = false
    pc.LexValue.ValOnHeap = false
    pc.LexValue.ValOnStack = false
    pc.LexValue.AnyValOnHeap = false
    pc.LexValue.IsLValue = false
end

function LexCleanup(pc)
    LexInteractiveClear(pc, nil)

    local Size = #ReservedWords
    for Count = 1, Size do
        TableDelete(pc, pc.ReservedWordTable,
            TableStrRegister(pc, ReservedWords[Count].Word))
    end
end

function LexCheckReservedWord(pc, Word)
    local val, Success

    Success, val, _, _, _ = TableGet(pc.ReservedWordTable, Word)
    if Success then
        return val.Token
    else
        return LexToken.TokenNone
    end
end

function LexGetNumber(pc, Lexer, Value)
    local Result = 0
    local Base = 10
    local ResultToken, FPResult, FPDiv

    if GET_LEXER_CHAR(Lexer) == '0' then
        LEXER_INC(Lexer)
        if Lexer.Pos ~= Lexer.End then
            if GET_LEXER_CHAR(Lexer) == 'x' or GET_LEXER_CHAR(Lexer) == 'X' then
                Base = 16
                LEXER_INC(Lexer)
            elseif GET_LEXER_CHAR(Lexer) == 'b' or GET_LEXER_CHAR(Lexer) == 'B' then
                Base = 2
                LEXER_INC(Lexer)
            elseif GET_LEXER_CHAR(Lexer) ~= '.' then
                Base = 8
            end
        end
    end

    --print(GET_LEXER_CHAR(Lexer))
    --print(IS_BASE_DIGIT(GET_LEXER_CHAR(Lexer), Base))
    while (Lexer.Pos ~= Lexer.End and
        IS_BASE_DIGIT(GET_LEXER_CHAR(Lexer), Base)) do
        Result = Result * Base + GET_BASE_DIGIT(GET_LEXER_CHAR(Lexer))
        LEXER_INC(Lexer)
    end

    if GET_LEXER_CHAR(Lexer) == 'u' or GET_LEXER_CHAR(Lexer) == 'U' then
        LEXER_INC(Lexer)
    end

    if GET_LEXER_CHAR(Lexer) == 'l' or GET_LEXER_CHAR(Lexer) == 'L' then
        LEXER_INC(Lexer)
    end

    Value.Typ = pc.LongType
    PointerSetSignedOrUnsignedInt(Value.Val, Result)

    ResultToken = LexToken.TokenIntegerConstant

    if Lexer.Pos == Lexer.End then
        return ResultToken
    end

    if (GET_LEXER_CHAR(Lexer) ~= '.' and GET_LEXER_CHAR(Lexer) ~= 'e' and
        GET_LEXER_CHAR(Lexer) ~= 'E') then
        return ResultToken
    end

    Value.Typ = pc.FPType
    FPResult = Result

    if GET_LEXER_CHAR(Lexer) == '.' then
        LEXER_INC(Lexer)
        FPDiv = 1 / Base
        while Lexer.Pos ~= Lexer.End and IS_BASE_DIGIT(GET_LEXER_CHAR(Lexer), Base) do
            FPResult = FPResult + GET_BASE_DIGIT(GET_LEXER_CHAR(Lexer)) * FPDiv
            LEXER_INC(Lexer)
            FPDiv = FPDiv / Base
        end
    end

    if (Lexer.Pos ~= Lexer.End and (GET_LEXER_CHAR(Lexer) == 'e' or
        GET_LEXER_CHAR(Lexer) == 'E')) then
        local ExponentSign = 1

        LEXER_INC(Lexer)
        if Lexer.Pos ~= Lexer.End and GET_LEXER_CHAR(Lexer) == '-' then
            ExponentSign = -1
            LEXER_INC(Lexer)
        end

        Result = 0
        while Lexer.Pos ~= Lexer.End and IS_BASE_DIGIT(GET_LEXER_CHAR(Lexer), Base) do
            Result = Result * Base + GET_BASE_DIGIT(GET_LEXER_CHAR(Lexer))
            LEXER_INC(Lexer)
        end

        FPResult = FPResult * (Base ^ (Result * ExponentSign))
    end

    PointerSetFP(Value.Val, FPResult)

    if GET_LEXER_CHAR(Lexer) == 'f' or GET_LEXER_CHAR(Lexer) == 'F' then
        LEXER_INC(Lexer)
    end

    return LexToken.TokenFPConstant
end

function LexGetWord(pc, Lexer, Value)
    local StartPos = Lexer.Pos
    local Token

    repeat
        LEXER_INC(Lexer)
    until Lexer.Pos == Lexer.End or not IsCident(GET_LEXER_CHAR(Lexer))

    Value.Typ = nil
    Value.Val = TableStrRegister2(pc, GET_LEXER_STR_FROM(Lexer, StartPos),
        Lexer.Pos - StartPos)
    --print("LGW: ", Value.Val.RawValue.Val, Lexer.Pos, StartPos, Value.Val)

    Token = LexCheckReservedWord(pc, Value.Val)
    if Token == LexToken.TokenHashInclude then
        Lexer.Mode = LexMode.LexModeHashInclude
    elseif Token == LexToken.TokenHashDefine then
        Lexer.Mode = LexMode.LexModeHashDefine
    end

    if Token ~= LexToken.TokenNone then
        return Token
    end

    if Lexer.Mode == LexMode.LexModeHashDefineSpace then
        Lexer.Mode = LexMode.LexModeHashDefineSpaceIdent
    end

    return LexToken.TokenIdentifier
end

function LexUnEscapeCharacterConstant(From, FromPos, FirstChar, Base)
    local Total = GET_BASE_DIGIT(FirstChar)
    local CCount = 0

    while IS_BASE_DIGIT(CHAR_AT(From, FromPos), Base) and CCount < 2 do
        Total = Total * Base + GET_BASE_DIGIT(CHAR_AT(From, FromPos))
        CCount = CCount + 1
        FromPos = FromPos + 1
    end

    return string.char(Total), FromPos
end

function LexUnEscapeCharacter(From, FromPos, EndPos)
    local ThisChar
    local Return

    while (FromPos ~= EndPos and CHAR_AT(From, FromPos) == '\\' and
        FromPos + 1 ~= EndPos and CHAR_AT(From, FromPos + 1) == '\n') do
        FromPos = FromPos + 2
    end

    while (FromPos ~= EndPos and CHAR_AT(From, FromPos) == '\\' and
        FromPos + 1 ~= EndPos and CHAR_AT(From, FromPos + 1) == '\r' and
        FromPos + 2 ~= EndPos and CHAR_AT(From, FromPos + 2) == '\n') do
        FromPos = FromPos + 3
    end

    if FromPos == EndPos then
        return '\\', FromPos
    end

    if CHAR_AT(From, FromPos) == '\\' then
        FromPos = FromPos + 1
        if FromPos == EndPos then
            return '\\', FromPos
        end

        ThisChar = CHAR_AT(From, FromPos)
        FromPos = FromPos + 1
        if ThisChar == '\\' then
            return '\\', FromPos
        elseif ThisChar == "'" then
            return "'", FromPos
        elseif ThisChar == '"' then
            return '"', FromPos
        elseif ThisChar == 'a' then
            return '\a', FromPos
        elseif ThisChar == 'b' then
            return '\b', FromPos
        elseif ThisChar == 'f' then
            return '\f', FromPos
        elseif ThisChar == 'n' then
            return '\n', FromPos
        elseif ThisChar == 'r' then
            return '\r', FromPos
        elseif ThisChar == 't' then
            return '\t', FromPos
        elseif ThisChar == 'v' then
            return '\v', FromPos
        elseif ThisChar >= '0' and ThisChar <= '3' then
            return LexUnEscapeCharacterConstant(From, FromPos, ThisChar, 8)
        elseif ThisChar == 'x' then
            return LexUnEscapeCharacterConstant(From, FromPos, '0', 16)
        else
            return ThisChar, FromPos
        end
    else
        Return = CHAR_AT(From, FromPos)
        FromPos = FromPos + 1
        return Return, FromPos
    end
end

function LexGetStringConstant(pc, Lexer, Value, EndChar)
    local Escape = false
    local StartPos = Lexer.Pos
    local EndPos
    local EscBuf, EscBufPos, RegString
    local ArrayValue

    while (Lexer.Pos ~= Lexer.End and
        (GET_LEXER_CHAR(Lexer) ~= EndChar or Escape)) do
        if Escape then
            if GET_LEXER_CHAR(Lexer) == '\r' and Lexer.Pos + 1 ~= Lexer.End then
                Lexer.Pos = Lexer.Pos + 1
            end

            if GET_LEXER_CHAR(Lexer) == '\n' and Lexer.Pos + 1 ~= Lexer.End then
                Lexer.Line = Lexer.Line + 1
                Lexer.Pos = Lexer.Pos + 1
                Lexer.CharacterPos = 0
                Lexer.EmitExtraNewlines = Lexer.EmitExtraNewlines + 1
            end

            Escape = false
        elseif GET_LEXER_CHAR(Lexer) == '\\' then
            Escape = true
        end

        LEXER_INC(Lexer)
    end
    EndPos = Lexer.Pos

    EscBuf = HeapAllocStack(pc)
    if EscBuf == nil then
        LexFail(pc, Lexer, "(LexGetStringConstant) out of memory")
    end
    EscBuf.Str = ""

    EscBufPos = 1
    Lexer.Pos = StartPos
    while Lexer.Pos ~= EndPos do
        local CurChar
        CurChar, Lexer.Pos = LexUnEscapeCharacter(Lexer.SourceText,
            Lexer.Pos, EndPos)
        --print("Byte:", string.byte(CurChar), CurChar)
        EscBuf.Str = EscBuf.Str .. CurChar
        EscBufPos = EscBufPos + 1
    end

    RegString = TableStrRegister2(pc, EscBuf.Str, EscBufPos - 1)
    HeapPopStack(pc, 1, EscBuf.StackId - 1)
    ArrayValue = VariableStringLiteralGet(pc, RegString)
    if ArrayValue == nil then
        ArrayValue = VariableAllocValueAndData(pc, nil, 0, false, nil, true)
        ArrayValue.Typ = pc.CharArrayType
        ArrayValue.Val = RegString
        VariableStringLiteralDefine(pc, RegString, ArrayValue)
    end

    Value.Typ = pc.CharPtrType
    --print(Value.Val.Ident, " ", RegString.RawValue.Val)
    PointerReference(Value.Val, RegString)
    if GET_LEXER_CHAR(Lexer) == EndChar then
        LEXER_INC(Lexer)
    end

    return LexToken.TokenStringConstant
end

function LexGetCharacterConstant(pc, Lexer, Value)
    Value.Typ = pc.CharType
    Value.Val.RawValue.Val, Lexer.Pos = LexUnEscapeCharacter(Lexer.SourceText,
            Lexer.Pos, Lexer.End)
    if Lexer.Pos ~= Lexer.End and GET_LEXER_CHAR(Lexer) ~= "'" then
        LexFail(pc, Lexer, "expected \"'\"")
    end

    LEXER_INC(Lexer)
    return LexToken.TokenCharacterConstant
end

function LexSkipComment(Lexer, NextChar)
    if NextChar == '*' then
        while (Lexer.Pos ~= Lexer.End and
            (GET_LEXER_CHAR_AT(Lexer, Lexer.Pos - 1) ~= '*' or
            GET_LEXER_CHAR(Lexer) ~= '/')) do
            if GET_LEXER_CHAR(Lexer) == '\n' then
                Lexer.EmitExtraNewlines = Lexer.EmitExtraNewlines + 1
            end
            LEXER_INC(Lexer)
        end

        if Lexer.Pos ~= Lexer.End then
            LEXER_INC(Lexer)
        end

        Lexer.Mode = LexMode.LexModeNormal
    else
        while Lexer.Pos ~= Lexer.End and GET_LEXER_CHAR(Lexer) ~= '\n' do
            LEXER_INC(Lexer)
        end
    end
end

function LexSkipLineCont(Lexer, NextChar)
    while Lexer.Pos ~= Lexer.End and GET_LEXER_CHAR(Lexer) ~= '\n' do
        LEXER_INC(Lexer)
    end
end

function LexScanGetToken(pc, Lexer, InitValue)
    local ThisChar, NextChar
    local GotToken = LexToken.TokenNone
    local Value = InitValue

    if Lexer.EmitExtraNewlines > 0 then
        Lexer.EmitExtraNewlines = Lexer.EmitExtraNewlines - 1
        return LexToken.TokenEndOfLine, Value
    end

    repeat
        LexResetLexValue(pc)
        Value = pc.LexValue

        while Lexer.Pos ~= Lexer.End and IsSpace(GET_LEXER_CHAR(Lexer)) do
            if GET_LEXER_CHAR(Lexer) == '\n' then
                Lexer.Line = Lexer.Line + 1
                Lexer.Pos = Lexer.Pos + 1
                Lexer.Mode = LexMode.LexModeNormal
                Lexer.CharacterPos = 0
                return LexToken.TokenEndOfLine, Value
            elseif (Lexer.Mode == LexMode.LexModeHashDefine or
                Lexer.Mode == LexMode.LexModeHashDefineSpace) then
                Lexer.Mode = LexMode.LexModeHashDefineSpace
            elseif Lexer.Mode == LexMode.LexModeHashDefineSpaceIdent then
                Lexer.Mode = LexMode.LexModeNormal
            end

            LEXER_INC(Lexer)
        end

        --print(Lexer.Pos)
        if Lexer.Pos == Lexer.End or GET_LEXER_CHAR(Lexer) == "" then
            return LexToken.TokenEOF, Value
        end

        ThisChar = GET_LEXER_CHAR(Lexer)
        if IsCidstart(ThisChar) then
            local Result = LexGetWord(pc, Lexer, Value)
            return Result, Value
        end

        if IsDigit(ThisChar) then
            local Result = LexGetNumber(pc, Lexer, Value)
            return Result, Value
        end

        if Lexer.Pos + 1 ~= Lexer.End then
            NextChar = GET_LEXER_CHAR_AT(Lexer, Lexer.Pos + 1)
        else
            NextChar = '\0'
        end
        LEXER_INC(Lexer)
        if ThisChar == '"' then
            GotToken = LexGetStringConstant(pc, Lexer, Value, '"')
        elseif ThisChar == "'" then
            GotToken = LexGetCharacterConstant(pc, Lexer, Value)
        elseif ThisChar == '(' then
            if Lexer.Mode == LexMode.LexModeHashDefineSpaceIdent then
                GotToken = LexToken.TokenOpenMacroBracket
            else
                GotToken = LexToken.TokenOpenBracket
            end
            Lexer.Mode = LexMode.LexModeNormal
        elseif ThisChar == ')' then
            GotToken = LexToken.TokenCloseBracket
        elseif ThisChar == '=' then
            GotToken = NEXTIS('=', LexToken.TokenEqual, LexToken.TokenAssign, NextChar, Lexer)
        elseif ThisChar == '+' then
            GotToken = NEXTIS3('=', LexToken.TokenAddAssign, '+',
                LexToken.TokenIncrement, LexToken.TokenPlus, NextChar, Lexer)
        elseif ThisChar == '-' then
            GotToken = NEXTIS4('=', LexToken.TokenSubtractAssign, '>',
                LexToken.TokenArrow, '-', LexToken.TokenDecrement, LexToken.TokenMinus, NextChar, Lexer)
        elseif ThisChar == '*' then
            GotToken = NEXTIS('=', LexToken.TokenMultiplyAssign, LexToken.TokenAsterisk, NextChar, Lexer)
        elseif ThisChar == '/' then
            if NextChar == '/' or NextChar == '*' then
                LEXER_INC(Lexer)
                LexSkipComment(Lexer, NextChar)
            else
                GotToken = NEXTIS('=', LexToken.TokenDivideAssign, LexToken.TokenSlash, NextChar, Lexer)
            end
        elseif ThisChar == '%' then
            GotToken = NEXTIS('=', LexToken.TokenModulusAssign, LexToken.TokenModulus, NextChar, Lexer)
        elseif ThisChar == '<' then
            if Lexer.Mode == LexMode.LexModeHashInclude then
                GotToken = LexGetStringConstant(pc, Lexer, Value, '>')
            else
                GotToken = NEXTIS3PLUS('=', LexToken.TokenLessEqual, '<', LexToken.TokenShiftLeft, '=',
                    LexToken.TokenShiftLeftAssign, LexToken.TokenLessThan, NextChar, Lexer)
            end
        elseif ThisChar == '>' then
            GotToken = NEXTIS3PLUS('=', LexToken.TokenGreaterEqual, '>', LexToken.TokenShiftRight, '=',
                    LexToken.TokenShiftRightAssign, LexToken.TokenGreaterThan, NextChar, Lexer)
        elseif ThisChar == ';' then
            GotToken = LexToken.TokenSemicolon
        elseif ThisChar == '&' then
            GotToken = NEXTIS3('=', LexToken.TokenArithmeticAndAssign, '&', LexToken.TokenLogicalAnd,
                LexToken.TokenAmpersand, NextChar, Lexer)
        elseif ThisChar == '|' then
            GotToken = NEXTIS3('=', LexToken.TokenArithmeticOrAssign, '|', LexToken.TokenLogicalOr,
                LexToken.TokenArithmeticOr, NextChar, Lexer)
        elseif ThisChar == '{' then
            GotToken = LexToken.TokenLeftBrace
        elseif ThisChar == '}' then
            GotToken = LexToken.TokenRightBrace
        elseif ThisChar == '[' then
            GotToken = LexToken.TokenLeftSquareBracket
        elseif ThisChar == ']' then
            GotToken = LexToken.TokenRightSquareBracket
        elseif ThisChar == '!' then
            GotToken = NEXTIS('=', LexToken.TokenNotEqual, LexToken.TokenUnaryNot, NextChar, Lexer)
        elseif ThisChar == '^' then
            GotToken = NEXTIS('=', LexToken.TokenArithmeticExorAssign, LexToken.TokenArithmeticExor,
                NextChar, Lexer)
        elseif ThisChar == '~' then
            GotToken = LexToken.TokenUnaryExor
        elseif ThisChar == ',' then
            GotToken = LexToken.TokenComma
        elseif ThisChar == '.' then
            GotToken = NEXTISEXACTLY3('.', '.', LexToken.TokenEllipsis,
                LexToken.TokenDot, NextChar, Lexer)
        elseif ThisChar == '?' then
            GotToken = LexToken.TokenQuestionMark
        elseif ThisChar == ':' then
            GotToken = LexToken.TokenColon
        elseif ThisChar == '\\' then
            if NextChar == ' ' or NextChar == '\n' then
                LEXER_INC(Lexer)
                LexSkipLineCont(Lexer, NextChar)
            else
                LexFail(pc, Lexer, "illegal character '%c'", ThisChar)
            end
        else
            LexFail(pc, Lexer, "illegal character '%c'", ThisChar)
        end
    until GotToken ~= LexToken.TokenNone

    return GotToken, Value
end

-- Return value of this function is disregarded:
-- just indicates a token has value if it does not return 0
function LexTokenSize(Token)
    if Token == LexToken.TokenIdentifier or Token == LexToken.TokenStringConstant then
        return 4
    elseif Token == LexToken.TokenIntegerConstant then
        return 4
    elseif Token == LexToken.TokenCharacterConstant then
        return 1
    elseif Token == LexToken.TokenFPConstant then
        return 8
    else
        return 0
    end
end

function LexTokenize(pc, Lexer)
    local MemUsed = 0
    local ValueSize
    local LastCharacterPos = 0
    local HeapMem
    --local TokenSpace = HeapAllocStack(pc)
    local TokenSpace = {}
    local Token
    local GotValue
    local TokenPos = 1
    local TokenLen

    if TokenSpace == nil then
        LexFail(pc, Lexer, "(LexTokenize TokenSpace == NULL) out of memory")
    end

    repeat
        Token, GotValue = LexScanGetToken(pc, Lexer, GotValue)
        --if Debug then
        --    io.write("" .. Token .. " ")
        --end

        TokenSpace[TokenPos] = Token
        TokenPos = TokenPos + 1
        MemUsed = MemUsed + 1

        -- Confine to 0xFF
        TokenSpace[TokenPos] = LastCharacterPos % 0x100
        TokenPos = TokenPos + 1
        MemUsed = MemUsed + 1

        ValueSize = LexTokenSize(Token)
        if ValueSize > 0 then
            if Token == LexToken.TokenIdentifier then
                TokenSpace[TokenPos] = GotValue.Val
            else
                TokenSpace[TokenPos] = PointerCopyAllValues(GotValue.Val, true)
                TokenSpace[TokenPos].RawValue.Val =
                    string.sub(TokenSpace[TokenPos].RawValue.Val, 1, ValueSize)
            end
            TokenPos = TokenPos + 1
            MemUsed = MemUsed + 1
        end

        LastCharacterPos = Lexer.CharacterPos
    until Token == LexToken.TokenEOF

    --[[
    HeapMem = {}
    if HeapMem == nil then
        LexFail(pc, Lexer, "(LexTokenize HeapMem == NULL) out of memory")
    end

    for k in pairs(TokenSpace) do
        HeapMem[k] = TokenSpace[k]
    end
    HeapPopStack(pc, 1, TokenSpace.StackId - 1)
    --]]

    TokenLen = MemUsed
    --return HeapMem, TokenLen
    return TokenSpace, TokenLen
end

function LexAnalyse(pc, FileName, Source, SourceLen)
    local Lexer = {}

    Lexer.Pos = 1
    Lexer.End = 1 + SourceLen
    Lexer.Line = 1
    Lexer.FileName = FileName
    Lexer.Mode = LexMode.LexModeNormal
    Lexer.EmitExtraNewlines = 0
    Lexer.CharacterPos = 1
    Lexer.SourceText = Source

    return LexTokenize(pc, Lexer)
end

function LexInitParser(Parser, pc, SourceText, TokenSource, FileName, RunIt, EnableDebugger)
    Parser.pc = pc
    Parser.ParsingTokens = TokenSource
    Parser.Pos = 1
    Parser.Line = 1
    Parser.FileName = FileName
    if RunIt then
        Parser.Mode = RunMode.RunModeRun
    else
        Parser.Mode = RunMode.RunModeSkip
    end
    Parser.SearchLabel = 0
    Parser.HashIfLevel = 0
    Parser.HashIfEvaluateToLevel = 0
    Parser.CharacterPos = 0
    Parser.SourceText = SourceText
    Parser.DebugMode = EnableDebugger
end

function LexGetRawToken(Parser, InitValue, IncPos)
    local ValueSize
    local Prompt
    local Token = LexToken.TokenNone
    local pc = Parser.pc
    local Value = InitValue

    repeat
        if Parser.ParsingTokens == nil and pc.InteractiveHead ~= nil then
            Parser.ParsingTokens = pc.InteractiveHead.Tokens
            Parser.Pos = 1
        end

        if Parser.FileName ~= pc.StrEmpty or pc.InteractiveHead ~= nil then
            Token = GET_PARSING(Parser)
            while Token == LexToken.TokenEndOfLine do
                Parser.Line = Parser.Line + 1
                Parser.Pos = Parser.Pos + TOKEN_DATA_OFFSET
                Token = GET_PARSING(Parser)
            end
        end

        -- If block will not be executed if interactive is off
        if (Parser.FileName == pc.StrEmpty and
            (pc.InteractiveHead == nil or Token == LexToken.TokenEOF)) then
            local LineBuffer
            local LineTokens
            local LineBytes
            local LineNode

            if (pc.InteractiveHead == nil or (
                Parser.ParsingTokens == pc.InteractiveTail.Tokens and
                Parser.Pos == pc.InteractiveTail.NumBytes - TOKEN_DATA_OFFSET + 1)) then
                if pc.LexUseStatementPrompt then
                    Prompt = INTERACTIVE_PROMPT_STATEMENT
                    pc.LexUseStatementPrompt = false
                else
                    Prompt = INTERACTIVE_PROMPT_LINE
                end

                LineBuffer = PlatformGetLine(LINEBUFFER_MAX, Prompt)
                if LineBuffer == nil then
                    return LexToken.TokenEOF, Value
                end

                LineTokens, LineBytes = LexAnalyse(pc, pc.StrEmpty, LineBuffer,
                    string.len(LineBuffer))
                LineNode = VariableAlloc(pc, Parser, true)
                LineNode.Tokens = LineTokens
                LineNode.NumBytes = LineBytes
                if pc.InteractiveHead == nil then
                    pc.InteractiveHead = LineNode
                    Parser.Line = 1
                    Parser.CharacterPos = 0
                else
                    pc.InteractiveTail.Next = LineNode
                end

                pc.InteractiveTail = LineNode
                pc.InteractiveCurrentLine = LineNode
                Parser.ParsingTokens = LineTokens
                Parser.Pos = 1
            else
                if (Parser.ParsingTokens ~= pc.InteractiveCurrentLine.Tokens or
                    Parser.Pos ~= pc.InteractiveCurrentLine.NumBytes - TOKEN_DATA_OFFSET + 1) then
                    pc.InteractiveCurrentLine = pc.InteractiveHead
                    while (Parser.ParsingTokens ~= pc.InteractiveCurrentLine.Tokens or
                        Parser.Pos ~= pc.InteractiveCurrentLine.NumBytes - TOKEN_DATA_OFFSET + 1) do
                        assert(pc.InteractiveCurrentLine.Next ~= nil, "LexGetRawToken: Next of InteractiveCurrentLine is nil")
                        pc.InteractiveCurrentLine = pc.InteractiveCurrentLine.Next
                    end
                end

                assert(pc.InteractiveCurrentLine ~= nil, "LexGetRawToken: InteractiveCurrentLine is nil")
                pc.InteractiveCurrentLine = pc.InteractiveCurrentLine.Next
                assert(pc.InteractiveCurrentLine ~= nil, "LexGetRawToken: InteractiveCurrentLine is nil")
                Parser.ParsingTokens = pc.InteractiveCurrentLine.Tokens
                Parser.Pos = 1
            end

            Token = GET_PARSING(Parser)
        end
    until not ((Parser.FileName == pc.StrEmpty and Token == LexToken.TokenEOF) or
        Token == LexToken.TokenEndOfLine)

    Parser.CharacterPos = GET_PARSING_AT(Parser, Parser.Pos + 1)

    ValueSize = LexTokenSize(Token)
    if ValueSize > 0 then
        --if Value ~= nil then
        if true then
            if Token == LexToken.TokenStringConstant then
                pc.LexValue.Typ = pc.CharPtrType
            elseif Token == LexToken.TokenIdentifier then
                pc.LexValue.Typ = nil
            elseif Token == LexToken.TokenIntegerConstant then
                pc.LexValue.Typ = pc.LongType
            elseif Token == LexToken.TokenCharacterConstant then
                pc.LexValue.Typ = pc.CharType
            elseif Token == LexToken.TokenFPConstant then
                pc.LexValue.Typ = pc.FPType
            end

            local LexValueVal = GET_PARSING_AT(Parser, Parser.Pos + TOKEN_DATA_OFFSET)

            if Token == LexToken.TokenIdentifier then
                pc.LexValue.Val = LexValueVal
            else
                pc.LexValue.Val = PointerCopyAllValues(LexValueVal, true)
            end
            pc.LexValue.ValOnHeap = false
            pc.LexValue.ValOnStack = false
            pc.LexValue.IsLValue = false
            pc.LexValue.LValueFrom = nil
            Value = pc.LexValue
        end

        if IncPos then
            Parser.Pos = Parser.Pos + 1 + TOKEN_DATA_OFFSET
        end
    else
        if IncPos and Token ~= LexToken.TokenEOF then
            Parser.Pos = Parser.Pos + TOKEN_DATA_OFFSET
        end
    end

    assert(Token >= LexToken.TokenNone and Token <= LexToken.TokenEndOfFunction, "LexGetRawToken: Function ends with illegal token")
    return Token, Value
end

function LexHashIncPos(Parser, IncPos)
    if not IncPos then
        LexGetRawToken(Parser, nil, true)
    end
end

function LexHashIfdef(Parser, IfNot)
    local IsDefined
    local IdentValue
    local SavedValue
    local Token
    Token, IdentValue = LexGetRawToken(Parser, IdentValue, true)

    if Token ~= LexToken.TokenIdentifier then
        ProgramFail(Parser, "identifier expected")
    end

    IsDefined, SavedValue, _, _, _ = TableGet(Parser.pc.GlobalTable, IdentValue.Val)    -- Changed from IdentValue.Val.Identifier
    if (Parser.HashIfEvaluateToLevel == Parser.HashIfLevel and
        ((IsDefined and not IfNot) or (not IsDefined and IfNot))) then
        Parser.HashIfEvaluateToLevel = Parser.HashIfEvaluateToLevel + 1
    end

    Parser.HashIfLevel = Parser.HashIfLevel + 1
end

function LexHashIf(Parser)
    local IdentValue
    local SavedValue
    local MacroParser = {}
    local Token
    Token, IdentValue = LexGetRawToken(Parser, IdentValue, true)

    if Token == LexToken.TokenIdentifier then
        local Success
        Success, SavedValue, _, _, _ = TableGet(Parser.pc.GlobalTable, IdentValue.Val)  -- Changed from IdentValue.Val.Identifier
        if not Success then
            ProgramFail(Parser, "'%s' is undefined", IdentValue.Val.RawValue.Val) -- Changed from IdentValue.Val.Identifier
        end

        if SavedValue.Typ.Base ~= BaseType.TypeMacro then
            ProgramFail(Parser, "value expected")
        end

        ParserCopy(MacroParser, SavedValue.Val.MacroDef.Body)
        Token, IdentValue = LexGetRawToken(MacroParser, IdentValue, true)
    end

    if Token ~= LexToken.TokenCharacterConstant and Token ~= LexToken.TokenIntegerConstant then
        ProgramFail(Parser, "value expected")
    end

    local Cond = C_INT_TO_LUA_BOOLEAN(PointerGetSignedChar(IdentValue.Val))
    if Parser.HashIfEvaluateToLevel == Parser.HashIfLevel and Cond then
        Parser.HashIfEvaluateToLevel = Parser.HashIfEvaluateToLevel + 1
    end

    Parser.HashIfLevel = Parser.HashIfLevel + 1
end

function LexHashElse(Parser)
    if Parser.HashIfEvaluateToLevel == Parser.HashIfLevel - 1 then
        Parser.HashIfEvaluateToLevel = Parser.HashIfEvaluateToLevel + 1
    elseif Parser.HashIfEvaluateToLevel == Parser.HashIfLevel then
        if Parser.HashIfLevel == 0 then
            ProgramFail(Parser, "#else without #if")
        end

        Parser.HashIfEvaluateToLevel = Parser.HashIfEvaluateToLevel - 1
    end
end

function LexHashEndif(Parser)
    if Parser.HashIfLevel == 0 then
        ProgramFail(Parser, "#endif without #if")
    end

    Parser.HashIfLevel = Parser.HashIfLevel - 1
    if Parser.HashIfEvaluateToLevel > Parser.HashIfLevel then
        Parser.HashIfEvaluateToLevel = Parser.HashIfLevel
    end
end

function LexGetToken(Parser, InitValue, IncPos)
    local TryNextToken
    local Token
    local Value = InitValue

    repeat
        local WasPreProcToken = true

        Token, Value = LexGetRawToken(Parser, Value, IncPos)
        if Token == LexToken.TokenHashIfdef then
            LexHashIncPos(Parser, IncPos)
            LexHashIfdef(Parser, false)
        elseif Token == LexToken.TokenHashIfndef then
            LexHashIncPos(Parser, IncPos)
            LexHashIfdef(Parser, true)
        elseif Token == LexToken.TokenHashIf then
            LexHashIncPos(Parser, IncPos)
            LexHashIf(Parser)
        elseif Token == LexToken.TokenHashElse then
            LexHashIncPos(Parser, IncPos)
            LexHashElse(Parser)
        elseif Token == LexToken.TokenHashEndif then
            LexHashIncPos(Parser, IncPos)
            LexHashEndif(Parser)
        else
            WasPreProcToken = false
        end

        TryNextToken = ((Parser.HashIfEvaluateToLevel < Parser.HashIfLevel and
            Token ~= LexToken.TokenEOF) or WasPreProcToken)
        if not IncPos and TryNextToken then
            LexGetRawToken(Parser, nil, true)
        end
    until not TryNextToken

    return Token, Value
end

function LexRawPeekToken(Parser)
    return GET_PARSING(Parser)
end

function LexToEndOfMacro(Parser)
    local isContinued = false
    while true do
        local Token = GET_PARSING(Parser)
        if Token == LexToken.TokenEOF then
            return
        elseif Token == LexToken.TokenEndOfLine then
            if not isContinued then
                return
            end
            isContinued = false
        end
        if Token == LexToken.TokenBackSlash then
            isContinued = true
        end
        LexGetRawToken(Parser, nil, true)
    end
end

function LexCopyTokens(StartParser, EndParser)
    local EndPos
    local ParsingTokens = StartParser.ParsingTokens
    local EndParsingTokens = EndParser.ParsingTokens
    local NewTokens
    local ILine
    local pc = StartParser.pc

    if pc.InteractiveHead == nil then
        NewTokens = {}
        for i = StartParser.Pos, EndParser.Pos - 1 do
            table.insert(NewTokens, ParsingTokens[i])
        end
    else
        pc.InteractiveCurrentLine = pc.InteractiveHead
        while (pc.InteractiveCurrentLine ~= nil and
            ParsingTokens ~= pc.InteractiveCurrentLine.Tokens) do
            pc.InteractiveCurrentLine = pc.InteractiveCurrentLine.Next
        end

        if EndParsingTokens == ParsingTokens then
            NewTokens = {}
            for i = StartParser.Pos, EndParser.Pos - 1 do
                table.insert(NewTokens, ParsingTokens[i])
            end
        else
            EndPos = pc.InteractiveCurrentLine.NumBytes - TOKEN_DATA_OFFSET + 1
            NewTokens = {}
            for i = StartParser.Pos, EndPos - 1 do
                table.insert(NewTokens, ParsingTokens[i])
            end
            ILine = pc.InteractiveCurrentLine.Next
            while ILine ~= nil and EndParsingTokens ~= ILine.Tokens do
                for i = 1, ILine.NumBytes - TOKEN_DATA_OFFSET do
                    table.insert(NewTokens, ILine.Tokens[i])
                end
                ILine = ILine.Next
            end
            assert(ILine ~= nil, "LexCopyTokens: ILine is null")
            for i = 1, EndParser.Pos - 1 do
                table.insert(NewTokens, ILine.Tokens[i])
            end
        end
    end

    table.insert(NewTokens, LexToken.TokenEndOfFunction)
    table.insert(NewTokens, 0)

    return NewTokens
end

function LexInteractiveClear(pc, Parser)
    while pc.InteractiveHead ~= nil do
        pc.InteractiveHead = pc.InteractiveHead.Next
    end

    if Parser ~= nil then
        Parser.ParsingTokens = nil
    end

    pc.InteractiveTail = nil
    collectgarbage()
end

function LexInteractiveCompleted(pc, Parser)
    while (pc.InteractiveHead ~= nil and
        Parser.ParsingTokens ~= pc.InteractiveHead.Tokens) do
        pc.InteractiveHead = pc.InteractiveHead.Next

        if pc.InteractiveHead == nil then
            Parser.ParsingTokens = nil
            pc.InteractiveTail = nil
        end
    end

    collectgarbage()
end

function LexInteractiveStatementPrompt(pc)
    pc.LexUseStatementPrompt = true
end
