GEnableDebugger = false

function ParseCleanup(pc)
    collectgarbage()
end

function ParseStatementMaybeRun(Parser, Condition, CheckTrailingSemicolon)
    if Parser.Mode ~= RunMode.RunModeSkip and not Condition then
        local OldMode = Parser.Mode
        local Result
        Parser.Mode = RunMode.RunModeSkip
        Result = ParseStatement(Parser, CheckTrailingSemicolon)
        Parser.Mode = OldMode
        return Result
    else
        return ParseStatement(Parser, CheckTrailingSemicolon)
    end
end

function ParseCountParams(Parser)
    local ParamCount = 0

    local Token
    Token, _ = LexGetToken(Parser, nil, true)
    if Token ~= LexToken.TokenCloseBracket and Token ~= LexToken.TokenEOF then
        ParamCount = ParamCount + 1
        Token, _ = LexGetToken(Parser, nil, true)
        while Token ~= LexToken.TokenCloseBracket and Token ~= LexToken.TokenEOF do
            if Token == LexToken.TokenComma then
                ParamCount = ParamCount + 1
            end
            Token, _ = LexGetToken(Parser, nil, true)
        end
    end

    return ParamCount
end

function ParseFunctionDefinition(Parser, ReturnType, Identifier)
    local ParamCount = 0
    local ParamIdentifier
    local Token = LexToken.TokenNone
    local Tok
    local ParamType
    local ParamParser = {}
    local FuncValue
    local OldFuncValue
    local FuncBody = {}
    local pc = Parser.pc

    if pc.TopStackFrameId ~= 0 then
        ProgramFail(Parser, "nested function definitions are not allowed")
    end

    LexGetToken(Parser, nil, true)
    ParserCopy(ParamParser, Parser)
    ParamCount = ParseCountParams(Parser)
    if ParamCount > PARAMETER_MAX then
        ProgramFail(Parser, "too many parameters (%d allowed)", PARAMETER_MAX)
    end

    -- RawValue is not used, so DataSize is of no use
    FuncValue = VariableAllocValueAndData(pc, Parser, 0, false, nil, true)
    FuncValue.Typ = pc.FunctionType
    FuncValue.Val.FuncDef.ReturnType = ReturnType
    FuncValue.Val.FuncDef.NumParams = ParamCount
    FuncValue.Val.FuncDef.VarArgs = false
    FuncValue.Val.FuncDef.ParamType = {}
    FuncValue.Val.FuncDef.ParamName = {}

    ParamCount = 1
    while ParamCount <= FuncValue.Val.FuncDef.NumParams do
        Tok, _ = LexGetToken(ParamParser, nil, false)
        if ParamCount == FuncValue.Val.FuncDef.NumParams and Tok == LexToken.TokenEllipsis then
            FuncValue.Val.FuncDef.NumParams = FuncValue.Val.FuncDef.NumParams - 1
            FuncValue.Val.FuncDef.VarArgs = true
            break
        else
            ParamType, ParamIdentifier, _ = TypeParse(ParamParser)
            if ParamType.Base == BaseType.TypeVoid then
                FuncValue.Val.FuncDef.NumParams = FuncValue.Val.FuncDef.NumParams - 1
            else
                FuncValue.Val.FuncDef.ParamType[ParamCount] = ParamType
                FuncValue.Val.FuncDef.ParamName[ParamCount] = ParamIdentifier
            end
        end

        Token, _ = LexGetToken(ParamParser, nil, true)
        if Token ~= LexToken.TokenComma and ParamCount < FuncValue.Val.FuncDef.NumParams then
            ProgramFail(ParamParser, "comma expected")
        end

        ParamCount = ParamCount + 1
    end

    if (FuncValue.Val.FuncDef.NumParams ~= 0 and Token ~= LexToken.TokenCloseBracket and
        Token ~= LexToken.TokenComma and Token ~= LexToken.TokenEllipsis) then
        ProgramFail(ParamParser, "bad parameter")
    end

    if Identifier.RawValue.Val == "main" then
        if (FuncValue.Val.FuncDef.ReturnType ~= pc.IntType and
            FuncValue.Val.FuncDef.ReturnType ~= pc.VoidType) then
            ProgramFail(Parser, "main() should return an int or void")
        end

        if (FuncValue.Val.FuncDef.NumParams ~= 0 and
            (FuncValue.Val.FuncDef.NumParams ~= 2 or
            FuncValue.Val.FuncDef.ParamType[1] ~= pc.IntType)) then
            ProgramFail(Parser, "bad parameters to main()")
        end
    end

    Token, _ = LexGetToken(Parser, nil, false)
    if Token == LexToken.TokenSemicolon then
        LexGetToken(Parser, nil, true)
    else
        if Token ~= LexToken.TokenLeftBrace then
            ProgramFail(Parser, "bad function definition")
        end

        ParserCopy(FuncBody, Parser)
        if ParseStatementMaybeRun(Parser, false, true) ~= ParserResult.ParseResultOk then
            ProgramFail(Parser, "function definition expected")
        end

        FuncValue.Val.FuncDef.Body = FuncBody
        FuncValue.Val.FuncDef.Body.ParsingTokens = LexCopyTokens(FuncBody, Parser)
        FuncValue.Val.FuncDef.Body.Pos = 1

        local Success
        Success, OldFuncValue, _, _, _ = TableGet(pc.GlobalTable, Identifier)
        if Success then
            if OldFuncValue.Val.FuncDef.Body.ParsingTokens == nil then
                VariableFree(pc, TableDelete(pc, pc.GlobalTable, Identifier))
            else
                ProgramFail(Parser, "'%s' is already defined", Identifier.RawValue.Val)
            end
        end
    end

    if (not TableSet(pc, pc.GlobalTable, Identifier, FuncValue,
        Parser.FileName, Parser.Line, Parser.CharacterPos)) then
            ProgramFail(Parser, "'%s' is already defined", Identifier.RawValue.Val)
    end

    return FuncValue
