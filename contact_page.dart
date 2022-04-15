// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'package:agenda_contatos/helpers/contact_helpers.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {
  final Contact contact;

  const ContactPage({Key key, this.contact}) : super(key: key); /*parametro opcional*/

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameFocus = FocusNode();
  bool _userEdited = false;

  Contact _editedContact; /*contato que será editado*/

  @override
  void initState() {
    super.initState();
    if (widget.contact == null) {
      _editedContact = Contact(); /*se não tiver contato para editar, será carregado um novo contato.*/
    } else {
      _editedContact = Contact.fromMap(widget.contact.toMap()); /*transformando o contato em Mapa e inserindo o contato no editedContact */
      _nameController.text = _editedContact.name;
      _emailController.text = _editedContact.email;
      _phoneController.text = _editedContact.phone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text(_editedContact.name ?? "Novo Contato"),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if(_editedContact.name != null && _editedContact.name.isNotEmpty){
              /*Navigator trabalha com conceito de pilha, Navigator.push insere o elemento na pilha e o Navigator.pop remove o elemento da pilha*/
              Navigator.pop(context, _editedContact);
            }else{
              FocusScope.of(context).requestFocus(_nameFocus);
            }
          },
          child: Icon(Icons.save),
          backgroundColor: Colors.red,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              GestureDetector(
                child: Container(
                  width: 140.0,
                  height: 140.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      /*Verifica se o index possui alguma imagem, caso contrário carrega a imagem que definimos por padrão*/
                        image: _editedContact.img != null
                            ? FileImage(File(_editedContact.img))
                            : AssetImage("images/person.png"),
                            fit: BoxFit.cover
                    ),
                  ),
                ),
                onTap:(){
                  // ignore: deprecated_member_use
                  ImagePicker.pickImage(source: ImageSource.camera).then((file){
                    /*verificando se o usuario tirou a foto*/
                    if(file == null) return;
                    setState(() {
                      _editedContact.img = file.path;
                    });
                  });
                },
              ),
              TextField(
                controller: _nameController,
                focusNode: _nameFocus,
                decoration: InputDecoration(labelText: "Nome"),
                onChanged: (text) {
                  _userEdited = true;
                  setState(() {
                    _editedContact.name = text; /*alterando o nome e atualizando na tela em tempo real*/
                  });
                },
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email"),
                onChanged: (text) {
                  _userEdited = true;
                  _editedContact.email = text; /*alterando o nome e atualizando na tela em tempo real*/
                },
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: "Phone"),
                onChanged: (text) {
                  _userEdited = true;
                  _editedContact.phone =
                      text; /*alterando o nome e atualizando na tela em tempo real*/
                },
                keyboardType:  TextInputType.phone, /*ativa o teclado numerico para inserir o telefone*/
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<bool> _requestPop(){
    if(_userEdited){
      showDialog(context: context,
      builder: (context){
        return AlertDialog(
          title: Text("Descartar Alterações?"),
          content: Text("Se sair, as alterações serão perdidas."),
          actions: <Widget>[
            // ignore: deprecated_member_use
            FlatButton(
                child: Text("Cancelar"),
                onPressed: (){
                  Navigator.pop(context);
                },
            ),
            // ignore: deprecated_member_use
            FlatButton(
              child: Text("Sim"),
              onPressed: (){
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        );
      }
      );
      return Future.value(false);
    }else{
      return Future.value(true);
    }
  }
}
/*SingleChildScrollView permite que o teclado não fique sobreposto ao texto */
