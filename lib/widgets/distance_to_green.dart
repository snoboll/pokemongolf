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

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }

  static ({Club club, int distance, bool isCarry})? _recommendClub(
      List<Club> clubs, double targetMeters) {
    Club? best;
    int? bestDist;
    bool bestIsCarry = false;
    double? bestDiff;

    for (final Club club in clubs) {
      final int? carry = club.carryDistance;
      final int? total = club.totalDistance;
      final int? d = carry ?? total;
      if (d == null) continue;
      final double diff = (d - targetMeters).abs();
      if (bestDiff == null || diff < bestDiff) {
        best = club;
        bestDist = d;
        bestIsCarry = carry != null;
        bestDiff = diff;
      }
    }

    if (best == null || bestDist == null) return null;
    return (club: best, distance: bestDist, isCarry: bestIsCarry);
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

    final clubs = PokemonGolfScope.of(context).clubs;
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
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.sports_golf, size: 14, color: theme.colorScheme.secondary),
                const SizedBox(width: 4),
                Text(
                  '${recommendation.club.name} · ${recommendation.distance}m',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
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
