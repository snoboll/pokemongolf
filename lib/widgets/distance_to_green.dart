import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../app.dart';
import '../models/club.dart';

enum _LocationState { checking, listening, serviceOff, denied, deniedForever }

class DistanceToGreen extends StatefulWidget {
  const DistanceToGreen({super.key, required this.target});

  final ({double lat, double lng}) target;

  @override
  State<DistanceToGreen> createState() => _DistanceToGreenState();
}

class _DistanceToGreenState extends State<DistanceToGreen> {
  StreamSubscription<Position>? _positionSub;
  double? _distanceMeters;
  _LocationState _state = _LocationState.checking;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  @override
  void didUpdateWidget(DistanceToGreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.target != widget.target) {
      _distanceMeters = null;
    }
  }

  Future<void> _startListening() async {
    if (mounted) setState(() => _state = _LocationState.checking);

    bool serviceEnabled;
    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
    } catch (_) {
      serviceEnabled = false;
    }
    if (!serviceEnabled) {
      if (mounted) setState(() => _state = _LocationState.serviceOff);
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      if (mounted) setState(() => _state = _LocationState.denied);
      return;
    }
    if (permission == LocationPermission.deniedForever) {
      if (mounted) setState(() => _state = _LocationState.deniedForever);
      return;
    }

    if (mounted) setState(() => _state = _LocationState.listening);

    try {
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null && mounted) {
        _updateDistance(lastKnown.latitude, lastKnown.longitude);
      }
    } catch (_) {}

    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 1,
    );

    _positionSub?.cancel();
    _positionSub = Geolocator.getPositionStream(locationSettings: settings)
        .listen(
      (pos) => _updateDistance(pos.latitude, pos.longitude),
      onError: (_) {},
    );
  }

  void _updateDistance(double lat, double lng) {
    if (!mounted) return;
    final d = Geolocator.distanceBetween(lat, lng, widget.target.lat, widget.target.lng);
    setState(() => _distanceMeters = d);
  }

  void _onTap() {
    switch (_state) {
      case _LocationState.serviceOff:
        Geolocator.openLocationSettings();
      case _LocationState.denied:
        _startListening();
      case _LocationState.deniedForever:
        Geolocator.openAppSettings();
      case _LocationState.checking:
      case _LocationState.listening:
        break;
    }
  }

  void _showAllClubs(BuildContext context, List<Club> clubs, double? targetMeters) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AllClubsSheet(clubs: clubs, targetMeters: targetMeters),
    );
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }

  static ({Club best, Club? up, Club? down})? _recommendClub(
      List<Club> clubs, double targetMeters) {
    final sorted = clubs
        .where((c) => (c.carryDistance ?? c.totalDistance) != null)
        .toList()
      ..sort((a, b) {
        final da = a.carryDistance ?? a.totalDistance!;
        final db = b.carryDistance ?? b.totalDistance!;
        return da.compareTo(db);
      });

    if (sorted.isEmpty) return null;

    int bestIdx = 0;
    double bestDiff = double.infinity;
    for (int i = 0; i < sorted.length; i++) {
      final d = sorted[i].carryDistance ?? sorted[i].totalDistance!;
      final diff = (d - targetMeters).abs();
      if (diff < bestDiff) {
        bestDiff = diff;
        bestIdx = i;
      }
    }

    return (
      best: sorted[bestIdx],
      up: bestIdx + 1 < sorted.length ? sorted[bestIdx + 1] : null,
      down: bestIdx - 1 >= 0 ? sorted[bestIdx - 1] : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dim = theme.colorScheme.onSurface.withValues(alpha: 0.5);

    final (IconData icon, Color iconColor, String label, bool tappable) = switch (_state) {
      _LocationState.checking => (Icons.my_location, dim, 'Locating...', false),
      _LocationState.serviceOff => (Icons.location_off, dim, 'Turn on location', true),
      _LocationState.denied => (Icons.location_off, dim, 'Allow location', true),
      _LocationState.deniedForever => (Icons.location_off, dim, 'Open settings', true),
      _LocationState.listening => (
          Icons.flag,
          theme.colorScheme.primary,
          _distanceMeters == null ? 'Locating...' : '${_distanceMeters!.round()} m',
          false,
        ),
    };

    final clubs = BogeybeastGolfScope.of(context).clubs;
    final recommendation = (_state == _LocationState.listening && _distanceMeters != null)
        ? _recommendClub(clubs, _distanceMeters!)
        : null;

    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: tappable ? dim : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          if (recommendation != null) ...<Widget>[
            const SizedBox(height: 6),
            const Divider(height: 1, thickness: 0.5),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => _showAllClubs(context, clubs, _distanceMeters),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (recommendation.up != null)
                    _ClubRow(club: recommendation.up!, dim: true, theme: theme),
                  _ClubRow(club: recommendation.best, dim: false, theme: theme),
                  if (recommendation.down != null)
                    _ClubRow(club: recommendation.down!, dim: true, theme: theme),
                  const SizedBox(height: 2),
                  Text(
                    'tap to see all clubs',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );

    if (tappable) {
      return GestureDetector(onTap: _onTap, child: chip);
    }
    return chip;
  }
}

// ── _AllClubsSheet ────────────────────────────────────────────────────────────

class _AllClubsSheet extends StatelessWidget {
  const _AllClubsSheet({required this.clubs, required this.targetMeters});

  final List<Club> clubs;
  final double? targetMeters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final sorted = clubs
        .where((c) => (c.carryDistance ?? c.totalDistance) != null)
        .toList()
      ..sort((a, b) {
        final da = a.carryDistance ?? a.totalDistance!;
        final db = b.carryDistance ?? b.totalDistance!;
        return db.compareTo(da); // longest first
      });

    // Find best-match index for highlighting
    int? bestIdx;
    if (targetMeters != null && sorted.isNotEmpty) {
      double bestDiff = double.infinity;
      for (int i = 0; i < sorted.length; i++) {
        final d = sorted[i].carryDistance ?? sorted[i].totalDistance!;
        final diff = (d - targetMeters!).abs();
        if (diff < bestDiff) {
          bestDiff = diff;
          bestIdx = i;
        }
      }
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text('Your bag', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                if (targetMeters != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    '· ${targetMeters!.round()} m to green',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            if (sorted.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No clubs with distances set.\nAdd distances in your bag settings.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              )
            else
              ...List.generate(sorted.length, (i) {
                final club = sorted[i];
                final isBest = i == bestIdx;
                final carry = club.carryDistance;
                final total = club.totalDistance;

                String distLabel() {
                  if (carry != null && total != null) return '${carry} m carry  /  ${total} m total';
                  if (carry != null) return '${carry} m carry';
                  if (total != null) return '${total} m total';
                  return '';
                }

                final color = isBest
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.75);

                return Container(
                  margin: const EdgeInsets.only(bottom: 2),
                  decoration: BoxDecoration(
                    color: isBest
                        ? theme.colorScheme.secondary.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Row(
                      children: [
                        Icon(Icons.sports_golf, size: 16, color: color),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            club.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: isBest ? FontWeight.w800 : FontWeight.w500,
                              color: color,
                            ),
                          ),
                        ),
                        Text(
                          distLabel(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isBest
                                ? theme.colorScheme.secondary.withValues(alpha: 0.85)
                                : theme.colorScheme.onSurface.withValues(alpha: 0.45),
                            fontWeight: isBest ? FontWeight.w700 : FontWeight.w400,
                          ),
                        ),
                        if (isBest) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.check_circle, size: 16, color: theme.colorScheme.secondary),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── _ClubRow ──────────────────────────────────────────────────────────────────

class _ClubRow extends StatelessWidget {
  const _ClubRow({required this.club, required this.dim, required this.theme});

  final Club club;
  final bool dim;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final color = dim
        ? theme.colorScheme.onSurface.withValues(alpha: 0.35)
        : theme.colorScheme.secondary;
    final weight = dim ? FontWeight.w500 : FontWeight.w700;

    String distLabel() {
      final carry = club.carryDistance;
      final total = club.totalDistance;
      if (carry != null && total != null) return '${carry}m / ${total}m';
      if (carry != null) return 'carry ${carry}m';
      if (total != null) return 'total ${total}m';
      return '';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sports_golf, size: 12, color: color),
          const SizedBox(width: 5),
          SizedBox(
            width: 34,
            child: Text(
              club.name,
              style: theme.textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: weight,
              ),
            ),
          ),
          Text(
            distLabel(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: dim
                  ? theme.colorScheme.onSurface.withValues(alpha: 0.25)
                  : theme.colorScheme.secondary.withValues(alpha: 0.75),
              fontWeight: weight,
            ),
          ),
        ],
      ),
    );
  }
}
