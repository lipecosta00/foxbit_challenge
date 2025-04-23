import 'package:flutter/material.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:foxbit_hiring_test_template/app/pages/home/home_controller.dart';
import 'package:foxbit_hiring_test_template/app/pages/home/widgets/crypto_list_item.dart';

class HomePage extends CleanView {
  const HomePage({super.key, this.title = "Cotação"});

  final String title;

  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends CleanViewState<HomePage, HomeController> {
  HomePageState() : super(HomeController());

  @override
  Widget get view {
    return ControlledWidgetBuilder<HomeController>(
      builder: (context, controller) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(widget.title),
            backgroundColor: Colors.white,
            elevation: 1,
          ),
          body: _buildBody(controller),
        );
      },
    );
  }

  Widget _buildBody(HomeController controller) {
    if (controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (controller.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              controller.errorMessage!,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => controller.refreshData(),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (controller.cryptos.isEmpty) {
      return const Center(
        child: Text(
          'Não há moedas disponíveis no momento.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => controller.refreshData(),
      child: ListView.builder(
        itemCount: controller.cryptos.length,
        itemBuilder: (context, index) {
          final crypto = controller.cryptos[index];
          return CryptoListItem(crypto: crypto);
        },
      ),
    );
  }
}
