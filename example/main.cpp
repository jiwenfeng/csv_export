#include "config_mgr.h"
#include <iostream>

using namespace std;

int main()
{
	CsvConfig::Test *ptr = CsvConfigMgr::getInstance().findTestByKey(1);
	if(ptr == NULL)
	{
		std::cout<<"Nothing found"<<std::endl;
		return 0;
	}

	std::cout<<"one:"<<ptr->get_one()<<std::endl;
	std::cout<<"two:";
	for(std::map<int, int>::const_iterator i = ptr->get_two().begin(); i != ptr->get_two().end(); ++i)
	{
		std::cout<<"{"<<i->first<<","<<i->second<<"}"<<std::endl;
	}
	std::cout<<"three:[";
	for(std::vector<int>::const_iterator i = ptr->get_three().begin(); i != ptr->get_three().end(); ++i)
	{
		std::cout<<*i<<",";
	}
	std::cout<<"]"<<std::endl;

	Json::Value root = ptr->get_four();
	Json::StreamWriterBuilder stream;
	std::cout<<Json::writeString(stream, root)<<std::endl;

	const std::map<int, Json::Value> &v = ptr->get_five();
	std::cout<<"Five:"<<v.size()<<endl;
	for(auto &i : v)
	{
		std::cout<<"key:"<<i.first<<"value:"<<Json::writeString(stream, i.second)<<std::endl;
	}

	return 0;
}
