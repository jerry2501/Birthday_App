import 'package:cloud_firestore/cloud_firestore.dart';
class DatbaseSevice{
    final String uid;
    DatbaseSevice({this.uid});
  final CollectionReference collectionReference=Firestore.instance.collection('users');

  Future updateUserData(String number,String email,String photo,String uid,String name,int noti_hour,int noti_minute) async
  {
    return await collectionReference.document(uid).setData({
      'Mobile number':number,
       'Email':email,
      'photo':photo,
      'Uid':uid,
      'name':name,
      'Notification_hour':noti_hour,
      'Notification_minute':noti_minute,

    });
  }
  Future createEvent(String event,String name,String date,String id,int eventToken,int smsid) async
  {

    return await collectionReference.document(uid).collection('events').document(id).setData({
      'Event':event,
      'Name':name,
      'Date':date,
      'Uid':id,
       'EventToken':eventToken,
      'SmsId':smsid,

    });
  }
}