end

function ParseArrayInitializer(Parser, NewVariable, DoAssignment)
    local ArrayIndex = 0
    local Token
    local CValue

    if DoAssignment and Parser.Mode == RunMode.RunModeRun then
        local CountParser = {}
        local NumElements

        ParserCopy(CountParser, Parser)
        NumElements = ParseArrayInitializer(CountParser, NewVariable, false)

        if NewVariable.Typ.Base ~= BaseType.TypeArray then
            AssignFail(Parser, "%t from array initializer", NewVariable.Typ,
                nil, 0, 0, nil, 0)
        end

        if NewVariable.Typ.ArraySize == 0 then
            NewVariable.Typ = TypeGetMatching(Parser.pc, Parser,
                NewVariable.Typ.FromType, NewVariable.Typ.Base, NumElements,
                NewVariable.Typ.Identifier, true)
            VariableRealloc(Parser, NewVariable, TypeSizeValue(NewVariable, false))
        end
    end

    Token, _ = LexGetToken(Parser, nil, false)
    while Token ~= LexToken.TokenRightBrace do
        local Tok
        Tok, _ = LexGetToken(Parser, nil, false)
        if Tok == LexToken.TokenLeftBrace then
            local SubArraySize = 0
            local SubArray = NewVariable
            if Parser.Mode == RunMode.RunModeRun and DoAssignment then
                SubArraySize = TypeSize(NewVariable.Typ.FromType,
                    NewVariable.Typ.FromType.ArraySize, true)
                local SubArrayVal = {}
                PointerDeriveNewValue(SubArrayVal, NewVariable.Val, true)
                SubArrayVal.Offset = SubArrayVal.Offset + SubArraySize * ArrayIndex
                SubArray = VariableAllocValueFromExistingData(Parser,
                    NewVariable.Typ.FromType, SubArrayVal, true, NewVariable)

                if ArrayIndex >= NewVariable.Typ.ArraySize then
                    ProgramFail(Parser, "too many array elements")
                end
            end
            LexGetToken(Parser, nil, true)
            ParseArrayInitializer(Parser, SubArray, DoAssignment)
        else
            local ArrayElement = nil

            if Parser.Mode == RunMode.RunModeRun and DoAssignment then
                local ElementType = NewVariable.Typ
                local TotalSize = 1
                local ElementSize = 0

                while ElementType.Base == BaseType.TypeArray do
                    TotalSize = TotalSize * ElementType.ArraySize
                    ElementType = ElementType.FromType

                    local Tok1
                    Tok1, _ = LexGetToken(Parser, nil, false)
                    if (Tok1 == LexToken.TokenStringConstant and
                        ElementType.FromType.Base == BaseType.TypeChar) then
                        break
                    end
                end
                ElementSize = TypeSize(ElementType, ElementType.ArraySize, true)

                if ArrayIndex >= TotalSize then
                    ProgramFail(Parser, "too many array elements")
                end
                local ArrayElementVal = {}
                PointerDeriveNewValue(ArrayElementVal, NewVariable.Val, true)
                ArrayElementVal.Offset = ArrayElementVal.Offset + ElementSize * ArrayIndex
                ArrayElement = VariableAllocValueFromExistingData(Parser, ElementType,
                    ArrayElementVal, true, NewVariable)
            end

            local Success
            Success, CValue = ExpressionParse(Parser)
            if not Success then
                ProgramFail(Parser, "expression expected")
            end

            if Parser.Mode == RunMode.RunModeRun and DoAssignment then
                ExpressionAssign(Parser, ArrayElement, CValue, false, nil, 0, false)
                --print(PointerGetString(ArrayElement.Val))
                VariableStackPop(Parser, CValue)
                VariableStackPop(Parser, ArrayElement)
            end
        end

        ArrayIndex = ArrayIndex + 1

        Token, _ = LexGetToken(Parser, nil, false)
        if Token == LexToken.TokenComma then
            LexGetToken(Parser, nil, true)
            Token, _ = LexGetToken(Parser, nil, false)
        elseif Token ~= LexToken.TokenRightBrace then
            ProgramFail(Parser, "comma expected")
        end
    end

    if Token == LexToken.TokenRightBrace then
        LexGetToken(Parser, nil, true)
    else
        ProgramFail(Parser, "'}' expected")
    end

    return ArrayIndex
