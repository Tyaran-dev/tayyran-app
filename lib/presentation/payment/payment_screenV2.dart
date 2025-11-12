import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:myfatoorah_flutter/MFUtils.dart';
import 'package:myfatoorah_flutter/myfatoorah_flutter.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreen();
}

class _PaymentScreen extends State<PaymentScreen> {
  String? _response = '';
  MFInitiateSessionResponse? session;

  List<MFPaymentMethod> paymentMethods = [];
  List<bool> isSelected = [];
  int selectedPaymentMethodIndex = -1;

  String amount = "1.00";
  bool visibilityObs = false;
  late MFCardPaymentView mfCardView;
  late MFApplePayButton mfApplePayButton;
  late MFGooglePayButton mfGooglePayButton;

  @override
  void initState() {
    super.initState();
    initiate();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> initiate() async {
    if (Config.testAPIKey.isEmpty) {
      setState(() {
        _response =
            "Missing API Token Key.. You can get it from here: https://myfatoorah.readme.io/docs/test-token";
      });
      return;
    }

    // TODO, don't forget to init the MyFatoorah Plugin with the following line
    await MFSDK.init(
      Config.liveAPIKey,
      MFCountry.SAUDIARABIA,
      MFEnvironment.LIVE,
    );
    // (Optional) un comment the following lines if you want to set up properties of AppBar.
    // MFSDK.setUpActionBar(
    //     toolBarTitle: 'Company Payment',
    //     toolBarTitleColor: '#FFEB3B',
    //     toolBarBackgroundColor: '#CA0404',
    //     isShowToolBar: true);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await initiateSessionForCardView();
      await initiateSessionForGooglePay();
      await initiatePayment();
      // await initiateSession();
    });
  }

  void log(Object object) {
    var json = const JsonEncoder.withIndent('  ').convert(object);
    setState(() {
      debugPrint(json);
      _response = json;
    });
  }

  // Initiate Payment
  Future<void> initiatePayment() async {
    var request = MFInitiatePaymentRequest(
      invoiceAmount: 1,
      currencyIso: MFCurrencyISO.SAUDIARABIA_SAR,
    );

    await MFSDK
        .initiatePayment(request, MFLanguage.ENGLISH)
        .then(
          (value) => {
            log(value),
            paymentMethods.addAll(value.paymentMethods!),
            for (int i = 0; i < paymentMethods.length; i++)
              isSelected.add(false),
          },
        )
        .catchError((error) => {log(error.message)});
  }

  // Execute Regular Payment
  Future<void> executeRegularPayment(int paymentMethodId) async {
    var request = MFExecutePaymentRequest(
      paymentMethodId: paymentMethodId,
      invoiceValue: double.parse(amount),
    );
    request.displayCurrencyIso = MFCurrencyISO.SAUDIARABIA_SAR;

    // var recurring = MFRecurringModel();
    // recurring.intervalDays = 10;
    // recurring.recurringType = MFRecurringType.Custom;
    // recurring.iteration = 2;
    // request.recurringModel = recurring;

    await MFSDK
        .executePayment(request, MFLanguage.ENGLISH, (invoiceId) {
          log(invoiceId);
        })
        .then((value) => log(value))
        .catchError((error) => {log(error.message)});
  }

  void setPaymentMethodSelected(int index, bool value) {
    for (int i = 0; i < isSelected.length; i++) {
      if (i == index) {
        isSelected[i] = value;
        if (value) {
          selectedPaymentMethodIndex = index;
          visibilityObs = paymentMethods[index].isDirectPayment!;
        } else {
          selectedPaymentMethodIndex = -1;
          visibilityObs = false;
        }
      } else {
        isSelected[i] = false;
      }
    }
  }

  void executePayment() {
    if (selectedPaymentMethodIndex == -1) {
      setState(() {
        _response = "Please select payment method first";
      });
    } else {
      if (amount.isEmpty) {
        setState(() {
          _response = "Set the amount";
        });
      } else {
        executeRegularPayment(
          paymentMethods[selectedPaymentMethodIndex].paymentMethodId!,
        );
      }
    }
  }

  MFCardViewStyle cardViewStyle() {
    MFCardViewStyle cardViewStyle = MFCardViewStyle();
    cardViewStyle.cardHeight = 240;
    cardViewStyle.hideCardIcons = false;
    cardViewStyle.backgroundColor = getColorHexFromStr("#ccd9ff");
    cardViewStyle.input?.inputMargin = 3;
    cardViewStyle.label?.display = true;
    cardViewStyle.input?.fontFamily = MFFontFamily.TimesNewRoman;
    cardViewStyle.label?.fontWeight = MFFontWeight.Light;
    cardViewStyle.savedCardText?.saveCardText = "حفظ بيانات البطاقة";
    cardViewStyle.savedCardText?.addCardText = "استخدام كارت اخر";
    MFDeleteAlert deleteAlertText = MFDeleteAlert();
    deleteAlertText.title = "حذف البطاقة";
    deleteAlertText.message = "هل تريد حذف البطاقة";
    deleteAlertText.confirm = "نعم";
    deleteAlertText.cancel = "لا";
    cardViewStyle.savedCardText?.deleteAlertText = deleteAlertText;
    return cardViewStyle;
  }

  Future<void> initiateSessionForCardView() async {
    /*
      If you want to use saved card option with embedded payment, send the parameter
      "customerIdentifier" with a unique value for each customer. This value cannot be used
      for more than one Customer.
     */
    // var request = MFInitiateSessionRequest("12332212");
    /*
      If not, then send null like this.
     */
    MFInitiateSessionRequest initiateSessionRequest = MFInitiateSessionRequest(
      customerIdentifier: "123",
    );

    await MFSDK
        .initSession(initiateSessionRequest, MFLanguage.ENGLISH)
        .then((value) => loadEmbeddedPayment(value))
        .catchError((error) => {log(error.message)});
  }

  void loadCardView(MFInitiateSessionResponse session) {
    mfCardView.load(session, (bin) {
      log(bin);
    });
  }

  Future<void> loadEmbeddedPayment(MFInitiateSessionResponse session) async {
    MFExecutePaymentRequest executePaymentRequest = MFExecutePaymentRequest(
      invoiceValue: 1,
    );
    executePaymentRequest.displayCurrencyIso = MFCurrencyISO.SAUDIARABIA_SAR;
    loadCardView(session);
    if (Platform.isIOS) {
      applePayPayment(session);
    }
  }

  Future<void> applePayPayment(MFInitiateSessionResponse session) async {
    MFExecutePaymentRequest executePaymentRequest = MFExecutePaymentRequest(
      invoiceValue: 1,
    );
    executePaymentRequest.displayCurrencyIso = MFCurrencyISO.SAUDIARABIA_SAR;

    await mfApplePayButton
        .displayApplePayButton(
          session,
          executePaymentRequest,
          MFLanguage.ENGLISH,
        )
        .then(
          (value) => {
            log(value),
            // mfApplePayButton
            //     .executeApplePayButton(null, (invoiceId) => log(invoiceId))
            //     .then((value) => log(value))
            //     .catchError((error) => {log(error.message)})
          },
        )
        .catchError((error) => {log(error.message)});
  }

  Future<void> pay() async {
    var executePaymentRequest = MFExecutePaymentRequest(invoiceValue: 1);
    executePaymentRequest.processingDetails?.autoCapture = false;

    await mfCardView
        .pay(executePaymentRequest, MFLanguage.ENGLISH, (invoiceId) {
          debugPrint("-----------$invoiceId------------");
          log(invoiceId);
        })
        .then((value) => _handlePaymentSuccess(value))
        .catchError((error) => {_handleMFError(error)});
  }

  // GooglePay Section
  Future<void> initiateSessionForGooglePay() async {
    MFInitiateSessionRequest initiateSessionRequest = MFInitiateSessionRequest(
      // A uniquue value for each customer must be added
    );

    await MFSDK
        .initSession(initiateSessionRequest, MFLanguage.ENGLISH)
        .then((value) => {setupGooglePayHelper(value.sessionId)})
        // ignore: invalid_return_type_for_catch_error
        .catchError((error) => {log(error.message)});
  }

  Future<void> setupGooglePayHelper(String sessionId) async {
    MFGooglePayRequest googlePayRequest = MFGooglePayRequest(
      totalPrice: "1",
      merchantId: Config.googleMerchantId,
      merchantName: "Test Vendor",
      countryCode: MFCountry.KUWAIT,
      currencyIso: MFCurrencyISO.UAE_AED,
    );

    await mfGooglePayButton
        .setupGooglePayHelper(sessionId, googlePayRequest, (invoiceId) {
          log("-----------Invoice Id: $invoiceId------------");
        })
        .then((value) => log(value))
        .catchError((error) => {log(error.message)});
  }
  //#region aaa

  //endregion

  // UI Section
  @override
  Widget build(BuildContext context) {
    mfCardView = MFCardPaymentView(cardViewStyle: cardViewStyle());
    mfApplePayButton = MFApplePayButton(applePayStyle: MFApplePayStyle());
    mfGooglePayButton = MFGooglePayButton();

    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          toolbarHeight: 1,
          //   title: const Text('Plugin example app'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Flex(
              direction: Axis.vertical,
              children: [
                Text("Payment Amount", style: textStyle()),
                amountInput(),
                if (Platform.isIOS) applePayView(),
                if (Platform.isAndroid) googlePayButton(),
                embeddedCardView(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        paymentMethodsList(),
                        if (selectedPaymentMethodIndex != -1)
                          btn("Execute Payment", executePayment),
                        btn("Reload GooglePay", initiateSessionForGooglePay),
                        ColoredBox(
                          color: const Color(0xFFD8E5EB),
                          child: SelectableText.rich(
                            TextSpan(
                              text: _response!,
                              style: const TextStyle(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget embeddedCardView() {
    return Column(
      children: [
        SizedBox(height: 180, child: mfCardView),
        Row(
          children: [
            const SizedBox(width: 2),
            Expanded(child: elevatedButton("Pay", pay)),
            const SizedBox(width: 2),
            elevatedButton("", initiateSessionForCardView),
          ],
        ),
      ],
    );
  }

  Widget applePayView() {
    return Column(children: [SizedBox(height: 50, child: mfApplePayButton)]);
  }

  Widget googlePayButton() {
    return SizedBox(height: 70, child: mfGooglePayButton);
  }

  Widget paymentMethodsList() {
    return Column(
      children: [
        Text("Select payment method", style: textStyle()),
        SizedBox(
          height: 85,
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: paymentMethods.length,
            itemBuilder: (BuildContext ctxt, int index) {
              return paymentMethodsItem(ctxt, index);
            },
          ),
        ),
      ],
    );
  }

  Widget paymentMethodsItem(BuildContext ctxt, int index) {
    return SizedBox(
      width: 70,
      height: 75,
      child: Container(
        decoration: isSelected[index]
            ? BoxDecoration(
                border: Border.all(color: Colors.blueAccent, width: 2),
              )
            : const BoxDecoration(),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Column(
            children: <Widget>[
              Image.network(paymentMethods[index].imageUrl!, height: 35.0),
              SizedBox(
                height: 24.0,
                width: 24.0,
                child: Checkbox(
                  checkColor: Colors.blueAccent,
                  activeColor: const Color(0xFFC9C5C5),
                  value: isSelected[index],
                  onChanged: (bool? value) {
                    setState(() {
                      setPaymentMethodSelected(index, value!);
                    });
                  },
                ),
              ),
              Text(
                paymentMethods[index].paymentMethodEn ?? "",
                style: TextStyle(
                  fontSize: 8.0,
                  fontWeight: isSelected[index]
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget btn(String title, Function onPressed) {
    return SizedBox(
      width: double.infinity, // <-- match_parent
      child: elevatedButton(title, onPressed),
    );
  }

  Widget elevatedButton(String title, Function onPressed) {
    return ElevatedButton(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
        backgroundColor: WidgetStateProperty.all<Color>(
          const Color(0xff0495ca),
        ),
        shape: WidgetStateProperty.resolveWith<RoundedRectangleBorder>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.pressed)) {
            return RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: const BorderSide(color: Colors.red, width: 1.0),
            );
          } else {
            return RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: const BorderSide(color: Colors.white, width: 1.0),
            );
          }
        }),
      ),
      child: (title.isNotEmpty)
          ? Text(title, style: textStyle())
          : const Icon(Icons.refresh),
      onPressed: () async {
        await onPressed();
      },
    );
  }

  Widget amountInput() {
    return TextField(
      style: const TextStyle(color: Colors.white),
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      controller: TextEditingController(text: amount),
      decoration: const InputDecoration(
        filled: true,
        fillColor: Color(0xff0495ca),
        hintText: "0.00",
        contentPadding: EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 1.0),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 1.0),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
      onChanged: (value) {
        amount = value;
      },
    );
  }

  TextStyle textStyle() {
    return const TextStyle(fontSize: 16.0, fontStyle: FontStyle.italic);
  }
}

void logObject(Object object) {
  var json = const JsonEncoder.withIndent('  ').convert(object);
  debugPrint(json);
}

void _handlePaymentSuccess(MFGetPaymentStatusResponse response) {
  debugPrint("💰 PAYMENT SUCCESS HANDLER:");
  debugPrint("   Invoice ID: ${response.invoiceId}");
  debugPrint("   Is Direct Payment: ${response.depositStatus}");
  debugPrint("   invoiceStatus: ${response.invoiceStatus}");
  debugPrint("   Customer Reference: ${response.customerReference}");
  logObject(response);

  // Update UI state, navigate to success screen, etc.
  // setState(() {
  //   _paymentStatus = PaymentStatus.success;
  // });
}

void _handleMFError(MFError error) {
  debugPrint("🛑 MFError Handler:");
  debugPrint("   Code: ${error.code}");
  debugPrint("   Message: ${error.message}");
  logObject(error);
  // Handle specific error codes
  switch (error.code) {
    case '100':
      debugPrint("   ❌ Invalid session ID");
      // Handle session expiration
      break;
    case '200':
      debugPrint("   ❌ Payment method not available");
      break;
    case '300':
      debugPrint("   ❌ Insufficient funds");
      break;
    case '400':
      debugPrint("   ❌ Card declined");
      break;
    default:
      debugPrint("   ❌ Unknown error code: ${error.code}");
      break;
  }
}

// Dummy Config class for API key
class Config {
  static const String testAPIKey =
      "rLtt6JWvbUHDDhsZnfpAhpYk4dxYDQkbcPTyGaKp2TYqQgG7FGZ5Th_WD53Oq8Ebz6A53njUoo1w3pjU1D4vs_ZMqFiz_j0urb_BH9Oq9VZoKFoJEDAbRZepGcQanImyYrry7Kt6MnMdgfG5jn4HngWoRdKduNNyP4kzcp3mRv7x00ahkm9LAK7ZRieg7k1PDAnBIOG3EyVSJ5kK4WLMvYr7sCwHbHcu4A5WwelxYK0GMJy37bNAarSJDFQsJ2ZvJjvMDmfWwDVFEVe_5tOomfVNt6bOg9mexbGjMrnHBnKnZR1vQbBtQieDlQepzTZMuQrSuKn-t5XZM7V6fCW7oP-uXGX-sMOajeX65JOf6XVpk29DP6ro8WTAflCDANC193yof8-f5_EYY-3hXhJj7RBXmizDpneEQDSaSz5sFk0sV5qPcARJ9zGG73vuGFyenjPPmtDtXtpx35A-BVcOSBYVIWe9kndG3nclfefjKEuZ3m4jL9Gg1h2JBvmXSMYiZtp9MR5I6pvbvylU_PP5xJFSjVTIz7IQSjcVGO41npnwIxRXNRxFOdIUHn0tjQ-7LwvEcTXyPsHXcMD8WtgBh-wxR8aKX7WPSsT1O8d8reb2aR7K3rkV3K82K_0OgawImEpwSvp9MNKynEAJQS6ZHe_J_l77652xwPNxMRTMASk1ZsJL";
  static const String liveAPIKey =
      "eCRJJ2Fz-aS0O4CKzSly7d75kPVyZiBGdqcqQA8L5BqBvXVayiQfX_S01qAJPPGBjVLwW6uZbbzXfixHw5G33tlizcwXoV7DH7CGkOhHTJ43TwAj7FIzJK338jpnMdy1k1-AfbeKSePVNg6umtyD-Vh_4hGxRSb9pxmU_XLyukjKbMY0dV23vFJLHMj82P9GhdGpS0sDh1yGKimB9ztMmhJB03jLbohtMEnBvlutd1v_TVvlYfPqz_BGkuNy0OMXSU67prKGxSEYPRnwr7fA4YvC6J6HJbE_i99q9Fo9foxFu3E404yEDauriK2vLYvRrnJGuLPfWCudOGv2rk40lpkQ34yW1g9CvtjW9eQOxDFHG3RukxsIvpY65bd9tszpp0rzx5pbrcYHARfSsNT88ntf_x0S4nfeip-hzpDwWuxRsIvKGudMhmDdPcfhWIzgo9cTMFQj65IV786zuNSufUg5Eym8l7whheMrC6eFDuAdjXGdWjUsMJKUNQk5hOHv8SGrsHHVQ9Go5nLZK3sEpnX4OzyY9JtpJ8wT24hk44MY-5E84ejrVL2rmwzetzOoEFpUEs_06eyKkAxE4S2IorMkHAu5PUMT0NEZSHxgx4DANlDpzJuXscttxFKsjnKB9sTc0aAwI_gAwrcbmEeDReOEhuXdgx_Xj0cgRXBkAO3wpRJX70JYAdc1RGvAvSnXeH00H09xRji9b5hKzkvHW3a4at-JCliGMQgwwDPZqbd6DhJS";
  static const String googleMerchantId = "your_google_merchant_id";
}
