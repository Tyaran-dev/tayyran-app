// // lib/core/widgets/app_service_builder.dart
// import 'package:flutter/material.dart';
// import 'package:tayyran_app/core/dependency_injection.dart';
// import 'package:tayyran_app/core/services/app_service.dart';

// class AppServiceBuilder extends StatefulWidget {
//   final Widget Function(BuildContext context, AppService appService) builder;

//   const AppServiceBuilder({super.key, required this.builder});

//   @override
//   State<AppServiceBuilder> createState() => _AppServiceBuilderState();
// }

// class _AppServiceBuilderState extends State<AppServiceBuilder> {
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
//     return widget.builder(context, _appService);
//   }
// }
