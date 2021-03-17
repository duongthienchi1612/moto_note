import 'dart:io';

import 'package:uuid/uuid.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:moto_note/models/Accessory.dart';
import 'package:moto_note/widgets/new_accessory.dart';
import 'package:moto_note/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharePref().init();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ghi chú',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        accentColor: Colors.blue[200],
        textTheme: ThemeData.light().textTheme.copyWith(
              headline1: TextStyle(
                fontFamily: 'Saira',
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 16,
              ),
              subtitle1: TextStyle(
                fontFamily: 'Saira',
                fontWeight: FontWeight.normal,
                color: Colors.black,
                fontSize: 15,
              ),
              button: TextStyle(color: Colors.white),
            ),
        appBarTheme: AppBarTheme(
          textTheme: ThemeData.light().textTheme.copyWith(
                title: TextStyle(
                    fontFamily: 'Saira-Bold',
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
        ),
      ),
      home: MyHomePage(title: 'Ghi chú'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage({Key key, this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Accessory> _accessoriesLoad;
  bool _sortValue, _sortDestination, _sortAsc;
  int _sortColumnIndex, _addStatus = 1, _editStatus = 2;
  var uuid = Uuid();

  SharePref _sharePref = SharePref();
  Accessory accessoryLoad = Accessory();

  String encodeData;

  @override
  void initState() {
    _sortAsc = false;
    _sortValue = false;
    _sortDestination = false;
    _accessoriesLoad = [];
    _loadData();
    super.initState();
  }

  void _saveData(List<Accessory> data) {
    if (data != null) {
      setState(() {
        _accessoriesLoad = data;
      });
    }
    encodeData = Accessory.encode(_accessoriesLoad);
    _sharePref.save("accessories", encodeData);
  }

  void _loadData() async {
    var test = await _sharePref.read('accessories');
    setState(() {
      _accessoriesLoad = Accessory.decode(test);
    });
  }

  void _addNewAccessory(String id, String name, String note, int value,
      int destination, int status) {
    if (status == _editStatus) {
      return;
    }
    final accessory = Accessory(
        id: id, name: name, note: note, value: value, destination: destination);
    setState(() {
      _accessoriesLoad.add(accessory);
    });
    _saveData(_accessoriesLoad);
  }

  void _editAccesory(String id, String name, String note, int value,
      int destination, int status) {
    if (status == _addStatus) {
      return;
    }
    final item = _accessoriesLoad.firstWhere((element) => element.id == id,
        orElse: () => null);
    if (item != null) {
      setState(() {
        item.name = name;
        item.note = note;
        item.value = value;
        item.destination = destination;
      });
    }
    _saveData(_accessoriesLoad);
  }

  void _startAddNewAccessory(BuildContext ctx) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      backgroundColor: Colors.white,
      context: ctx,
      isScrollControlled: true,
      builder: (_) => NewAccessory(
        addAccessory: _addNewAccessory,
        editAccessory: _editAccesory,
        status: _addStatus,
        accessory: null,
      ),
    );
  }

  void _startEditAccessory(BuildContext ctx, Accessory accessory) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      builder: (_) => NewAccessory(
          addAccessory: _addNewAccessory,
          editAccessory: _editAccesory,
          status: _editStatus,
          accessory: accessory),
    );
  }

  void _onSortColumn(int columnIndex, ascending) {
    if (columnIndex == 2) {
      if (ascending) {
        _accessoriesLoad.sort((a, b) => a.value.compareTo(b.value));
      } else {
        _accessoriesLoad.sort((a, b) => b.value.compareTo(a.value));
      }
    }
    if (columnIndex == 3) {
      if (ascending) {
        _accessoriesLoad.sort((a, b) => a.destination.compareTo(b.destination));
      } else {
        _accessoriesLoad.sort((a, b) => b.destination.compareTo(a.destination));
      }
    }
  }

  void _deleteCell(Accessory accessory) {
    setState(() {
      _accessoriesLoad.remove(accessory);
    });
    _saveData(_accessoriesLoad);
  }

  Widget _buildAppbar() {
    return Platform.isIOS
        ? CupertinoNavigationBar(
            middle: Text(widget.title),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  child: Icon(CupertinoIcons.add),
                  onTap: () => _startAddNewAccessory(context),
                )
              ],
            ),
          )
        : AppBar(
            title: Text(widget.title),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(Icons.add),
                tooltip: 'Thêm',
                onPressed: () => _startAddNewAccessory(context),
              ),
            ],
          );
  }

  @override
  Widget build(BuildContext context) {
    final PreferredSizeWidget appBar = _buildAppbar();
    final pageBody = SafeArea(
      child: _accessoriesLoad.length == 0
          ? Center(
              child: Text('Thêm mới nội dung'),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                    columnSpacing: 18,
                    sortAscending: _sortAsc,
                    sortColumnIndex: _sortColumnIndex,
                    showBottomBorder: true,
                    columns: [
                      DataColumn(
                        label: Expanded(
                          child: Text(
                            'Thiết bị',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headline1,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Expanded(
                          child: Text(
                            'Tình trạng',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headline1,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Container(
                          width: 60,
                          child: Text(
                            'Tại Km',
                            textAlign: TextAlign.left,
                            style: Theme.of(context).textTheme.headline1,
                          ),
                        ),
                        numeric: true,
                        onSort: (columnIndex, ascending) {
                          setState(() {
                            _sortColumnIndex = columnIndex;
                            _sortValue = !_sortValue;
                            _sortAsc = _sortValue;
                          });
                          _onSortColumn(columnIndex, ascending);
                        },
                      ),
                      DataColumn(
                          label: Container(
                            width: 90,
                            child: Text(
                              'Km tiếp theo',
                              textAlign: TextAlign.left,
                              style: Theme.of(context).textTheme.headline1,
                            ),
                          ),
                          numeric: true,
                          onSort: (columnIndex, ascending) {
                            setState(() {
                              _sortColumnIndex = columnIndex;
                              _sortDestination = !_sortDestination;
                              _sortAsc = _sortDestination;
                            });
                            _onSortColumn(columnIndex, ascending);
                          }),
                      DataColumn(
                        label: Expanded(
                          child: Text(
                            'Xóa',
                            style: Theme.of(context).textTheme.headline1,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                    rows: _accessoriesLoad
                        .map(
                          (accessory) => DataRow(
                            cells: [
                              DataCell(
                                Center(
                                  child: Text(
                                    accessory.name,
                                    style:
                                        Theme.of(context).textTheme.subtitle1,
                                  ),
                                ),
                                onTap: () =>
                                    _startEditAccessory(context, accessory),
                              ),
                              DataCell(
                                Center(
                                  child: Text(
                                    accessory.note,
                                    style:
                                        Theme.of(context).textTheme.subtitle1,
                                  ),
                                ),
                                onTap: () =>
                                    _startEditAccessory(context, accessory),
                              ),
                              DataCell(
                                Center(
                                  child: Text(
                                    accessory.value.toString(),
                                    style:
                                        Theme.of(context).textTheme.subtitle1,
                                  ),
                                ),
                                onTap: () =>
                                    _startEditAccessory(context, accessory),
                              ),
                              DataCell(
                                Center(
                                  child: Text(
                                    accessory.destination.toString(),
                                    style:
                                        Theme.of(context).textTheme.subtitle1,
                                  ),
                                ),
                                onTap: () =>
                                    _startEditAccessory(context, accessory),
                              ),
                              DataCell(
                                Center(
                                  child: IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () => _deleteCell(accessory),
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                        .toList()),
              ),
            ),
    );
    return Scaffold(
      appBar: appBar,
      body: pageBody,
      floatingActionButton: FloatingActionButton(
        tooltip: 'Thêm',
        backgroundColor: Theme.of(context).accentColor,
        child: Icon(
          Icons.add,
        ),
        onPressed: () => _startAddNewAccessory(context),
      ),
      bottomNavigationBar: new BottomAppBar(
          notchMargin: 4,
          shape: CircularNotchedRectangle(),
          color: Colors.white,
          child: Container(height: 40)),
      // This trailing comma makes auto-fo
      floatingActionButtonLocation: FloatingActionButtonLocation
          .centerDocked, // rmatting nicer for build methods.
    );
  }
}