end

function ParseDeclarationAssignment(Parser, NewVariable, DoAssignment)
    local CValue
    local Tok

    --if Debug then
    --    print("ParseDeclarationAssignment Enter")
    --end

    Tok, _ = LexGetToken(Parser, nil, false)
    if Tok == LexToken.TokenLeftBrace then
        LexGetToken(Parser, nil, true)
        ParseArrayInitializer(Parser, NewVariable, DoAssignment)
    else
        local Success
        Success, CValue = ExpressionParse(Parser)
        if not Success then
            ProgramFail(Parser, "expression expected")
        end

        if Parser.Mode == RunMode.RunModeRun and DoAssignment then
            --print(ExpressionCoerceInteger(CValue))
            --print(NewVariable.Typ.Base)
            ExpressionAssign(Parser, NewVariable, CValue, false, nil, 0, false)
            VariableStackPop(Parser, CValue)
        end
    end
end

function ParseDeclaration(Parser, Token)
    --if Debug then
    --    print("ParseDeclaration Enter")
    --end
    local IsStatic = false
    local FirstVisit = false
    local Identifier
    local BasicType
    local Typ
    local NewVariable = nil
    local pc = Parser.pc

    _, BasicType, IsStatic = TypeParseFront(Parser)

    repeat
        Typ, Identifier = TypeParseIdentPart(Parser, BasicType)
        if (Token ~= LexToken.TokenVoidType and Token ~= LexToken.TokenStructType and
            Token ~= LexToken.TokenUnionType and Token ~= LexToken.TokenEnumType and
            Identifier == pc.StrEmpty) then
            ProgramFail(Parser, "identifier expected")
        end

        if Identifier ~= pc.StrEmpty then
            local Tok
            Tok, _ = LexGetToken(Parser, nil, false)
            if Tok == LexToken.TokenOpenBracket then
                --if Debug then
                --    print("Define", Identifier.RawValue.Val)
                --end
                ParseFunctionDefinition(Parser, Typ, Identifier)
                return false
            else
                if Typ == pc.VoidType and Identifier ~= pc.StrEmpty then
                    ProgramFail(Parser, "can't define a void variable")
                end

                if Parser.Mode == RunMode.RunModeRun or Parser.Mode == RunMode.RunModeGoto then
                    --if Debug then
                    --    print("Define", Identifier.RawValue.Val)
                    --end
                    NewVariable, FirstVisit = VariableDefineButIgnoreIdentical(Parser,
                        Identifier, Typ, IsStatic)
                end

                Tok, _ = LexGetToken(Parser, nil, false)
                if Tok == LexToken.TokenAssign then
                    --if Debug then
                    --    print("Assign")
                    --end
                    LexGetToken(Parser, nil, true)
                    ParseDeclarationAssignment(Parser, NewVariable,
                        (not IsStatic) or FirstVisit)
                end
            end
        end

        Token, _ = LexGetToken(Parser, nil, false)
        if Token == LexToken.TokenComma then
            LexGetToken(Parser, nil, true)
        end
    until Token ~= LexToken.TokenComma

    return true
end

