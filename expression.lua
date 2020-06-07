BRACKET_PRECEDENCE = 20
DEEP_PRECEDENCE = BRACKET_PRECEDENCE * 1000

function IS_LEFT_TO_RIGHT(p)
    return (p ~= 2) and (p ~= 14)
end

-- enum OperatorOrder
OperatorOrder = {
    OrderNone = 1,
    OrderPrefix = 2,
    OrderInfix = 3,
    OrderPostfix = 4
}

OperatorPrecedence = {
    -- TokenNone
    {
        PrefixPrecedence = 0,
        PostfixPrecedence = 0,
        InfixPrecedence = 0,
        Name = "none",
    },
    -- TokenComma
    {
        PrefixPrecedence = 0,
        PostfixPrecedence = 0,
        InfixPrecedence = 0,
        Name = ",",
    },
    -- TokenAssign
    {
        PrefixPrecedence = 0,
        PostfixPrecedence = 0,
        InfixPrecedence = 2,
        Name = "=",
    },
    -- TokenAddAssign
    {
        PrefixPrecedence = 0,
        PostfixPrecedence = 0,
        InfixPrecedence = 2,
        Name = "+=",
    },
    -- TokenSubtractAssign
    {
        PrefixPrecedence = 0,
        PostfixPrecedence = 0,
        InfixPrecedence = 2,
        Name = "-=",
    },
    -- TokenMultiplyAssign
    {
        PrefixPrecedence = 0,
        PostfixPrecedence = 0,
        InfixPrecedence = 2,
        Name = "*=",
    },
    -- TokenDivideAssign
    {
        PrefixPrecedence = 0,
        PostfixPrecedence = 0,
        InfixPrecedence = 2,
        Name = "/=",
    },
    -- TokenModulusAssign
    {
        PrefixPrecedence = 0,
        PostfixPrecedence = 0,
        InfixPrecedence = 2,
        Name = "%=",
    },
    -- TokenShiftLeftAssign
    {
        PrefixPrecedence = 0,
        PostfixPrecedence = 0,
        InfixPrecedence = 2,
        Name = "<<=",
    },
    -- TokenShiftRightAssign
    {
        PrefixPrecedence = 0,
        PostfixPrecedence = 0,
        InfixPrecedence = 2,
        Name = ">>=",
    },
    -- TokenArithmeticAndAssign
    {
        PrefixPrecedence = 0,
        PostfixPrecedence = 0,
        InfixPrecedence = 2,
        Name = "&=",
    },
    -- TokenArithmeticOrAssign
    {
        PrefixPrecedence = 0,
        PostfixPrecedence = 0,
        InfixPrecedence = 2,
        Name = "|=",
    },
    -- TokenArithmeticExorAssign
    {
        PrefixPrecedence = 0,
        PostfixPrecedence = 0,
        InfixPrecedence = 2,
        Name = "^=",
    },
    -- TokenQuestionMark
    {
        PrefixPrecedence = 0,
        PostfixPrecedence = 0,
        InfixPrecedence = 3,
        Name = "?",
    },
    -- TokenColon
    {
        PrefixPrecedence = 0,
        PostfixPrecedence = 0,
        InfixPrecedence = 3,
        Name = ":",
    },
    -- TokenLogicalOr
    {
        PrefixPrecedence = 0,
        PostfixPrecedence = 0,
        InfixPrecedence = 4,
        Name = "||",
    },
    -- TokenLogicalAnd
    {
        PrefixPrecedence = 0,
        PostfixPrecedence = 0,
        InfixPrecedence = 5,
        Name = "&&",
    },
    -- TokenArithmeticOr
    {
        PrefixPrecedence = 0,
        PostfixPrecedence = 0,
        InfixPrecedence = 6,
        Name = "=",
    },
    -- TokenArithmeticExor
    {
        PrefixPrecedence = 0,
        PostfixPrecedence = 0,
        InfixPrecedence = 7,
        Name = "^",
    },
    -- TokenAmpersand
    {
        PrefixPrecedence = 14,
        PostfixPrecedence = 0,
        InfixPrecedence = 8,
        Name = "&",
    },
    -- TokenEqual
    {
        PrefixPrecedence = 0,
        PostfixPrecedence = 0,
        InfixPrecedence = 9,
        Name = "==",
    },
    -- TokenNotEqual
    {
        PrefixPrecedence = 0,
        PostfixPrecedence = 0,
        InfixPrecedence = 9,
        Name = "!=",
    },
    -- TokenLessThan
    {
        PrefixPrecedence = 0,
        PostfixPrecedence = 0,
        InfixPrecedence = 10,
        Name = "<",
    },
    -- TokenGreaterThan
    {
        PrefixPrecedence = 0,
        PostfixPrecedence = 0,
        InfixPrecedence = 10,
        Name = ">",
    },
    -- TokenLessEqual
    {
        PrefixPrecedence = 0,
        PostfixPrecedence = 0,
        InfixPrecedence = 10,
        Name = "<=",
    },
    -- TokenGreaterEqual
    {
        PrefixPrecedence = 0,
        PostfixPrecedence = 0,
        InfixPrecedence = 10,
        Name = ">=",
    },
    -- TokenShiftLeft
    {
        PrefixPrecedence = 0,
        PostfixPrecedence = 0,
        InfixPrecedence = 11,
        Name = "<<",
    },
    -- TokenShiftRight
    {
        PrefixPrecedence = 0,
        PostfixPrecedence = 0,
        InfixPrecedence = 11,
        Name = ">>",
    },
    -- TokenPlus
    {
        PrefixPrecedence = 14,
        PostfixPrecedence = 0,
        InfixPrecedence = 12,
        Name = "+",
    },
    -- TokenMinus
    {
        PrefixPrecedence = 14,
        PostfixPrecedence = 0,
        InfixPrecedence = 12,
        Name = "-",
    },
    -- TokenAsterisk
    {
        PrefixPrecedence = 14,
        PostfixPrecedence = 0,
        InfixPrecedence = 13,
        Name = "*",
    },
    -- TokenSlash
    {
        PrefixPrecedence = 0,
        PostfixPrecedence = 0,
        InfixPrecedence = 13,
        Name = "/",
    },
    -- TokenModulus
    {
        PrefixPrecedence = 0,
        PostfixPrecedence = 0,
        InfixPrecedence = 13,
        Name = "%",
    },
    -- TokenIncrement
    {
        PrefixPrecedence = 14,
        PostfixPrecedence = 15,
        InfixPrecedence = 0,
        Name = "++",
    },
    -- TokenDecrement
    {
        PrefixPrecedence = 14,
        PostfixPrecedence = 15,
        InfixPrecedence = 0,
        Name = "--",
    },
    -- TokenUnaryNot
    {
        PrefixPrecedence = 14,
        PostfixPrecedence = 0,
        InfixPrecedence = 0,
        Name = "!",
    },
    -- TokenUnaryExor
    {
        PrefixPrecedence = 14,
        PostfixPrecedence = 0,
        InfixPrecedence = 0,
        Name = "~",
    },
    -- TokenSizeof
    {
        PrefixPrecedence = 14,
        PostfixPrecedence = 0,
        InfixPrecedence = 0,
        Name = "sizeof",
    },
    -- TokenCast
    {
        PrefixPrecedence = 14,
        PostfixPrecedence = 0,
        InfixPrecedence = 0,
        Name = "cast",
    },
    -- TokenLeftSquareBracket
    {
        PrefixPrecedence = 0,
        PostfixPrecedence = 0,
        InfixPrecedence = 15,
        Name = "[",
    },
    -- TokenRightSquareBracket
    {
        PrefixPrecedence = 0,
        PostfixPrecedence = 15,
        InfixPrecedence = 0,
        Name = "]",
    },
    -- TokenDot
    {
        PrefixPrecedence = 0,
        PostfixPrecedence = 0,
        InfixPrecedence = 15,
        Name = ".",
    },
    -- TokenArrow
    {
        PrefixPrecedence = 0,
        PostfixPrecedence = 0,
        InfixPrecedence = 15,
        Name = "->",
    },
    -- TokenOpenBracket
    {
        PrefixPrecedence = 15,
        PostfixPrecedence = 0,
        InfixPrecedence = 0,
        Name = "(",
    },
    -- TokenCloseBracket
    {
        PrefixPrecedence = 0,
        PostfixPrecedence = 15,
        InfixPrecedence = 0,
        Name = ")",
    },
}

function IsTypeToken(Parser, t, LexValue)
    local VarValue

    if t >= LexToken.TokenIntType and t <= LexToken.TokenUnsignedType then
        return true
    end

    if t == LexToken.TokenIdentifier then
        if VariableDefined(Parser.pc, LexValue.Val) then
            VarValue = VariableGet(Parser.pc, Parser, LexValue.Val)
            if VarValue.Typ == Parser.pc.TypeType then
                return true
            end
        end
    end

    return false
end

function ExpressionCoerceInteger(Val)
    if Val.Typ.Base == BaseType.TypeInt then
        return PointerGetSignedInt(Val.Val)
    elseif Val.Typ.Base == BaseType.TypeUnsignedInt then
        return PointerGetUnsignedInt(Val.Val)
    elseif Val.Typ.Base == BaseType.TypeChar then
        return PointerGetSignedChar(Val.Val)
    elseif Val.Typ.Base == BaseType.TypeUnsignedChar then
        return PointerGetUnsignedChar(Val.Val)
    elseif Val.Typ.Base == BaseType.TypeShort then
        return PointerGetSignedShort(Val.Val)
    elseif Val.Typ.Base == BaseType.TypeUnsignedShort then
        return PointerGetUnsignedShort(Val.Val)
    elseif Val.Typ.Base == BaseType.TypeLong then
        return PointerGetSignedInt(Val.Val)
    elseif Val.Typ.Base == BaseType.TypeUnsignedLong then
        return PointerGetUnsignedInt(Val.Val)
    elseif Val.Typ.Base == BaseType.TypePointer then
        -- Getting the absolute address of a pointer is not supported
        -- If pointer is not null, cast a dummy address
        if IsPointerNull(Val.Val) then
            return 0
        else
            return 0xCCCC
        end
    elseif Val.Typ.Base == BaseType.TypeFP then
        print("FP")
        return (math.floor(PointerGetFP(Val.Val)) + 0x80000000) % 0x100000000 - 0x80000000
    else
        return 0
    end
