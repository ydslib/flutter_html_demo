import 'package:html/dom.dart' as dom;

class TableBean {

  dom.Element? element;

  ///是否有标题行
  bool? hasTitleRow = false;

  ///表格对应的列表占位符
  String placeHolder = "";

  ///表格除标题行外还有多少行
  int size = 0;

  TableBean({this.hasTitleRow});
}