function ParseMacroDefinition(Parser)
    local MacroNameStr
    local MacroName
    local ParamName
    local MacroValue
    local Tok

    Tok, MacroName = LexGetToken(Parser, MacroName, true)
    if Tok ~= LexToken.TokenIdentifier then
        ProgramFail(Parser, "identifier expected")
    end

    MacroNameStr = MacroName.Val

    if LexRawPeekToken(Parser) == LexToken.TokenOpenMacroBracket then
        local Token
        Token, _ = LexGetToken(Parser, nil, true)
        local ParamParser = {}
        local NumParams
        local ParamCount = 1

        ParserCopy(ParamParser, Parser)
        NumParams = ParseCountParams(ParamParser)
        MacroValue = VariableAllocValueAndData(Parser.pc, Parser,
            0, false, nil, true)
        MacroValue.Val.MacroDef.NumParams = NumParams
        MacroValue.Val.MacroDef.ParamName = {}

        Token, ParamName = LexGetToken(Parser, ParamName, true)
        while Token == LexToken.TokenIdentifier do
            MacroValue.Val.MacroDef.ParamName[ParamCount] =
                ParamName.Val
            ParamCount = ParamCount + 1

            Token, _ = LexGetToken(Parser, nil, true)
            if Token == LexToken.TokenComma then
                Token, ParamName = LexGetToken(Parser, ParamName, true)
            elseif Token ~= LexToken.TokenCloseBracket then
                ProgramFail(Parser, "comma expected")
            end
        end

        if Token ~= LexToken.TokenCloseBracket then
            ProgramFail(Parser, "close bracket expected")
        end
    else
        MacroValue = VariableAllocValueAndData(Parser.pc, Parser,
            0, false, nil, true)
        MacroValue.Val.MacroDef.NumParams = 0
    end

    ParserCopy(MacroValue.Val.MacroDef.Body, Parser)
    MacroValue.Typ = Parser.pc.MacroType
    LexToEndOfMacro(Parser)
    MacroValue.Val.MacroDef.Body.ParsingTokens =
        LexCopyTokens(MacroValue.Val.MacroDef.Body, Parser)
    MacroValue.Val.MacroDef.Body.Pos = 1

    if not TableSet(Parser.pc, Parser.pc.GlobalTable, MacroNameStr, MacroValue,
        Parser.FileName, Parser.Line, Parser.CharacterPos) then
        ProgramFail(Parser, "'%s' is already defined", MacroNameStr.RawValue.Val)
    end
end

function ParserCopy(To, From)
    To.pc = From.pc
    To.Pos = From.Pos
    To.ParsingTokens = From.ParsingTokens
    To.FileName = From.FileName
    To.Line = From.Line
    To.CharacterPos = From.CharacterPos
    To.Mode = From.Mode
    To.SearchLabel = From.SearchLabel
    To.SearchGotoLabel = From.SearchGotoLabel
    To.SourceText = From.SourceText
    To.HashIfLevel = From.HashIfLevel
    To.HashIfEvaluateToLevel = From.HashIfEvaluateToLevel
    To.DebugMode = From.DebugMode
    To.ScopeID = From.ScopeID
end

function ParserCopyPos(To, From)
    To.Pos = From.Pos
    To.ParsingTokens = From.ParsingTokens
    To.Line = From.Line
    To.HashIfLevel = From.HashIfLevel
    To.HashIfEvaluateToLevel = From.HashIfEvaluateToLevel
    To.CharacterPos = From.CharacterPos
end

function ParseFor(Parser)
    local Condition
    local PreConditional = {}
    local PreIncrement = {}
    local PreStatement = {}
    local After = {}

    local OldMode = Parser.Mode

    local PrevScopeID = 0
    local ScopeID
    ScopeID, PrevScopeID = VariableScopeBegin(Parser)

    local Token
    Token, _ = LexGetToken(Parser, nil, true)
    if Token ~= LexToken.TokenOpenBracket then
        ProgramFail(Parser, "'(' expected")
    end

    if ParseStatement(Parser, true) ~= ParserResult.ParseResultOk then
        ProgramFail(Parser, "statement expected")
    end

    ParserCopyPos(PreConditional, Parser)
    Token, _ = LexGetToken(Parser, nil, false)
    if Token == LexToken.TokenSemicolon then
        Condition = true
    else
        Condition = C_INT_TO_LUA_BOOLEAN(ExpressionParseInt(Parser))
    end

    Token, _ = LexGetToken(Parser, nil, true)
    if Token ~= LexToken.TokenSemicolon then
        ProgramFail(Parser, "';' expected")
    end

    ParserCopyPos(PreIncrement, Parser)
    ParseStatementMaybeRun(Parser, false, false)

    Token, _ = LexGetToken(Parser, nil, true)
    if Token ~= LexToken.TokenCloseBracket then
        ProgramFail(Parser, "')' expected")
    end

    ParserCopyPos(PreStatement, Parser)
    if ParseStatementMaybeRun(Parser, Condition, true) ~= ParserResult.ParseResultOk then
        ProgramFail(Parser, "statement expected")
    end

    if Parser.Mode == RunMode.RunModeContinue and OldMode == RunMode.RunModeRun then
        Parser.Mode = RunMode.RunModeRun
    end

    ParserCopyPos(After, Parser)

    while Condition and Parser.Mode == RunMode.RunModeRun do
        ParserCopyPos(Parser, PreIncrement)
        ParseStatement(Parser, false)

        ParserCopyPos(Parser, PreConditional)
        Token, _ = LexGetToken(Parser, nil, false)
        if Token == LexToken.TokenSemicolon then
            Condition = true
        else
            Condition = C_INT_TO_LUA_BOOLEAN(ExpressionParseInt(Parser))
        end

        if Condition then
            ParserCopyPos(Parser, PreStatement)
            ParseStatement(Parser, true)

            if Parser.Mode == RunMode.RunModeContinue then
                Parser.Mode = RunMode.RunModeRun
            end
        end
    end

    if Parser.Mode == RunMode.RunModeBreak and OldMode == RunMode.RunModeRun then
        Parser.Mode = RunMode.RunModeRun
    end

    VariableScopeEnd(Parser, ScopeID, PrevScopeID)

    ParserCopyPos(Parser, After)
