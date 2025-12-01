import '../Models/BusinessModel.dart';

class BusinessRepository {
  // final BusinessDao _dao;
  //
  // BusinessRepository(AppDatabase db) : _dao = db.businessDao;
  //
  // Future<void> addBusiness(BusinessesData business) async {
  //   await _dao.insertBusiness(business);
  // }
  //
  // Future<List<Business>> getAllBusinesses() async {
  //   var rows = await _dao.getAllBusinesses();
  //   return rows.map((e) => e.toModel()).toList();
  // }
  //
  // Future<BusinessesData?> findBusinessById(String id) async {
  //   final rows = await (_dao.select(_dao.businesses)
  //     ..where((tbl) => tbl.id.equals(id)))
  //       .get();
  //
  //   return rows.isNotEmpty ? rows.first : null;
  // }
  //
  // Future<void> updateBusiness(BusinessesData business) async {
  //   await _dao.updateBusiness(business);
  // }
  //
  // Future<void> deleteBusiness(String id) async {
  //   await _dao.deleteBusiness(id);
  // }
}
