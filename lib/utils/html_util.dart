import 'package:flutter/material.dart';
import 'package:flutter_html_demo/utils/table_util.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as htmlparser;
import 'package:flutter_html/flutter_html.dart';

import 'html_parse_util.dart';

class HtmlUtil {
  TableUtil tableUtil;

  HtmlUtil(this.tableUtil);

  ///通过html模版和Json数据重建Html
  Widget buildHtmlByHtmlModelAndJson(
      dom.Document document, Map<String, dynamic> map) {
    //重新构建table模版
    _buildTableModel(document, map);
    String html = parseHtml(document.outerHtml, map);
    print('html:$html');

    return Html(data: html, style: {
      "th": Style(border: Border.all(color: Colors.red)),
      "td": Style(border: Border.all(color: Colors.red)),
      "font": Style(fontSize: FontSize.xxLarge)
    });
  }

  ///构建table模版
  ///html模版中如果有table，则只会给出table的标题行和模版行，其它行需要根据模版行和Json中对应的数据
  ///列表长度自动生成
  void _buildTableModel(dom.Document document, Map<String, dynamic> map) {
    //判断是否有table模版
    var hasTableModels = tableUtil.hasTableModelInHtml;
    if (!hasTableModels) {
      //如果没有table模版，直接返回
      return;
    }

    tableUtil.buildTableStyleDocument(document);
  }
}
