import 'package:flutter/material.dart';
import 'package:pidevmobileflutter/functions/dashboard_page.dart';
import 'package:pidevmobileflutter/functions/services/notification_service.dart';
import 'package:pidevmobileflutter/pages/screen/admin/ListeCaregiver%20.dart';
import 'package:pidevmobileflutter/pages/screen/admin/ProfileAdminScreen.dart';
import 'package:pidevmobileflutter/pages/screen/admin/adduser.dart';
import 'package:pidevmobileflutter/pages/screen/admin/listeuser.dart';
import 'package:pidevmobileflutter/pages/screen/caregiver/listechild.dart';
import 'package:pidevmobileflutter/pages/screen/child/addchild.dart';
import 'package:pidevmobileflutter/pages/screen/child/profilechild.dart';
import 'package:pidevmobileflutter/pages/screen/parent/ProfileparentScreen.dart';
import 'package:pidevmobileflutter/pages/screen/caregiver/homecaregiver.dart';
import 'package:pidevmobileflutter/pages/screen/parent/homeparent.dart';
import 'package:pidevmobileflutter/pages/screen/admin/homesuperadmin.dart';
import 'package:pidevmobileflutter/pages/security/login.dart';
import 'package:pidevmobileflutter/pages/security/resetpassword.dart';
import 'package:pidevmobileflutter/pages/security/signup.dart';
import 'package:pidevmobileflutter/pages/security/verificationresetpassword.dart';
import 'package:pidevmobileflutter/pages/test.dart';
import 'package:pidevmobileflutter/pages/welcome.dart';
import 'package:pidevmobileflutter/pages/screen/caregiver/ProfilecaregiverScreen.dart';

import 'pages/configuration/constantas.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  SocketService.initSocket();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
     initialRoute: "/login",debugShowCheckedModeBanner: false,
      routes:{
  
        "/login":(context)=> const Login() ,
        "/signup":(context)=> const Signup() ,
        "/resetpassword":(context)=> const ResetPassword() ,
        "/verificationresetpassword":(context)=> const Verificationresetpassword() ,
        "/homeparent":(context)=> const Homeparent() ,
        "/homecaregiver":(context)=> const Homecaregiver(chappiemail: '', token: '',) ,
        "/homesuperadmin":(context)=> const Homesuperadmin() ,
        "/profile": (context) => ProfileScreen(email: "", token: ""), 
        "/profileadmin": (context) => ProfileadminScreen(email: "", token: ""), 

        "/profileparent": (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return ProfileparentScreen(
            email: args?["email"] ?? "",
            token: args?["token"] ?? "",
            
          );
        },
        "/getusers": (context) => Listechild(email: "", token: ""), 
        "/adduser": (context) => Adduser(email: "", token: ""), 
        "/listcaregiver": (context) => ListeCaregiver(email: "", token: ""), 
        "/addchild":(context)  =>  AddChildScreen(email: "", token: "") ,
        "/profilechild": (context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    return ProfileChild(
      email: args?['email'] ?? '',
      token: args?['token'] ?? '',
      parentId: args?['parentId'] ?? '',
    );
  },


        

      }
          );
  }
  
}