end

function ExpressionCoerceUnsignedInteger(Val)
    if Val.Typ.Base == BaseType.TypeInt then
        return PointerGetUnsignedInt(Val.Val)
    elseif Val.Typ.Base == BaseType.TypeUnsignedInt then
        return PointerGetUnsignedInt(Val.Val)
    elseif Val.Typ.Base == BaseType.TypeChar then
        return PointerGetUnsignedChar(Val.Val)
    elseif Val.Typ.Base == BaseType.TypeUnsignedChar then
        return PointerGetUnsignedChar(Val.Val)
    elseif Val.Typ.Base == BaseType.TypeShort then
        return PointerGetUnsignedShort(Val.Val)
    elseif Val.Typ.Base == BaseType.TypeUnsignedShort then
        return PointerGetUnsignedShort(Val.Val)
    elseif Val.Typ.Base == BaseType.TypeLong then
        return PointerGetUnsignedInt(Val.Val)
    elseif Val.Typ.Base == BaseType.TypeUnsignedLong then
        return PointerGetUnsignedInt(Val.Val)
    elseif Val.Typ.Base == BaseType.TypePointer then
        -- Getting the absolute address of a pointer is not supported
        -- If pointer is not null, cast a dummy address
        if IsPointerNull(Val.Val) then
            return 0
        else
            return 0xCCCC
        end
    elseif Val.Typ.Base == BaseType.TypeFP then
        return math.floor(PointerGetFP(Val.Val)) % 0x100000000
    else
        return 0
    end
end

function ExpressionCoerceFP(Val)
    if Val.Typ.Base == BaseType.TypeInt then
        return PointerGetSignedInt(Val.Val)
    elseif Val.Typ.Base == BaseType.TypeUnsignedInt then
        return PointerGetUnsignedInt(Val.Val)
    elseif Val.Typ.Base == BaseType.TypeChar then
        return PointerGetSignedChar(Val.Val)
    elseif Val.Typ.Base == BaseType.TypeUnsignedChar then
        return PointerGetUnsignedChar(Val.Val)
    elseif Val.Typ.Base == BaseType.TypeShort then
        return PointerGetSignedShort(Val.Val)
    elseif Val.Typ.Base == BaseType.TypeUnsignedShort then
        return PointerGetUnsignedShort(Val.Val)
    elseif Val.Typ.Base == BaseType.TypeLong then
        return PointerGetSignedInt(Val.Val)
    elseif Val.Typ.Base == BaseType.TypeUnsignedLong then
        return PointerGetUnsignedInt(Val.Val)
    elseif Val.Typ.Base == BaseType.TypeFP then
        return PointerGetFP(Val.Val)
    else
        return 0
    end
end

function ExpressionAssignInt(Parser, DestValue, FromInt, After)
    local Result

    if not DestValue.IsLValue then
        ProgramFail(Parser, "can't assign to this")
    end

    if After then
        Result = ExpressionCoerceInteger(DestValue)
    else
        Result = FromInt
    end

    if (DestValue.Typ.Base == BaseType.TypeInt or
        DestValue.Typ.Base == BaseType.TypeUnsignedInt) then
        PointerSetSignedOrUnsignedInt(DestValue.Val, FromInt)
    elseif (DestValue.Typ.Base == BaseType.TypeChar or
        DestValue.Typ.Base == BaseType.TypeUnsignedChar) then
        PointerSetSignedOrUnsignedChar(DestValue.Val, FromInt)
    elseif (DestValue.Typ.Base == BaseType.TypeShort or
        DestValue.Typ.Base == BaseType.TypeUnsignedShort) then
        PointerSetSignedOrUnsignedShort(DestValue.Val, FromInt)
    elseif (DestValue.Typ.Base == BaseType.TypeLong or
        DestValue.Typ.Base == BaseType.TypeUnsignedLong) then
        PointerSetSignedOrUnsignedInt(DestValue.Val, FromInt)
    end
    --if VariableDebug then
    --    print("Variable:", FromInt)
    --end

    return Result
end

function ExpressionAssignFP(Parser, DestValue, FromFP)
    if not DestValue.IsLValue then
        ProgramFail(Parser, "can't assign to this")
    end

    PointerSetFP(DestValue.Val, FromFP)
    --if VariableDebug then
    --    print("Variable:", FromFP)
    --end
    return FromFP
end

function ExpressionStackPushValueNode(Parser, StackTop, ValueLoc)
    local StackNode
    StackNode = VariableAlloc(Parser.pc, Parser, false)
    if StackTop == nil then
        StackNode.NextNodeId = 0
    else
        StackNode.NextNodeId = StackTop.StackId
    end
    StackNode.Val = ValueLoc
    StackNode.Op = LexToken.TokenNone
    StackNode.Precedence = 0
    StackNode.Order = OperatorOrder.OrderNone
    StackTop = StackNode

    -- #ifdef FANCY_ERROR_MESSAGES
    --StackNode.Line = Parser.Line
    --StackNode.CharacterPos = Parser.CharacterPos
    -- #endif

    -- #ifdef DEBUG_EXPRESSIONS
    -- ExpressionStackShow(Parser.pc, StackTop)
    -- #endif

    return StackTop
end

function ExpressionStackPushValueByType(Parser, StackTop, PushType)
    local ValueLoc
    ValueLoc = VariableAllocValueFromType(Parser.pc, Parser,
        PushType, false, nil, false)
    StackTop = ExpressionStackPushValueNode(Parser, StackTop, ValueLoc)
    --if Debug then
    --    print("Set", ValueLoc.Typ.Base)
    --end

    return ValueLoc, StackTop
end

function ExpressionStackPushValue(Parser, StackTop, PushValue)
    local ValueLoc = VariableAllocValueAndCopy(Parser.pc, Parser,
        PushValue, false)
    StackTop = ExpressionStackPushValueNode(Parser, StackTop, ValueLoc)

    return StackTop
end

function ExpressionStackPushLValue(Parser, StackTop, PushValue, Offset)
    local ValueLoc = VariableAllocValueShared(Parser, PushValue)
    StackTop = ExpressionStackPushValueNode(Parser, StackTop, ValueLoc)

    return StackTop
end

function ExpressionStackPushDereference(Parser, StackTop, DereferenceValue)
    local DerefIsLValue, DerefVal, ValueLoc, DerefType
    local DerefDataLoc
    DerefDataLoc, DerefVal, DerefType, _, DerefIsLValue =
        VariableDereferencePointer(DereferenceValue)
    --print("Dereference:", DerefType.Base)
    if DerefDataLoc == nil then
        ProgramFail(Parser, "trying to dereference a void pointer - is the pointer NULL or pointing to a deallocated variable?")
    end

    ValueLoc = VariableAllocValueFromExistingData(Parser, DerefType,
        DerefDataLoc, DerefIsLValue, DerefVal)
    StackTop = ExpressionStackPushValueNode(Parser, StackTop, ValueLoc)
    return StackTop
end

function ExpressionPushInt(Parser, StackTop, IntValue)
    local ValueLoc = VariableAllocValueFromType(Parser.pc, Parser,
        Parser.pc.IntType, false, nil, false)
    PointerSetSignedOrUnsignedInt(ValueLoc.Val, IntValue)

    StackTop = ExpressionStackPushValueNode(Parser, StackTop, ValueLoc)
    return StackTop
end

function ExpressionPushFP(Parser, StackTop, FPValue)
    local ValueLoc = VariableAllocValueFromType(Parser.pc, Parser,
        Parser.pc.FPType, false, nil, false)
    PointerSetFP(ValueLoc.Val, FPValue)

    StackTop = ExpressionStackPushValueNode(Parser, StackTop, ValueLoc)
    return StackTop
end

function ExpressionAssignToPointer(Parser, ToValue, FromValue, FuncName, ParamNo, AllowPointerCoercion)
    local PointedToType = ToValue.Typ.FromType

    if (FromValue.Typ == ToValue.Typ or
        FromValue.Typ == Parser.pc.VoidPtrType or
        (ToValue.Typ == Parser.pc.VoidPtrType and
        FromValue.Typ.Base == BaseType.TypePointer)) then
        PointerCopyPointer(ToValue.Val, FromValue.Val)
    elseif (FromValue.Typ.Base == BaseType.TypeArray and
        (PointedToType == FromValue.Typ.FromType or
        ToValue.Typ == Parser.pc.VoidPtrType)) then
        PointerReference(ToValue.Val, FromValue.Val)
        --print("CoercePointer:", PointerGetSignedInt(ToValue.Val))
    elseif (FromValue.Typ.Base == BaseType.TypePointer and
        FromValue.Typ.FromType.Base == BaseType.TypeArray and
        (PointedToType == FromValue.Typ.FromType.FromType or
        ToValue.Typ == Parser.pc.VoidPtrType)) then
        PointerCopyPointer(ToValue.Val, FromValue.Val)
    elseif (IS_NUMERIC_COERCIBLE(FromValue) and
        ExpressionCoerceInteger(FromValue) == 0) then
        PointerSetNull(ToValue.Val)
    elseif AllowPointerCoercion and IS_NUMERIC_COERCIBLE(FromValue) then
        -- Assigning absolute address is not supported:
        -- There is no real address space!
        ProgramFail(Parser, "assigning absolute address to pointer is not supported")
    elseif AllowPointerCoercion and FromValue.Typ.Base == BaseType.TypePointer then
        PointerCopyPointer(ToValue.Val, FromValue.Val)
    else
        AssignFail(Parser, "%t from %t", ToValue.Typ, FromValue.Typ, 0, 0,
            FuncName, ParamNo)
    end
