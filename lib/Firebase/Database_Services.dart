
import 'package:cloud_firestore/cloud_firestore.dart';



 class Database_Services{

  final CollectionReference ALUMNI = FirebaseFirestore.instance.collection('ALUMNI');
  final CollectionReference users = FirebaseFirestore.instance.collection('users');


  //while updating the user profile, this function will be called to update the user to the database for changing the photoURL of the user and generate an avatar of the user.
  Future updateUserData_Profile(String uid, String email, String displayName, String yearOfGrad) async {
    //TODO: Add isStudent field to the database
    return await users.doc(uid).set({
        'email': email,
        'displayName': displayName,
        'yearOfGrad': yearOfGrad,
        'photoURL': '',
        'uid': uid,
    });
  }
   Future updateALUMNIData_Profile(String collegeName, String uid, String email, String displayName, String yearsOfExperience) async {
     //TODO: Add isStudent field to the database
     return await ALUMNI.doc(uid).set({
       'email': email,
       'displayName': displayName,
       'yearsOfExperience': yearsOfExperience,
       'photoURL': '',
       'reviewAuthors':[],
       'reviewComments': [],
       'collegeName': collegeName,
       'uid': uid,
       'rating': [],
     });
   }

  Future<List> sendALUMNINames() async{
    List alumniNames = [];
    await ALUMNI
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        alumniNames.add(doc['displayName']);
        }
      });
    return alumniNames;
  }

  Future<String> sendAlumniYOE(String name) async{
    String uid = await fetchUIDFromName(name);
    DocumentReference<
        Map<String, dynamic>> documentRef = await FirebaseFirestore.instance.collection("ALUMNI")
        .doc(uid);

    DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await documentRef
        .get();
    String yoe = documentSnapshot.data()!['yearsOfExperience'];
    return yoe;
  }

  Future<String> sendAlumniCollege(String name) async{
    String uid = await fetchUIDFromName(name);
    DocumentReference<
        Map<String, dynamic>> documentRef = await FirebaseFirestore.instance.collection("ALUMNI")
        .doc(uid);

    DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await documentRef
        .get();
    String c = documentSnapshot.data()!['collegeName'];
    return c;
  }

  Future<void> postReview(String name, String uid, String review, double rating) async{
    String uidALUMNI = await fetchUIDFromName(name);
    String author = await fetchNameFromUID(uid);

    DocumentReference<
        Map<String, dynamic>> documentRef = await FirebaseFirestore.instance.collection("ALUMNI")
        .doc(uidALUMNI);

    DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await documentRef
        .get();

      final ratingList = documentSnapshot.data()!['rating'];
      ratingList.add(rating);
      final reviewAuthor = documentSnapshot.data()!['reviewAuthors'];
      final reviewComments = documentSnapshot.data()!['reviewComments'];
      reviewComments.add(review);

      bool given = false;
      for(int index=0; index<reviewAuthor.length; index++) {
        if(reviewAuthor[index]==author) given = true;
      }

      if(!given) {
        await documentRef.update({
          'reviewComments': reviewComments,
          'reviewAuthors': FieldValue.arrayUnion([author]),
          'rating': ratingList,
        });
      }
  }

  Future<List> sendAlumniRating(String name) async{
    String uid = await fetchUIDFromName(name);
    List r=[];
    DocumentReference<
        Map<String, dynamic>> documentRef = await FirebaseFirestore.instance.collection("ALUMNI")
        .doc(uid);

    DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await documentRef
        .get();
    r= documentSnapshot.data()!['rating'];
    return r;
  }

   Future<List> sendAlumniReviews(String name) async{
     String uid = await fetchUIDFromName(name);
     List r=[];
     DocumentReference<
         Map<String, dynamic>> documentRef = await FirebaseFirestore.instance.collection("ALUMNI")
         .doc(uid);

     DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await documentRef
         .get();
     r= documentSnapshot.data()!['reviewComments'];
     return r;
   }

   Future<List> sendAlumniReviewsAuthor(String name) async{
     String uid = await fetchUIDFromName(name);

     List r = [];
     DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await FirebaseFirestore.instance.collection("ALUMNI").doc(uid).get();

     r= documentSnapshot.data()!['reviewAuthors'];

     return r;
   }

  Future<String> sendStudentPhotoUrl(String name) async{
    String uid = await fetchUIDFromNameStudent(name);

    DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await FirebaseFirestore.instance.collection("users").doc(uid).get();
    print(documentSnapshot.data());
    String r= documentSnapshot.data()!['photoURL'];

    return r;
  }

  Future<String> sendPhotoUrl(String name) async{
    String uid = await fetchUIDFromName(name);
    DocumentReference<
        Map<String, dynamic>> documentRef = await FirebaseFirestore.instance.collection("ALUMNI")
        .doc(uid);

    DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await documentRef
        .get();

    String r= documentSnapshot.data()!['photoURL'];
    print(r);
    return r;
  }

   Future<String> fetchUIDFromName(name) async{
     String uid="";
     await ALUMNI
         .get()
         .then((QuerySnapshot querySnapshot) {
       for (var doc in querySnapshot.docs) {
         if (doc['displayName'] == name) {
           uid = doc['uid'];
           break;
         }
       }
     });
     return uid;
   }

  Future<String> fetchNameFromUID(uid) async{
    String name="";
    DocumentReference<Map<String, dynamic>> documentRef = await FirebaseFirestore
        .instance
        .collection('users')
        .doc(uid);

    DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await documentRef.get();

    name = documentSnapshot.data()!['displayName'];
    return name;

  }

  Future<String> fetchUIDFromNameStudent(name) async{
    String uid="";
    await users
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (doc['displayName'] == name) {
          uid = doc['uid'];
          break;
        }
      }
    });
    return uid;
  }

  Future <bool> isEmailExisting(String email) async {
    bool isEmailExisting = false;
    await users.get().then((QuerySnapshot querySnapshot){
      for(var doc in querySnapshot.docs){
        print(doc['email']);
        if(doc['email'] == email){
          isEmailExisting = true;
        }
      }

    });
  return isEmailExisting;
  }

  Future<Map> userData(String uid) async {
    Map<String, dynamic> userData = {};
    await users.doc(uid).get().then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        userData = documentSnapshot.data() as Map<String, dynamic>;
        userData['uid'] = uid;
      } else {
        print('Document does not exist on the database');
      }
    });
    return userData;
  }
}