end

function ParseBlock(Parser, AbsorbOpenBrace, Condition)
    local PrevScopeID = 0
    local ScopeID
    ScopeID, PrevScopeID = VariableScopeBegin(Parser)

    --if Debug then
    --    print("ParseBlock Enter")
    --end

    if AbsorbOpenBrace then
        local Token
        Token, _ = LexGetToken(Parser, nil, true)
        if Token ~= LexToken.TokenLeftBrace then
            ProgramFail(Parser, "'{' expected")
        end
    end

    if Parser.Mode == RunMode.RunModeSkip or not Condition then
        local OldMode = Parser.Mode
        Parser.Mode = RunMode.RunModeSkip
        local ParseResult = ParseStatement(Parser, true)
        while ParseResult == ParserResult.ParseResultOk do
            ParseResult = ParseStatement(Parser, true)
        end
        Parser.Mode = OldMode
    else
        local ParseResult = ParseStatement(Parser, true)
        while ParseResult == ParserResult.ParseResultOk do
            ParseResult = ParseStatement(Parser, true)
        end
    end

    Token, _ = LexGetToken(Parser, nil, true)
    if Token ~= LexToken.TokenRightBrace then
        ProgramFail(Parser, "'}' expected")
    end

    VariableScopeEnd(Parser, ScopeID, PrevScopeID)

    return Parser.Mode
end

function ParseTypedef(Parser)
    local TypeName
    local Typ
    local InitValue

    Typ, TypeName, _ = TypeParse(Parser)
    InitValue = VariableAllocValueAndData(Parser.pc, Parser, 0, false, nil, true)

    --print("Typedef:", Typ.Base, TypeName.RawValue.Val, InitValue.Val.Ident)

    if Parser.Mode == RunMode.RunModeRun then
        InitValue.Typ = Parser.pc.TypeType
        InitValue.Val.Typ = Typ     -- Val here points to Typ, not AnyValue type
        VariableDefine(Parser.pc, Parser, TypeName, InitValue, nil, false)
    end
end

