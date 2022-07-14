import 'package:flutter_html_demo/bean/table_bean.dart';
import 'package:flutter_html_demo/utils/html_parse_util.dart';
import 'package:html/dom.dart' as dom;

class TableUtil {
  ///html中是否有table模版
  var hasTableModelInHtml = false;

  ///表格模版
  List<dom.Element> tableList = [];

  List<TableBean> tableBeanList = [];

  TableUtil(dom.Document document, Map<String, dynamic> map) {
    tableList = document.getElementsByTagName("table");
    //初始化是否有表格模版
    hasTableModelInHtml = tableList.isNotEmpty;
    for (var element in tableList) {
      TableBean bean = TableBean();
      bean.element = element;
      //element代表table，获取每一行
      List<dom.Element> tr = element.getElementsByTagName("tr");
      if (tr.isNotEmpty) {
        List<dom.Element> th = tr[0].getElementsByTagName("th");
        bean.hasTitleRow = th.isNotEmpty;
        dom.Element e = tr[0].children[0];
        if (e.text.length >= 2) {
          bean.placeHolder = e.text.substring(1, e.text.length - 1);
          if (bean.placeHolder.isNotEmpty) {
            bean.size = getListDataSize(bean.placeHolder, map);
          }
        }
      }
      tableBeanList.add(bean);
    }
  }

  ///往table的模版行添加剩余的行
  void buildTableStyleDocument(dom.Document document) {
    for (var bean in tableBeanList) {
      dom.Element? element = bean.element;
      List<dom.Element>? tr = element?.getElementsByTagName("tr");
      if (tr != null && tr.isNotEmpty) {
        //当前行第父结点
        var parent = tr[0].parent;
        //父节点的孩子结点列表
        var childs = parent?.children;
        var index = 0;
        if (bean.hasTitleRow == true) {
          index = 1;
        }
        var model = tr[index].outerHtml;
        //获取每一单元格,bean.size包含了标题和模版行，所以要减去index-1
        for (var i = 0; i < bean.size - index - 1; i++) {
          dom.Element childElement = dom.Element.html(model);
          List<dom.Element> tdList = childElement.getElementsByTagName("td");
          List<dom.Element> reBuildTd = [];
          for (var j = 0; j < tdList.length; j++) {
            var text = tdList[j].outerHtml.replaceFirstMapped(
                "-$index-", (match) => "-${index + i + 1}-");
            reBuildTd.add(dom.Element.html(text));
          }
          childElement.children.clear();
          childElement.children.addAll(reBuildTd);
          childs?.insert(index + i + 2, childElement);
        }
      }
    }
  }

  //判定是否为数字
  bool isNumeric(String? s) {
    if (s == null) {
      return false;
    }
    return int.tryParse(s) != null;
  }
}
