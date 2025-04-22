import 'package:chatpt/Home.dart';
import 'package:chatpt/SigninPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final emailController=TextEditingController();
  final passwordController=TextEditingController();

  Future<void> _createAccount() async {
    try{
    await FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailController.text.trim(), password: passwordController.text.trim());
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Created Account Sucessfully")));
    if (!mounted) return;
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
                "Sign Up.",
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
                child: ElevatedButton(onPressed:_createAccount,style: ButtonStyle(shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5)))),backgroundColor: MaterialStateProperty.all(Color.fromRGBO(51, 105, 255, 1),)),child: Text("SignUp", style: TextStyle(color: Colors.white),))),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account?"),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.white)),onPressed: (){
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>SigninPage()));
                    }, child: Text("SignIN",style: TextStyle(color:Color.fromRGBO(51, 105, 255, 1)),)),
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