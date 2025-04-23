import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:foxbit_hiring_test_template/app/pages/home/home_presenter.dart';
import 'package:foxbit_hiring_test_template/data/helpers/websocket.dart';
import 'package:foxbit_hiring_test_template/domain/entities/crypto_entity.dart';
import 'package:foxbit_hiring_test_template/domain/entities/quote_entity.dart';

class HomeController extends Controller {
  final HomePresenter presenter;
  final FoxbitWebSocket ws;

  // Estado da View
  List<CryptoEntity> cryptos = [];
  bool isLoading = true;
  String? errorMessage;

  // Lista de IDs de instrumentos interessantes
  final List<int> relevantInstrumentIds = [
    1,
    2,
    4,
    6,
    10,
  ]; // Bitcoin, Litecoin, Ethereum, TrueUSD, XRP

  HomeController()
      : presenter = HomePresenter(),
        ws = FoxbitWebSocket() {
    _initialize();
  }

  Future<void> _initialize() async {
    ws.connect();
    presenter.sendHeartbeat(ws);

    // Busca os instrumentos depois de conectar
    await Future.delayed(const Duration(milliseconds: 500));
    presenter.getInstruments(ws);
  }

  void refreshData() {
    isLoading = true;
    errorMessage = null;
    refreshUI();

    presenter.getInstruments(ws);
  }

  void _subscribeToRelevantQuotes() {
    for (final crypto in cryptos) {
      if (relevantInstrumentIds.contains(crypto.instrumentId)) {
        presenter.subscribeToQuote(ws, crypto.instrumentId);
      }
    }
  }

  @override
  void onDisposed() {
    ws.disconnect();
    presenter.dispose();
    super.onDisposed();
  }

  @override
  void initListeners() {
    // Heartbeat
    presenter.heartbeatOnComplete = heartbeatOnComplete;
    presenter.heartbeatOnError = heartbeatOnError;

    // Instrumentos
    presenter.getInstrumentsOnNext = getInstrumentsOnNext;
    presenter.getInstrumentsOnError = getInstrumentsOnError;

    // Quote
    presenter.quoteOnNext = quoteOnNext;
    presenter.quoteOnError = quoteOnError;
  }

  // Heartbeat callbacks
  void heartbeatOnComplete() {
    _scheduleNextHeartbeat();
  }

  void heartbeatOnError(dynamic e) {
    ScaffoldMessenger.of(getContext()).showSnackBar(
      const SnackBar(
        duration: Duration(seconds: 10),
        content: Text('Não foi possível enviar a mensagem: [PING]'),
      ),
    );

    _scheduleNextHeartbeat();
  }

  void _scheduleNextHeartbeat() {
    Timer(const Duration(seconds: 30), () {
      presenter.sendHeartbeat(ws);
    });
  }

  // Instruments callbacks
  void getInstrumentsOnNext(List<CryptoEntity> instruments) {
    cryptos = instruments
        // Filtra apenas os instrumentos relevantes
        .where((crypto) => relevantInstrumentIds.contains(crypto.instrumentId))
        // Ordena por sortIndex
        .toList()
      ..sort(
        (a, b) => a.instrument.sortIndex.compareTo(b.instrument.sortIndex),
      );

    isLoading = false;
    errorMessage = null;
    refreshUI();

    // Agora que temos os instrumentos, vamos inscrever para receber as cotações
    _subscribeToRelevantQuotes();
  }

  void getInstrumentsOnError(dynamic e) {
    isLoading = false;
    errorMessage = 'Não foi possível carregar a lista de moedas';
    refreshUI();

    ScaffoldMessenger.of(getContext()).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 5),
        content: Text(errorMessage!),
        action: SnackBarAction(
          label: 'Tentar novamente',
          onPressed: refreshData,
        ),
      ),
    );
  }

  // Quote callbacks
  void quoteOnNext(int instrumentId, QuoteEntity quote) {
    final index =
        cryptos.indexWhere((crypto) => crypto.instrumentId == instrumentId);

    if (index != -1) {
      cryptos[index] = cryptos[index].copyWithQuote(quote);
      refreshUI();
    }
  }

  void quoteOnError(int instrumentId, dynamic e) {
    // Tenta novamente após 5 segundos
    Timer(const Duration(seconds: 5), () {
      presenter.subscribeToQuote(ws, instrumentId);
    });
  }
}
