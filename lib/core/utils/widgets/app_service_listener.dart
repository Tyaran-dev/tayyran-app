// // lib/core/widgets/app_service_listener.dart
// import 'package:flutter/material.dart';
// import 'package:tayyran_app/core/dependency_injection.dart';
// import 'package:tayyran_app/core/services/app_service.dart';

// class AppServiceListener extends StatefulWidget {
//   final Widget child;

//   const AppServiceListener({super.key, required this.child});

//   @override
//   State<AppServiceListener> createState() => _AppServiceListenerState();
// }

// class _AppServiceListenerState extends State<AppServiceListener> {
//   final AppService _appService = getIt<AppService>();

//   @override
//   void initState() {
//     super.initState();
//     _appService.addListener(_onAppServiceChanged);
//   }

//   @override
//   void dispose() {
//     _appService.removeListener(_onAppServiceChanged);
//     super.dispose();
//   }

//   void _onAppServiceChanged() {
//     if (mounted) {
//       setState(() {});
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return widget.child;
//   }
// }
