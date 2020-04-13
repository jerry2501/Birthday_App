import 'package:cloud_firestore/cloud_firestore.dart';
class DatbaseSevice{
    final String uid;
    DatbaseSevice({this.uid});
  final CollectionReference collectionReference=Firestore.instance.collection('users');

  Future updateUserData(String number,String city,String uid,String name) async
  {
    return await collectionReference.document(uid).setData({
      'Mobile number':number,

      'City':city,
      'Uid':uid,
      'name':name,

    });
  }
  Future createEvent(String event,String name,String date) async
  {
    String id=DateTime.now().toString();
    return await collectionReference.document(uid).collection('events').document(id).setData({
      'Event':event,
      'Name':name,
      'Date':date,
      'Uid':id,
    });
  }
}