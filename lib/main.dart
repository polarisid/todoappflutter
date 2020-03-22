import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/item.dart';

//stl cria stateless
//stf cria stateful
void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // tem que retornar material APP para casca da app
    //return Container(
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo App',
      theme: ThemeData(primarySwatch: Colors.grey),
      home: HomePage(),
    );
  }
}

////como a home vai mudar sempre ele vai ser um stafull
///esta classe só é chamada uma vez
class HomePage extends StatefulWidget {
  var items = new List<Item>();
  //metodo construtor
  HomePage() {
    items = [];
    // items.add(Item(title: "Item 1", done: false));
    // items.add(Item(title: "Item 2", done: true));
    // items.add(Item(title: "Item 3", done: false));
  }
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var newTaskCtrl = TextEditingController();
  void add() {
    if (newTaskCtrl.text.isEmpty) return;

    ///tem que usar setstate para atualizar a tela
    setState(() {
      widget.items.add(Item(
        title: newTaskCtrl.text,
        done: false,
      ));
      newTaskCtrl.text = ""; //newTaskCtrl.clear()
      save();
    });
  }

  void remove(int index) {
    setState(() {
      widget.items.removeAt(index);
      save();
    });
  }

  //Função para carregar dados
  Future load() async {
    var prefs = await SharedPreferences.getInstance();
    var data = prefs.getString('data');
    if (data != null) {
      //lista
      Iterable decoded = jsonDecode(data);
      List<Item> result = decoded.map((x) => Item.fromJson(x)).toList();
      setState(() {
        widget.items = result;
      });
    }
  }

  ///função para salvar

  save() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('data', jsonEncode(widget.items));
  }

  //construtor para carregar arquivos
  _HomePageState() {
    load();
  }

  @override
  Widget build(BuildContext context) {
    // tem que retornar Scaffold criar uma pagina
    //return Container(

    return Scaffold(
      appBar: AppBar(
        //backgroundColor: Colors.black,
        title: TextFormField(
          //para pegar informações
          controller: newTaskCtrl,
          keyboardType: TextInputType.text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
          decoration: InputDecoration(
            labelText: "Nova Tarefa",
            labelStyle: TextStyle(color: Colors.white),
          ),
        ),
      ),
      //.builder para renderizar os items em tempo de execução
      body: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (BuildContext ctxt, int index) {
          final item = widget.items[index];
          return Dismissible(
            background: Container(color: Colors.red.withOpacity(0.3)),
            onDismissed: (direction) {
              //if(direction==DismissDirection.endToStart)
              //chamando função remove
              remove(index);
              //print(direction);
            },
            key: Key(item.title),
            child: CheckboxListTile(
              title: Text(item.title),
              //tem que ser unico a key
              //key: Key(item.title),
              value: item.done,
              onChanged: (value) {
                //paraatualizar a pagina
                setState(() {
                  //repassando o valor novo que for clicado
                  item.done = value;
                  //assim quando mudar o estado ele salva
                  save();
                });
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        //so passando a função, add() chama a função
        onPressed: add,
        child: Icon(Icons.add),
        backgroundColor: Colors.grey,
      ),
    );
  }
}
