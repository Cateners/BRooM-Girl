extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#计算该日期距离公元0年1月1日相差的天数(0年指公元1年的前1年)。
#目前不考虑1582年10月04日到10月15日这种特殊情况。
#目前闰年一律按4年一闰，100年不闰，400又闰处理(不考虑1582年以前是4年一闰)。
#date是Dictionary类型(参考Time.get_date_dict_from_system()返回的格式)
#如{ "year": 2022, "month": 11, "day": 2, "weekday": 3 } (只需要year, month, day)
#func total_days(date):
#	#days是用来存放计算结果的变量
#	var days = 0
#	#每月天数
#	var days_by_month = [0, 31, 29 if (date.year%4==0 and date.year%100!=0) or date.year%400==0 else 28, 31, 30, 31, 30, 31, 31, 30, 31, 30]
#	#经过的闰年数
#	var leap = floori((date.year+3)/4)-floori((date.year-1)/100)+floori((date.year-1)/400)
#	#加上由年产生的天数
#	days+=(date.year-leap)*365+leap*366
#	#加上由月产生的天数
#	days+=days_by_month.slice(0,date.month).reduce(func(a,b):return a+b,0)
#	#加上由日产生的天数
#	days+=date.day-1
#	#返回计算结果
#	return days
#简化代码版
#func total_days(date):
#	var leap = (date.year+3)/4-(date.year-1)/100+(date.year-1)/400
#	return date.day-1+[0,31,29 if (date.year%4==0 and date.year%100!=0) or date.year%400==0 else 28,31,30,31,30,31,31,30,31,30].slice(0,date.month).reduce(func(a,b):return a+b,0)+(date.year-leap)*365+leap*366
#另一个简化代码版
func total_days(date):
	#print(date)
	return date.day-1+[0,31,29 if (date.year%4==0 and date.year%100!=0) or date.year%400==0 else 28,31,30,31,30,31,31,30,31,30].slice(0,date.month).reduce(func(a,b):return a+b,0)+date.year*365+(date.year+3)/4-(date.year-1)/100+(date.year-1)/400

#计算两个日期相差的天数(date1比date2大)
#日期格式同上
func diff_days(date1,date2):
	return total_days(date1)-total_days(date2)

#根据与0年1月1日相差的天数反求年份
#如果所求年份大于2147483648会出错:P
#返回值是xx年1月1日的Dictionary!
#func get_year(days):
#	#先求一个大致的年份
#	var predict_date = {"year":(days/366+days*3/365)/4,"month":1,"day":1}
#	#相差的日子
#	var diff = days-total_days(predict_date)
#	#逐渐减小差距直到年份对上
#	#我期望猜测的年份小于等于真实年份，所以diff<0
#	#如果天数相差不到365天(平年)或366天(闰年)说明找对了，否则继续循环
#	while diff < 0 or (abs(diff) > 365 if ((predict_date.year%4 == 0 and predict_date.year%100 != 0) or (predict_date.year%400 == 0)) else abs(diff) > 364):
#		predict_date.year = diff/365 + predict_date.year
#		diff = days-total_days(predict_date)
#		#print("py:%s"%pretend_year)
#		#print("df:%s"%diff)
#	#print("py:%s"%pretend_year)
#	#print("df:%s"%diff)
#	return predict_date

#获取距离公元0年1月1日后days天的日期
#返回Dictionary类型，包含year,month,day,weekday
func get_date(days):
	#先求一个大致的年份
	var predict_date = {"year":floori((days/366+days*3/365)/4),"month":1,"day":1,"weekday":roundi(days-1)%7}
	#相差的日子
	var diff = days-total_days(predict_date)
	#逐渐减小差距直到年份对上
	#我期望猜测的年份小于等于真实年份，所以diff<0
	#如果天数相差不到365天(平年)或366天(闰年)说明找对了，否则继续循环
	while diff < 0 or (abs(diff) > 365 if ((predict_date.year%4 == 0 and predict_date.year%100 != 0) or (predict_date.year%400 == 0)) else abs(diff) > 364):
		predict_date.year = floori(diff/365.) + predict_date.year
		diff = days-total_days(predict_date)
	#此时年份已经确定，根据与1月1日相差的天数diff求解月份
	for i in [31,29 if (predict_date.year%4==0 and predict_date.year%100!=0) or predict_date.year%400==0 else 28,31,30,31,30,31,31,30,31,30,31]:
		#从1月开始减去每个月的天数，什么时候小于零说明就是那个月
		diff-=i
		#顺便让月份当计数器:P
		predict_date.month+=1
		if diff<0:
			predict_date.month-=1
			predict_date.day=diff+i+1
			break
	return predict_date

#某日期后days天的日期
func diff_date(date,days):
	return get_date(total_days(date)+days)
	
#下面是日期字典和日期字符串的转换函数TODO
#字典: {"year":1234, "month":1, "day":11}
#字符串:1234-01-11
func get_date_string_from_date_dict(dict):
	var s = Time.get_datetime_string_from_datetime_dict(dict,false)
	return s.substr(0,s.find("T"))


func get_date_dict_from_date_string(str):
	var r = Time.get_datetime_dict_from_datetime_string(str,false)
	return {"year":1970,"month":1,"day":1} if r.is_empty() else r
