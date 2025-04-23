import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:foxbit_hiring_test_template/data/helpers/websocket.dart';
import 'package:foxbit_hiring_test_template/data/repositories/heartbeat_repository.dart';
import 'package:foxbit_hiring_test_template/data/repositories/instrument_repository_impl.dart';
import 'package:foxbit_hiring_test_template/data/repositories/quote_repository_impl.dart';
import 'package:foxbit_hiring_test_template/domain/entities/crypto_entity.dart';
import 'package:foxbit_hiring_test_template/domain/entities/instrument_entity.dart';
import 'package:foxbit_hiring_test_template/domain/entities/quote_entity.dart';
import 'package:foxbit_hiring_test_template/domain/usecases/get_instruments_usecase.dart';
import 'package:foxbit_hiring_test_template/domain/usecases/heartbeat_usecase.dart';
import 'package:foxbit_hiring_test_template/domain/usecases/subscribe_quote_usecase.dart';

class HomePresenter extends Presenter {
  // Callbacks para o Heartbeat
  late Function heartbeatOnComplete;
  late Function(dynamic) heartbeatOnError;

  // Callbacks para os Instrumentos
  late Function(List<CryptoEntity>) getInstrumentsOnNext;
  late Function(dynamic) getInstrumentsOnError;

  // Callbacks para Quote
  late Function(int, QuoteEntity) quoteOnNext;
  late Function(int, dynamic) quoteOnError;

  // Use Cases
  final HeartbeatUseCase _heartbeatUseCase =
      HeartbeatUseCase(HeartbeatRepository());
  final GetInstrumentsUseCase _getInstrumentsUseCase =
      GetInstrumentsUseCase(InstrumentRepository());
  final SubscribeQuoteUseCase _subscribeQuoteUseCase =
      SubscribeQuoteUseCase(QuoteRepository());

  void sendHeartbeat(FoxbitWebSocket ws) {
    _heartbeatUseCase.execute(_HeartBeatObserver(this), ws);
  }

  void getInstruments(FoxbitWebSocket ws) {
    _getInstrumentsUseCase.execute(_GetInstrumentsObserver(this), ws);
  }

  void subscribeToQuote(FoxbitWebSocket ws, int instrumentId) {
    final params = SubscribeQuoteParams(
      webSocket: ws,
      instrumentId: instrumentId,
    );

    _subscribeQuoteUseCase.execute(
        _SubscribeQuoteObserver(this, instrumentId), params);
  }

  @override
  void dispose() {
    _heartbeatUseCase.dispose();
    _getInstrumentsUseCase.dispose();
    _subscribeQuoteUseCase.dispose();
  }
}

class _HeartBeatObserver implements Observer<void> {
  HomePresenter presenter;

  _HeartBeatObserver(this.presenter);

  @override
  void onNext(_) {}

  @override
  void onComplete() {
    presenter.heartbeatOnComplete();
  }

  @override
  void onError(dynamic e) {
    presenter.heartbeatOnError(e);
  }
}

class _GetInstrumentsObserver implements Observer<List<InstrumentEntity>> {
  HomePresenter presenter;

  _GetInstrumentsObserver(this.presenter);

  @override
  void onNext(List<InstrumentEntity>? instruments) {
    // Converte instrumentos em crypto entities
    final cryptos = instruments!
        .map((instrument) => CryptoEntity(instrument: instrument))
        .toList();

    presenter.getInstrumentsOnNext(cryptos);
  }

  @override
  void onComplete() {}

  @override
  void onError(dynamic e) {
    presenter.getInstrumentsOnError(e);
  }
}

class _SubscribeQuoteObserver implements Observer<QuoteEntity> {
  HomePresenter presenter;
  int instrumentId;

  _SubscribeQuoteObserver(this.presenter, this.instrumentId);

  @override
  void onNext(QuoteEntity? quote) {
    presenter.quoteOnNext(instrumentId, quote!);
  }

  @override
  void onComplete() {}

  @override
  void onError(dynamic e) {
    presenter.quoteOnError(instrumentId, e);
  }
}
