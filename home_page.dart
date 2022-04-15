// ignore_for_file: prefer_const_constructors, deprecated_member_use

import 'package:agenda_contatos/helpers/contact_helpers.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'contact_page.dart';


enum OrderOptions {orderaz, orderza}

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  ContactHelper helper = ContactHelper();
  List<Contact> contacts = [];
  @override
  void initState(){
    /*Carregar os contatos do banco de dados para a lista de contatos do app quando aberto*/
    super.initState();
    _getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contatos"),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions:<Widget> [
          PopupMenuButton<OrderOptions>(itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
            const PopupMenuItem<OrderOptions>(
              child:  Text("Ordenar de A-Z"),
              value: OrderOptions.orderaz,
            ),
            const PopupMenuItem<OrderOptions>(
              child:  Text("Ordenar de Z-A"),
              value: OrderOptions.orderza,
            ),
          ],
            onSelected: _orderList,
          )
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _showContactPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
          padding: EdgeInsets.all(10.0),
          itemCount: contacts.length,
          itemBuilder: (context ,index){
            return _contactCard(context, index);
          }
      ),
    );
  }
  Widget _contactCard(BuildContext context, int index){
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: <Widget> [
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    /*Verifica se o index possui alguma imagem, caso contrário carrega a imagem que definimos por padrão*/
                      image: contacts[index].img !=null ?
                          FileImage(File(contacts[index].img)) :
                          AssetImage("images/person.png"),
                          fit: BoxFit.cover
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget> [
                    Text(contacts[index].name ?? "",
                    style: TextStyle(fontSize: 22.0,
                            fontWeight: FontWeight.bold),
                    ),
                    Text(contacts[index].email ?? "",
                      style: TextStyle(fontSize: 18.0),
                    ),
                    Text(contacts[index].phone ?? "",
                      style: TextStyle(fontSize: 18.0),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onTap:(){
        _showOption(context, index);
      },
    );
  }

  void _showOption(BuildContext context, int index){
    showModalBottomSheet(
        context: context,
        builder: (context){
          return BottomSheet(
            onClosing: (){

            },
            builder: (context){
              return Container(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children:<Widget> [
                    Padding(padding: EdgeInsets.all(10.0),
                      child: FlatButton(
                          onPressed: (){
                             launch("tel: ${contacts[index].phone}");
                             Navigator.pop(context);
                          },
                          child: Text("Ligar",
                            style: TextStyle(color: Colors.red, fontSize: 20.0),)
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(10.0),
                      child: FlatButton(
                          onPressed: (){
                            Navigator.pop(context);
                            _showContactPage(contact: contacts[index]);/*mostrando a tela de contatos*/
                          },
                          child: Text("Editar",
                            style: TextStyle(color: Colors.red, fontSize: 20.0),)
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(10.0),
                      child: FlatButton(
                          onPressed: (){
                            helper.deleteContact(contacts[index].id);
                           setState(() {
                             contacts.removeAt(index);
                             Navigator.pop(context);
                           });
                          },
                          child: Text("Excluir",
                            style: TextStyle(color: Colors.red, fontSize: 20.0),)
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
    );
  }

  void _showContactPage({Contact contact}) async{
    /*quando for chamar a função do botão não passaremos um contato, quando estiver alterando o contato, passaremos o proprio contato  */

    /*Vamos chamar o ContactPage tanto do Botão adidionar quanto do card do contato*/

    final recContact = await Navigator.push(context,
        MaterialPageRoute(builder:(context) => ContactPage(contact: contact,))/*enviar dado para a proxima tela*/
    );
    if(recContact != null){
      if(contact != null){
        await helper.updateContact(recContact);

      }else{
        await helper.saveContact(recContact);
      }
      _getAllContacts();
    }
  }
  void _getAllContacts(){
    helper.getAllContacts().then((list){
      setState(() {
        contacts = list;
      });
    });
  }
  void _orderList(OrderOptions result){
    switch(result){
      case OrderOptions.orderaz:
        contacts.sort((a, b){
         return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
      break;
      case OrderOptions.orderza:
        contacts.sort((a, b){
         return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
    }
    setState(() {

    });
  }
}
