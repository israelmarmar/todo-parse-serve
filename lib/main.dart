import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/item.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  var items = new List<Item>();

  HomePage() {
    items = [];
    //items.add(Item(title: "Item 1", done: false));
    //items.add(Item(title: "Item 2", done: true));
    //items.add(Item(title: "Item 3", done: false));

  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
 var newTaskCtrl = TextEditingController();
 
  void add(){
    if (newTaskCtrl.text.isEmpty) return;

    setState(() {
      widget.items.add(
        Item(
          title: newTaskCtrl.text, 
          done: false,
          objectId: null
          ),
        );
      
      var itens = ParseObject('Itens');
      itens.set('title', newTaskCtrl.text);
	    itens.set('done', false);
      itens.save();
      newTaskCtrl.clear();
    });
  }

  void remove(int index){
    var objectId = widget.items[index].objectId;
    setState((){
      widget.items.removeAt(index);  
    });

    var itens = ParseObject('Itens');
    itens.set('objectId', objectId);
    itens.delete();
  }

  Future load() async {
    var prefs = await SharedPreferences.getInstance();

    await Parse().initialize(
        "parse-server-test",
        "https://parser-server-imm.herokuapp.com/parse",
        masterKey: "gf7d89sga78fa86df9ads5695et", // Required for Back4App and others
        debug: true, // When enabled, prints logs to console
        autoSendSessionId: true, // Required for authentication and ACL
	coreStore: await CoreStoreSharedPrefsImp.getInstance());

  var apiResponse = await ParseObject('Itens').getAll();

  if (apiResponse.success){
    List<Item> result=[];
    var oneitem;
    for (var item in apiResponse.result) {
      oneitem = new Item(title: item["title"], done: item["done"], objectId: item["objectId"]);
      print(oneitem.objectId);
      result.add(oneitem);
    }
   
  setState((){
        widget.items = result;
  });
  }

  
   
  }

  _HomePageState() {
    
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: TextFormField(
            controller:newTaskCtrl,
            keyboardType: TextInputType.text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              ),
          decoration: InputDecoration(
            labelText: "Nova Tarefa",
            labelStyle: TextStyle(color: Colors.white),
          ),
          ),
        ),
        body: ListView.builder(
          itemCount: widget.items.length,
          itemBuilder:(BuildContext ctxt, int index){
            final item = widget.items[index];
            return Dismissible(
              child: CheckboxListTile(
              title: Text(item.title),
              value: item.done,
              onChanged: (value) {
                print(value);
                setState((){
                  item.done = value;
                  var itens = ParseObject('Itens');
                  itens.set('objectId', item.objectId);
	                itens.set('done', item.done);
                  itens.save();
                });
              }
            ),
            key:Key(item.title),
            background:  Container(
              color: Colors.red.withOpacity(0.2),
            ),
            onDismissed: (direction) {
              remove(index);
            },
            )
            ;
          }
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: add,
        child: Icon(Icons.add),
        backgroundColor: Colors.pink,
      ),
      );
  }
}