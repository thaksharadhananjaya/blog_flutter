import 'dart:async';
import 'dart:io' as io;
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'models/blog.model.dart';

class DBHelper {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "blog.db");

    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    // When creating the db, create the table
    try {
      await db.execute(
          "CREATE TABLE Blog(id INTEGER PRIMARY KEY AUTOINCREMENT, title Text, description TEXT, imgPath TEXT, date DATETIME DEFAULT (strftime('%Y-%m-%d', 'now', 'localtime')))");
    } catch (e) {
      print(e);
    }
  }

  Future<List<Blog>> getBlogs() async {
    var dbClient = await db;
    List<Map> blogs = await dbClient.rawQuery('SELECT * FROM Blog');
    List<Blog> blog = [];

    for (var row in blogs) {
      blog.add(Blog(
          id: row['id'],
          title: row['title'],
          description: row['description'],
          imgPath: row['imgPath'],
          date: row['date']));
    }
    return blog;
  }

  Future<List<Blog>> getBlogByTitle(String title) async {
    var dbClient = await db;
    List<Map> blogs = await dbClient
        .rawQuery("SELECT * FROM Blog where title LIKE '%$title%'");

    List<Blog> blog = [];
    for (var row in blogs) {
      blog.add(Blog(
          id: row['id'],
          title: row['title'],
          description: row['description'],
          imgPath: row['imgPath'],
          date: row['date']));
    }
    return blog;
  }

  Future<bool> saveBlog(
    Blog blog,
  ) async {
    var dbClient = await db;

    try {
      await dbClient.transaction((txn) async {
        return await txn.rawInsert(
            "INSERT INTO Blog(title, description , imgPath , date) VALUES('${blog.title}', '${blog.description}', '${blog.imgPath}', '${blog.date}')");
      });
    } catch (e) {
      return false;
    }
    return true;
  }

  Future deleteBlog(int id) async {
    var dbClient = await db;
    try {
      await dbClient.execute("DELETE FROM Blog WHERE id = '$id'");
    } catch (e) {
      print(e);
    }
  }

  Future<bool> updateBlog(Blog blog) async {
    print(blog);
    var dbClient = await db;
    try {
      await dbClient.execute(
          "UPDATE Blog SET title = '${blog.title}', description = '${blog.description}', imgPath = '${blog.imgPath}', date = '${blog.date}' WHERE id = '${blog.id}'");
    } catch (e) {
      print(e);
      return false;
    }
    return true;
  }
}
