import 'package:chatpt/Home.dart';
import 'package:chatpt/SignupPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {

  final emailController=TextEditingController();
  final passwordController=TextEditingController();

  Future<void> _LoginAccount() async{
    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailController.text.trim(), password: passwordController.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Logged In Sucessfully")));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Home()));
    }catch(e){
      if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(35.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Sign IN.",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,color: Color.fromRGBO(51, 105, 255, 1),),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "EmailId",
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Password",
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 40,
                width: double.infinity,
                child: ElevatedButton(onPressed:_LoginAccount,style: ButtonStyle(shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5)))),backgroundColor: MaterialStateProperty.all(Color.fromRGBO(51, 105, 255, 1))),child: Text("SignIN", style: TextStyle(color: Colors.white),))),
                const SizedBox(height: 20),
                Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Not have an account?"),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.white)),onPressed: (){
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>SignupPage()));
                    }, child: Text("SignUP",style: TextStyle(color:Color.fromRGBO(51, 105, 255, 1)),)),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}