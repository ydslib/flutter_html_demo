/// 解析html标签获取占位字符串
/// htmlStr :<div>[test-0-test]</div><p>[test]</p>
///
/// return:[test-0-test,test]
///
List<String> parseHtmlToPlaceHolderData(String htmlStr) {
  List<String> res = [];
  try {
    var htmlParseList = RegExp(r'\[.*?\]').allMatches(htmlStr);
    for (var element in htmlParseList) {
      String? ele = element.group(0);
      if (ele != null && ele.isNotEmpty == true) {
        if (ele.length >= 2) {
          res.add(ele.substring(1, ele.length - 1));
        }
      }
    }
  } catch (e) {}
  return res;
}

/// 解析html标签获取除占位字符串以外的字符串列表，如：
/// <div>[test-0-test]</div>
/// 调用方法后：
/// [<div>,</div>]
List<String> splitHtml(String html) {
  return html.split(RegExp(r'\[.*?\]'));
}

///根据占位字符去查找Json中真实数据
dynamic getHtmlPlaceHolderRealData(
    String placeHolderStr, Map<String, dynamic> map) {
  List<String> holder = placeHolderStr.split(RegExp(r'-'));
  dynamic res = map[holder[0]];
  for(int i=1;i<holder.length;i++){
    if(isNumeric(holder[i])){
      res = res[int.parse(holder[i])];
    }else{
      res = res[holder[i]];
    }
  }
  return res;
}

/**
 * 获取列表长度
 */
int getListDataSize(String placeHolderStr, Map<String, dynamic> map){
  List<String> holder = placeHolderStr.split(RegExp(r'-'));
  dynamic res = map[holder[0]];
  bool hasNumber = false;
  for(int i=1;i<holder.length;i++){
    if(isNumeric(holder[i])){
      hasNumber = true;
      break;
    }
  }

  if(hasNumber){
    return (res as List<dynamic>).length;
  }
  return 0;
}

//判定是否为数字
bool isNumeric(String s) {
  if (s == null) {
    return false;
  }
  return int.tryParse(s) != null;
}

String parseHtml(String htmlStr,Map<String, dynamic> map){
  //占位字符列表
  List<String> placeHolderList = parseHtmlToPlaceHolderData(htmlStr);
  //标签字符列表
  List<String> tagList = splitHtml(htmlStr);

  String result = tagList[0];
  for(var i=0;i<placeHolderList.length;i++){
    String text = getHtmlPlaceHolderRealData(placeHolderList[i],map);
    result = result + text + tagList[i+1];
  }

  return result;
}