end

function ExpressionAssign(Parser, DestValue, SourceValue, Force, FuncName, ParamNo, AllowPointerCoercion)
    if not DestValue.IsLValue and not Force then
        AssignFail(Parser, "not an lvalue", nil, nil, 0, 0, FuncName, ParamNo)
    end

    if (IS_NUMERIC_COERCIBLE(DestValue) and
        not IS_NUMERIC_COERCIBLE_PLUS_POINTERS(SourceValue, AllowPointerCoercion)) then
        AssignFail(Parser, "%t from %t", DestValue.Typ, SourceValue.Typ, 0, 0,
            FuncName, ParamNo)
    end

    if DestValue.Typ.Base == BaseType.TypeInt then
        --if VariableDebug then
        --    print("Variable:", ExpressionCoerceInteger(SourceValue))
        --end
        PointerSetSignedOrUnsignedInt(DestValue.Val, ExpressionCoerceInteger(SourceValue))
    elseif DestValue.Typ.Base == BaseType.TypeShort then
        --if VariableDebug then
        --    print("Variable:", ExpressionCoerceInteger(SourceValue))
        --end
        PointerSetSignedOrUnsignedShort(DestValue.Val, ExpressionCoerceInteger(SourceValue))
    elseif DestValue.Typ.Base == BaseType.TypeChar then
        --if VariableDebug then
        --    print("Variable:", ExpressionCoerceInteger(SourceValue))
        --end
        PointerSetSignedOrUnsignedChar(DestValue.Val, ExpressionCoerceInteger(SourceValue))
    elseif DestValue.Typ.Base == BaseType.TypeLong then
        --if VariableDebug then
        --    print("Variable:", ExpressionCoerceInteger(SourceValue))
        --end
        PointerSetSignedOrUnsignedInt(DestValue.Val, ExpressionCoerceInteger(SourceValue))
    elseif DestValue.Typ.Base == BaseType.TypeUnsignedInt then
        --if VariableDebug then
        --    print("Variable:", ExpressionCoerceInteger(SourceValue))
        --end
        PointerSetSignedOrUnsignedInt(DestValue.Val, ExpressionCoerceUnsignedInteger(SourceValue))
    elseif DestValue.Typ.Base == BaseType.TypeUnsignedShort then
        --if VariableDebug then
        --    print("Variable:", ExpressionCoerceInteger(SourceValue))
        --end
        PointerSetSignedOrUnsignedShort(DestValue.Val, ExpressionCoerceUnsignedInteger(SourceValue))
    elseif DestValue.Typ.Base == BaseType.TypeUnsignedLong then
        --if VariableDebug then
        --    print("Variable:", ExpressionCoerceInteger(SourceValue))
        --end
        PointerSetSignedOrUnsignedInt(DestValue.Val, ExpressionCoerceUnsignedInteger(SourceValue))
    elseif DestValue.Typ.Base == BaseType.TypeUnsignedChar then
        --if VariableDebug then
        --    print("Variable:", ExpressionCoerceInteger(SourceValue))
        --end
        PointerSetSignedOrUnsignedChar(DestValue.Val, ExpressionCoerceInteger(SourceValue))
    elseif DestValue.Typ.Base == BaseType.TypeFP then
        --if VariableDebug then
        --    print("Variable:", ExpressionCoerceFP(SourceValue))
        --end
        if not IS_NUMERIC_COERCIBLE_PLUS_POINTERS(SourceValue, AllowPointerCoercion) then
            AssignFail(Parser, "%t from %t", DestValue.Typ, SourceValue.Typ, 0, 0,
                FuncName, ParamNo)
        end
        PointerSetFP(DestValue.Val, ExpressionCoerceFP(SourceValue))
    elseif DestValue.Typ.Base == BaseType.TypePointer then
        ExpressionAssignToPointer(Parser, DestValue, SourceValue, FuncName,
            ParamNo, AllowPointerCoercion)
    elseif DestValue.Typ.Base == BaseType.TypeArray then
        local DerefVal, Size

        if (SourceValue.Typ.Base == BaseType.TypeArray and
            DestValue.Typ.ArraySize == 0) then
            DestValue.Typ = SourceValue.Typ
            VariableRealloc(Parser, DestValue, TypeSizeValue(DestValue, false))

            if DestValue.LValueFrom ~= nil then
                DestValue.LValueFrom.Val = DestValue.Val
                DestValue.LValueFrom.AnyValOnHeap = DestValue.AnyValOnHeap
            end
        end

        if (DestValue.Typ.FromType.Base == BaseType.TypeChar and
            SourceValue.Typ.Base == BaseType.TypePointer and
            SourceValue.Typ.FromType.Base == BaseType.TypeChar) then
            DerefVal = PointerDereference(SourceValue.Val)

            if DestValue.Typ.ArraySize == 0 then
                Size = PointerStringLen(DerefVal)

                DestValue.Typ = TypeGetMatching(Parser.pc, Parser,
                    DestValue.Typ.FromType, DestValue.Typ.Base,
                    Size, DestValue.Typ.Identifier, true)
                VariableRealloc(Parser, DestValue, TypeSizeValue(DestValue,
                    false))
            end

            PointerCopyValue(DestValue.Val, DerefVal, DestValue.Typ)
        else
            if DestValue.Typ ~= SourceValue.Typ then
                AssignFail(Parser, "%t from %t", DestValue.Typ, SourceValue.Typ,
                    0, 0, FuncName, ParamNo)
            end

            if DestValue.Typ.ArraySize ~= SourceValue.Typ.ArraySize then
                AssignFail(Parser, "from an array of size %d to one of size %d",
                    nil, nil, DestValue.Typ.ArraySize,
                    SourceValue.Typ.ArraySize, FuncName, ParamNo)
            end

            PointerCopyValue(DestValue.Val, SourceValue.Val, DestValue.Typ)
        end
    elseif (DestValue.Typ.Base == BaseType.TypeStruct or
        DestValue.Typ.Base == BaseType.TypeUnion) then
        if DestValue.Typ ~= SourceValue.Typ then
           AssignFail(Parser, "%t from %t", DestValue.Typ, SourceValue.Typ,
                0, 0, FuncName, ParamNo)
        end
        PointerCopyValue(DestValue.Val, SourceValue.Val, DestValue.Typ)
    else
        AssignFail(Parser, "%t", DestValue.Typ, nil, 0, 0, FuncName, ParamNo)
    end
end

function ExpressionQuestionMarkOperator(Parser, StackTop, BottomValue, TopValue)
    if not IS_NUMERIC_COERCIBLE(TopValue) then
        ProgramFail(Parser, "first argument to '?' should be a number")
    end

    if ExpressionCoerceInteger(TopValue) ~= 0 then
        StackTop = ExpressionStackPushValue(Parser, StackTop, BottomValue)
    else
        _, StackTop = ExpressionStackPushValueByType(Parser, StackTop, Parser.pc.VoidType)
    end

    return StackTop
end

function ExpressionColonOperator(Parser, StackTop, BottomValue, TopValue)
    if TopValue.Typ.Base == BaseType.TypeVoid then
        StackTop = ExpressionStackPushValue(Parser, StackTop, BottomValue)
    else
        StackTop = ExpressionStackPushValue(Parser, StackTop, TopValue)
    end

    return StackTop
end

function ExpressionPrefixOperator(Parser, StackTop, Op, TopValue)
    local Result, Typ
    local ResultFP, ResultInt, TopInt

    if Op == LexToken.TokenAmpersand then
        if not TopValue.IsLValue then
            ProgramFail(Parser, "can't get the address of this")
        end

        Result = VariableAllocValueFromType(Parser.pc, Parser,
            TypeGetMatching(Parser.pc, Parser, TopValue.Typ,
                BaseType.TypePointer, 0, Parser.pc.StrEmpty, true),
            false, nil, false)
        PointerReference(Result.Val, TopValue.Val)

        StackTop = ExpressionStackPushValueNode(Parser, StackTop, Result)
    elseif Op == LexToken.TokenAsterisk then
        if StackTop ~= nil then
            if StackTop.Op == LexToken.TokenSizeof then
                _, StackTop = ExpressionStackPushValueByType(Parser, StackTop, TopValue.Typ)
            else
                StackTop = ExpressionStackPushDereference(Parser, StackTop, TopValue)
            end
        else
            StackTop = ExpressionStackPushDereference(Parser, StackTop, TopValue)
        end
    elseif Op == LexToken.TokenSizeof then
        if TopValue.Typ == Parser.pc.TypeType then
            Typ = TopValue.Val.Typ  -- Val here points to Typ, not AnyValue type
        else
            Typ = TopValue.Typ
        end
        --if Typ.FromType ~= nil then
        --    if Typ.FromType.Base == BaseType.TypeStruct then
        --        Typ = Typ.FromType
        --    end
        --end
        StackTop = ExpressionPushInt(Parser, StackTop, TypeSize(Typ, Typ.ArraySize, true))
    else
        if TopValue.Typ == Parser.pc.FPType then
            ResultFP = 0.0
            if Op == LexToken.TokenPlus then
                ResultFP = PointerGetFP(TopValue.Val)
            elseif Op == LexToken.TokenMinus then
                ResultFP = -PointerGetFP(TopValue.Val)
            elseif Op == LexToken.TokenIncrement then
                ResultFP = ExpressionAssignFP(Parser, TopValue,
                    PointerGetFP(TopValue.Val) + 1)
            elseif Op == LexToken.TokenDecrement then
                ResultFP = ExpressionAssignFP(Parser, TopValue,
                    PointerGetFP(TopValue.Val) - 1)
            elseif Op == LexToken.TokenUnaryNot then
                if PointerGetFP(TopValue.Val) == 0 then
                    ResultFP = 1
                else
                    ResultFP = 0
                end
            else
                ProgramFail(Parser, "invalid operation")
            end
            StackTop = ExpressionPushFP(Parser, StackTop, ResultFP)
        elseif IS_NUMERIC_COERCIBLE(TopValue) then
            ResultInt = 0
            TopInt = 0
            if TopValue.Typ.Base == BaseType.TypeLong then
                TopInt = PointerGetSignedInt(TopValue.Val)
            else
                TopInt = ExpressionCoerceInteger(TopValue)
            end
            if Op == LexToken.TokenPlus then
                ResultInt = TopInt
            elseif Op == LexToken.TokenMinus then
                ResultInt = -TopInt
            elseif Op == LexToken.TokenIncrement then
                ResultInt = ExpressionAssignInt(Parser, TopValue,
                    TopInt + 1, false)
            elseif Op == LexToken.TokenDecrement then
                ResultInt = ExpressionAssignInt(Parser, TopValue,
                    TopInt - 1, false)
            elseif Op == LexToken.TokenUnaryNot then
                if TopInt == 0 then
                    ResultInt = 1
                else
                    ResultInt = 0
                end
            elseif Op == LexToken.TokenUnaryExor then
                ResultInt = bnot(TopInt)
            else
                ProgramFail(Parser, "invalid operation")
            end
            StackTop = ExpressionPushInt(Parser, StackTop, ResultInt)
        elseif TopValue.Typ.Base == BaseType.TypePointer then
            local Size = TypeSize(TopValue.Typ.FromType, 0, true)
            local StackValue

            if Op ~= LexToken.TokenUnaryNot and IsPointerNull(TopValue.Val) then
                ProgramFail(Parser, "a. invalid use of a NULL pointer")
            end
            if not TopValue.IsLValue then
                ProgramFail(Parser, "can't assign to this")
            end
            if Op == LexToken.TokenIncrement then
                PointerMovePointer(TopValue.Val, Size)
            elseif Op == LexToken.TokenDecrement then
                PointerMovePointer(TopValue.Val, -Size)
            elseif Op == LexToken.TokenUnaryNot then
                if IsPointerNull(TopValue.Val) then
                    StackTop = ExpressionPushInt(Parser, StackTop, 1)
                else
                    StackTop = ExpressionPushInt(Parser, StackTop, 0)
                end
                return StackTop
            else
                ProgramFail(Parser, "invalid operation")
            end

            StackValue, StackTop = ExpressionStackPushValueByType(Parser, StackTop,
                TopValue.Typ)
            StackValue.Val = PointerCopyAllValues(TopValue.Val, true)
        else
            ProgramFail(Parser, "invalid operation")
        end
    end

    return StackTop
