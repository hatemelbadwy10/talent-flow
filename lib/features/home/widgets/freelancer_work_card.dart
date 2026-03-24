import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_flow/app/core/app_storage_keys.dart';
import 'package:talent_flow/app/core/styles.dart';
import 'package:talent_flow/components/status_chip.dart';
import 'package:talent_flow/data/config/di.dart';
import 'package:talent_flow/features/home/model/freelancer_profile_model.dart';
import 'package:talent_flow/features/setting/repo/favourite_repo.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';
import 'package:talent_flow/navigation/routes.dart';

class FreelancerWorkCard extends StatefulWidget {
  const FreelancerWorkCard({
    super.key,
    required this.work,
    this.onTap,
  });

  final Work work;
  final Future<void> Function()? onTap;

  @override
  State<FreelancerWorkCard> createState() => _FreelancerWorkCardState();
}

class _FreelancerWorkCardState extends State<FreelancerWorkCard> {
  late bool _isInFavorites;
  bool _isFavouriteLoading = false;

  bool get _canFavourite =>
      !(sl<SharedPreferences>().getBool(AppStorageKey.isFreelancer) ?? false);

  @override
  void initState() {
    super.initState();
    _isInFavorites = widget.work.isInFavorites ?? false;
  }

  @override
  void didUpdateWidget(covariant FreelancerWorkCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.work.isInFavorites != widget.work.isInFavorites) {
      _isInFavorites = widget.work.isInFavorites ?? false;
    }
  }

  Future<void> _toggleFavourite() async {
    if (!_canFavourite || _isFavouriteLoading || (widget.work.id ?? 0) <= 0) {
      return;
    }

    final previous = _isInFavorites;
    setState(() {
      _isFavouriteLoading = true;
      _isInFavorites = !_isInFavorites;
    });

    final result =
        await sl<FavouriteRepo>().toggleWorkFavourite(widget.work.id!);
    if (!mounted) {
      return;
    }

    result.fold(
      (_) {
        _isInFavorites = previous;
      },
      (_) {},
    );

    setState(() {
      _isFavouriteLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final status = ProjectStatusHelper.fromString(widget.work.status);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: widget.onTap != null
            ? () async {
                await widget.onTap!();
              }
            : widget.work.id == null
                ? null
                : () {
                    CustomNavigator.push(
                      Routes.work,
                      arguments: {
                        'id': widget.work.id,
                        'work': widget.work,
                      },
                    );
                  },
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: SizedBox(
                      width: double.infinity,
                      height: 124,
                      child: widget.work.image != null &&
                              widget.work.image!.trim().isNotEmpty
                          ? Image.network(
                              widget.work.image!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _fallbackImage(),
                            )
                          : _fallbackImage(),
                    ),
                  ),
                  if (_canFavourite)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: _toggleFavourite,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: _isFavouriteLoading
                                ? const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(
                                    _isInFavorites
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    size: 18,
                                    color: _isInFavorites
                                        ? const Color(0xFFDB5353)
                                        : const Color(0xFF6B7280),
                                  ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.work.title ?? '-',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Styles.HEADER,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.work.description ?? '-',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: Styles.SUBTITLE,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _StatItem(
                          icon: Icons.visibility_outlined,
                          value: '${widget.work.views ?? 0}',
                        ),
                        const SizedBox(width: 10),
                        _StatItem(
                          icon: Icons.thumb_up_alt_outlined,
                          value: '${widget.work.likes ?? 0}',
                        ),
                        const Spacer(),
                        StatusChip(status: status),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallbackImage() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0E8A8F),
            Color(0xFF14A0A5),
          ],
        ),
      ),
      child: const Center(
        child: Icon(Icons.work_outline, color: Colors.white, size: 36),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
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
        Icon(icon, size: 14, color: Styles.HINT_COLOR),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Styles.HINT_COLOR,
          ),
        ),
      ],
    );
  }
}
