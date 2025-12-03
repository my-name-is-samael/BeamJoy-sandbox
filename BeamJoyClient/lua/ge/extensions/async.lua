---@class NGJob
---@field yield fun()
---@field sleep fun(sec: number)
---@field setExitCallback fun(cb: fun(jobData: table))

local M = {
    preloadedDependencies = { "core_jobsystem" },
    dependencies = {},

    tasks = {},
    tasksToRemove = {},
    delayedTasks = {},
    delayedToRemove = {},
}
AddPreloadedDependencies(M)
-- gc prevention
local ctxt = { now = 0 }

local function onInit()
    InitPreloadedDependencies(M)
end

local function onUpdate()
    ctxt = extensions.beamjoy_context.get()
end

---@param key string
local function exists(key)
end

---@param key string
local function getRemainingDelay(key)
end

---@param key string
local function removeTask(key)
    if M.tasks[key] then
        M.tasksToRemove[key] = true
    end

    if M.delayedTasks[key] then
        M.delayedToRemove[key] = true
    end
end

---@param conditionFn fun(job: NGJob, ctxt: TickContext): boolean
---@param taskFn fun(job: NGJob, ctxt: TickContext)
---@param key? string|integer
local function task(conditionFn, taskFn, key)
    if conditionFn == nil or taskFn == nil or
        type(conditionFn) ~= "function" or type(conditionFn) ~= type(taskFn) then
        error("Tasks need conditionFn and taskFn")
    end
    if key == nil then
        key = UUID()
    end

    local function start()
        ---@param job NGJob
        extensions.core_jobsystem.create(function(job)
            while not conditionFn(job, ctxt) and not M.tasksToRemove[key] do
                job.sleep(.01)
            end
            if M.tasksToRemove[key] then
                M.tasksToRemove[key] = nil
            else
                taskFn(job, ctxt)
            end
            M.tasks[key] = nil
        end, .1)
        M.tasks[key] = true
    end

    if M.tasks[key] then
        M.tasksToRemove[key] = true
        ---@param job NGJob
        extensions.core_jobsystem.create(function(job)
            job.setExitCallback(start)
            while M.tasks[key] do
                job.sleep(.01)
            end
        end, .1)
    else
        start()
    end
end

---@param taskFn fun(job: NGJob, ctxt: TickContext)
---@param targetMs integer|number
---@param key? string|integer
local function programTask(taskFn, targetMs, key)
    if taskFn == nil or type(targetMs) ~= "number" or type(taskFn) ~= "function" then
        error("Delayed tasks need taskFn and targetMs")
    end
    key = key or UUID()

    local function start()
        ---@param job NGJob
        extensions.core_jobsystem.create(function(job)
            while ctxt.now < targetMs and not M.delayedToRemove[key] do
                job.sleep(.01)
            end
            if M.delayedToRemove[key] then
                M.delayedToRemove[key] = nil
            else
                taskFn(job, ctxt)
            end
            M.delayedTasks[key] = nil
        end, .1)
        M.delayedTasks[key] = true
    end

    if M.delayedTasks[key] then
        M.delayedToRemove[key] = true
        ---@param job NGJob
        extensions.core_jobsystem.create(function(job)
            job.setExitCallback(start)
            while M.delayedTasks[key] do
                job.sleep(.01)
            end
        end, .1)
    else
        start()
    end
end

---@param taskFn fun(job: NGJob, ctxt: TickContext)
---@param delayMs integer|number
---@param key? string|integer
local function delayTask(taskFn, delayMs, key)
    if taskFn == nil or type(delayMs) ~= "number" or type(taskFn) ~= "function" then
        error("Delayed tasks need taskFn and delayMs")
    end

    M.programTask(taskFn, ctxt.now + delayMs, key)
end

M.onInit = onInit
M.onUpdate = onUpdate

M.exists = exists
M.getRemainingDelay = getRemainingDelay
M.removeTask = removeTask
M.task = task
M.delayTask = delayTask
M.programTask = programTask


return M
