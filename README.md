## csv_export
#csv文件说明</br>
第9行为该列的数据类型 支持string,map,array,int,json</br>
第11行为注释行</br>
第12行为该列的字段名,不能有空格</br>
数据内容从第13行开始</br>
#类型定义</br>
map的定义要符合c++ std::map的定义格式 key和value类型只能是string,int</br>
array需要符合c++ std::vector的格式定义 类型只能是int,string</br>
#数据格式定义</br>
array 数据格式为 1,2,3,4 </br>
map 数据格式为 1:1,2:2 </br>

#生成</br>
lua gen.lua file1.csv file2.csv </br>
