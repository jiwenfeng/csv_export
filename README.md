## csv_export
#csv文件说明
第9行为该列的数据类型 支持string,map,array,int,json
第11行为注释行
第12行为该列的字段名,不能有空格
数据内容从第13行开始
#类型定义
map的定义要符合c++ std::map的定义格式 key和value类型只能是string,int
array需要符合c++ std::vector的格式定义 类型只能是int,string
#数据格式定义
array 数据格式为 1,2,3,4 
map 数据格式为 1:1,2:2 

#生成
lua gen.lua file1.csv file2.csv 
