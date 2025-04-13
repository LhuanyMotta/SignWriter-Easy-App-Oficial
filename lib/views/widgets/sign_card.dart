import 'package:flutter/material.dart';
import '../../models/sign_model.dart';

/// Widget que mostra um card de sinal
class SignCard extends StatelessWidget {
  /// O modelo de sinal a ser exibido
  final SignModel sign;
  
  /// Callback quando o botão de editar é pressionado
  final VoidCallback onEdit;
  
  /// Callback quando o botão de excluir é pressionado
  final VoidCallback onDelete;
  
  /// Callback quando o botão de favorito é alternado
  final VoidCallback onFavoriteToggle;

  /// Construtor
  const SignCard({
    super.key,
    required this.sign,
    required this.onEdit,
    required this.onDelete,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Aqui no futuro podemos mostrar detalhes do sinal
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSignImage(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sign.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (sign.description != null) ...[
                          Text(
                            sign.description!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                        ],
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                sign.category,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const Spacer(),
                            _buildDateText(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(
                      sign.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: sign.isFavorite ? Colors.red : Colors.grey,
                    ),
                    onPressed: onFavoriteToggle,
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Image.asset(
        sign.signImagePath,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Icon(
              Icons.sign_language,
              size: 40,
              color: Colors.grey.shade400,
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateText() {
    final now = DateTime.now();
    final difference = now.difference(sign.createdAt);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return Text(
          'Há ${difference.inMinutes} min',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        );
      }
      return Text(
        'Há ${difference.inHours} h',
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      );
    } else if (difference.inDays < 7) {
      return Text(
        'Há ${difference.inDays} dias',
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      );
    } else {
      return Text(
        '${sign.createdAt.day}/${sign.createdAt.month}/${sign.createdAt.year}',
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      );
    }
  }
} 