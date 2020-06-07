function IS_FP(v)
    return v.Typ.Base == BaseType.TypeFP
end

function FP_VAL(v)
    return v.Val.FP
end

function IS_POINTER_COERCIBLE(v, ap)
    if ap then
        return v.Typ.Base == BaseType.TypePointer
    else
        return false
    end
end

function POINTER_COERCE(v)
    return "v.Val.Pointer"
end

function IS_INTEGER_NUMERIC_TYPE(t)
    return (t.Base >= BaseType.TypeInt) and (t.Base <= BaseType.TypeUnsignedLong)
end

function IS_INTEGER_NUMERIC(v)
    return IS_INTEGER_NUMERIC_TYPE(v.Typ)
end

function IS_NUMERIC_COERCIBLE(v)
    return IS_INTEGER_NUMERIC(v) or IS_FP(v)
end

function IS_NUMERIC_COERCIBLE_PLUS_POINTERS(v, ap)
    return IS_NUMERIC_COERCIBLE(v) or IS_POINTER_COERCIBLE(v, ap)
end

function LUA_BOOLEAN_TO_C(cond)
    if cond then
        return 1
    else
        return 0
    end
end

function C_INT_TO_LUA_BOOLEAN(i)
    if i ~= 0 then
        return true
    else
        return false
    end
end

function C_LOGICAL_AND(a, b)
    return LUA_BOOLEAN_TO_C((a ~= 0) and (b ~= 0))
end

function C_LOGICAL_OR(a, b)
    return LUA_BOOLEAN_TO_C((a ~= 0) or (b ~= 0))
end

function MIN(a, b)
    if a < b then
        return a
    else
        return b
    end
end

LexToken = {
    TokenNone = 1,
    TokenComma = 2,
    TokenAssign = 3,
    TokenAddAssign = 4,
    TokenSubtractAssign = 5,
    TokenMultiplyAssign = 6,
    TokenDivideAssign = 7,
    TokenModulusAssign = 8,
    TokenShiftLeftAssign = 9,
    TokenShiftRightAssign = 10,
    TokenArithmeticAndAssign = 11,
    TokenArithmeticOrAssign = 12,
    TokenArithmeticExorAssign = 13,
    TokenQuestionMark = 14,
    TokenColon = 15,
    TokenLogicalOr = 16,
    TokenLogicalAnd = 17,
    TokenArithmeticOr = 18,
    TokenArithmeticExor = 19,
    TokenAmpersand = 20,
    TokenEqual = 21,
    TokenNotEqual = 22,
    TokenLessThan = 23,
    TokenGreaterThan = 24,
    TokenLessEqual = 25,
    TokenGreaterEqual = 26,
    TokenShiftLeft = 27,
    TokenShiftRight = 28,
    TokenPlus = 29,
    TokenMinus = 30,
    TokenAsterisk = 31,
    TokenSlash = 32,
    TokenModulus = 33,
    TokenIncrement = 34,
    TokenDecrement = 35,
    TokenUnaryNot = 36,
    TokenUnaryExor = 37,
    TokenSizeof = 38,
    TokenCast = 39,
    TokenLeftSquareBracket = 40,
    TokenRightSquareBracket = 41,
    TokenDot = 42,
    TokenArrow = 43,
    TokenOpenBracket = 44,
    TokenCloseBracket = 45,
    TokenIdentifier = 46,
    TokenIntegerConstant = 47,
    TokenFPConstant = 48,
    TokenStringConstant = 49,
    TokenCharacterConstant = 50,
    TokenSemicolon = 51,
    TokenEllipsis = 52,
    TokenLeftBrace = 53,
    TokenRightBrace = 54,
    TokenIntType = 55,
    TokenCharType = 56,
    TokenFloatType = 57,
    TokenDoubleType = 58,
    TokenVoidType = 59,
    TokenEnumType = 60,
    TokenLongType = 61,
    TokenSignedType = 62,
    TokenShortType = 63,
    TokenStaticType = 64,
    TokenAutoType = 65,
    TokenRegisterType = 66,
    TokenExternType = 67,
    TokenStructType = 68,
    TokenUnionType = 69,
    TokenUnsignedType = 70,
    TokenTypedef = 71,
    TokenContinue = 72,
    TokenDo = 73,
    TokenElse = 74,
    TokenFor = 75,
    TokenGoto = 76,
    TokenIf = 77,
    TokenWhile = 78,
    TokenBreak = 79,
    TokenSwitch = 80,
    TokenCase = 81,
    TokenDefault = 82,
    TokenReturn = 83,
    TokenHashDefine = 84,
    TokenHashInclude = 85,
    TokenHashIf = 86,
    TokenHashIfdef = 87,
    TokenHashIfndef = 88,
    TokenHashElse = 89,
    TokenHashEndif = 90,
    TokenNew = 91,
    TokenDelete = 92,
    TokenOpenMacroBracket = 93,
    TokenEOF = 94,
    TokenEndOfLine = 95,
    TokenEndOfFunction = 96,
    TokenBackSlash = 97
}

RunMode = {
    RunModeRun = 1,
    RunModeSkip = 2,
    RunModeReturn = 3,
    RunModeCaseSearch = 4,
    RunModeBreak = 5,
    RunModeContinue = 6,
    RunModeGoto = 7
}

BaseType = {
    TypeVoid = 1,
    TypeInt = 2,
    TypeShort = 3,
    TypeChar = 4,
    TypeLong = 5,
    TypeUnsignedInt = 6,
    TypeUnsignedShort = 7,
    TypeUnsignedChar = 8,
    TypeUnsignedLong = 9,
    TypeFP = 10,
    TypeFunction = 11,
    TypeMacro = 12,
    TypePointer = 13,
    TypeArray = 14,
    TypeStruct = 15,
    TypeUnion = 16,
    TypeEnum = 17,
    TypeGotoLabel = 18,
    TypeType = 19
}

LexMode = {
    LexModeNormal = 1,
    LexModeHashInclude = 2,
    LexModeHashDefine = 3,
    LexModeHashDefineSpace = 4,
    LexModeHashDefineSpaceIdent = 5
}

ParserResult = {
    ParseResultEOF = 1,
    ParseResultError = 2,
    ParseResultOk = 3
}

FREELIST_BUCKETS = 8
SPLIT_MEM_THRESHOLD = 17
BREAKPOINT_TABLE_SIZE = 21

Debug = false
VariableDebug = false