end

function ExpressionPostfixOperator(Parser, StackTop, Op, TopValue)
    local ResultFP, ResultInt, TopInt

    if TopValue.Typ == Parser.pc.FPType then
        ResultFP = 0.0

        if Op == LexToken.TokenIncrement then
            ResultFP = ExpressionAssignFP(Parser, TopValue, PointerGetFP(TopValue.Val) + 1)
        elseif Op == LexToken.TokenDecrement then
            ResultFP = ExpressionAssignFP(Parser, TopValue, PointerGetFP(TopValue.Val) - 1)
        else
            ProgramFail(Parser, "invalid operation")
        end
        StackTop = ExpressionPushFP(Parser, StackTop, ResultFP)
    elseif IS_NUMERIC_COERCIBLE(TopValue) then
        ResultInt = 0
        TopInt = ExpressionCoerceInteger(TopValue)
        if Op == LexToken.TokenIncrement then
            ResultInt = ExpressionAssignInt(Parser, TopValue, TopInt + 1, true)
        elseif Op == LexToken.TokenDecrement then
            ResultInt = ExpressionAssignInt(Parser, TopValue, TopInt - 1, true)
        elseif Op == LexToken.TokenRightSquareBracket then
            ProgramFail(Parser, "not supported")
        elseif Op == LexToken.TokenCloseBracket then
            ProgramFail(Parser, "not supported")
        else
            ProgramFail(Parser, "invalid operation")
        end
        StackTop = ExpressionPushInt(Parser, StackTop, ResultInt)
    elseif TopValue.Typ.Base == BaseType.TypePointer then
        local Size = TypeSize(TopValue.Typ.FromType, 0, true)
        local StackValue
        local OrigPointerVal = {}

        if IsPointerNull(TopValue.Val) then
            ProgramFail(Parser, "a. invalid use of a NULL or void pointer")
        end

        if not TopValue.IsLValue then
            ProgramFail(Parser, "can't assign to this")
        end

        OrigPointerVal = PointerCopyAllValues(TopValue.Val, true)

        if Op == LexToken.TokenIncrement then
            PointerMovePointer(TopValue.Val, Size)
        elseif Op == LexToken.TokenDecrement then
            PointerMovePointer(TopValue.Val, -Size)
        else
            ProgramFail(Parser, "invalid operation")
        end

        StackValue, StackTop = ExpressionStackPushValueByType(Parser, StackTop,
            TopValue.Typ)
        StackValue.Val = PointerCopyAllValues(OrigPointerVal, true)
    else
        ProgramFail(Parser, "invalid operation")
    end

    return StackTop
end

