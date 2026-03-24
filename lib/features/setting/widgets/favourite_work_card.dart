import 'package:flutter/material.dart';

import '../../../app/core/styles.dart';
import '../model/favourite_model.dart';
import 'favourite_toggle_button.dart';

class FavouriteWorkCard extends StatelessWidget {
  const FavouriteWorkCard({
    super.key,
    required this.work,
    this.onToggleFavourite,
  });

  final FavouriteWorkModel work;
  final VoidCallback? onToggleFavourite;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FavouriteToggleButton(onPressed: onToggleFavourite),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 88,
                  height: 88,
                  child: work.image != null
                      ? Image.network(
                          work.image!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder(),
                        )
                      : _placeholder(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      work.title ?? '-',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      work.description ?? '-',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF4B5563),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 12,
                      runSpacing: 6,
                      children: [
                        _Meta(
                            icon: Icons.remove_red_eye_outlined,
                            value: '${work.views ?? 0}'),
                        _Meta(
                            icon: Icons.thumb_up_alt_outlined,
                            value: '${work.likes ?? 0}'),
                        if ((work.status ?? '').trim().isNotEmpty)
                          _Meta(icon: Icons.info_outline, value: work.status!),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFE5E7EB),
      child: const Center(
        child: Icon(
          Icons.work_outline,
          color: Styles.PRIMARY_COLOR,
          size: 28,
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({
    required this.icon,
    required this.value,
  });

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: const Color(0xFF6B7280)),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
