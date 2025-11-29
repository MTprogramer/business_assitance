import 'package:drift/drift.dart';

class Businesses extends Table {
  TextColumn get id => text()(); // primary key set in DB class
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get description => text().nullable()();
  TextColumn get category => text().nullable()();
  TextColumn get location => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get website => text().nullable()();
  TextColumn get image => text().nullable()();
  TextColumn get date => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Products extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get businessId => text()();
  RealColumn get price => real()();
  TextColumn get imageUrl => text().nullable()();
  IntColumn get quantity => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class Sales extends Table {
  TextColumn get id => text()();
  TextColumn get productId => text()();
  TextColumn get businessId => text()();
  TextColumn get productName => text()();
  IntColumn get soldQuantity => integer()();
  TextColumn get date => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