function ExpressionInfixOperator(Parser, StackTop, Op, BottomValue, TopValue)
    local NewValue
    local ResultInt, StackValue
    local ArrayIndex, Result
    local ResultIsInt, ResultFP, TopFP, BottomFP
    local TopInt, BottomInt
    local ValueLoc

    if BottomValue == nil or TopValue == nil then
        ProgramFail(Parser, "invalid expression")
    end

    --if Debug then
    --    print("ExpressionInfixOperator Enter", Op, "Position:", Parser.Line, Parser.CharacterPos)
    --end

    if Op == LexToken.TokenLeftSquareBracket then
        --if Debug then
        --    print("Infix ArrayOperation")
        --end
        if not IS_NUMERIC_COERCIBLE(TopValue) then
            ProgramFail(Parser, "array index must be an integer")
        end

        ArrayIndex = ExpressionCoerceInteger(TopValue)

        if BottomValue.Typ.Base == BaseType.TypeArray then
            NewValue = {}
            PointerDeriveNewValue(NewValue, BottomValue.Val, true)
            NewValue.Offset = NewValue.Offset + TypeSize(BottomValue.Typ, ArrayIndex, true)
            --print("Coerce1:", PointerGetSignedInt(NewValue))
            Result = VariableAllocValueFromExistingData(Parser,
                BottomValue.Typ.FromType, NewValue,
                BottomValue.IsLValue, BottomValue.LValueFrom)
            --print("Coerce1:", ArrayIndex, NewValue.Offset)
            --print("Coerce1:", string.len(Result.Val.RawValue.Val))
            --print("Coerce1:", PointerGetSignedInt(Result.Val))
        elseif BottomValue.Typ.Base == BaseType.TypePointer then
            NewValue = PointerCopyAllValues(BottomValue.Val, true)
            PointerMovePointer(NewValue, TypeSize(BottomValue.Typ.FromType, 0, true) * ArrayIndex)
            NewValue = PointerDereference(NewValue)
            if NewValue ~= nil then
                Result = VariableAllocValueFromExistingData(Parser,
                    BottomValue.Typ.FromType, NewValue,
                    BottomValue.IsLValue, BottomValue.LValueFrom)
            else
                ProgramFail(Parser, "trying to dereference a void pointer - is the pointer NULL or pointing to a deallocated variable?")
            end
        else
            ProgramFail(Parser, "this %t is not an array", BottomValue.Typ)
        end

        StackTop = ExpressionStackPushValueNode(Parser, StackTop, Result)
    elseif Op == LexToken.TokenQuestionMark then
        StackTop = ExpressionQuestionMarkOperator(Parser, StackTop, TopValue, BottomValue)
    elseif Op == LexToken.TokenColon then
        StackTop = ExpressionColonOperator(Parser, StackTop, TopValue, BottomValue)
    elseif ((TopValue.Typ == Parser.pc.FPType and BottomValue.Typ == Parser.pc.FPType) or
            (TopValue.Typ == Parser.pc.FPType and IS_NUMERIC_COERCIBLE(BottomValue)) or
            (IS_NUMERIC_COERCIBLE(TopValue) and BottomValue.Typ == Parser.pc.FPType)) then
        ResultIsInt = false
        ResultFP = 0.0
        if TopValue.Typ == Parser.pc.FPType then
            TopFP = PointerGetFP(TopValue.Val)
        else
            TopFP = ExpressionCoerceInteger(TopValue)
        end
        if BottomValue.Typ == Parser.pc.FPType then
            BottomFP = PointerGetFP(BottomValue.Val)
        else
            BottomFP = ExpressionCoerceInteger(BottomValue)
        end

        if Op == LexToken.TokenAssign then
            if IS_FP(BottomValue) then
                ResultFP = ExpressionAssignFP(Parser, BottomValue, TopFP)
            else
                ResultInt = ExpressionAssignInt(Parser, BottomValue, TopFP, false)
                ResultIsInt = true
            end
        elseif Op == LexToken.TokenAddAssign then
            if IS_FP(BottomValue) then
                ResultFP = ExpressionAssignFP(Parser, BottomValue, TopFP + BottomFP)
            else
                ResultInt = ExpressionAssignInt(Parser, BottomValue, TopFP + BottomFP, false)
                ResultIsInt = true
            end
        elseif Op == LexToken.TokenSubtractAssign then
            if IS_FP(BottomValue) then
                ResultFP = ExpressionAssignFP(Parser, BottomValue, BottomFP - TopFP)
            else
                ResultInt = ExpressionAssignInt(Parser, BottomValue, BottomFP - TopFP, false)
                ResultIsInt = true
            end
        elseif Op == LexToken.TokenMultiplyAssign then
            if IS_FP(BottomValue) then
                ResultFP = ExpressionAssignFP(Parser, BottomValue, BottomFP * TopFP)
            else
                ResultInt = ExpressionAssignInt(Parser, BottomValue, BottomFP * TopFP, false)
                ResultIsInt = true
            end
        elseif Op == LexToken.TokenDivideAssign then
            if IS_FP(BottomValue) then
                ResultFP = ExpressionAssignFP(Parser, BottomValue, BottomFP / TopFP)
            else
                ResultInt = ExpressionAssignInt(Parser, BottomValue, math.floor(BottomFP / TopFP), false)
                ResultIsInt = true
            end
        elseif Op == LexToken.TokenEqual then
            ResultInt = LUA_BOOLEAN_TO_C(BottomFP == TopFP)
            ResultIsInt = true
        elseif Op == LexToken.TokenNotEqual then
            ResultInt = LUA_BOOLEAN_TO_C(BottomFP ~= TopFP)
            ResultIsInt = true
        elseif Op == LexToken.TokenLessThan then
            ResultInt = LUA_BOOLEAN_TO_C(BottomFP < TopFP)
            ResultIsInt = true
        elseif Op == LexToken.TokenGreaterThan then
            ResultInt = LUA_BOOLEAN_TO_C(BottomFP > TopFP)
            ResultIsInt = true
        elseif Op == LexToken.TokenLessEqual then
            ResultInt = LUA_BOOLEAN_TO_C(BottomFP <= TopFP)
            ResultIsInt = true
        elseif Op == LexToken.TokenGreaterEqual then
            ResultInt = LUA_BOOLEAN_TO_C(BottomFP >= TopFP)
            ResultIsInt = true
        elseif Op == LexToken.TokenPlus then
            ResultFP = BottomFP + TopFP
        elseif Op == LexToken.TokenMinus then
            ResultFP = BottomFP - TopFP
        elseif Op == LexToken.TokenAsterisk then
            ResultFP = BottomFP * TopFP
        elseif Op == LexToken.TokenSlash then
            ResultFP = BottomFP / TopFP
        else
            ProgramFail(Parser, "invalid operation")
        end

        if ResultIsInt then
            StackTop = ExpressionPushInt(Parser, StackTop, ResultInt)
        else
            StackTop = ExpressionPushFP(Parser, StackTop, ResultFP)
        end
    elseif IS_NUMERIC_COERCIBLE(TopValue) and IS_NUMERIC_COERCIBLE(BottomValue) then
        TopInt = ExpressionCoerceInteger(TopValue)
        BottomInt = ExpressionCoerceInteger(BottomValue)
        --if Debug then
        --    print("TopInt:", TopInt)
        --    print("BottomInt:", BottomInt)
        --end

        if Op == LexToken.TokenAssign then
            ResultInt = ExpressionAssignInt(Parser, BottomValue, TopInt, false)
        elseif Op == LexToken.TokenAddAssign then
            ResultInt = ExpressionAssignInt(Parser, BottomValue, BottomInt + TopInt, false)
        elseif Op == LexToken.TokenSubtractAssign then
            ResultInt = ExpressionAssignInt(Parser, BottomValue, BottomInt - TopInt, false)
        elseif Op == LexToken.TokenMultiplyAssign then
            ResultInt = ExpressionAssignInt(Parser, BottomValue, BottomInt * TopInt, false)
        elseif Op == LexToken.TokenDivideAssign then
            ResultInt = ExpressionAssignInt(Parser, BottomValue, math.floor(BottomInt / TopInt), false)
        elseif Op == LexToken.TokenModulusAssign then
            ResultInt = ExpressionAssignInt(Parser, BottomValue, BottomInt % TopInt, false)
        elseif Op == LexToken.TokenShiftLeftAssign then
            ResultInt = ExpressionAssignInt(Parser, BottomValue, lshift(BottomInt, TopInt), false)
        elseif Op == LexToken.TokenShiftRightAssign then
            ResultInt = ExpressionAssignInt(Parser, BottomValue, rshift(BottomInt, TopInt), false)
        elseif Op == LexToken.TokenArithmeticAndAssign then
            ResultInt = ExpressionAssignInt(Parser, BottomValue, band(BottomInt, TopInt), false)
        elseif Op == LexToken.TokenArithmeticOrAssign then
            ResultInt = ExpressionAssignInt(Parser, BottomValue, bor(BottomInt, TopInt), false)
        elseif Op == LexToken.TokenArithmeticExorAssign then
            ResultInt = ExpressionAssignInt(Parser, BottomValue, bxor(BottomInt, TopInt), false)
        elseif Op == LexToken.TokenLogicalOr then
            ResultInt = C_LOGICAL_OR(BottomInt, TopInt)
        elseif Op == LexToken.TokenLogicalAnd then
            ResultInt = C_LOGICAL_AND(BottomInt, TopInt)
        elseif Op == LexToken.TokenArithmeticOr then
            ResultInt = bor(BottomInt, TopInt)
        elseif Op == LexToken.TokenArithmeticExor then
            ResultInt = bxor(BottomInt, TopInt)
        elseif Op == LexToken.TokenAmpersand then
            ResultInt = band(BottomInt, TopInt)
        elseif Op == LexToken.TokenEqual then
            ResultInt = LUA_BOOLEAN_TO_C(BottomInt == TopInt)
        elseif Op == LexToken.TokenNotEqual then
            ResultInt = LUA_BOOLEAN_TO_C(BottomInt ~= TopInt)
        elseif Op == LexToken.TokenLessThan then
            ResultInt = LUA_BOOLEAN_TO_C(BottomInt < TopInt)
        elseif Op == LexToken.TokenGreaterThan then
            ResultInt = LUA_BOOLEAN_TO_C(BottomInt > TopInt)
        elseif Op == LexToken.TokenLessEqual then
            ResultInt = LUA_BOOLEAN_TO_C(BottomInt <= TopInt)
        elseif Op == LexToken.TokenGreaterEqual then
            ResultInt = LUA_BOOLEAN_TO_C(BottomInt >= TopInt)
        elseif Op == LexToken.TokenShiftLeft then
            ResultInt = lshift(BottomInt, TopInt)
        elseif Op == LexToken.TokenShiftRight then
            ResultInt = rshift(BottomInt, TopInt)
        elseif Op == LexToken.TokenPlus then
            ResultInt = BottomInt + TopInt
        elseif Op == LexToken.TokenMinus then
            ResultInt = BottomInt - TopInt
        elseif Op == LexToken.TokenAsterisk then
            ResultInt = BottomInt * TopInt
        elseif Op == LexToken.TokenSlash then
            ResultInt = math.floor(BottomInt / TopInt)
        elseif Op == LexToken.TokenModulus then
            ResultInt = BottomInt % TopInt
        else
            ProgramFail(Parser, "invalid operation")
        end
        StackTop = ExpressionPushInt(Parser, StackTop, ResultInt)
    elseif (BottomValue.Typ.Base == BaseType.TypePointer and
        IS_NUMERIC_COERCIBLE(TopValue)) then
        TopInt = ExpressionCoerceInteger(TopValue)

        if Op == LexToken.TokenEqual or Op == LexToken.TokenNotEqual then
            if TopInt ~= 0 then
                ProgramFail(Parser, "invalid operation")
            end

            if Op == LexToken.TokenEqual then
                StackTop = ExpressionPushInt(Parser, StackTop,
                    LUA_BOOLEAN_TO_C(IsPointerNull(BottomValue.Val)))
            else
                StackTop = ExpressionPushInt(Parser, StackTop,
                    LUA_BOOLEAN_TO_C(not IsPointerNull(BottomValue.Val)))
            end
        elseif Op == LexToken.TokenPlus or Op == LexToken.TokenMinus then
            local Size = TypeSize(BottomValue.Typ.FromType, 0, true)
            local NewOffset = 0

            if IsPointerNull(BottomValue.Val) then
                ProgramFail(Parser, "c. invalid use of a NULL or void pointer")
            end

            if Op == LexToken.TokenPlus then
                NewOffset = TopInt * Size
            else
                NewOffset = -TopInt * Size
            end

            StackValue, StackTop = ExpressionStackPushValueByType(Parser, StackTop,
                BottomValue.Typ)
            StackValue.Val = PointerCopyAllValues(BottomValue.Val, true)
            PointerMovePointer(StackValue.Val, NewOffset)
        elseif Op == LexToken.TokenAssign and TopInt == 0 then
            -- Recover Value on the stack (the operand) as we only push a ExpressionStack
            -- So on the top of the stack it is now ExpressionStack + Value
            HeapUnpopStack(Parser.pc)
            ExpressionAssign(Parser, BottomValue, TopValue, false, nil, 0, false)
            StackTop = ExpressionStackPushValueNode(Parser, StackTop, BottomValue)
        elseif Op == LexToken.TokenAddAssign or Op == LexToken.TokenSubtractAssign then
            local Size = TypeSize(BottomValue.Typ.FromType, 0, true)
            local NewOffset = 0

            if IsPointerNull(BottomValue.Val) then
                ProgramFail(Parser, "c. invalid use of a NULL or void pointer")
            end

            if Op == LexToken.TokenAddAssign then
                NewOffset = TopInt * Size
            else
                NewOffset = -TopInt * Size
            end

            HeapUnpopStack(Parser.pc)
            PointerMovePointer(BottomValue.Val, NewOffset)
            StackTop = ExpressionStackPushValueNode(Parser, StackTop, BottomValue)
        else
            ProgramFail(Parser, "invalid operation")
        end
    elseif (BottomValue.Typ.Base == BaseType.TypePointer and
        TopValue.Typ.Base == BaseType.TypePointer and Op ~= LexToken.TokenAssign) then
        local CompareResult

        if Op == LexToken.TokenEqual then
            CompareResult, _ = PointerComparePointer(TopValue.Val, BottomValue.Val, true)
            StackTop = ExpressionPushInt(Parser, StackTop,
                LUA_BOOLEAN_TO_C(CompareResult))
        elseif Op == LexToken.TokenNotEqual then
            CompareResult, _ = PointerComparePointer(TopValue.Val, BottomValue.Val, true)
            StackTop = ExpressionPushInt(Parser, StackTop,
                LUA_BOOLEAN_TO_C(not CompareResult))
        elseif Op == LexToken.TokenMinus then
            local RefOffsetDifference
            CompareResult, RefOffsetDifference = PointerComparePointer(TopValue.Val, BottomValue.Val, false)
            if (not CompareResult or
                TopValue.Typ.FromType.Base ~= BottomValue.Typ.FromType.Base) then
                -- Difference between pointers referencing different
                -- variables is not supported here
                ProgramFail(Parser, "comparison between pointers with different base addresses is not supported")
            end

            StackTop = ExpressionPushInt(Parser, StackTop,
                math.floor(RefOffsetDifference / TypeSize(BottomValue.Typ.FromType, 0, true)))
        else
            ProgramFail(Parser, "invalid operation")
        end
    elseif Op == LexToken.TokenAssign then
        HeapUnpopStack(Parser.pc)
        ExpressionAssign(Parser, BottomValue, TopValue, false, nil, 0, false)
        StackTop = ExpressionStackPushValueNode(Parser, StackTop, BottomValue)
    elseif Op == LexToken.TokenCast then
        ValueLoc, StackTop = ExpressionStackPushValueByType(Parser, StackTop, BottomValue.Val.Typ)
        ExpressionAssign(Parser, ValueLoc, TopValue, true, nil, 0, true)
        --if Debug then
        --    print("Infix Cast Operation")
        --end
    else
        ProgramFail(Parser, "invalid operation");
    end

    return StackTop
