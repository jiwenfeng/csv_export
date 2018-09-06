local TypeList = {
    ["int"] = "String2Int",
    ["std::map"] = "String2Map", 
    ["std::vector"] = "String2Vector",
    ["Json::Value"] = "String2Json"
}

local CSV_PATH = ""

function Split(str, sep)
    local strList = {}
    string.gsub(str, '[^' .. sep .. ']+', function(w)
        table.insert(strList, w)
    end)
    return strList
end

function SplitCsvData(str)
    local strList = {}
    while true do
        str, n = string.gsub(str, '""', '"')
        if n == 0 then
            break
        end
    end
    local flag = false
    local start = 1
    for i = 1, #str do
        if string.char(string.byte(str, i, i)) == '"' then
            flag = not flag
        else
            if string.char(string.byte(str, i, i)) == ',' and not flag then
                local data = string.sub(str, start, i - 1)
                data = string.gsub(data, '"', '')
                if string.len(data) > 0 then
                    table.insert(strList, data)
                end
                start = i + 1
            end
        end
    end
    if start ~= #str then
        local data = string.sub(str, start, #str)
        data = string.gsub(data, '"', '')
        if string.len(data) > 0 then
            table.insert(strList, data)
        end
    end
    return strList
end

function GetClassName(path)
    local strList = Split(path, "/")
    if #strList == 0 then
        return nil
    end
    local filename = strList[#strList]
    return string.match(filename, "(%w+).%w+")
end

function AnalysisCsvFile(path)
    local csv_file_handler = io.open(path, "r")
    if not csv_file_handler then
        return nil
    end

    local attr_data = {}
    local line = 1
    while line <= 12 do
        local line_data = csv_file_handler:read("*line")
        if not line_data then
            break
        end
        if line == 9 or line == 11 or line == 12 then
            table.insert(attr_data, line_data)
        end
        line = line + 1
    end
    csv_file_handler:close()

    if #attr_data ~= 3 then
        return nil
    end

    local varTypeList = SplitCsvData(attr_data[1], ",")
    local commentList = SplitCsvData(attr_data[2], ",")
    local varNameList = SplitCsvData(attr_data[3], ",")

    if #varTypeList ~= #varNameList then
        return nil
    end

    local result = {}
    result.clsName = GetClassName(path)
    result.path = path
    result.cols = {}

    for i = 1, #varTypeList do
        local attr = {}
        attr.varType = varTypeList[i]
        attr.varType = string.gsub(attr.varType, "string", "std::string")
        attr.varType = string.gsub(attr.varType, "map", "std::map")
        attr.varType = string.gsub(attr.varType, "array", "std::vector")
        attr.varType = string.gsub(attr.varType, "json", "Json::Value")
        attr.varName = varNameList[i]
        attr.comment = commentList[i]
        table.insert(result.cols, attr)
    end

    return result
end

function ExportClassHeaderFile(data)
    local handler = io.open(data.clsName .. ".h", "w+")
    if not handler then
        return false
    end
    handler:write("#ifndef __" .. string.upper(data.clsName) .. "_H__\n")
    handler:write("#define __" .. string.upper(data.clsName) .. "_H__\n\n")
    handler:write("#include <json/json.h>\n")
    handler:write("#include <vector>\n")
    handler:write("#include <map>\n")
    handler:write("\n\n")
    handler:write("namespace CsvConfig\n{\n\n")
    handler:write("\tclass " .. data.clsName .. "\n\t{\n")
    handler:write("\tpublic:\n")
    handler:write("\t\t" .. data.clsName .. "();\n\n")
    handler:write("\t\t~" .. data.clsName .. "();\n\n")
    handler:write("\tpublic:\n")
    handler:write("\t\tvoid init(std::map<std::string, std::string> data);\n\n")
    handler:write("\tpublic:\n")
    for _, attr in ipairs(data.cols) do
        handler:write("\t\tconst " .. attr.varType .. "& " .. "get_" .. attr.varName .. "() const;\n\n")
    end
    handler:write("\tprivate:\n")
    for _, attr in ipairs(data.cols) do
        handler:write("\t\t" .. attr.varType .. " m_" .. attr.varName .. "; //".. attr.comment .."\n\n")
    end
    handler:write("\tpublic:\n")
    handler:write("\t\tstatic std::string m_fileName;\n")
    handler:write("\t};\n")
    handler:write("}\n\n")
    handler:write("#endif")
    handler:close()
    return true
end

function ExportClassSourceFile(data)
    local handler = io.open(data.clsName .. ".cpp", "w+")
    if not handler then
        return false
    end
    handler:write("#include \"" .. data.clsName .. ".h\"\n")
    handler:write("#include \"csv_tool.h\"\n\n")
    handler:write("namespace CsvConfig\n{\n")
    handler:write("\tstd::string " .. data.clsName .. "::m_fileName = \"" .. CSV_PATH .. data.path .. "\";\n")
    handler:write("\t" .. data.clsName .. "::" .. data.clsName .. "()\n\t{\n\t}\n\n")
    handler:write("\t" .. data.clsName .. "::~" .. data.clsName .. "()\n\t{\n\t}\n\n")

    handler:write("\tvoid " .. data.clsName .. "::init(std::map<std::string, std::string> data)\n\t{\n")
    for _, attr in ipairs(data.cols) do
        strType = string.match(attr.varType, "(%w+%p-%w+)<*")
        if TypeList[strType] then
            handler:write("\t\t".. TypeList[strType] .. "(data[\"" .. attr.varName .. "\"], m_" .. attr.varName .. ");\n")
        else
            handler:write("\t\tm_" .. attr.varName .. " = data[\"" .. attr.varName .. "\"];\n")
        end
    end
    handler:write("\t}\n\n")

    for _, attr in ipairs(data.cols) do
        handler:write("\tconst " .. attr.varType .. "& " .. data.clsName .. "::get_" .. attr.varName .. "() const\n\t{\n")
        handler:write("\t\treturn m_" .. attr.varName .. ";\n")
        handler:write("\t}\n\n")
    end
    handler:write("}\n")
    handler:close()
    return true
end

function ExportClassFile(path)
    local result = AnalysisCsvFile(path)
    if not result then
        print("Analysis " .. path .. " fail")
        return false
    end
    if ExportClassHeaderFile(result) and ExportClassSourceFile(result) then
        return true, result
    end
end

function ExportMgrHeaderFile(result)
    local handler = io.open("config_mgr.h", "w+")
    if not handler then
        return false
    end
    handler:write("#ifndef __CONFIG_MGR_H__\n")
    handler:write("#define __CONFIG_MGR_H__\n")

    handler:write("#include <map>\n")

    for _, data in ipairs(result) do
        handler:write("#include \"" .. data.clsName .. ".h\"\n")
    end
    handler:write("\n\n")

    handler:write("class CsvConfigMgr\n{\n")
    handler:write("public:\n")
    handler:write("\tstatic CsvConfigMgr &getInstance()\n")
    handler:write("\t{\n")
    handler:write("\t\tstatic CsvConfigMgr inst;\n")
    handler:write("\t\treturn inst;\n")
    handler:write("\t}\n\n")

    handler:write("public:\n")
    handler:write("\tvoid reload();\n\n")

    handler:write("private:\n")
    handler:write("\tCsvConfigMgr();\n\n")
    handler:write("\tCsvConfigMgr(const CsvConfigMgr &rhs);\n\n")
    handler:write("\tCsvConfigMgr &operator=(const CsvConfigMgr &rhs);\n\n")
    
    handler:write("private:\n")
    handler:write("\tvoid load();\n\n")
    for _, data in ipairs(result) do
        handler:write("\tvoid load" .. data.clsName .. "FromCsv();\n\n")
    end

    handler:write("public:\n")
    for _, data in ipairs(result) do
        handler:write("\tCsvConfig::" .. data.clsName .. "* find" .. data.clsName .. "ByKey(" .. data.cols[1].varType .. " " .. data.cols[1].varName .. ");\n\n")
        handler:write("\tconst std::map<" .. data.cols[1].varType..", CsvConfig::" .. data.clsName .. "> get" .. data.clsName .. "Map();\n\n")
    end

    handler:write("private:\n")
    for _, data in ipairs(result) do
        handler:write("\tstd::map<"..data.cols[1].varType..", CsvConfig::" .. data.clsName .. "> m_map" .. data.clsName .. ";\n")
    end

    handler:write("};\n")
    handler:write("#endif\n")
    handler:close()
    return true
end

function ExportMgrSourceFile(result)
    local handler = io.open("config_mgr.cpp", "w+")
    if not handler then
        return false
    end
    handler:write("#include <vector>\n")
    handler:write("#include \"config_mgr.h\"\n")
    handler:write("#include \"csv_tool.h\"\n\n")

    handler:write("CsvConfigMgr::CsvConfigMgr()\n")
    handler:write("{\n")
    handler:write("}\n\n")

    handler:write("void CsvConfigMgr::reload()\n")
    handler:write("{\n")
    for _, data in ipairs(result) do
        handler:write("\tm_map"..data.clsName..".clear();\n")
    end
    handler:write("}\n\n")

    handler:write("void CsvConfigMgr::load()\n")
    handler:write("{\n")
    for _, data in ipairs(result) do
        handler:write("\tload"..data.clsName.."FromCsv();\n")
    end
    handler:write("}\n\n")

    for _, data in ipairs(result) do
        handler:write("CsvConfig::" .. data.clsName .."* " .. "CsvConfigMgr::find" .. data.clsName .. "ByKey(" .. data.cols[1].varType .. " " .. data.cols[1].varName .. ")\n")
        handler:write("{\n")
        handler:write("\tif(m_map" .. data.clsName .. ".empty())\n")
        handler:write("\t{\n")
        handler:write("\t\tload"..data.clsName.."FromCsv();\n")
        handler:write("\t}\n")
        handler:write("\tstd::map<"..data.cols[1].varType..", CsvConfig::" .. data.clsName .. ">::iterator i = m_map"..data.clsName..".find(" .. data.cols[1].varName .. ");\n")
        handler:write("\tif(i == m_map"..data.clsName..".end())\n")
        handler:write("\t{\n")
        handler:write("\t\treturn NULL;\n")
        handler:write("\t}\n")
        handler:write("\treturn &i->second;\n")
        handler:write("}\n\n")

        handler:write("const std::map<"..data.cols[1].varType .. ", CsvConfig::"..data.clsName .."> CsvConfigMgr::get" .. data.clsName .. "Map()\n")
        handler:write("{\n")
        handler:write("\tif(m_map"..data.clsName..".empty())\n")
        handler:write("\t{\n")
        handler:write("\t\tload" .. data.clsName .. "FromCsv();\n")
        handler:write("\t}\n")
        handler:write("\treturn m_map" .. data.clsName .. ";\n")
        handler:write("}\n\n")

        handler:write("void CsvConfigMgr::load"..data.clsName .. "FromCsv()\n")
        handler:write("{\n")
        handler:write("\tif(!m_map"..data.clsName..".empty())\n")
        handler:write("\t{\n")
        handler:write("\t\treturn;\n")
        handler:write("\t}\n")
        handler:write("\tstd::vector<std::map<std::string, std::string> > data;\n")
        handler:write("\tstd::string key;\n")
        handler:write("\tCsvTable2Vector(CsvConfig::"..data.clsName.."::m_fileName, key, data);\n")
        handler:write("\tfor(size_t i = 0; i < data.size(); ++i)\n")
        handler:write("\t{\n")
        handler:write("\t\tCsvConfig::" .. data.clsName .. " obj;\n")
        handler:write("\t\tobj.init(data[i]);\n")
        handler:write("\t\t" .. data.cols[1].varType .. " val;\n")

        strType = string.match(data.cols[1].varType, "(%w+%p-%w+)<*")
        if TypeList[strType] then
            handler:write("\t\t" .. TypeList[strType] .."(data[i][key], val);\n")
        else
            handler:write("\t\tval = data[i][key];\n")
        end
        handler:write("\t\tm_map" .. data.clsName .. ".insert(std::make_pair(val, obj));\n")
        handler:write("\t}\n")
        handler:write("}\n\n")
    end

    handler:close()
    return true
end

function ExportMgrFile(result)
   return ExportMgrHeaderFile(result) and ExportMgrSourceFile(result)
end

function main(files)
    local result = {}
	CSV_PATH = files[1]
    for i = 2, #files do
        local ret, data = ExportClassFile(files[i])
        if not ret then
            print(string.format("Export `%s` Fail", files[i]))
        else
            print(string.format("Export `%s` Done", files[i]))
            table.insert(result, data)
        end
    end
    if not ExportMgrFile(result) then
        print("Export config_mgr Fail")
    end
end

main(arg)
