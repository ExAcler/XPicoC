function HeapInit(pc)
    pc.HeapMemory = {}
    pc.HeapStackTop = 0
    pc.StackFrame = 0
    pc.TopStackFrameId = 0
end

function HeapCleanup(pc)
    pc.HeapMemory = nil
    collectgarbage()
end

function HeapAllocStack(pc)
    local NewTop = pc.HeapStackTop + 1
    local NewMem = {
        StackId = NewTop
    }

    pc.HeapMemory[NewTop] = NewMem
    pc.HeapStackTop = NewTop
    return NewMem
end

function HeapUnpopStack(pc)
    local NewTop = pc.HeapStackTop + 1

    if pc.HeapMemory[NewTop] ~= nil then
        pc.HeapStackTop = NewTop
    end
end

-- Pop stack without actually removing the item
-- Just move the top pointer
function HeapPopStack(pc, n, ExpectedAddress)
    if n > pc.HeapStackTop then
        return false
    end

    --[[
    if ExpectedAddress then
        assert(pc.HeapStackTop - n == ExpectedAddress,
            string.format("HeapPopStack assertion failed: Stack location expected at %d, but got %d",
            ExpectedAddress, pc.HeapStackTop - n))
    end
    --]]

    pc.HeapStackTop = pc.HeapStackTop - n
    return true
end

function HeapPushStackFrame(pc)
    local NewTop = pc.HeapStackTop + 1
    local NewMem = {
        StackId = NewTop,
        PreviousFrameLoc = pc.StackFrame
    }

    pc.HeapMemory[NewTop] = NewMem
    pc.StackFrame = pc.HeapStackTop + 1
    pc.HeapStackTop = NewTop
end

function HeapPopStackFrame(pc)
    local StackFrameItem = pc.HeapMemory[pc.StackFrame]
    if StackFrameItem ~= nil then
        local PreviousFrameLoc = StackFrameItem.PreviousFrameLoc

        if PreviousFrameLoc ~= nil then
            pc.HeapStackTop = pc.StackFrame - 1
            pc.StackFrame = PreviousFrameLoc
            return true
        else
            return false
        end
    else
        return false
    end
end

function HeapGetStackNode(pc, n)
    return pc.HeapMemory[n]
end
