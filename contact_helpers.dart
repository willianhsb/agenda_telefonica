// ignore_for_file: prefer_const_constructors
// ignore: import_of_legacy_library_into_null_safe
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

const String contactTable = "contactTable";
const String idColumn = "idColumn";
const String nameColumn = "nameColumn";
const String emailColumn = "emailColumn";
const String phoneColumn = "phoneColumn";
const String imgColumn = "imgColumn";

class ContactHelper {
  static final ContactHelper _instance = ContactHelper.internal(); /*instanciando o ContactHelper para utilizar em qualquer lugar no codigo*/
  factory ContactHelper() => _instance;
  ContactHelper.internal(); /*Declarando o Banco de Dados*/
  Database _db; /*_db limita a alteração no banco somente à classe ContactHelpers, nenhum outro lugar será capaz de efetuar alguma alteração no banco */
  Future<Database> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "contacts.db");
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      await db.execute(
          "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY , $nameColumn TEXT, $emailColumn TEXT,"
              " $phoneColumn TEXT, $imgColumn TEXT )"
      );
    });
  }

  Future<Contact> saveContact(Contact contact) async {
    Database dbContact = await db; /*obtendo o banco de dados*/
    contact.id = await dbContact.insert(
        contactTable, contact.toMap()); /*inserindo o contato na tabela e obtendo o id de onde o contato foi salvo*/
    return contact;
  }

  Future<Contact> getContact(int id) async {
    Database dbContact = await db; /*obtendo o banco de dados*/
    List<Map> maps = await dbContact.query(contactTable,
        columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn],
        where: "$idColumn = ?",
        whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Contact.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> deleteContact(int id) async {
    Database dbContact = await db; /*obtendo o banco de dados*/
    return await dbContact.delete(contactTable, where: "$idColumn = ?", whereArgs: [id]); /*deletar da tabela contato o item correspondente ao ID passado pelo usuario*/
  }

  Future<int> updateContact(Contact contact) async{
    Database dbContact = await db;
     return await dbContact.update(contactTable, contact.toMap(), where: "$idColumn = ?", whereArgs: [contact.id]);
  }

  Future<List> getAllContacts() async {
    Database dbContact = await db;
    List listMap = await dbContact.rawQuery("SELECT * FROM $contactTable");/*Lista de Mapas onde cada mapa é um Contato*/
    List<Contact> listContact = [];
    for(Map m in listMap){
      listContact.add(Contact.fromMap(m));/*transformando o ListMap numa Lista de Contatos*/
    }
    return listContact;

  }

  Future<int> getNumber() async {
    Database dbContact = await db;
    return Sqflite.firstIntValue(await dbContact.rawQuery("SELECT COUNT (*) FROM $contactTable"));/*obtendo a contagem e retornando a qtd de elementos da tabela */
  }

  Future close() async{
    Database dbContact = await db;
    dbContact.close();
  }

}

class Contact {
  int id;
  String name;
  String email;
  String phone;
  String img;

  Contact();

  Contact.fromMap(Map map) {
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img = map[imgColumn];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img
    };
    if (id != null) {
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Contact(id:$id, name:$name, email:$email, phone:$phone, img:$img)";
  }
}