end

function ExpressionStackCollapse(Parser, StackTop, Precedence, IgnorePrecedence)
    local FoundPrecedence = Precedence
    local TopValue, BottomValue, TopStackNode, TopOperatorNode
    TopStackNode = StackTop

    while (TopStackNode ~= nil and HeapGetStackNode(Parser.pc, TopStackNode.NextNodeId) ~= nil and
        FoundPrecedence >= Precedence) do
        if TopStackNode.Order == OperatorOrder.OrderNone then
            -- ExpressionStack + Value
            TopOperatorNode = HeapGetStackNode(Parser.pc, TopStackNode.NextNodeId)
        else
            TopOperatorNode = TopStackNode
        end

        FoundPrecedence = TopOperatorNode.Precedence

        if FoundPrecedence >= Precedence and TopOperatorNode ~= nil then
            if TopOperatorNode.Order == OperatorOrder.OrderPrefix then
                TopValue = TopStackNode.Val
                --if Debug then
                --    print("Top:", PointerGetSignedInt(TopValue.Val))
                --end

                -- OperatorNode, Value, ExpressionStack
                -- (From bottom to top)
                HeapPopStack(Parser.pc, 3)
                --HeapPopStack(Parser.pc, 2)  -- ExpressionStack + Value
                --HeapPopStack(Parser.pc, 1, TopOperatorNode.StackId - 1)  -- OperatorNode
                StackTop = HeapGetStackNode(Parser.pc, TopOperatorNode.NextNodeId)

                if Parser.Mode == RunMode.RunModeRun then
                    StackTop = ExpressionPrefixOperator(Parser, StackTop,
                        TopOperatorNode.Op, TopValue)
                else
                    StackTop = ExpressionPushInt(Parser, StackTop, 0)
                end
            elseif TopOperatorNode.Order == OperatorOrder.OrderPostfix then
                TopValue = HeapGetStackNode(Parser.pc, TopStackNode.NextNodeId).Val

                -- Value, ExpressionStack, OperatorNode
                -- (From bottom to top)
                HeapPopStack(Parser.pc, 3)
                --HeapPopStack(Parser.pc, 1)  -- OperatorNode
                --HeapPopStack(Parser.pc, 2, TopValue.StackId - 1)  -- ExpressionStack + Value
                StackTop = HeapGetStackNode(Parser.pc,
                    HeapGetStackNode(Parser.pc, TopStackNode.NextNodeId).NextNodeId)

                if Parser.Mode == RunMode.RunModeRun then
                    StackTop = ExpressionPostfixOperator(Parser, StackTop,
                        TopOperatorNode.Op, TopValue)
                else
                    StackTop = ExpressionPushInt(Parser, StackTop, 0)
                end
            elseif TopOperatorNode.Order == OperatorOrder.OrderInfix then
                --if Debug then
                --    print("Collapse Infix")
                --end
                TopValue = TopStackNode.Val

                if TopValue ~= nil then
                    BottomValue = HeapGetStackNode(Parser.pc, TopOperatorNode.NextNodeId).Val

                    --if Debug then
                    --    print("Top:", PointerGetSignedInt(TopValue.Val), TopValue.Typ)
                    --    print("Bottom:", PointerGetSignedInt(BottomValue.Val), BottomValue.Typ)
                    --end

                    -- Value, ExpressionStack, OperatorNode, Value, ExpressionStack
                    -- (From bottom to top)
                    HeapPopStack(Parser.pc, 5)
                    --HeapPopStack(Parser.pc, 2)  -- ExpressionStack + Value
                    --HeapPopStack(Parser.pc, 1)  -- OperatorNode
                    --HeapPopStack(Parser.pc, 2, BottomValue.StackId - 1)  -- ExpressionStack + Value
                    StackTop = HeapGetStackNode(Parser.pc,
                        HeapGetStackNode(Parser.pc, TopOperatorNode.NextNodeId).NextNodeId)

                    if Parser.Mode == RunMode.RunModeRun then
                        StackTop = ExpressionInfixOperator(Parser, StackTop,
                            TopOperatorNode.Op, BottomValue, TopValue)
                    else
                        StackTop = ExpressionPushInt(Parser, StackTop, 0)
                    end
                else
                    FoundPrecedence = -1
                end
            else
                -- empty
            end

            if FoundPrecedence <= IgnorePrecedence then
                IgnorePrecedence = DEEP_PRECEDENCE
            end
        end

        TopStackNode = StackTop
    end

    return StackTop, IgnorePrecedence
end

function ExpressionStackPushOperator(Parser, StackTop, Order, Token, Precedence)
    local StackNode
    StackNode = VariableAlloc(Parser.pc, Parser, false)
    if StackTop == nil then
        StackNode.NextNodeId = 0
    else
        StackNode.NextNodeId = StackTop.StackId
    end
    StackNode.Order = Order
    StackNode.Op = Token
    StackNode.Precedence = Precedence
    StackTop = StackNode

    --StackNode.Line = Parser.Line
    --StackNode.CharacterPos = Parser.CharacterPos

    return StackTop
end

function ExpressionGetStructElement(Parser, StackTop, Token)
    local Ident
    local ParamVal, StructVal, StructType, DerefDataLoc, MemberValue, Result
    local TokenG
    local PF1, PF2
    local Success
    local LValueFrom

    TokenG, Ident = LexGetToken(Parser, Ident, true)
    if TokenG ~= LexToken.TokenIdentifier then
        if Token == LexToken.TokenDot then
            ProgramFail(Parser, "need an structure or union member after '.'")
        else
            ProgramFail(Parser, "need an structure or union member after '->'")
        end
    end

    if Parser.Mode == RunMode.RunModeRun then
        ParamVal = StackTop.Val
        StructVal = ParamVal
        StructType = ParamVal.Typ
        DerefDataLoc = {}
        MemberValue = nil

        PointerDeriveNewValue(DerefDataLoc, ParamVal.Val, false)

        if Token == LexToken.TokenArrow then
            DerefDataLoc, StructVal, StructType, _, _ = VariableDereferencePointer(ParamVal)

            if DerefDataLoc == nil then
                ProgramFail(Parser, "trying to dereference a void pointer - is the pointer NULL or pointing to a deallocated variable?")
            end

            -- Change the identity of dereferenced value - members in a struct are *de jure* different objects
            -- but *de facto* the struct itself with different offsets
            DerefDataLoc.Ident = math.random(1, 0x7FFFFFFF)
        end

        if StructType.Base ~= BaseType.TypeStruct and StructType.Base ~= BaseType.TypeUnion then
            if Token == LexToken.TokenDot then PF1 = "."
                else PF1 = "->" end
            if Token == LexToken.TokenArrow then PF2 = "pointer"
                else PF2 = "" end
            ProgramFail(Parser, "can't use '%s' on something that's not a struct or union %s : it's a %t",
                PF1, PF2, ParamVal.Typ)
        end

        -- Ident: Value
        Success, MemberValue, _, _, _ = TableGet(StructType.Members, Ident.Val) -- Changed from Ident.Val.Identifier
        if not Success then
            ProgramFail(Parser, "doesn't have a member called '%s",
                Ident.Val.RawValue.Val)   -- Changed from Ident.Val.Identifier
        end

        HeapPopStack(Parser.pc, 2, ParamVal.StackId - 1)  -- ExpressionStack + Value
        StackTop = HeapGetStackNode(Parser.pc, StackTop.NextNodeId)

        if StructVal ~= nil then
            LValueFrom = StructType.LValueFrom
        else
            LValueFrom = nil
        end

        DerefDataLoc.Offset = DerefDataLoc.Offset +
            PointerGetSignedInt(MemberValue.Val)

        Result = VariableAllocValueFromExistingData(Parser, MemberValue.Typ,
            DerefDataLoc, true, LValueFrom)
        StackTop = ExpressionStackPushValueNode(Parser, StackTop, Result)
    end

    return StackTop
end

