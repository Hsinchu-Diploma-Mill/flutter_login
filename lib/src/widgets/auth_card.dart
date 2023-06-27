library auth_card;

import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_login/src/regex.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:another_transformer_page_view/another_transformer_page_view.dart';

import 'package:flutter_login/src/models/login_data.dart';
import 'package:flutter_login/src/models/login_user_type.dart';
import 'package:flutter_login/src/providers/auth.dart';
import 'package:flutter_login/src/providers/login_messages.dart';
import 'package:flutter_login/src/providers/login_theme.dart';
import 'package:flutter_login/src/utils/text_field_utils.dart';
import 'package:flutter_login/src/constants.dart';
import 'package:flutter_login/src/dart_helper.dart';
import 'package:flutter_login/src/matrix.dart';
import 'package:flutter_login/src/paddings.dart';
import 'package:flutter_login/src/widget_helper.dart';

import 'animated_button.dart';
import 'animated_icon.dart';
import 'animated_text.dart';
import 'animated_text_form_field.dart';
import 'custom_page_transformer.dart';
import 'expandable_container.dart';
import 'fade_in.dart';

part 'login_card.dart';
part 'recover_card.dart';
part 'register_notice_card.dart';
part 'custom_card.dart';

class AuthCard extends StatefulWidget {
  AuthCard(
      {Key? key,
      required this.userType,
      this.padding = const EdgeInsets.all(0),
      this.loadingController,
      this.userValidator,
      this.passwordValidator,
      this.onSubmit,
      this.onSubmitCompleted,
      this.hideForgotPasswordButton = false,
      this.hideSignUpButton = false,
      this.loginAfterSignUp = true,
      this.hideProvidersTitle = false,
      this.disableCustomPageTransformer = false,
      this.loginTheme,
      this.navigateBackAfterRecovery = false})
      : super(key: key);

  final EdgeInsets padding;
  final AnimationController? loadingController;
  final FormFieldValidator<String>? userValidator;
  final FormFieldValidator<String>? passwordValidator;
  final Function? onSubmit;
  final Function? onSubmitCompleted;
  final bool hideForgotPasswordButton;
  final bool hideSignUpButton;
  final bool loginAfterSignUp;
  final LoginUserType userType;
  final bool hideProvidersTitle;
  final bool disableCustomPageTransformer;
  final LoginTheme? loginTheme;
  final bool navigateBackAfterRecovery;

  @override
  AuthCardState createState() => AuthCardState();
}

class AuthCardState extends State<AuthCard> with TickerProviderStateMixin {
  final GlobalKey _cardKey = GlobalKey();

  var _isLoadingFirstTime = true;
  var _pageIndex = 0;
  static const cardSizeScaleEnd = .2;

  var _isRecovery = false;

  TransformerPageController? _pageController;
  late AnimationController _formLoadingController;
  late AnimationController _routeTransitionController;
  late Animation<double> _flipAnimation;
  late Animation<double> _cardSizeAnimation;
  late Animation<double> _cardSize2AnimationX;
  late Animation<double> _cardSize2AnimationY;
  late Animation<double> _cardRotationAnimation;
  late Animation<double> _cardOverlayHeightFactorAnimation;
  late Animation<double> _cardOverlaySizeAndOpacityAnimation;