function ParseStatement(Parser, CheckTrailingSemicolon)
    local Condition
    local Token
    local CValue
    local LexerValue
    local VarValue
    local PreState = {}

    ParserCopy(PreState, Parser)
    Token, LexerValue = LexGetToken(Parser, LexerValue, true)
    --if Debug then
    --    print("Token:", Token)
    --end

    if Token == LexToken.TokenEOF then
        return ParserResult.ParseResultEOF
    elseif Token == LexToken.TokenIdentifier then
        --if Debug then
        --    print("Parse Identifier")
        --end
        if VariableDefined(Parser.pc, LexerValue.Val) then
            VarValue = VariableGet(Parser.pc, Parser, LexerValue.Val)
            if VarValue.Typ.Base == BaseType.TypeType then
                ParserCopy(Parser, PreState)
                ParseDeclaration(Parser, Token)
                CheckTrailingSemicolon = false
            else
                -- Fallthrough
                ParserCopy(Parser, PreState)
                _, CValue = ExpressionParse(Parser)
                if Parser.Mode == RunMode.RunModeRun then
                    VariableStackPop(Parser, CValue)
                end
            end
        else
            local NextToken
            NextToken, _ = LexGetToken(Parser, nil, false)
            if NextToken == LexToken.TokenColon then
                LexGetToken(Parser, nil, true)
                if (Parser.Mode == RunMode.RunModeGoto and
                    LexerValue.Val == Parser.SearchGotoLabel) then
                    Parser.Mode = RunMode.RunModeRun
                end
                CheckTrailingSemicolon = false
            else
                -- Fallthrough
                ParserCopy(Parser, PreState)
                _, CValue = ExpressionParse(Parser)
                if Parser.Mode == RunMode.RunModeRun then
                    VariableStackPop(Parser, CValue)
                end
            end
        end
    elseif (Token == LexToken.TokenAsterisk or Token == LexToken.TokenAmpersand or
        Token == LexToken.TokenIncrement or Token == LexToken.TokenDecrement or
        Token == LexToken.TokenOpenBracket) then
        ParserCopy(Parser, PreState)
        _, CValue = ExpressionParse(Parser)
        if Parser.Mode == RunMode.RunModeRun then
            VariableStackPop(Parser, CValue)
        end
    elseif Token == LexToken.TokenLeftBrace then
        ParseBlock(Parser, false, true)
        CheckTrailingSemicolon = false
    elseif Token == LexToken.TokenIf then
        local Tok
        Tok, _ = LexGetToken(Parser, nil, true)
        if Tok ~= LexToken.TokenOpenBracket then
            ProgramFail(Parser, "'(' expected")
        end
        Condition = C_INT_TO_LUA_BOOLEAN(ExpressionParseInt(Parser))
        Tok, _ = LexGetToken(Parser, nil, true)
        if Tok ~= LexToken.TokenCloseBracket then
            ProgramFail(Parser, "')' expected")
        end
        if ParseStatementMaybeRun(Parser, Condition, true) ~= ParserResult.ParseResultOk then
            ProgramFail(Parser, "statement expected")
        end
        Tok, _ = LexGetToken(Parser, nil, false)
        if Tok == LexToken.TokenElse then
            LexGetToken(Parser, nil, true)
            if ParseStatementMaybeRun(Parser, not Condition, true) ~= ParserResult.ParseResultOk then
                ProgramFail(Parser, "statement expected")
            end
        end
        CheckTrailingSemicolon = false
    elseif Token == LexToken.TokenWhile then
        local PreConditional = {}
        local PreMode = Parser.Mode
        local Tok
        Tok, _ = LexGetToken(Parser, nil, true)
        if Tok ~= LexToken.TokenOpenBracket then
            ProgramFail(Parser, "'(' expected")
        end
        ParserCopyPos(PreConditional, Parser)
        repeat
            ParserCopyPos(Parser, PreConditional)
            Condition = C_INT_TO_LUA_BOOLEAN(ExpressionParseInt(Parser))
            Tok, _ = LexGetToken(Parser, nil, true)
            if Tok ~= LexToken.TokenCloseBracket then
                ProgramFail(Parser, "')' expected")
            end
            if ParseStatementMaybeRun(Parser, Condition, true) ~= ParserResult.ParseResultOk then
                ProgramFail(Parser, "statement expected")
            end
            if Parser.Mode == RunMode.RunModeContinue then
                Parser.Mode = PreMode
            end
        until Parser.Mode ~= RunMode.RunModeRun or not Condition
        if Parser.Mode == RunMode.RunModeBreak then
            Parser.Mode = PreMode
        end
        CheckTrailingSemicolon = false
    elseif Token == LexToken.TokenDo then
        local PreStatement = {}
        local PreMode = Parser.Mode
        ParserCopyPos(PreStatement, Parser)
        repeat
            ParserCopyPos(Parser, PreStatement)
            if ParseStatement(Parser, true) ~= ParserResult.ParseResultOk then
                ProgramFail(Parser, "statement expected")
            end
            if Parser.Mode == RunMode.RunModeContinue then
                Parser.Mode = PreMode
            end
            local Tok
            Tok, _ = LexGetToken(Parser, nil, true)
            if Tok ~= LexToken.TokenWhile then
                ProgramFail(Parser, "'while' expected")
            end
            Tok, _ = LexGetToken(Parser, nil, true)
            if Tok ~= LexToken.TokenOpenBracket then
                ProgramFail(Parser, "'(' expected")
            end
            Condition = C_INT_TO_LUA_BOOLEAN(ExpressionParseInt(Parser))
            Tok, _ = LexGetToken(Parser, nil, true)
            if Tok ~= LexToken.TokenCloseBracket then
                ProgramFail(Parser, "')' expected")
            end
        until not Condition or Parser.Mode ~= RunMode.RunModeRun
        if Parser.Mode == RunMode.RunModeBreak then
            Parser.Mode = PreMode
        end
    elseif Token == LexToken.TokenFor then
        ParseFor(Parser)
        CheckTrailingSemicolon = false
    elseif Token == LexToken.TokenSemicolon then
        CheckTrailingSemicolon = false
    elseif (Token == LexToken.TokenIntType or Token == LexToken.TokenShortType or
        Token == LexToken.TokenCharType or Token == LexToken.TokenLongType or
        Token == LexToken.TokenFloatType or Token == LexToken.TokenDoubleType or
        Token == LexToken.TokenVoidType or Token == LexToken.TokenStructType or
        Token == LexToken.TokenUnionType or Token == LexToken.TokenEnumType or
        Token == LexToken.TokenSignedType or Token == LexToken.TokenUnsignedType or
        Token == LexToken.TokenStaticType or Token == LexToken.TokenAutoType or
        Token == LexToken.TokenRegisterType or Token == LexToken.TokenExternType) then
        ParserCopy(Parser, PreState)
        --if Debug then
        --    print("PS:", Parser.Line, Parser.CharacterPos)
        --end
        CheckTrailingSemicolon = ParseDeclaration(Parser, Token)
    elseif Token == LexToken.TokenHashDefine then
        ParseMacroDefinition(Parser)
        CheckTrailingSemicolon = false
    elseif Token == LexToken.TokenHashInclude then
        local Tok
        Tok, LexerValue = LexGetToken(Parser, LexerValue, true)
        if Tok ~= LexToken.TokenStringConstant then
            ProgramFail(Parser, "\"filename.h\" expected")
        end
        local StringConstant = PointerDereference(LexerValue.Val)
        IncludeFile(Parser.pc, StringConstant)
        CheckTrailingSemicolon = false
    elseif Token == LexToken.TokenSwitch then
        Tok, _ = LexGetToken(Parser, nil, true)
        if Tok ~= LexToken.TokenOpenBracket then
            ProgramFail(Parser, "'(' expected")
        end
        Condition = ExpressionParseInt(Parser)
        Tok, _ = LexGetToken(Parser, nil, true)
        if Tok ~= LexToken.TokenCloseBracket then
            ProgramFail(Parser, "')' expected")
        end
        Tok, _ = LexGetToken(Parser, nil, false)
        if Tok ~= LexToken.TokenLeftBrace then
            ProgramFail(Parser, "'{' expected")
        end

        local OldMode = Parser.Mode
        local OldSearchLabel = Parser.SearchLabel
        Parser.Mode = RunMode.RunModeCaseSearch
        Parser.SearchLabel = Condition
        ParseBlock(Parser, true, OldMode ~= RunMode.RunModeSkip and
            OldMode ~= RunMode.RunModeReturn)
        if Parser.Mode ~= RunMode.RunModeReturn then
            Parser.Mode = OldMode
        end
        Parser.SearchLabel = OldSearchLabel
        CheckTrailingSemicolon = false
    elseif Token == LexToken.TokenCase then
        if Parser.Mode == RunMode.RunModeCaseSearch then
            Parser.Mode = RunMode.RunModeRun
            Condition = ExpressionParseInt(Parser)
            Parser.Mode = RunMode.RunModeCaseSearch
        else
            Condition = ExpressionParseInt(Parser)
        end
        local Tok
        Tok, _ = LexGetToken(Parser, nil, true)
        if Tok ~= LexToken.TokenColon then
            ProgramFail(Parser, "':' expected")
        end
        if Parser.Mode == RunMode.RunModeCaseSearch and Condition == Parser.SearchLabel then
            Parser.Mode = RunMode.RunModeRun
        end
        CheckTrailingSemicolon = false
    elseif Token == LexToken.TokenDefault then
        local Tok
        Tok, _ = LexGetToken(Parser, nil, true)
        if Tok ~= LexToken.TokenColon then
            ProgramFail(Parser, "':' expected")
        end
        if Parser.Mode == RunMode.RunModeCaseSearch then
            Parser.Mode = RunMode.RunModeRun
        end
        CheckTrailingSemicolon = false
    elseif Token == LexToken.TokenBreak then
        if Parser.Mode == RunMode.RunModeRun then
            Parser.Mode = RunMode.RunModeBreak
        end
    elseif Token == LexToken.TokenContinue then
        if Parser.Mode == RunMode.RunModeRun then
            Parser.Mode = RunMode.RunModeContinue
        end
    elseif Token == LexToken.TokenReturn then
        if Parser.Mode == RunMode.RunModeRun then
            local GlobalOrNotVoid
            --print("Get StackFrame ReturnValue", Parser.pc.TopStackFrameId)
            if Parser.pc.TopStackFrameId == 0 then
                GlobalOrNotVoid = true
            elseif HeapGetStackNode(Parser.pc, Parser.pc.TopStackFrameId).ReturnValue.Typ.Base ~= BaseType.TypeVoid then
                GlobalOrNotVoid = true
            else
                GlobalOrNotVoid = false
            end

            if GlobalOrNotVoid then
                local Success
                Success, CValue = ExpressionParse(Parser)
                if not Success then
                    ProgramFail(Parser, "value required in return")
                end
                if Parser.pc.TopStackFrameId == 0 then
                    -- Exit the program
                    PlatformExit(Parser.pc, ExpressionCoerceInteger(CValue))
                else
                    local TopStackFrame = HeapGetStackNode(Parser.pc, Parser.pc.TopStackFrameId)
                    ExpressionAssign(Parser,
                        TopStackFrame.ReturnValue, CValue, true,
                        nil, 0, false)
                    VariableStackPop(Parser, CValue)
                end
            else
                local Success
                Success, CValue = ExpressionParse(Parser)
                if Success then
                    ProgramFail(Parser, "value in return from a void function")
                end
            end
            Parser.Mode = RunMode.RunModeReturn
        else
            _, CValue = ExpressionParse(Parser)
        end
    elseif Token == LexToken.TokenTypedef then
        ParseTypedef(Parser)
    elseif Token == LexToken.TokenGoto then
        local Tok
        Tok, LexerValue = LexGetToken(Parser, LexerValue, true)
        if Tok ~= LexToken.TokenIdentifier then
            ProgramFail(Parser, "identifier expected")
        end
        if Parser.Mode == RunMode.RunModeRun then
            Parser.SearchGotoLabel = LexerValue.Val
            Parser.Mode = RunMode.RunModeGoto
        end
    elseif Token == LexToken.TokenDelete then
        local Tok
        Tok, LexerValue = LexGetToken(Parser, LexerValue, true)
        if Tok ~= LexToken.TokenIdentifier then
            ProgramFail(Parser, "identifier expected")
        end
        if Parser.Mode == RunMode.RunModeRun then
            CValue = TableDelete(Parser.pc, Parser.pc.GlobalTable,
                LexerValue.Val)
            if CValue == nil then
                ProgramFail(Parser, "'%s' is not defined",
                    LexerValue.Val.RawValue.Val)
            end

            VariableFree(Parser.pc, CValue)
        end
    else
        ParserCopy(Parser, PreState)
        return ParserResult.ParseResultError
    end

    if CheckTrailingSemicolon then
        local Tok
        Tok, _ = LexGetToken(Parser, nil, true)
        --if Debug then
        --    print(Token, Tok, Parser.Line, Parser.CharacterPos)
        --end
        if Tok ~= LexToken.TokenSemicolon then
            ProgramFail(Parser, "';' expected")
        end
    end

    return ParserResult.ParseResultOk
