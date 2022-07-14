import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_demo/utils/html_parse_util.dart';
import 'package:flutter_html_demo/utils/html_util.dart';
import 'package:flutter_html_demo/utils/table_util.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as htmlparser;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  List<String> _parseHtml(String htmlStr) {
    List<String> res = [];
    try {
      var htmlParseList = RegExp(r'\[.*?\]').allMatches(htmlStr);
      htmlParseList.forEach((element) {
        String? ele = element.group(0);
        if (ele != null && ele.isNotEmpty == true) {
          res.add(ele);
        }
      });
    } catch (e) {}
    return res;
  }

  /// 解析html标签获取占位字符串
  /// <div>{test-0-test}</div><p>test</p>
  /// [test-0-test,test]
  ///
  List<String> _parseHtmlToPlaceHolderData(String htmlStr) {
    List<String> res = [];
    try {
      var htmlParseList = RegExp(r'\[.*?\]').allMatches(htmlStr);
      htmlParseList.forEach((element) {
        String? ele = element.group(0);
        if (ele != null && ele.isNotEmpty == true) {
          res.add(ele);
        }
      });
    } catch (e) {}
    return res;
  }

  /// 解析html标签获取除占位字符串以外的字符串列表，如：
  /// <div>[test-0-test]</div>
  /// 调用方法后：
  /// [<div>,</div>]
  List<String> _splitHtml(String html) {
    return html.split(RegExp(r'\[.*?\]'));
  }

  /**
   * 根据html标签中的占位符获取Json中的真实数据。
   */
  List<String> _getHtmlPlaceHolderRealData(
      List<String> placeHolderStr, Map<String, dynamic> map) {
    List<String> result = [];
    placeHolderStr.forEach((holder) {
      List<dynamic> holderValue = jsonDecode(holder);
      if (holderValue.length == 1) {
        result.add(map[holderValue[0]]);
      } else if (holderValue.length == 2) {
        result.add(map[holderValue[0]][holderValue[1]]);
      } else if (holderValue.length == 3) {
        result.add(map[holderValue[0]][holderValue[1]][holderValue[2]]);
      } else if (holderValue.length == 4) {
        result.add(map[holderValue[0]][holderValue[1]][holderValue[2]]
            [holderValue[3]]);
      } else if (holderValue.length == 5) {
        result.add(map[holderValue[0]][holderValue[1]][holderValue[2]]
            [holderValue[3]][holderValue[4]]);
      }
    });
    return result;
  }

  String _buildHtmlStr(List<String> data, List<String> lable) {
    String res = lable[0];
    for (var i = 0; i < data.length; i++) {
      res = res + data[i] + lable[i + 1];
    }
    return res;
  }

  String _buildHtmlByJson(Map<String, dynamic> map, String html) {
    //获取html标签中的占位字符串
    List<String> placeHolder = _parseHtmlToPlaceHolderData(html);
    //获取以 html标签中的占位字符串 分割后的字符串
    List<String> lable = _splitHtml(html);

    //获取真实数据
    List<String> realData = _getHtmlPlaceHolderRealData(placeHolder, map);

    return _buildHtmlStr(realData, lable);
  }

  /**
   * 列表类型
   */
  dom.Document buildListStyleDocument(dom.Document document, String className) {
    List<dom.Element> list = document.getElementsByClassName(className);
    list.forEach((element) {
      String res = element.outerHtml;
      dom.Element? e = element.parent;
      print('${e?.outerHtml}');
      var index = e?.children.indexOf(element);
      if (index != null && index >= 0) {
        for (int i = 0; i < 3; i++) {
          e?.children?.insert(index + 1 + i, dom.Element.html(res));
        }
        e?.children?.removeAt(index);
      }
      // e?.children.removeAt(index!);
    });

    return document;
  }

  /**
   * 判断是否有table类型的模版
   */
  bool hasTableModel(dom.Document document) {
    List<dom.Element> tableList = document.getElementsByTagName("table");
    return tableList.isNotEmpty;
  }

  /**
   * 表格类型
   *
   * @params size 要生成几行
   *
   */
  void buildTableStyleDocument(dom.Document document, int size) {
    print('localName:${document.children[0].localName}');
    List<dom.Element> tableList = document.getElementsByTagName("table");
    tableList.forEach((element) {
      //element代表table，获取每一行
      List<dom.Element> tr = element.getElementsByTagName("tr");
      //判断是不是有标题行
      if (tr != null && tr.isNotEmpty) {
        //获取标题单元格
        List<dom.Element> th = tr[0].getElementsByTagName("th");
        var hasTitle = th.isNotEmpty; //判断有没有标题，true为有标题
        //当前行第父结点
        var parent = tr[0].parent;
        //父节点的孩子结点列表
        var childs = parent?.children;
        var index = 0;
        //如果有标题单元格，则数据模版是第二行
        if (hasTitle) {
          //模版行所在列表中的索引
          index = 1;
        }
        var model = tr[index].outerHtml;
        for (var i = 0; i < size; i++) {
          childs?.insert(index + 1 + i, dom.Element.html(model));
        }
        //移除掉模版结点
        childs?.removeAt(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    var result = {
      "businessType": "",
      "destinationWhName": "USWC Warehouse",
      "isMasterPackage": "N",
      "leave": "A",
      "mStatus": "PRESORTING_COMPLETED",
      "orderNo": "WI991128340300",
      "packageSerno": "B0400000001069804405",
      "putAwaysArea": -1,
      "result": [
        {
          "abcAttribute": "B",
          "isWorking": -1,
          "itemQty": 0,
          "itemTotalQty": 4,
          "palletStatus": -1,
          "pickingType": -1,
          "size": "0 * 0 * 0 (CM)",
          "sku": "M010000000004016060",
          "skuQty": 1,
          "skuSpec": "T50-",
          "status": -1,
          "width": 0,
          "winitOrderNo": "WI991128340300"
        }
      ],
      "typeThree": [
        {
          "index": "序号",
          "barcode": "条码",
          "goods": "商品",
          "numbers": "数量",
          "isOnShelf": "是否上架"
        },
        {
          "index": "1",
          "barcode": "B04000000000000750",
          "goods": "M*23398",
          "numbers": "5",
          "isOnShelf": "N"
        },
        {
          "index": "2",
          "barcode": "B04000000000000751",
          "goods": "M*23399",
          "numbers": "4",
          "isOnShelf": "N"
        },
        {
          "index": "3",
          "barcode": "B04000000000000752",
          "goods": "M*23349",
          "numbers": "10",
          "isOnShelf": "N"
        }
      ],
      "scanKeword": "B0400000001069804405",
      "scanType": "B",
      "status": 2131691974,
      "taskType": -1,
      "unloadTime": "2022-06-13 19:47"
    };

    var htmlData1 = """
    <div>
        <div>[scanKeword] [scanType]</div>
    </div>
    <div><font color = \"#FF0033\" size='5'>[scanKeword] [scanType]</font></div>
    <table style="width:100%">
      <tr>
		    <th>[typeThree-0-index]</th> 
		    <th>[typeThree-0-barcode]</th> 
		    <th>[typeThree-0-goods]</th> 
		    <th>[typeThree-0-numbers]</th> 
		    <th>[typeThree-0-isOnShelf]</th> 
	    </tr>
      <tr> 
		    <td>[typeThree-1-index]</td> 
		    <td>[typeThree-1-barcode]</td> 
		    <td><font color="#FF0033">[typeThree-1-goods]</font></td> 
		    <td>[typeThree-1-numbers]</td> 
		    <td>[typeThree-1-isOnShelf]</td> 
	    </tr>
  </table>
  </br>
    """;

    // var resource = _buildHtmlByJson(result, htmlData);
    // print('resource:$resource');
    //
    // dom.Document document = htmlparser.parse(htmlData1);
    // var hasTableModels = hasTableModel(document);
    // if (hasTableModels) {
    //   //获取table的列表数据在json中的key值
    //   List<String> tablePlaceHolder = getTableListPlaceHolder(document);
    //   print('tablePlaceHolder:$tablePlaceHolder');
    //   //计算每个table的item条数
    //   for (var holder in tablePlaceHolder) {
    //     var size = getListDataSize(holder, result);
    //     buildTableStyleDocument(document,size);
    //     print('size:$size');
    //   }
    // }

    // var list = parseHtmlToPlaceHolderData("<div>[scanKeword] [scanType]</div>");
    // print('list:${list}');
    // var realData = getHtmlPlaceHolderRealData(list[0], result);
    // print('realData:$realData');

    //   List<dom.Element> th = element.getElementsByTagName("th");
    //
    //   List<dom.Element> td = element.getElementsByTagName("td");
    //   var parent = element.parent;
    //   var index = parent?.children.indexOf(element);
    //   if (index != null && index >= 0) {}
    //   td.forEach((tdele) {
    //     print('${tdele.outerHtml}');
    //   });
    // });
    //将html模版解析成document
    dom.Document document = htmlparser.parse(htmlData1);
    TableUtil tableUtil = TableUtil(document, result);
    HtmlUtil htmlUtil = HtmlUtil(tableUtil);
    Widget html = htmlUtil.buildHtmlByHtmlModelAndJson(document,result);

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Column(
            // Column is also a layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Invoke "debug painting" (press "p" in the console, choose the
            // "Toggle Debug Paint" action from the Flutter Inspector in Android
            // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
            // to see the wireframe for each widget.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'You have pushed the button this many times:',
              ),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.headline4,
              ),
              html,
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  String moduleOne(Map<String, dynamic> json) {
    String str = "";
    json.forEach((key, value) {
      if (key == "typeOne") {
        str = typeOne(value, str);
      } else if (key == "typeTwo") {
        str = typeTwo(value, str);
      } else if (key == "typeThree") {
        str = typeThree(value, str);
      }
    });
    return str;
  }

  /**
   * 名称：类型模版
   * 如：  单品条码:B04000000000000750
   */
  String typeOne(List<dynamic> list, String str) {
    list.forEach((element) {
      Map<String, dynamic> content = element;
      str = str + "<p>";
      content.forEach((k, v) {
        str = str + "$v：";
      });
      str = str.substring(0, str.length - 1);
      str = str + "</p></br>";
    });
    return str;
  }

  /**
   * 一行多个类容
   * 如：003274   10   2B  ...
   */
  String typeTwo(List<dynamic> list, String str) {
    list.forEach((element) {
      Map<String, dynamic> content = element;
      str = str + "<p>";
      content.forEach((k, v) {
        str = str + "$v${space(2)}";
      });
      str = str.substring(0, str.length - 1);
      str = str + "</p></br>";
    });
    return str;
  }

  /**
   * 表格模版
   */
  String typeThree(List<dynamic> list, String str) {
    str = str + "<table>";
    list.forEach((element) {
      Map<String, dynamic> content = element;
      str = str + "<tr>";
      content.forEach((key, value) {
        str = str + "<td>$value</td>";
      });
      str = str + "</tr>";
    });
    str = str + "</table>";
    return str;
  }

  /**
   * 非严格
   */
  String space(int nums) {
    String sp = " ";
    for (int i = 0; i < nums; i++) {
      sp = sp + "&nbsp";
    }
    return sp + " ";
  }
}
