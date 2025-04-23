import 'package:flutter/material.dart';
import 'package:foxbit_hiring_test_template/domain/entities/crypto_entity.dart';

class CryptoListItem extends StatelessWidget {
  final CryptoEntity crypto;

  const CryptoListItem({
    super.key, 
    required this.crypto
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Logo da Criptomoeda
            Image.asset(
              'assets/images/${crypto.instrumentId}.png',
              width: 40,
              height: 40,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.currency_bitcoin,
                size: 40,
                color: Colors.amber,
              ),
            ),
            const SizedBox(width: 16),
            // Informações da Criptomoeda
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    crypto.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Volume: ${crypto.volume.toStringAsFixed(4)}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Preço e Variação
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'R\$ ${double.parse(crypto.price).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      crypto.change >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                      color: crypto.change >= 0 ? Colors.green : Colors.red,
                      size: 12,
                    ),
                    Text(
                      '${crypto.change.abs().toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: crypto.change >= 0 ? Colors.green : Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}