end

function PicocParse(pc, FileName, Source, SourceLen, RunIt, EnableDebugger)
    local RegFileName = TableStrRegister(pc, FileName)
    local Ok = ParserResult.ParseResultOk
    local Parser = {}

    local Tokens
    Tokens, _ = LexAnalyse(pc, RegFileName, Source, SourceLen)

    LexInitParser(Parser, pc, Source, Tokens, RegFileName, RunIt,
        EnableDebugger)

    repeat
        Ok = ParseStatement(Parser, true)
    until Ok ~= ParserResult.ParseResultOk

    if Ok == ParserResult.ParseResultError then
        ProgramFail(Parser, "parse error")
    end
end

function PicocParseInteractiveNoStartPrompt(pc, EnableDebugger)
    local Status
    local Ok
    local Parser = {}

    LexInitParser(Parser, pc, nil, nil, pc.StrEmpty, true, EnableDebugger)
    LexInteractiveClear(pc, Parser)

    repeat
        LexInteractiveStatementPrompt(pc)

        ParseInteractive = coroutine.create(function()
            return ParseStatement(Parser, true)
        end)

        repeat
            Status, Ok = coroutine.resume(ParseInteractive)
            if coroutine.status(ParseInteractive) == "suspended" then
                coroutine.yield()
            else
                if Status then
                    LexInteractiveCompleted(pc, Parser)
                else
                    if string.find(Ok, "C Parsing Error") ~= nil then
                        LexInteractiveClear(pc, Parser)
                        Ok = ParserResult.ParseResultOk
                    else
                        error(Ok)
                    end
                end
            end
        until coroutine.status(ParseInteractive) ~= "suspended"
    until Ok ~= ParserResult.ParseResultOk

    if Ok == ParserResult.ParseResultError then
        ProgramFail(Parser, "parse error")
    end

    PlatformPrintf(pc.CStdOut, "\n")
end

function PicocParseInteractive(pc)
    PlatformPrintf(pc.CStdOut, INTERACTIVE_HEAD_STATEMENT)
    PicocParseInteractiveNoStartPrompt(pc, GEnableDebugger)
end
