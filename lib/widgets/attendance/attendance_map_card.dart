import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:latlong2/latlong.dart';
import '../../core/constants/app_colors.dart';
import '../../screens/attendance/viewmodels/attendance_view_model.dart';

/// Interactive Map card rendering OpenStreetMap tiles, stall pin, 10m presence circle,
/// user GPS radar marker, and live geofence verification badge.
class AttendanceMapCard extends StatefulWidget {
  final AttendanceViewModel viewModel;

  const AttendanceMapCard({
    super.key,
    required this.viewModel,
  });

  @override
  State<AttendanceMapCard> createState() => _AttendanceMapCardState();
}

class _AttendanceMapCardState extends State<AttendanceMapCard> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final stall = widget.viewModel.stall;
    final hasStallCoords = stall != null && stall.hasCoordinates;

    final userPos = widget.viewModel.currentPosition;
    final userPoint = userPos != null ? LatLng(userPos.latitude, userPos.longitude) : null;

    // Center on stall coordinates if configured; otherwise center on user position
    final stallPoint = hasStallCoords ? LatLng(stall.latitude!, stall.longitude!) : null;
    final centerPoint = stallPoint ?? (userPoint ?? const LatLng(-7.792849, 110.365842));
    final radiusMeter = stall?.radiusMeter ?? 25;

    return Container(
      width: double.infinity,
      height: 190,
      decoration: BoxDecoration(
        color: const Color(0xFFF6EFE6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: PotColors.warmBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // 1. Flutter Map with OpenStreetMap tiles
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: centerPoint,
              initialZoom: 18.0,
              minZoom: 14.0,
              maxZoom: 19.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.pot.pot_apps',
              ),
              // 25m Geofenced Radius Circle (rendered only when stall coords exist)
              if (stallPoint != null)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: stallPoint,
                      radius: radiusMeter.toDouble(),
                      useRadiusInMeter: true,
                      color: PotColors.primaryRed.withValues(alpha: 0.16),
                      borderColor: PotColors.primaryRed.withValues(alpha: 0.75),
                      borderStrokeWidth: 2.0,
                    ),
                  ],
                ),
              // Stall & User Markers
              MarkerLayer(
                markers: [
                  // Stall Location Pin (if configured)
                  if (stallPoint != null)
                    Marker(
                      point: stallPoint,
                      width: 44,
                      height: 44,
                      child: _buildStallPin(stall?.nama ?? 'Lapak'),
                    ),
                  // User GPS Radar Marker
                  if (userPoint != null)
                    Marker(
                      point: userPoint,
                      width: 28,
                      height: 28,
                      child: _buildUserRadar(),
                    ),
                ],
              ),
            ],
          ),

          // 2. Top-Left Stall Name Floating Pill (interactive: tap to locate & focus stall on map)
          Positioned(
            top: 10,
            left: 10,
            child: GestureDetector(
              onTap: () {
                if (stallPoint != null) {
                  _mapController.move(stallPoint, 18.0);
                } else if (userPoint != null) {
                  _mapController.move(userPoint, 18.0);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: PotColors.warmBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Iconsax.shop,
                      size: 14,
                      color: PotColors.primaryRed,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      stall?.nama ?? 'Lapak Belum Ditugaskan',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: PotColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Bottom-Right Geofence Distance Verification Badge
          Positioned(
            bottom: 10,
            right: 10,
            child: _buildGeofenceBadge(radiusMeter),
          ),

          // 4. Bottom-Left Re-Center Button
          Positioned(
            bottom: 10,
            left: 10,
            child: GestureDetector(
              onTap: () {
                _mapController.move(stallPoint ?? (userPoint ?? centerPoint), 18.0);
              },
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: PotColors.warmBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Iconsax.gps,
                  size: 16,
                  color: PotColors.primaryRed,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStallPin(String stallName) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: PotColors.primaryRed,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Icon(
            Iconsax.shop,
            size: 14,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildUserRadar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0284C7),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: 0.4),
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildGeofenceBadge(int maxRadius) {
    final vm = widget.viewModel;
    final dist = vm.distanceToStallMeters;
    final isWithin = vm.isWithinRadius;
    final isLoading = vm.isLoadingLocation;
    final isServiceEnabled = vm.isLocationServiceEnabled;
    final isPermissionGranted = vm.isLocationPermissionGranted;
    final hasStallLocation = vm.hasStallLocation;

    if (isLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: PotColors.warmBorder),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(strokeWidth: 2, color: PotColors.primaryRed),
            ),
            SizedBox(width: 6),
            Text(
              'Mencari lokasi GPS...',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: PotColors.textMuted),
            ),
          ],
        ),
      );
    }

    if (!isServiceEnabled) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: PotColors.statusErrorBg.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: PotColors.statusErrorBorder),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_off_rounded, size: 12, color: PotColors.statusErrorText),
            SizedBox(width: 4),
            Text(
              'Layanan GPS Nonaktif',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: PotColors.statusErrorText),
            ),
          ],
        ),
      );
    }

    if (!isPermissionGranted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: PotColors.statusWarningBg.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: PotColors.statusWarningBorder),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_rounded, size: 12, color: PotColors.statusWarningText),
            SizedBox(width: 4),
            Text(
              'Izin Lokasi Belum Diberikan',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: PotColors.statusWarningText),
            ),
          ],
        ),
      );
    }

    if (!hasStallLocation) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: PotColors.statusWarningBg.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: PotColors.statusWarningBorder),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline_rounded, size: 12, color: PotColors.statusWarningText),
            SizedBox(width: 4),
            Text(
              'Lokasi lapak belum disetel Admin',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: PotColors.statusWarningText),
            ),
          ],
        ),
      );
    }

    if (dist == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: PotColors.statusErrorBg.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: PotColors.statusErrorBorder),
        ),
        child: const Text(
          'Lokasi tidak aktif',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: PotColors.statusErrorText),
        ),
      );
    }

    final distanceInt = dist.round();

    if (isWithin) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: PotColors.statusSuccessBg.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: PotColors.statusSuccessBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, size: 13, color: PotColors.statusSuccessText),
            const SizedBox(width: 4),
            Text(
              'Dalam radius presensi (${distanceInt}m)',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: PotColors.statusSuccessText,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: PotColors.statusErrorBg.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PotColors.statusErrorBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber_rounded, size: 13, color: PotColors.statusErrorText),
          const SizedBox(width: 4),
          Text(
            'Di luar radius (${distanceInt}m / maks ${maxRadius}m)',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: PotColors.statusErrorText,
            ),
          ),
        ],
      ),
    );
  }
}
