import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'business_assistance.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE businesses(
            id TEXT PRIMARY KEY,
            name TEXT,
            description TEXT,
            category TEXT,
            location TEXT,
            phone TEXT,
            website TEXT,
            image TEXT,
            date TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE products(
            id TEXT PRIMARY KEY,
            name TEXT,
            businessId TEXT,
            price REAL,
            imageUrl TEXT,
            quantity INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE sales(
            id TEXT PRIMARY KEY,
            productId TEXT,
            businessId TEXT,
            productName TEXT,
            soldQuantity INTEGER,
            date TEXT
          )
        ''');
      },
    );
  }
}
