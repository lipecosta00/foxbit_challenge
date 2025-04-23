import 'package:flutter/material.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:foxbit_hiring_test_template/app/pages/home/home_controller.dart';

class HomePage extends CleanView {
  const HomePage({super.key, this.title = ""});

  final String title;

  @override
  HomePageState createState() =>
      // inject dependencies inwards
      HomePageState();
}

class HomePageState extends CleanViewState<HomePage, HomeController> {
  HomePageState() : super(HomeController());

  @override
  Widget get view => Scaffold(
    appBar: AppBar(
      title: const Text('Home Screen'),
    ),
    body: const Center(
      child: Text('Olá Mundo!'),
    ),
  );
}
