import 'dart:convert';

import 'package:todo_app/models/task.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Todo App",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  var items = List<Task>();

  HomePage() {
    items = [];
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var newItemController = TextEditingController();

  _HomePageState() {
    load();
  }

  void addItem() {
    if (newItemController.text.isEmpty) return;
    setState(() {
      widget.items.add(Task(title: newItemController.text, done: false));
      save();
      newItemController.clear();
    });
  }

  void removeItem(int index) {
    setState(() {
      widget.items.removeAt(index);
      save();
    });
  }

  Future load() async {
    var prefs = await SharedPreferences.getInstance();
    var data = prefs.getString('data');

    if (data != null) {
      Iterable decode = jsonDecode(data);
      List<Task> result = decode.map((x) => Task.fromJson(x)).toList();
      setState(() {
        widget.items = result;
      });
    }
  }

  void save() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('data', jsonEncode(widget.items));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          controller: newItemController,
          keyboardType: TextInputType.text,
          autocorrect: false,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
              labelText: "Nova tarefa",
              labelStyle: TextStyle(color: Colors.white)),
        ),
      ),
      body: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (BuildContext context, int index) {
          final item = widget.items[index];
          return Dismissible(
            child: CheckboxListTile(
                title: Text(item.title),
                value: item.done,
                onChanged: (value) {
                  setState(() {
                    item.done = value;
                    save();
                  });
                }),
            key: Key(item.title),
            background: Container(
                color: Colors.red,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text("Apagar",
                        textAlign: TextAlign.right,
                        style: TextStyle(color: Colors.white)),
                    Icon(
                      Icons.delete,
                      color: Colors.white,
                    )
                  ],
                )),
            onDismissed: (direction) {
              removeItem(index);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addItem,
        child: Icon(Icons.add),
        backgroundColor: Colors.purple,
      ),
    );
  }
}

