#ifndef __CSV_TOOL_H__
#define __CSV_TOOL_H__

#include <sstream>
#include <map>
#include <vector>
#include <string>
#include <json/json.h>
#include <iostream>

void String2Json(const std::string &data, Json::Value &out);

void String2Int(const std::string &data, int &out);

std::vector<std::string> SplitString(const std::string &data, const char sep);

template<typename T1, typename T2>
T2 Convert(const T1 &data)
{
    std::stringstream ss;
    ss<<data;
    T2 out;
    ss>>out;
    return out;
}

//1,2,3,4,5,6,7
template<class T>
void String2Vector(const std::string &data, T &out)
{
    std::vector<std::string> v = SplitString(data, ',');
    for(std::vector<std::string>::iterator i = v.begin(); i != v.end(); ++i)
    {
        typename T::value_type val = Convert<std::string, typename T::value_type>(*i);
        out.push_back(val);
    }
}

//1|1,2|2
template<typename T>
void String2Map(const std::string &data, T &out)
{
    std::vector<std::string> v = SplitString(data, ',');
    for(std::vector<std::string>::iterator i = v.begin(); i != v.end(); ++i)
    {
        std::vector<std::string> pair = SplitString(*i, '|');
        if(pair.size() != 2)
        {
            continue;
        }
        typename T::key_type key = Convert<std::string, typename T::key_type>(pair[0]);
        typename T::mapped_type data = Convert<std::string, typename T::mapped_type>(pair[1]);
        out.insert(std::make_pair(key, data));
    }
}

void CsvTable2Vector(const std::string &filename, std::string &key, std::vector<std::map<std::string, std::string> > &data);

#endif
