import 'package:flutter/material.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talent_flow/app/core/extensions.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';

import '../../../app/core/styles.dart';
import '../../../data/config/di.dart';
import '../../../navigation/routes.dart';
import '../../setting/repo/favourite_repo.dart';

class FreelancerListItem extends StatefulWidget {
  final String name;
  final double? rating;
  final String? jopTitle;
  final String? imageUrl;
  final int id;
  final double? cardWidth;
  final bool isInFavorites;
  final bool showFavourite;
  final VoidCallback? onToggleFavourite;

  const FreelancerListItem(
      {super.key,
      required this.name,
      required this.id,
      this.rating,
      this.imageUrl,
      this.jopTitle,
      this.cardWidth,
      this.isInFavorites = false,
      this.showFavourite = true,
      this.onToggleFavourite});

  @override
  State<FreelancerListItem> createState() => _FreelancerListItemState();
}

class _FreelancerListItemState extends State<FreelancerListItem> {
  late bool _isInFavorites;
  bool _isFavouriteLoading = false;

  @override
  void initState() {
    super.initState();
    _isInFavorites = widget.isInFavorites;
  }

  @override
  void didUpdateWidget(covariant FreelancerListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isInFavorites != widget.isInFavorites) {
      _isInFavorites = widget.isInFavorites;
    }
  }

  Future<void> _toggleFavourite() async {
    if (_isFavouriteLoading || widget.id <= 0) {
      return;
    }

    final previous = _isInFavorites;
    setState(() {
      _isFavouriteLoading = true;
      _isInFavorites = !_isInFavorites;
    });

    if (widget.onToggleFavourite != null) {
      widget.onToggleFavourite!();
      if (mounted) {
        setState(() {
          _isFavouriteLoading = false;
        });
      }
      return;
    }

    final result =
        await sl<FavouriteRepo>().toggleFreelancerFavourite(widget.id);
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
    const freelancerPlaceholder = 'assets/images/freelancer_place_holder.png';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8.0)),
              child:
                  widget.imageUrl != null && widget.imageUrl!.trim().isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: widget.imageUrl!.trim(),
                          height: 100.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Container(color: Colors.grey[200]),
                          errorWidget: (context, url, error) => Image.asset(
                            freelancerPlaceholder,
                            height: 100.h,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.asset(
                          freelancerPlaceholder,
                          height: 100.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
            ),
            if (widget.showFavourite)
              Positioned(
                top: 6.h,
                right: 6.w,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: _toggleFavourite,
                  child: Container(
                    width: 30.w,
                    height: 30.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .95),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: _isFavouriteLoading
                          ? SizedBox(
                              width: 12.w,
                              height: 12.h,
                              child: const CircularProgressIndicator(
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
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    constraints: BoxConstraints(maxWidth: 80.w, minWidth: 50.w),
                    child: Text(
                      widget.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    constraints: BoxConstraints(minWidth: 50.w),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        SizedBox(width: 4.w),
                        Text(
                          widget.rating != null
                              ? widget.rating!.toStringAsFixed(1)
                              : 'N/A',
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(height: 4.h),
              Visibility(
                visible: widget.jopTitle != null && widget.jopTitle!.isNotEmpty,
                child: Text(
                  widget.jopTitle!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    ).onTap(() {
      CustomNavigator.push(Routes.freeLancerView,
          arguments: {"freelancerId": widget.id});
    }, borderRadius: BorderRadius.circular(8)).setContainerToView(
      borderColor: Styles.GREY_BORDER,
      width: widget.cardWidth ?? 150.w,
      radius: 8,
    );
  }
}

class FreelancerListItemShimmer extends StatelessWidget {
  const FreelancerListItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: 150.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100.h,
              width: double.infinity,
              color: Colors.white,
            ),
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100.w,
                    height: 14,
                    color: Colors.white,
                  ),
                  SizedBox(height: 4.h),
                  Container(
                    width: 70.w,
                    height: 12,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
