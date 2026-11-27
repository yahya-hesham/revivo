import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/functions/extensions.dart';
import '../../../../core/widgets/empty_state_card.dart';
import '../../../../core/widgets/shimmer/app_shimmer.dart';
import '../../data/models/car_catalog_models.dart';

/// Renders a vehicle's hero photo (192px, radius 20) with Unsplash attribution
/// when a live [carImage] lookup is available, or the Figma `Image unavailable`
/// (`10:1234`) card when no photo is available.
class VehicleHeroCard extends StatelessWidget {
  const VehicleHeroCard({
    super.key,
    this.imageUrl,
    this.carImage,
    this.isLoading = false,
  });

  final String? imageUrl;
  final CarImageModel? carImage;
  final bool isLoading;

  Future<void> _openUrl(String? rawUrl) async {
    if (rawUrl == null || rawUrl.isEmpty) return;
    final uri = Uri.tryParse(rawUrl);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const AppShimmerBox(height: 192);
    }

    final resolvedUrl =
        (carImage?.isFound == true ? carImage!.imageUrl : null) ?? imageUrl;

    if (resolvedUrl == null || resolvedUrl.trim().isEmpty) {
      return EmptyStateCard(
        title: 'garage.image_unavailable_title'.tr(),
        subtitle: carImage?.message.isNotEmpty == true
            ? carImage!.message
            : 'garage.image_unavailable_subtitle'.tr(),
      );
    }

    final captionStyle = context.textTheme.bodySmall?.copyWith(
      color: context.colorScheme.onSurfaceVariant,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: AppConstants.borderRadius20,
          child: SizedBox(
            width: double.infinity,
            height: 192,
            child: CachedNetworkImage(
              imageUrl: resolvedUrl,
              fit: BoxFit.cover,
              placeholder: (_, _) => const AppShimmerBox(height: 192),
              errorWidget: (_, _, _) => EmptyStateCard(
                title: 'garage.image_unavailable_title'.tr(),
                subtitle: 'garage.image_unavailable_subtitle'.tr(),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppConstants.space8),
        if (carImage?.isFound == true &&
            carImage?.photographerName != null &&
            carImage!.photographerName!.isNotEmpty)
          Wrap(
            spacing: AppConstants.space4,
            children: [
              Text('garage.photo_by'.tr(), style: captionStyle),
              GestureDetector(
                onTap: () => _openUrl(carImage!.photographerUrl),
                child: Text(
                  carImage!.photographerName!,
                  style: captionStyle?.copyWith(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Text('garage.on_unsplash'.tr(), style: captionStyle),
              if (carImage!.unsplashUrl != null)
                GestureDetector(
                  onTap: () => _openUrl(carImage!.unsplashUrl),
                  child: Text(
                    'Unsplash',
                    style: captionStyle?.copyWith(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
            ],
          )
        else
          Text('garage.illustrative_photo_caption'.tr(), style: captionStyle),
      ],
    );
  }
}
