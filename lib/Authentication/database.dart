import 'package:cloud_firestore/cloud_firestore.dart';
class DatbaseSevice{
    final String uid;
    DatbaseSevice({this.uid});
  final CollectionReference collectionReference=Firestore.instance.collection('users');

  Future updateUserData(String number,String photo,String uid,String name) async
  {
    return await collectionReference.document(uid).setData({
      'Mobile number':number,

      'photo':photo,
      'Uid':uid,
      'name':name,

    });
  }
  Future createEvent(String event,String name,String date,String id,int eventToken) async
  {

    return await collectionReference.document(uid).collection('events').document(id).setData({
      'Event':event,
      'Name':name,
      'Date':date,
      'Uid':id,
       'EventToken':eventToken,
    });
  }
}