function ExpressionParse(Parser)
    local PrefixState = true
    local Done = false
    local BracketPrecedence = 0
    local LocalPrecedence
    local Precedence = 0
    local IgnorePrecedence = DEEP_PRECEDENCE
    local TernaryDepth = 0
    local LexValue
    local StackTop = nil
    local Result

    repeat
        local PreState = {}
        local Token

        ParserCopy(PreState, Parser)
        Token, LexValue = LexGetToken(Parser, LexValue, true)
        --print("Token:", Token)
        if (((Token > LexToken.TokenComma and Token <= LexToken.TokenOpenBracket) or
            (Token == LexToken.TokenCloseBracket and BracketPrecedence ~= 0)) and
            (Token ~= LexToken.TokenColon or TernaryDepth > 0)) then
            if PrefixState then
                --if Debug then
                --    print("Prefix Precedence:", Token, OperatorPrecedence[Token].InfixPrecedence)
                --end
                if OperatorPrecedence[Token].PrefixPrecedence == 0 then
                    ProgramFail(Parser, "operator not expected here")
                end

                LocalPrecedence = OperatorPrecedence[Token].PrefixPrecedence
                Precedence = BracketPrecedence + LocalPrecedence

                if Token == LexToken.TokenOpenBracket then
                    local BracketToken
                    BracketToken, LexValue = LexGetToken(Parser, LexValue, false)

                    local Cond = false
                    if StackTop == nil then
                        Cond = true
                    else
                        if StackTop.Op ~= LexToken.TokenSizeof then
                            Cond = true
                        else
                            Cond = false
                        end
                    end

                    if IsTypeToken(Parser, BracketToken, LexValue) and Cond then
                        local CastType
                        local CastTypeValue
                        local Tok

                        --if Debug then
                        --    print("Type Cast", BracketToken)
                        --end

                        CastType, _, _ = TypeParse(Parser)
                        Tok, LexValue = LexGetToken(Parser, LexValue, true)
                        if Tok ~= LexToken.TokenCloseBracket then
                            ProgramFail(Parser, "brackets not closed")
                        end

                        Precedence = BracketPrecedence +
                            OperatorPrecedence[LexToken.TokenCast].PrefixPrecedence

                        StackTop, IgnorePrecedence = ExpressionStackCollapse(Parser,
                            StackTop, Precedence + 1, IgnorePrecedence)
                        CastTypeValue = VariableAllocValueFromType(Parser.pc,
                            Parser, Parser.pc.TypeType, false, nil, false)
                        CastTypeValue.Val.Typ = CastType    -- Val here points to Typ, not AnyValue type
                        StackTop = ExpressionStackPushValueNode(Parser, StackTop,
                            CastTypeValue)
                        StackTop = ExpressionStackPushOperator(Parser, StackTop,
                            OperatorOrder.OrderInfix, LexToken.TokenCast, Precedence)
                    else
                        BracketPrecedence = BracketPrecedence + BRACKET_PRECEDENCE
                    end
                else
                    local NextToken
                    local TempPrecedenceBoost = 0
                    NextToken, _ = LexGetToken(Parser, nil, false)
                    if NextToken > LexToken.TokenComma and NextToken < LexToken.TokenOpenBracket then
                        local NextPrecedence =
                            OperatorPrecedence[NextToken].PrefixPrecedence

                        if LocalPrecedence == NextPrecedence then
                            TempPrecedenceBoost = -1
                        end
                    end

                    StackTop, IgnorePrecedence = ExpressionStackCollapse(Parser,
                        StackTop, Precedence, IgnorePrecedence)
                    StackTop = ExpressionStackPushOperator(Parser, StackTop, OperatorOrder.OrderPrefix,
                        Token, Precedence + TempPrecedenceBoost)
                    --if Debug then
                    --    print("Prefix")
                    --end
                end
            else
                --if Debug then
                --    print("Precedence:", Token, OperatorPrecedence[Token].InfixPrecedence)
                --end
                if OperatorPrecedence[Token].PostfixPrecedence ~= 0 then
                    if (Token == LexToken.TokenCloseBracket or
                        Token == LexToken.TokenRightSquareBracket) then
                        if BracketPrecedence == 0 then
                            ParserCopy(Parser, PreState)
                            Done = true
                        else
                            StackTop, IgnorePrecedence = ExpressionStackCollapse(Parser,
                                StackTop, BracketPrecedence, IgnorePrecedence)
                            BracketPrecedence = BracketPrecedence - BRACKET_PRECEDENCE
                        end
                    else
                        Precedence = BracketPrecedence +
                            OperatorPrecedence[Token].PostfixPrecedence
                        StackTop, IgnorePrecedence = ExpressionStackCollapse(Parser,
                            StackTop, Precedence, IgnorePrecedence)
                        StackTop = ExpressionStackPushOperator(Parser, StackTop,
                            OperatorOrder.OrderPostfix, Token, Precedence)
                        --if Debug then
                        --    print("Postfix")
                        --end
                    end
                elseif OperatorPrecedence[Token].InfixPrecedence ~= 0 then
                    Precedence = BracketPrecedence +
                        OperatorPrecedence[Token].InfixPrecedence

                    if IS_LEFT_TO_RIGHT(OperatorPrecedence[Token].InfixPrecedence) then
                        StackTop, IgnorePrecedence = ExpressionStackCollapse(Parser,
                            StackTop, Precedence, IgnorePrecedence)
                    else
                        StackTop, IgnorePrecedence = ExpressionStackCollapse(Parser,
                            StackTop, Precedence + 1, IgnorePrecedence)
                    end

                    if Token == LexToken.TokenDot or Token == LexToken.TokenArrow then
                        StackTop = ExpressionGetStructElement(Parser, StackTop, Token)
                    else
                        if ((Token == LexToken.TokenLogicalOr or Token == LexToken.TokenLogicalAnd) and
                            IS_NUMERIC_COERCIBLE(StackTop.Val)) then
                            local LHSInt = ExpressionCoerceInteger(StackTop.Val)
                            if (((Token == LexToken.TokenLogicalOr and LHSInt ~= 0) or
                                (Token == LexToken.TokenLogicalAnd and LHSInt == 0)) and
                                (IgnorePrecedence > Precedence)) then
                                IgnorePrecedence = Precedence
                            end
                        end

                        StackTop = ExpressionStackPushOperator(Parser, StackTop,
                            OperatorOrder.OrderInfix, Token, Precedence)
                        PrefixState = true
                        --if Debug then
                        --    print("Infix")
                        --end

                        if Token == LexToken.TokenQuestionMark then
                            TernaryDepth = TernaryDepth + 1
                        elseif Token == LexToken.TokenColon then
                            TernaryDepth = TernaryDepth - 1
                        end
                    end

                    if Token == LexToken.TokenLeftSquareBracket then
                        BracketPrecedence = BracketPrecedence + BRACKET_PRECEDENCE
                    end
                else
                    ProgramFail(Parser, "operator not expected here")
                end
            end
        elseif Token == LexToken.TokenIdentifier then
            --if Debug then
            --    print("Precedence:", Token)
            --end
            if not PrefixState then
                ProgramFail(Parser, "identifier not expected here")
            end

            local Tok
            Tok, _ = LexGetToken(Parser, nil, false)
            if Tok == LexToken.TokenOpenBracket then
                StackTop = ExpressionParseFunctionCall(Parser, StackTop,
                    LexValue.Val,    -- Changed from LexValue.Val.Identifier
                    Parser.Mode == RunMode.RunModeRun and Precedence < IgnorePrecedence)
            else
                if Parser.Mode == RunMode.RunModeRun then
                    local VariableValue

                    VariableValue = VariableGet(Parser.pc, Parser, LexValue.Val) -- Changed from LexValue.Val.Identifier
                    if VariableValue.Typ.Base == BaseType.TypeMacro then
                        local MacroParser = {}
                        local MacroResult

                        ParserCopy(MacroParser, VariableValue.Val.MacroDef.Body)
                        MacroParser.Mode = Parser.Mode
                        if VariableValue.Val.MacroDef.NumParams ~= 0 then
                            ProgramFail(MacroParser, "macro arguments missing")
                        end

                        local Success
                        Success, MacroResult = ExpressionParse(MacroParser)
                        Tok, _ = LexGetToken(MacroParser, nil, false)
                        if (not Success) or Tok ~= LexToken.TokenEndOfFunction then
                            ProgramFail(MacroParser, "expression expected")
                        end

                        StackTop = ExpressionStackPushValueNode(Parser, StackTop, MacroResult)
                    elseif VariableValue.Typ == Parser.pc.VoidType then
                        ProgramFail(Parser, "a void value isn't much use here")
                    else
                        StackTop = ExpressionStackPushLValue(Parser, StackTop,
                            VariableValue, 0)
                    end
                else
                    StackTop = ExpressionPushInt(Parser, StackTop, 0)
                end
            end

            if Precedence <= IgnorePrecedence then
                IgnorePrecedence = DEEP_PRECEDENCE
            end

            PrefixState = false
        elseif Token > LexToken.TokenCloseBracket and Token <= LexToken.TokenCharacterConstant then
            if not PrefixState then
                ProgramFail(Parser, "value not expected here")
            end

            PrefixState = false
            StackTop = ExpressionStackPushValue(Parser, StackTop, LexValue)
            --if Debug then
            --    print(LexValue.Val.Offset)
            --end
        elseif IsTypeToken(Parser, Token, LexValue) then
            local Typ
            local TypeValue

            if not PrefixState then
                ProgramFail(Parser, "type not expected here")
            end

            PrefixState = false
            ParserCopy(Parser, PreState)
            Typ, _, _ = TypeParse(Parser)
            TypeValue = VariableAllocValueFromType(Parser.pc, Parser,
                Parser.pc.TypeType, false, nil, false)
            TypeValue.Val.Typ = Typ     -- Val here points to Typ, not AnyValue type
            StackTop = ExpressionStackPushValueNode(Parser, StackTop, TypeValue)
        else
            ParserCopy(Parser, PreState)
            Done = true
        end
    until Done

    if BracketPrecedence > 0 then
        ProgramFail(Parser, "brackets not closed")
    end

    StackTop, IgnorePrecedence = ExpressionStackCollapse(Parser, StackTop, 0, IgnorePrecedence)

    if StackTop ~= nil then
        if Parser.Mode == RunMode.RunModeRun then
            if (StackTop.Order ~= OperatorOrder.OrderNone or
                HeapGetStackNode(Parser.pc, StackTop.NextNodeId) ~= nil) then
                ProgramFail(Parser, "invalid expression")
            end

            Result = StackTop.Val
            HeapPopStack(Parser.pc, 1, StackTop.StackId - 1)  -- Pop ExpressionStack, Value is left on stack
        else
            HeapPopStack(Parser.pc, 2, StackTop.Val.StackId - 1)  -- Pop ExpressionStack + Value
        end
    end

    return StackTop ~= nil, Result
