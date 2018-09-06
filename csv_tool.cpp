#include "csv_tool.h"
#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <map>

typedef std::map<std::string, std::string> FieldType;

static std::vector<std::string> ParseCsvRecord(const std::string &data);

std::vector<std::string> SplitString(const std::string &data, const std::string &sep)
{
    std::vector<std::string> v;
    std::string::size_type pos = 0, start = 0;
    while(true)
    {
        pos = data.find(sep, pos);
        if(pos == std::string::npos)
        {
            break;
        }
        std::string str(data, start, pos - start);
        v.push_back(str);
        start = pos + 1;
        pos = pos + sep.length();
    }
    std::string str(data, start, pos - start);
    v.push_back(str);
    return v;
}

void String2Json(const std::string &data, Json::Value &out)
{
    try
    {
		Json::Reader reader;
        if(!reader.parse(data, out))
        {
            (void)0;
        }
    }
    catch(...)
    {}
}

void String2Int(const std::string &data, int &out)
{
    std::stringstream ss;
    ss<<data;
    ss>>out;
}

void CsvTable2Vector(const std::string &file, std::string &key, std::vector<FieldType> &data)
{
	std::ifstream in(file.c_str(), std::ios_base::in);
	std::string line;
	int i = 0;
	std::vector<std::string> vFields;
	while(++i, getline(in, line))
	{
        if(i < 12)
        {
            continue;
        }
        if(i == 12)
        {
            vFields = ParseCsvRecord(line);
            key = vFields[0];
        }
        else
        {
            std::vector<std::string> vValues = ParseCsvRecord(line);
            if(vValues.empty())
            {
                continue;
            }
            if(vValues.size() != vFields.size())
            {
                continue;
            }
            std::map<std::string, std::string> record;
            for(size_t j = 0; j < vFields.size(); ++j)
            {
                record.insert(std::make_pair(vFields[j], vValues[j]));
            }
            data.push_back(record);
        }
	}
}



std::vector<std::string> ParseCsvRecord(const std::string &data)
{
    std::vector<std::string> v;
    std::string str = data;
    std::string::size_type pos = 0;
    while(true)
    {
        pos = str.find("\"\"", pos);
        if(pos == std::string::npos)
        {
            break;
        }
        str.replace(pos, 2, "\"");
        pos += 1;
    }
    size_t start = 0;
    for(size_t i = 0; i < str.length(); ++i)
    {
        if(str[i] == ',')
        {
            if(str[start] == '"' && str[i - 1] != '"')
            {
                continue;
            }
            int len = i - start;
            if(str[start] == '"')
            {
                start = start + 1;
                len -= 2;
            }
            std::string field(str, start, len);
            v.push_back(field);
            start = i + 1;
        }
    }
    int len = str.length() - start;
    if(str[start] == '"')
    {
        start = start + 1;
        len -= 2;
    }
    std::string field(str, start, len);
    v.push_back(field);
    return v;
}
