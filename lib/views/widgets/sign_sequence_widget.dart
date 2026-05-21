import 'package:flutter/material.dart';

import '../../models/sign_model.dart';

/// Widget para renderizar uma sequência de sinais
class SignSequenceWidget extends StatelessWidget {
  final List<SignModel> signs;
  final double height;

  const SignSequenceWidget({
    super.key,
    required this.signs,
    this.height = 110,
  });

  @override
  Widget build(BuildContext context) {
    if (signs.isEmpty) {
      return Center(
        child: Text(
          'Sem sinais para exibir',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: signs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final sign = signs[index];
          return _buildSignItem(context, sign);
        },
      ),
    );
  }

  Widget _buildSignItem(BuildContext context, SignModel sign) {
    return Container(
      width: 90,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Expanded(
            child: Image.asset(
              sign.signImagePath,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.sign_language,
                  color: Colors.grey.shade400,
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          Text(
            sign.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
