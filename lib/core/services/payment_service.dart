import 'package:flutter/material.dart';
import 'package:myfatoorah_flutter/myfatoorah_flutter.dart';

class PaymentService {
  static Future<void> init() async {
    try {
      // Replace with your actual API key and base URL
      MFSDK.init(
        "rLtt6JWvbUHDDhsZnfpAhpYk4dxYDQkbcPTyGaKp2TYqQgG7FGZ5Th_WD53Oq8Ebz6A53njUoo1w3pjU1D4vs_ZMqFiz_j0urb_BH9Oq9VZoKFoJEDAbRZepGcQanImyYrry7Kt6MnMdgfG5jn4HngWoRdKduNNyP4kzcp3mRv7x00ahkm9LAK7ZRieg7k1PDAnBIOG3EyVSJ5kK4WLMvYr7sCwHbHcu4A5WwelxYK0GMJy37bNAarSJDFQsJ2ZvJjvMDmfWwDVFEVe_5tOomfVNt6bOg9mexbGjMrnHBnKnZR1vQbBtQieDlQepzTZMuQrSuKn-t5XZM7V6fCW7oP-uXGX-sMOajeX65JOf6XVpk29DP6ro8WTAflCDANC193yof8-f5_EYY-3hXhJj7RBXmizDpneEQDSaSz5sFk0sV5qPcARJ9zGG73vuGFyenjPPmtDtXtpx35A-BVcOSBYVIWe9kndG3nclfefjKEuZ3m4jL9Gg1h2JBvmXSMYiZtp9MR5I6pvbvylU_PP5xJFSjVTIz7IQSjcVGO41npnwIxRXNRxFOdIUHn0tjQ-7LwvEcTXyPsHXcMD8WtgBh-wxR8aKX7WPSsT1O8d8reb2aR7K3rkV3K82K_0OgawImEpwSvp9MNKynEAJQS6ZHe_J_l77652xwPNxMRTMASk1ZsJL",
        // "eCRJJ2Fz-aS0O4CKzSly7d75kPVyZiBGdqcqQA8L5BqBvXVayiQfX_S01qAJPPGBjVLwW6uZbbzXfixHw5G33tlizcwXoV7DH7CGkOhHTJ43TwAj7FIzJK338jpnMdy1k1-AfbeKSePVNg6umtyD-Vh_4hGxRSb9pxmU_XLyukjKbMY0dV23vFJLHMj82P9GhdGpS0sDh1yGKimB9ztMmhJB03jLbohtMEnBvlutd1v_TVvlYfPqz_BGkuNy0OMXSU67prKGxSEYPRnwr7fA4YvC6J6HJbE_i99q9Fo9foxFu3E404yEDauriK2vLYvRrnJGuLPfWCudOGv2rk40lpkQ34yW1g9CvtjW9eQOxDFHG3RukxsIvpY65bd9tszpp0rzx5pbrcYHARfSsNT88ntf_x0S4nfeip-hzpDwWuxRsIvKGudMhmDdPcfhWIzgo9cTMFQj65IV786zuNSufUg5Eym8l7whheMrC6eFDuAdjXGdWjUsMJKUNQk5hOHv8SGrsHHVQ9Go5nLZK3sEpnX4OzyY9JtpJ8wT24hk44MY-5E84ejrVL2rmwzetzOoEFpUEs_06eyKkAxE4S2IorMkHAu5PUMT0NEZSHxgx4DANlDpzJuXscttxFKsjnKB9sTc0aAwI_gAwrcbmEeDReOEhuXdgx_Xj0cgRXBkAO3wpRJX70JYAdc1RGvAvSnXeH00H09xRji9b5hKzkvHW3a4at-JCliGMQgwwDPZqbd6DhJS",
        MFCountry.SAUDIARABIA,
        MFEnvironment.TEST, // Change to LIVE for production
      );
      initializeAppBar();
    } catch (error) {
      debugPrint(error.toString());
      throw Exception('Payment SDK initialization failed: $error');
    }
  }

  static void initializeAppBar() {
    try {
      MFSDK.setUpActionBar(
        toolBarTitle: 'Tayyran Payment',
        toolBarTitleColor: '#FFFFFF',
        toolBarBackgroundColor: '#016733',
        isShowToolBar: true,
      );
    } catch (e) {
      print('MyFatoorah initialization error: $e');
      rethrow;
    }
  }

  static Future<MFInitiateSessionResponse?> initiateSession({
    String? customerIdentifier,
  }) async {
    try {
      MFInitiateSessionRequest request = MFInitiateSessionRequest();
      if (customerIdentifier != null) {
        request.customerIdentifier = customerIdentifier;
      }
      // CORRECTED: The initiateSession method signature based on your code
      final response = await MFSDK.initiateSession(request, (String bin) {
        print('Card BIN: $bin');
      });
      return response;
    } catch (e) {
      print('Session initiation error: $e');
      return null;
    }
  }

  static Future<MFInitiateSessionResponse?> refreshSession({
    required String currentSessionId,
    String? customerIdentifier,
  }) async {
    try {
      print('Refreshing expired session: $currentSessionId');
      return await initiateSession(customerIdentifier: customerIdentifier);
    } catch (e) {
      print('Session refresh error: $e');
      return null;
    }
  }
}
