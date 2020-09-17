import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'dart:convert' as convert;

Dio dio = Dio();

class SkillEdit extends StatefulWidget {
  SkillEdit({Key key, this.skillList, this.arguments}) : super(key: key);
  final dynamic skillList;
  final Map arguments;

  @override
  _SkillEditState createState() => _SkillEditState();
}

class Skill {
  final int id;
  final String type;

  const Skill({
    this.id,
    this.type,
  });

  factory Skill.fromMap(Map<String, dynamic> json) {
    var _skillResult = '[]';
    if (json == null) return null;
    return Skill(
      id: json["id"] as int,
      type: json["type"] as String,
    );
  }
}

class _SkillEditState extends State<SkillEdit> {
  List<int> _selectedIds = [];
   void _updateSkill() async {
    Response response;
    response = await dio.post(
        "http://dftask-x5frwn.ndev.imdada.cn/hack/updateTransporterSkill",
        data:{'id': widget.arguments != null ? widget.arguments['id'] : 1, 'skill': _selectedIds.join(',')});
    print(response.data['content']);
  }

  Future<String> _getSkillList() async {
    var url =
        'http://dftask-x5frwn.ndev.imdada.cn/hack/transporterSkillTyeDict';
    var httpClient = new HttpClient();
    print(url);

    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      if (response.statusCode == HttpStatus.ok) {
        var json = await response.transform(utf8.decoder).join();
        var data = jsonDecode(json);
        return '${convert.jsonEncode(data['content'])}';
      } else {
        return "";
      }
    } catch (exception) {
      return "";
    }
  }

  _toggleSelectedItem(value) {
    print(widget.arguments['id']);
    if(_selectedIds.indexOf(value) > -1) {
      _selectedIds.remove(value);
    } else {
      _selectedIds.add(value);
    }
setState(() {
  _selectedIds = _selectedIds;
});
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('_selectedIds => $_selectedIds');
    return Scaffold(
      appBar: AppBar(
        title: Text('职业技能标签'),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.only(
                    bottom: 10.0, top: 20.0, left: 20.0, right: 20),
                child: Text('请选择您的技能标签，做多选择两个',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16.0))),
            Padding(
                padding: EdgeInsets.only(
                    bottom: 20.0, left: 20.0, right: 20, top: 20),
                child: FutureBuilder(
                  future: _getSkillList(),
                  initialData: '',
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData && snapshot.data != '') {
                      List<Skill> skills = ((json.decode(snapshot.data) ?? []) as List)
                          .map<Skill>(
                            (dayMap) => Skill.fromMap(dayMap),
                      )
                          .toList();
                      return GridView(
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3, //横轴三个子widget
                                  childAspectRatio: 2,
                                  crossAxisSpacing: 10.0,
                                  mainAxisSpacing: 20.0 //宽高比为1时，子widget
                                  ),
                          children: skills
                              .map<Widget>((item) => Container(
                                    child: FlatButton(
                                      // color: Colors.blue,
                                      highlightColor: Colors.blue[700],
                                      color: _selectedIds.indexOf(item.id) > -1 ? Colors.green : Colors.white,
                                      child: Text(item?.type, style: TextStyle(color: _selectedIds.indexOf(item.id) > -1 ? Colors.white : Colors.black),),
                                      onPressed: () {
                                        _toggleSelectedItem(item.id);
                                      },
                                    ),
                                  ))
                              .toList());
                    }
                    return Text('12');
                  },
                )),
            Padding(
              padding: EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20),
              child: Text('请上传职业技能证书',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20),
              child: SizedBox(
                width: 150,
                height: 100,
                child: RaisedButton(
                    elevation: 7.0,
                    child: Icon(
                      Icons.publish,
                      size: 40,
                      color: Colors.grey,
                    ),
                    textColor: Colors.white,
                    color: Colors.white,
                    onPressed: () {}),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20),
              child: Text('请上传工作证明&离职证明',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20),
              child: SizedBox(
                width: 150,
                height: 100,
                child: RaisedButton(
                    elevation: 7.0,
                    child: Icon(
                      Icons.publish,
                      size: 40,
                      color: Colors.grey,
                    ),
                    textColor: Colors.white,
                    color: Colors.white,
                    onPressed: () {}),
              ),
            ),
            Padding(
              padding:
                  EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20, top: 20),
              child: RaisedButton(
                padding: EdgeInsets.only(left: 50, right: 50),
                child: Text("提交"),
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
                onPressed: _updateSkill,
              ),
            )
          ],
        ),
      ),
    );
  }
}