end

function ExpressionParseMacroCall(Parser, StackTop, MacroName, MDef)
    local ArgCount
    local Token
    local ReturnValue = nil
    local Param
    local ParamArray = nil

    if Parser.Mode == RunMode.RunModeRun then
        _, StackTop = ExpressionStackPushValueByType(Parser, StackTop, Parser.pc.FPType)
        ReturnValue = StackTop.Val
        HeapPushStackFrame(Parser.pc)
        ParamArray = HeapAllocStack(Parser.pc)
        if ParamArray == nil then
            ProgramFail(Parser, "(ExpressionParseMacroCall) out of memory")
        end
    else
        StackTop = ExpressionPushInt(Parser, StackTop, 0)
    end

    ArgCount = 0
    repeat
        local StackNotNull
        StackNotNull, Param = ExpressionParse(Parser)
        if StackNotNull then
            if Parser.Mode == RunMode.RunModeRun then
                if ArgCount < MDef.NumParams then
                    ParamArray[ArgCount + 1] = Param
                else
                    -- MacroName: AnyValue
                    ProgramFail(Parser, "too many arguments to %s()", MacroName.RawValue.Val)
                end
            end

            ArgCount = ArgCount + 1
            Token, _ = LexGetToken(Parser, nil, true)
            if Token ~= LexToken.TokenComma and Token ~= LexToken.TokenCloseBracket then
                ProgramFail(Parser, "comma expected")
            end
        else
            Token, _ = LexGetToken(Parser, nil, true)
            if Token ~= LexToken.TokenCloseBracket then
                ProgramFail(Parser, "bad argument")
            end
        end
    until Token == LexToken.TokenCloseBracket

    if Parser.Mode == RunMode.RunModeRun then
        local MacroParser = {}
        local EvalValue

        if ArgCount < MDef.NumParams then
            ProgramFail(Parser, "not enough arguments to '%s'", MacroName.RawValue.Val)
        end

        if MDef.Body.ParsingTokens == nil then
            ProgramFail(Parser,
                "ExpressionParseMacroCall MacroName: '%s' is undefined", MacroName.RawValue.Val)
        end

        ParserCopy(MacroParser, MDef.Body)
        MacroParser.Mode = Parser.Mode
        VariableStackFrameAdd(Parser, MacroName, 0)
        local TopStackFrame = HeapGetStackNode(Parser.pc, Parser.pc.TopStackFrameId)
        TopStackFrame.NumParams = ArgCount
        TopStackFrame.ReturnValue = ReturnValue
        for Count = 1, MDef.NumParams do
            VariableDefine(Parser.pc, Parser, MDef.ParamName[Count],
                ParamArray[Count], nil, true)
        end

        _, EvalValue = ExpressionParse(MacroParser)
        ExpressionAssign(Parser, ReturnValue, EvalValue, true, MacroName, 0, false)
        VariableStackFramePop(Parser)
        HeapPopStackFrame(Parser.pc)
    end

    return StackTop
end

function ExpressionParseFunctionCall(Parser, StackTop, FuncName, RunIt)
    local ArgCount
    local Token
    local OldMode = Parser.Mode
    local ReturnValue = nil
    local FuncValue = nil
    local Param = nil
    local ParamArray = nil
    local ParamStartStackId = 0

    Token, _ = LexGetToken(Parser, nil, true)
    if RunIt then
        FuncValue = VariableGet(Parser.pc, Parser, FuncName)

        if FuncValue.Typ.Base == BaseType.TypeMacro then
            StackTop = ExpressionParseMacroCall(Parser, StackTop, FuncName,
                FuncValue.Val.MacroDef)
            return StackTop
        end

        --if Debug then
        --    print("Enter Function")
        --end
        if FuncValue.Typ.Base ~= BaseType.TypeFunction then
            ProgramFail(Parser, "%t is not a function - can't call",
                FuncValue.Typ)
        end

        _, StackTop = ExpressionStackPushValueByType(Parser, StackTop,
            FuncValue.Val.FuncDef.ReturnType)
        ReturnValue = StackTop.Val
        --print("Set StackFrame ReturnValue 1", StackTop.Val.Typ.Base)
        HeapPushStackFrame(Parser.pc)
        ParamArray = HeapAllocStack(Parser.pc)
        if ParamArray == nil then
            ProgramFail(Parser, "(ExpressionParseFunctionCall) out of memory")
        end
    else
        StackTop = ExpressionPushInt(Parser, StackTop, 0)
        Parser.Mode = RunMode.RunModeSkip
    end

    ArgCount = 0
    repeat
        if RunIt and ArgCount < FuncValue.Val.FuncDef.NumParams then
            ParamArray[ArgCount + 1] = VariableAllocValueFromType(Parser.pc, Parser,
                FuncValue.Val.FuncDef.ParamType[ArgCount + 1], false, nil, false)

            if ArgCount == 0 then
                ParamStartStackId = ParamArray[ArgCount + 1].StackId
            end
        end

        local StackNotNull
        StackNotNull, Param = ExpressionParse(Parser)
        if StackNotNull then
            if RunIt then
                if ArgCount < FuncValue.Val.FuncDef.NumParams then
                    ExpressionAssign(Parser, ParamArray[ArgCount + 1], Param, true,
                        FuncName, ArgCount + 1, false)
                    VariableStackPop(Parser, Param)
                else
                    if not FuncValue.Val.FuncDef.VarArgs then
                        -- FuncName: AnyValue
                        ProgramFail(Parser, "too many arguments to %s()", FuncName.RawValue.Val)
                    end
                end
            end

            ArgCount = ArgCount + 1
            Token, _ = LexGetToken(Parser, nil, true)
            if Token ~= LexToken.TokenComma and Token ~= LexToken.TokenCloseBracket then
                ProgramFail(Parser, "comma expected")
            end
        else
            Token, _ = LexGetToken(Parser, nil, true)
            if Token ~= LexToken.TokenCloseBracket then
                ProgramFail(Parser, "bad argument")
            end
        end

    until Token == LexToken.TokenCloseBracket

    if RunIt then
        if ArgCount < FuncValue.Val.FuncDef.NumParams then
            ProgramFail(Parser, "not enough arguments to '%s'", FuncName.RawValue.Val)
        end

        if FuncValue.Val.FuncDef.Intrinsic == nil then
            local OldScopeID = Parser.ScopeID
            local FuncParser = {}

            if FuncValue.Val.FuncDef.Body.ParsingTokens == nil then
                ProgramFail(Parser,
                    "ExpressionParseFunctionCall FuncName: '%s' is undefined",
                    FuncName.RawValue.Val)
            end

            ParserCopy(FuncParser, FuncValue.Val.FuncDef.Body)
            if FuncValue.Val.FuncDef.Intrinsic ~= nil then
                VariableStackFrameAdd(Parser, FuncName, FuncValue.Val.FuncDef.NumParams)
            else
                VariableStackFrameAdd(Parser, FuncName, 0)
            end
            local TopStackFrame = HeapGetStackNode(Parser.pc, Parser.pc.TopStackFrameId)
            TopStackFrame.NumParms = ArgCount
            --print("Set StackFrame ReturnValue", Parser.pc.TopStackFrameId)
            TopStackFrame.ReturnValue = ReturnValue
            --print("Set StackFrame ReturnValue", ReturnValue.Typ.Base)

            Parser.ScopeID = -1

            for Count = 1, FuncValue.Val.FuncDef.NumParams do
                --if Debug then
                --    print("ParamName:", ParamArray[Count].Typ)
                --end
                VariableDefine(Parser.pc, Parser,
                    FuncValue.Val.FuncDef.ParamName[Count], ParamArray[Count],
                    nil, true)
            end

            Parser.ScopeID = OldScopeID

            if ParseStatement(FuncParser, true) ~= ParserResult.ParseResultOk then
                ProgramFail(FuncParser, "function body expected")
            end

            if RunIt then
                if (FuncParser.Mode == RunMode.RunModeRun and
                    FuncValue.Val.FuncDef.ReturnType ~= Parser.pc.VoidType) then
                    ProgramFail(FuncParser,
                        "no value returned from a function returning %t",
                        FuncValue.Val.FuncDef.ReturnType)
                elseif FuncParser.Mode == RunMode.RunModeGoto then
                    ProgramFail(FuncParser, "couldn't find goto label '%s'",
                        FuncParser.SearchGotoLabel)
                end
            end

            VariableStackFramePop(Parser)
        else
            FuncValue.Val.FuncDef.Intrinsic(Parser, ReturnValue, ParamArray,
                ArgCount, ParamStartStackId)
        end

        --if Debug then
        --    print("Pop")
        --end
        HeapPopStackFrame(Parser.pc)
    end

    Parser.Mode = OldMode
    return StackTop
end

function ExpressionParseInt(Parser)
    local Result = 0
    local Val
    local ParseResult

    ParseResult, Val = ExpressionParse(Parser)
    if not ParseResult then
        ProgramFail(Parser, "expression expected")
    end

    if Parser.Mode == RunMode.RunModeRun then
        if not IS_NUMERIC_COERCIBLE_PLUS_POINTERS(Val, true) then
            ProgramFail(Parser, "integer value expected instead of %t", Val.Typ)
        end

        Result = ExpressionCoerceInteger(Val)
        --if Debug then
        --    print("ExpressionParseInt:", Result)
        --end
        VariableStackPop(Parser, Val)
    end

    return Result
end
