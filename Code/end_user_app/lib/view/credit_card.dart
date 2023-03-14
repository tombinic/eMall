import 'package:end_user_app/model/end_user.dart';
import 'package:end_user_app/model/payment_method.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_brand.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:end_user_app/controller/api_manager.dart';
import 'package:end_user_app/controller/api_response.dart';

// ignore: must_be_immutable
class CreditCard extends StatefulWidget {
  CreditCard({super.key, this.paymentMethod, required this.endUser});
  PaymentMethod? paymentMethod;
  final EndUser endUser;

  @override
  State<StatefulWidget> createState() => _CreditCardState();
}

class _CreditCardState extends State<CreditCard> {
  bool isCvvFocused = false;
  bool useGlassMorphism = false;
  bool useBackgroundImage = true;
  bool addCard = false;
  String cardNumber = '';
  String cvv = '';
  String expiredDate = '';
  OutlineInputBorder? border;
  ApiResponse _apiResponse = ApiResponse();
  final ApiManager _apiManager = ApiManager();
  bool _isLoading = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    if (widget.paymentMethod == null) {
      setState(() {
        addCard = true;
      });
    } else {
      setState(() {
        addCard = false;
      });
    }
    border = OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.grey.withOpacity(0.7),
        width: 2.0,
      ),
    );
    super.initState();
  }

  void updateUserValue(PaymentMethod newPm) {
    widget.paymentMethod!.cardNumber = newPm.cardNumber;
    widget.paymentMethod!.cvv = newPm.cvv;
    widget.paymentMethod!.expiredDate = newPm.expiredDate;
  }

  AppBar appBarCreditCard(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      title: addCard
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.bolt,
                  color: Color.fromARGB(255, 194, 57, 235),
                  size: 35,
                ),
                Text("Add a credit card"),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.bolt,
                  color: Color.fromARGB(255, 194, 57, 235),
                  size: 35,
                ),
                Text("Credit Card"),
              ],
            ),
      elevation: 0,
      titleTextStyle: const TextStyle(
          color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
      leading: GestureDetector(
        child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_outlined,
              size: 20,
              color: Color.fromARGB(255, 194, 57, 235),
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: appBarCreditCard(context),
        resizeToAvoidBottomInset: false,
        body: Container(
          decoration: BoxDecoration(
            image: !useBackgroundImage
                ? const DecorationImage(
                    image: ExactAssetImage('assets/images/card.png'),
                    fit: BoxFit.fill,
                  )
                : null,
            color: Colors.white,
          ),
          child: SafeArea(
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 10,
                ),
                CreditCardWidget(
                  glassmorphismConfig:
                      useGlassMorphism ? Glassmorphism.defaultConfig() : null,
                  cardNumber: addCard
                      ? cardNumber
                      : widget.paymentMethod!.cardNumber.toString(),
                  expiryDate: addCard
                      ? expiredDate
                      : widget.paymentMethod!.expiredDate.toString(),
                  cardHolderName: widget.endUser.username,
                  cvvCode: addCard ? cvv : widget.paymentMethod!.cvv.toString(),
                  bankName: 'Bank',
                  showBackView: isCvvFocused,
                  obscureCardNumber: false,
                  obscureCardCvv: false,
                  isHolderNameVisible: true,
                  cardBgColor: const Color.fromARGB(255, 194, 57, 235),
                  backgroundImage:
                      useBackgroundImage ? 'assets/images/card.png' : null,
                  isSwipeGestureEnabled: true,
                  onCreditCardWidgetChange:
                      (CreditCardBrand creditCardBrand) {},
                  customCardTypeIcons: <CustomCardTypeIcon>[
                    CustomCardTypeIcon(
                      cardType: CardType.mastercard,
                      cardImage: Image.asset(
                        'assets/images/mastercard.png',
                        height: 48,
                        width: 48,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        CreditCardForm(
                          formKey: formKey,
                          obscureCvv: false,
                          obscureNumber: false,
                          cardNumber: addCard
                              ? ""
                              : widget.paymentMethod!.cardNumber.toString(),
                          cvvCode: addCard
                              ? ""
                              : widget.paymentMethod!.cvv.toString(),
                          isHolderNameVisible: true,
                          isCardNumberVisible: true,
                          isExpiryDateVisible: true,
                          cardHolderName: widget.endUser.username,
                          expiryDate: addCard
                              ? ""
                              : widget.paymentMethod!.expiredDate.toString(),
                          themeColor: Colors.blue,
                          textColor: Colors.black,
                          cardNumberDecoration: InputDecoration(
                            enabled: !addCard ? false : true,
                            labelText: 'Number',
                            hintText: 'XXXX XXXX XXXX XXXX',
                            hintStyle: const TextStyle(color: Colors.black),
                            labelStyle: const TextStyle(color: Colors.black),
                            focusedBorder: border,
                            enabledBorder: border,
                          ),
                          expiryDateDecoration: InputDecoration(
                            enabled: !addCard ? false : true,
                            hintStyle: const TextStyle(color: Colors.black),
                            labelStyle: const TextStyle(color: Colors.black),
                            focusedBorder: border,
                            enabledBorder: border,
                            labelText: 'Expired Date',
                            hintText: 'XX/XX',
                          ),
                          cvvCodeDecoration: InputDecoration(
                            enabled: !addCard ? false : true,
                            hintStyle: const TextStyle(color: Colors.black),
                            labelStyle: const TextStyle(color: Colors.black),
                            focusedBorder: border,
                            enabledBorder: border,
                            labelText: 'CVV',
                            hintText: 'XXX',
                          ),
                          cardHolderDecoration: InputDecoration(
                            enabled: false,
                            hintStyle: const TextStyle(color: Colors.black),
                            labelStyle: const TextStyle(color: Colors.black),
                            focusedBorder: border,
                            enabledBorder: border,
                            labelText: 'Card Holder',
                          ),
                          onCreditCardModelChange: onCreditCardModelChange,
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 10,
                        ),
                        _isLoading
                            ? const CircularProgressIndicator(
                                color: Color.fromARGB(255, 194, 57, 235),
                              )
                            : addCard
                                ? CupertinoPageScaffold(
                                    backgroundColor: Colors.white,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CupertinoButton(
                                            color: const Color.fromARGB(
                                                255, 194, 57, 235),
                                            onPressed: () async {
                                              if (formKey.currentState!
                                                  .validate()) {
                                                setState(() {
                                                  _isLoading = true;
                                                });
                                                _apiResponse = await _apiManager
                                                    .addPaymentMethod(
                                                        widget.endUser,
                                                        PaymentMethod(
                                                            cardNumber,
                                                            cvv,
                                                            expiredDate));

                                                if ((_apiResponse.ApiError) ==
                                                    "") {
                                                  // ignore: use_build_context_synchronously
                                                  Navigator.pop(context);
                                                } else {
                                                  showInSnackBar(_apiResponse
                                                      .ApiError.toString());
                                                }
                                                setState(() {
                                                  _isLoading = false;
                                                });
                                              } else {
                                                //print('invalid!');
                                              }
                                            },
                                            child: const Text(
                                              "Add a new cart",
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : CupertinoPageScaffold(
                                    backgroundColor: Colors.white,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CupertinoButton(
                                            color: const Color.fromARGB(
                                                255, 194, 57, 235),
                                            onPressed: () async {
                                              if (formKey.currentState!
                                                  .validate()) {
                                                setState(() {
                                                  _isLoading = true;
                                                });
                                                _apiResponse =
                                                    await _apiManager.removePaymentMethod(
                                                        widget.endUser,
                                                        PaymentMethod(
                                                            widget
                                                                .paymentMethod!
                                                                .cardNumber,
                                                            widget
                                                                .paymentMethod!
                                                                .cvv,
                                                            widget
                                                                .paymentMethod!
                                                                .expiredDate));

                                                if ((_apiResponse.ApiError) ==
                                                    "") {
                                                  // ignore: use_build_context_synchronously
                                                  Navigator.pop(context);
                                                } else {
                                                  showInSnackBar(_apiResponse
                                                      .ApiError.toString());
                                                }
                                                setState(() {
                                                  _isLoading = false;
                                                });
                                              } else {
                                                //print('invalid!');
                                              }
                                            },
                                            child: const Text(
                                              "Remove cart",
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  void onCreditCardModelChange(CreditCardModel? creditCardModel) {
    setState(() {
      if (widget.paymentMethod != null) {
        widget.paymentMethod!.cardNumber = creditCardModel!.cardNumber;
        widget.paymentMethod!.expiredDate = creditCardModel.expiryDate;
        widget.paymentMethod!.cvv = creditCardModel.cvvCode;
        isCvvFocused = creditCardModel.isCvvFocused;
      } else {
        cardNumber = creditCardModel!.cardNumber;
        cvv = creditCardModel.cvvCode;
        expiredDate = creditCardModel.expiryDate;
        isCvvFocused = creditCardModel.isCvvFocused;
      }
    });
  }
}
