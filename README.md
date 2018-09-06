# csv_export
### csv文件说明</br>
第9行为该列的数据类型 支持string,map,array,int,json</br>
第11行为注释行</br>
第12行为该列的字段名,不能有空格</br>
## 以上行不能为空
**数据内容从第13行开始</br>
**第一列为索引,只能为int或stirng类型

### 类型定义</br>
map的定义要符合c++ std::map的定义格式 key和value类型只能是string,int</br>
array需要符合c++ std::vector的格式定义 类型只能是int,string</br>
#数据格式定义</br>
array 数据格式为 1,2,3,4 </br>
map 数据格式为 1:1,2:2 </br>

### 生成</br>
lua gen.lua [csv_path] [file1.csv] [file2.csv] ... </br>
## csv_path是执行程序读取csv文件的路径</br>
对于每一个csv文件都生成一个文件同名的类放在CsvConfig的名字空间下面.csv中的每一列都会在该类中生成一个get_xx()方法</br>
程序会生成一个ConfigMgr类,每一个csv文件都会在该类里面生成一个findxxByKey()方法和一个getxxMap()方法.find方法使用
csv的索引列作为key来查找,get方法返回对应csv的全部记录.</br>
CsvConfigMgr使用单例模式访问,只需要包含config_mgr.h头文件即可.


# 注意</br>
需要将csv_tool.h和csv_tool.cpp和最终生成的文件放在同一目录下</br>

