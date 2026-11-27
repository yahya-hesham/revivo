import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/functions/extensions.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../data/models/vehicle_model.dart';

/// Vehicle list card matching Figma `Vehicle card` (`3:39`).
class VehicleCard extends StatelessWidget {
  const VehicleCard({
    super.key,
    required this.vehicle,
    required this.onTap,
  });

  final VehicleModel vehicle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final formattedKm = NumberFormat.decimalPattern().format(
      vehicle.currentMileageKm,
    );
    final subtitleParts = <String>[
      '${vehicle.year}',
      if (vehicle.nickname != null && vehicle.nickname!.trim().isNotEmpty)
        vehicle.nickname!.trim(),
      '$formattedKm ${'garage.km_unit'.tr()}',
    ];

    return Material(
      color: scheme.surface,
      borderRadius: AppConstants.borderRadius20,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppConstants.borderRadius20,
        child: Padding(
          padding: AppConstants.paddingCard,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      vehicle.catalogTitle,
                      style: context.textTheme.titleLarge?.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppConstants.space8),
                    Text(
                      subtitleParts.join(' • '),
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    if (vehicle.isShared) ...[
                      const SizedBox(height: AppConstants.space12),
                      StatusChip(
                        label: 'garage.read_only'.tr(),
                        type: StatusChipType.readOnly,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