  @override
  void initState() {
    super.initState();

    _pageController = TransformerPageController();

    widget.loadingController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _isLoadingFirstTime = false;
        _formLoadingController.forward();
      }
    });

    _flipAnimation = Tween<double>(begin: pi / 2, end: 0).animate(
      CurvedAnimation(
        parent: widget.loadingController!,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeIn,
      ),
    );

    _formLoadingController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1150),
      reverseDuration: Duration(milliseconds: 300),
    );

    _routeTransitionController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1100),
    );

    _cardSizeAnimation = Tween<double>(begin: 1.0, end: cardSizeScaleEnd)
        .animate(CurvedAnimation(
      parent: _routeTransitionController,
      curve: Interval(0, .27272727 /* ~300ms */, curve: Curves.easeInOutCirc),
    ));
    // replace 0 with minPositive to pass the test
    // https://github.com/flutter/flutter/issues/42527#issuecomment-575131275
    _cardOverlayHeightFactorAnimation =
        Tween<double>(begin: double.minPositive, end: 1.0)
            .animate(CurvedAnimation(
      parent: _routeTransitionController,
      curve: Interval(.27272727, .5 /* ~250ms */, curve: Curves.linear),
    ));
    _cardOverlaySizeAndOpacityAnimation =
        Tween<double>(begin: 1.0, end: 0).animate(CurvedAnimation(
      parent: _routeTransitionController,
      curve: Interval(.5, .72727272 /* ~250ms */, curve: Curves.linear),
    ));
    _cardSize2AnimationX =
        Tween<double>(begin: 1, end: 1).animate(_routeTransitionController);
    _cardSize2AnimationY =
        Tween<double>(begin: 1, end: 1).animate(_routeTransitionController);
    _cardRotationAnimation =
        Tween<double>(begin: 0, end: pi / 2).animate(CurvedAnimation(
      parent: _routeTransitionController,
      curve: Interval(.72727272, 1 /* ~300ms */, curve: Curves.easeInOutCubic),
    ));
  }

  @override
  void dispose() {
    _formLoadingController.dispose();
    _pageController!.dispose();
    _routeTransitionController.dispose();
    super.dispose();
  }

  void _switchRecovery(bool recovery) {
    final auth = Provider.of<Auth>(context, listen: false);

    auth.isRecover = recovery;
    if (recovery) {
      _pageController!.nextPage(
        duration: Duration(milliseconds: 500),
        curve: Curves.ease,
      );
      _pageIndex = 1;
      _isRecovery = true;
    } else {
      _pageController!.previousPage(
        duration: Duration(milliseconds: 500),
        curve: Curves.ease,
      );
      _pageIndex = 0;
      _isRecovery = false;
    }
  }

  Future<void>? runLoadingAnimation() {
    if (widget.loadingController!.isDismissed) {
      return widget.loadingController!.forward().then((_) {
        if (!_isLoadingFirstTime) {
          _formLoadingController.forward();
        }
      });
    } else if (widget.loadingController!.isCompleted) {
      return _formLoadingController
          .reverse()
          .then((_) => widget.loadingController!.reverse());
    }
    return null;
  }

  Future<void> _forwardChangeRouteAnimation() {
    final deviceSize = MediaQuery.of(context).size;
    final cardSize = getWidgetSize(_cardKey)!;
    final widthRatio = deviceSize.width / cardSize.height + 1;
    final heightRatio = deviceSize.height / cardSize.width + .25;

    _cardSize2AnimationX =
        Tween<double>(begin: 1.0, end: heightRatio / cardSizeScaleEnd)
            .animate(CurvedAnimation(
      parent: _routeTransitionController,
      curve: Interval(.72727272, 1, curve: Curves.easeInOutCubic),
    ));
    _cardSize2AnimationY =
        Tween<double>(begin: 1.0, end: widthRatio / cardSizeScaleEnd)
            .animate(CurvedAnimation(
      parent: _routeTransitionController,
      curve: Interval(.72727272, 1, curve: Curves.easeInOutCubic),
    ));

    widget.onSubmit!();

    return _formLoadingController
        .reverse()
        .then((_) => _routeTransitionController.forward());
  }

  void _reverseChangeRouteAnimation() {
    _routeTransitionController
        .reverse()
        .then((_) => _formLoadingController.forward());
  }

  void runChangeRouteAnimation() {
    if (_routeTransitionController.isCompleted) {
      _reverseChangeRouteAnimation();
    } else if (_routeTransitionController.isDismissed) {
      _forwardChangeRouteAnimation();
    }
  }

  void runChangePageAnimation() {
    final auth = Provider.of<Auth>(context, listen: false);
    _switchRecovery(!auth.isRecover);
  }

  Widget _buildLoadingAnimator({Widget? child, required ThemeData theme}) {
    Widget card;
    Widget overlay;

    // loading at startup
    card = AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) => Transform(
        transform: Matrix.perspective()..rotateX(_flipAnimation.value),
        alignment: Alignment.center,
        child: child,
      ),
      child: child,
    );

    // change-route transition
    overlay = Padding(
      padding: theme.cardTheme.margin!,
      child: AnimatedBuilder(
        animation: _cardOverlayHeightFactorAnimation,
        builder: (context, child) => ClipPath.shape(
          shape: theme.cardTheme.shape!,
          child: FractionallySizedBox(
            heightFactor: _cardOverlayHeightFactorAnimation.value,
            alignment: Alignment.topCenter,
            child: child,
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(color: theme.colorScheme.secondary),
        ),
      ),
    );

    overlay = ScaleTransition(
      scale: _cardOverlaySizeAndOpacityAnimation,
      child: FadeTransition(
        opacity: _cardOverlaySizeAndOpacityAnimation,
        child: overlay,
      ),
    );

    return Stack(
      children: <Widget>[
        card,
        Positioned.fill(child: overlay),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deviceSize = MediaQuery.of(context).size;

    Widget current = Container(
      height: deviceSize.height,
      width: deviceSize.width,
      padding: widget.padding,
      child: TransformerPageView(
        physics: NeverScrollableScrollPhysics(),
        pageController: _pageController,
        itemCount: 3,

        /// Need to keep track of page index because soft keyboard will
        /// make page view rebuilt
        index: _pageIndex,
        transformer: widget.disableCustomPageTransformer
            ? null
            : CustomPageTransformer(),
        itemBuilder: (BuildContext context, int index) {
          final child = index == 0
              ? _buildLoadingAnimator(
                  theme: theme,
                  child: _LoginCard(
                    key: _cardKey,
                    userType: widget.userType,
                    loadingController: _isLoadingFirstTime
                        ? _formLoadingController
                        : (_formLoadingController..value = 1.0),
                    userValidator: widget.userValidator,
                    passwordValidator: widget.passwordValidator,
                    onSwitchRecoveryPassword: () => _switchRecovery(true),
                    onRegisterNotice: () {
                      _pageController!.nextPage(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.ease,
                      );
                    },
                    onSubmitCompleted: () {
                      _forwardChangeRouteAnimation().then((_) {
                        widget.onSubmitCompleted!();
                      });
                    },
                    hideSignUpButton: widget.hideSignUpButton,
                    hideForgotPasswordButton: widget.hideForgotPasswordButton,
                    loginAfterSignUp: widget.loginAfterSignUp,
                    hideProvidersTitle: widget.hideProvidersTitle,
                  ),
                )
              : index == 1
                  ? _isRecovery
                      ? _RecoverCard(
                          loginTheme: widget.loginTheme,
                          navigateBack: widget.navigateBackAfterRecovery,
                          onSwitchLogin: () => _switchRecovery(false),
                        )
                      : _RegisterNoticeCard(
                          title: '請問您是否同意：',
                          message:
                              '註冊後本帳號所上傳之生態資訊 (包含圖片、時間、地點等)，將依照創用CC授權條款，授權予公眾使用。',
                          onAccept: () {
                            _pageController!.nextPage(
                              duration: Duration(milliseconds: 500),
                              curve: Curves.ease,
                            );
                          },
                        )
                  : index == 2
                      ? _RegisterNoticeCard(
                          title: '姓名標示-非商業性-相同方式分享',
                          message:
                              '本授權條款允許使用者重製、散布、傳輸以及修改著作，但不得為商業目的之使用。若使用者修改該著作時，必須按照授權者所指定的方式來散布該衍生作品，並且將產出之新創著作採用相同的授權條款釋出。',
                          onAccept: () {
                            _pageController!.animateToPage(
                              3,
                              duration: Duration(milliseconds: 500),
                              curve: Curves.ease,
                            );
                          },
                          imageAsset: 'images/cc_notice.png',
                        )
                      : _RegisterNoticeCard(
                          title: '行動應用程式隱私權政策',
                          bodyTextAlign: TextAlign.left,
                          message: '''
歡迎使用台灣中油股份有限公司(以下簡稱本公司)所提供之「BioApp」（以下簡稱本行動應用程式），為了讓您能夠安心的使用本行動應用程式的各項服務與資訊，特此向您說明本行動應用程式的隱私權保護政策，以保障您的權益，請詳閱下列內容：
1、 隱私權保護政策的適用範圍
  隱私權保護政策內容，包括本行動應用程式如何處理在您使用行動應用程式服務時收集到的個人識別資料。隱私權保護政策不適用於本行動應用程式以外的相關連結網站，也不適用於非本行動應用程式所委託或參與管理的人員。

2、 個人資料隱私條款政策事項
  1. 於本行動應用程式註冊成功後，將取得特定帳號(手機號碼)及密碼，您務必維持其帳號與密碼之機密安全，依本行動應用程式輸入帳號及密碼原則，無論是否為本人或藉由他人使用，均視為會員本人使用，利用該帳號進行本行動應用程式一切行動，您需負完全責任。
  2. 帳號及密碼為您使用本服務之權利，請妥善保管您的帳號，不得轉借、轉讓或與他人合用帳號。
  3. 會員有責任保護帳號密碼的機密性，避免您的帳號密碼遭有心人士盜用，非經您的同意、依法律之規定，或本服務銷售(行銷)等目的用途外，絕不會將會員的個人資料透漏予任何與台灣中油股份有限公司無關之第三人。
  4. 若是與他人共享行動電話或使用公共行動電話，請務必記得使用完本行動應用程式後需登出，並建議您不定期更改密碼，若因帳號密碼外洩造成損害，台灣中油股份有限公司將不負任何賠償責任。
  5. 會員若發現並懷疑帳號遭人盜用或不當使用，會員應立即通知本公司，以利採取適當應變措施；經上述措施不得要求本公司對會員負有任何形式之賠償或補償義務。

3、 個人資料的蒐集、處理及利用方式
  當您造訪本行動應用程式或使用本行動應用程式所提供之功能服務時，我們將視該服務功能性質，請您提供必要的個人資料(包括但不限於姓名、行動電話號碼、電子郵件地址、地理位置、聯絡方式及其他依法受保護之資料等)，並在該特定目的範圍內處理及利用您的個人資料。

4、 與第三人共用個人資料之政策
  本行動應用程式絕不會提供、交換、出租或出售任何您的個人資料給其他個人、團體、私人企業或公務機關，但有法律依據或合約義務者，不在此限。前項但書之情形包括不限於：
    1. 經由您書面同意。
    2. 法律明文規定。
    3. 為免除您生命、身體、自由或財產上之危險。
    4. 與公務機關或學術研究機構合作，基於公共利益為統計或學術研究而有必要，且資料經過提供者處理或蒐集者依其揭露方式無從識別特定之當事人。
    5. 當您在行動應用程式的行為，違反服務條款或可能損害或妨礙網站與其他使用者權益或導致任何人遭受損害時，經行動應用程式管理單位研析揭露您的個人資料是為了辨識、聯絡或採取法律行動所必要者。
    6. 有利於您的權益。
    7. 本行動應用程式委託廠商協助蒐集、處理或利用您的個人資料時，將對委外廠商或個人善盡監督管理之責。

5、 服務暫停與中斷
  如下列情況發生時，本公司有權暫停提供行動應用程式服務，直至異常狀況排除：
    1. 會員服務相關軟硬體設備進行搬遷、更換、升級、保養或維修時。
    2. 會員有任何違反政府法令或會員權益情形。
    3. 天災或其他不可抗力因素。
    4. 其他不可歸責於本公司之事由。

6、 免責聲明
  1. 本公司對本行動應用程式服務不提供任何明示或默示之擔保，包括但不限於以下事項： (1.1) 本行動應用程式不受干擾、即時更新、安全可靠或免於出錯。 (1.2) 本行動應用程式使用而取得之結果為正確或可靠。(1.3) 經由本行動應用程式而取得之任何產品、服務、資訊或其他資料將符合您的需求或期望。
  2. 關於本行動應用程式服務之使用下載或取得任何資料應由您自行考量且自負風險，因前述任何資料之下載而導致系統之任何損失或資料流失，您應自負完全責任。

7、 智慧財產權
  本行動應用程式所提供本服務之內容，包括所有軟體、文字、圖片及其他使用者使用本服務所接獲/觸之所有資料，其專利權、著作權、商標、營業秘密、其他智慧財產權、所有權或其他一切權利，均為台灣中油股份有限公司或其權利人所有，概受著作權法、其他智慧財產權法令及其他中華民國及國際法令之保護。

8、 隱私權保護政策之修正
  本行動應用程式隱私權保護政策將因應需求隨時進行修正，修正後的條款將刊登於本行動應用程式上。

9、 準據法與管轄法院
  本隱私條款之解釋與適用，及與本隱私條款有關爭議或使用本行動應用程式所生爭議，均以中華民國法律為準據法，並以台灣台北地方法院為第一審管轄法院同意。
''',
                          onAccept: () {
                            _pageController!.animateToPage(
                              0,
                              duration: Duration(milliseconds: 500),
                              curve: Curves.ease,
                            );
                          },
                        );

          return Align(
            alignment: Alignment.topCenter,
            child: child,
          );
        },
      ),
    );

    return AnimatedBuilder(
      animation: _cardSize2AnimationX,
      builder: (context, snapshot) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..rotateZ(_cardRotationAnimation.value)
            ..scale(_cardSizeAnimation.value, _cardSizeAnimation.value)
            ..scale(_cardSize2AnimationX.value, _cardSize2AnimationY.value),
          child: current,
        );
      },
    );
  }
}
