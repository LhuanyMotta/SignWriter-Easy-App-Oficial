import 'package:flutter/material.dart';
import '../../models/sign_model.dart';
import '../../theme/app_theme.dart';

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
    final theme = Theme.of(context);
    final tokens = theme.extension<AppThemeTokens>();
    final spacing = tokens?.spacingScale ?? 1.0;
    return Card(
      margin: EdgeInsets.only(bottom: 16 * spacing),
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
          padding: EdgeInsets.all(16.0 * spacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSignImage(context),
                  SizedBox(width: 16 * spacing),
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
                        SizedBox(height: 4 * spacing),
                        if (sign.description != null) ...[
                          Text(
                            sign.description!,
                            style: TextStyle(
                              fontSize: 14,
                              color: tokens?.onSurfaceMuted ?? theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4 * spacing),
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
                            _buildDateText(context),
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
                      color: sign.isFavorite
                          ? theme.colorScheme.error
                          : (tokens?.onSurfaceMuted ?? theme.colorScheme.onSurfaceVariant),
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

  Widget _buildSignImage(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).extension<AppThemeTokens>()?.surfaceMuted ??
            Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Image.asset(
        sign.signImagePath,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Icon(
              Icons.sign_language,
              size: 40,
              color: Theme.of(context).extension<AppThemeTokens>()?.onSurfaceMuted ??
                  Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateText(BuildContext context) {
    final now = DateTime.now();
    final difference = now.difference(sign.createdAt);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return Text(
          'Há ${difference.inMinutes} min',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).extension<AppThemeTokens>()?.onSurfaceMuted ??
                Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        );
      }
      return Text(
        'Há ${difference.inHours} h',
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).extension<AppThemeTokens>()?.onSurfaceMuted ??
              Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    } else if (difference.inDays < 7) {
      return Text(
        'Há ${difference.inDays} dias',
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).extension<AppThemeTokens>()?.onSurfaceMuted ??
              Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    } else {
      return Text(
        '${sign.createdAt.day}/${sign.createdAt.month}/${sign.createdAt.year}',
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).extension<AppThemeTokens>()?.onSurfaceMuted ??
              Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }
  }
} 