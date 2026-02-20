#!/usr/bin/env lua

---
--- Expense Tracker CLI
---
local csv_file = "expenses.csv"

local function file_exists(path)
    local file = io.open(path, "r")
    if file then
        file:close()
        return true
    else
        return false
    end
end

local function save_to_csv(expense)
    if not file_exists(csv_file) then
        local file = io.open(csv_file, "w") or error("Error: Unable to create file " .. csv_file)

        file:write("id,date,description,amount\n")
        file:close()
    end

    local last_id = 0
    local file = io.open(csv_file, "r") or error("Error: Unable to open file " .. csv_file)

    for line in file:lines() do
        if not line:match("^id,") then
            local id = line:match("^(%d+),")
            if id then
                last_id = math.max(last_id, tonumber(id))
            end
        end
    end
    file:close()
    local next_id = last_id + 1

    local file = io.open(csv_file, "a") or error("Error: Unable to open file " .. csv_file)
    local line = string.format(
        "%d,%s,%s,%.2f\n",
        next_id,
        expense.date,
        expense.description,
        expense.amount
    )
    file:write(line)
    file:close()
    print("expense added successfully (ID: " .. next_id .. ")")
end

local function split_csv(line)
    local t = {}
    for field in string.gmatch(line, "([^,]+)") do
        table.insert(t, field)
    end
    return t
end

local function parse_args(start_index)
    local options = {}
    local i = start_index
    while i <= #arg do
        local current = arg[i]
        if string.sub(current, 1, 2) == "--" then
            local key = string.sub(current, 3)
            local value = arg[i + 1]
            if not value or string.sub(value, 1, 2) == "--" then
                print("Error: Option missing value for " .. current)
                os.exit(1)
            end

            options[key] = value
            i = i + 2
        else
            print("Error: Unexpected argument " .. current)
            i = i + 1
            os.exit(1)
        end
    end
    return options
end

local function add()
    local options = parse_args(2)
    if not options.amount or not options.description then
        print("Error: Missing required options --amount and --description")
        os.exit(1)
    end
    local amount = tonumber(options.amount) * 100
    if not amount then
        print("Error: Invalid amount value")
        os.exit(1)
    end
    local description = options.description
    local date = options.date or os.date("%Y-%m-%d")
    local expense = {
        amount = amount,
        description = description,
        date = date
    }
    save_to_csv(expense)
end

local function list()
    if not file_exists(csv_file) then
        print("No expenses recorded yet.")
        return
    end

    local file = io.open(csv_file, "r") or error("Error: Unable to open file " .. csv_file)

    print("\n📊  EXPENSE LIST")
    print("----------------------------------------------------")
    print(string.format("%-6s | %-12s | %-14s | %-10s", "ID", "Date", "Description", "Amount"))
    print("----------------------------------------------------")

    local first_line = true
    for line in file:lines() do
        if first_line then
            first_line = false
            goto continue
        end

        local data = split_csv(line)
        if #data == 4 then
            print(string.format(
                "%-6s | %-12s | %-14s | $ %8.2f",
                data[1],
                data[2],
                data[3],
                data[4] / 100
            ))
        end
        ::continue::
    end

    print("----------------------------------------------------")
    file:close()
end

local function delete()
    local options = parse_args(2)

    if not options.id then
        error("Error: Missing required option --id")
    end

    local id_to_delete = tonumber(options.id)

    if not id_to_delete then
        error("Error: Invalid ID value")
    end

    if not file_exists(csv_file) then
        print("No expenses recorded yet.")
        return
    end

    local file = io.open(csv_file, "r") or error("Error: Unable to open file " .. csv_file)
    local lines = {}
    local found = false
    for line in file:lines() do
        local data = split_csv(line)
        if #data == 4 and tonumber(data[1]) == id_to_delete then
            found = true
        else
            table.insert(lines, line)
        end
    end
    file:close()
    if not found then
        print("Expense with ID " .. id_to_delete .. " not found.")
        return
    end

    local file = io.open(csv_file, "w") or error("Error: Unable to open file " .. csv_file)
    for _, line in ipairs(lines) do
        file:write(line .. "\n")
    end
    file:close()
    print("Expense deleted successfully (ID: " .. id_to_delete .. ")")
end

local function month_names(num)
    local names = {
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    }
    return names[tonumber(num)]
end

local function summary()
    local options = parse_args(2)
    local month_filter = options.month
    local year_filter = options.year
    if month_filter and (tonumber(month_filter) < 1 or tonumber(month_filter) > 12) then
        error("Error: Invalid month value")
    end

    if year_filter and (tonumber(year_filter) < 1900 or tonumber(year_filter) > 2100) then
        error("Error: Invalid year value")
    end

    if not file_exists(csv_file) then
        print("No expenses recorded yet.")
        return
    end

    local file = io.open(csv_file, "r") or error("Error: Unable to open file " .. csv_file)
    local total = 0
    local first_line = true
    for line in file:lines() do
        if first_line then
            first_line = false
            goto continue
        end
        local data = split_csv(line)
        if #data == 4 then
            local date = data[2]
            local amount = tonumber(data[4])
            local year, month = date:match("^(%d%d%d%d)%-(%d%d)")
            if (not month_filter or month == string.format("%02d", month_filter)) and
                (not year_filter or year == year_filter) then
                total = total + amount
            end
        end
        ::continue::
    end
    file:close()

    local period = (month_filter and year_filter) and string.format("%s/%s", month_names(month_filter), year_filter)
        or (month_filter) and string.format("month %s", month_names(month_filter))
        or (year_filter) and string.format("year %s", year_filter)
        or ""

    print(string.format("Total expenses%s: $%.2f", period ~= "" and " for " .. period or "", total / 100))
end

local function help()
    print("Expense Tracker CLI")
    print("Usage:")
    print("  add --description <description> --amount <amount> ")
    print("  list")
    print("  delete --id <expense_id>")
    print("  summary [--month <1-12>]")
end

--- Command dispatch

local commands = {
    add = add,
    list = list,
    delete = delete,
    summary = summary,
    help = help
}


--- Main execution

local command = arg[1] or 'help'
local handler = commands[command]
if handler then
    local success, err = pcall(handler)
    if not success then
        print("Error: " .. err)
        os.exit(1)
    end
else
    print("Unknown command: " .. command)
    os.exit(1)
end
