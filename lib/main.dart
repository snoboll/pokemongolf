import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://cuwcunjtervjelgomeil.supabase.co',
    anonKey: 'sb_publishable_ygSnbzr2KiEAEOmgF9JMQQ_8qz36Qt6',
  );

  runApp(const BogeybeastGolfApp());
}
