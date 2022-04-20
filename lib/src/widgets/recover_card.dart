part of auth_card;

class _RecoverCard extends StatefulWidget {
  _RecoverCard(
      {Key? key,
      required this.onSwitchLogin,
      this.loginTheme,
      required this.navigateBack})
      : super(key: key);

  final Function onSwitchLogin;
  final LoginTheme? loginTheme;
  final bool navigateBack;

  @override
  _RecoverCardState createState() => _RecoverCardState();
}

class _RecoverCardState extends State<_RecoverCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formRecoverKey = GlobalKey();

  TextEditingController? _nameController;

  var _isSubmitting = false;

  AnimationController? _submitController;

  @override
  void initState() {
    super.initState();

    final auth = Provider.of<Auth>(context, listen: false);
    _nameController = TextEditingController(text: auth.email_addr);

    _submitController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _submitController!.dispose();
    super.dispose();
  }

  Future<bool> _submit() async {
    if (!_formRecoverKey.currentState!.validate()) {
      return false;
    }
    final auth = Provider.of<Auth>(context, listen: false);
    final messages = Provider.of<LoginMessages>(context, listen: false);

    _formRecoverKey.currentState!.save();
    await _submitController!.forward();
    setState(() => _isSubmitting = true);
    final error = await auth.onRecoverPassword!(auth.email_addr);

    if (error != null) {
      showErrorToast(context, messages.flushbarTitleError, error);
      setState(() => _isSubmitting = false);
      await _submitController!.reverse();
      return false;
    } else {
      showSuccessToast(context, messages.flushbarTitleSuccess,
          messages.recoverPasswordSuccess);
      setState(() => _isSubmitting = false);
      await _submitController!.reverse();
      if (widget.navigateBack) widget.onSwitchLogin();
      return true;
    }
  }

  Widget _buildRecoverNameField(
      double width, LoginMessages messages, Auth auth) {
    return AnimatedTextFormField(
      controller: _nameController,
      width: width,
      labelText: messages.emailHint,
      prefixIcon: Icon(Icons.email),
      keyboardType: TextFieldUtils.getKeyboardType(LoginUserType.email),
      autofillHints: [TextFieldUtils.getAutofillHints(LoginUserType.email)],
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (value) => _submit(),
      validator: (value) {
        if (value!.isEmpty || !Regex.email.hasMatch(value)) {
          return messages.emailError;
        }
        return null;
      },
      onSaved: (value) => auth.email_addr = value!,
    );
  }

  Widget _buildRecoverButton(ThemeData theme, LoginMessages messages) {
    return AnimatedButton(
      controller: _submitController,
      text: messages.recoverPasswordButton,
      onPressed: !_isSubmitting ? _submit : null,
    );
  }

  Widget _buildBackButton(
      ThemeData theme, LoginMessages messages, LoginTheme? loginTheme) {
    final calculatedTextColor =
        (theme.cardTheme.color!.computeLuminance() < 0.5)
            ? Colors.white
            : theme.primaryColor;
    return MaterialButton(
      onPressed: !_isSubmitting
          ? () {
              _formRecoverKey.currentState!.save();
              widget.onSwitchLogin();
            }
          : null,
      padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textColor: loginTheme?.switchAuthTextColor ?? calculatedTextColor,
      child: Text(messages.goBackButton),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<Auth>(context, listen: false);
    final messages = Provider.of<LoginMessages>(context, listen: false);
    final deviceSize = MediaQuery.of(context).size;
    final cardWidth = min(deviceSize.width * 0.75, 360.0);
    const cardPadding = 16.0;
    final textFieldWidth = cardWidth - cardPadding * 2;

    return FittedBox(
      child: Card(
        child: Container(
          padding: const EdgeInsets.only(
            left: cardPadding,
            top: cardPadding + 10.0,
            right: cardPadding,
            bottom: cardPadding,
          ),
          width: cardWidth,
          alignment: Alignment.center,
          child: Form(
            key: _formRecoverKey,
            child: Column(
              children: [
                Text(
                  messages.recoverPasswordIntro,
                  key: kRecoverPasswordIntroKey,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyText2,
                ),
                SizedBox(height: 20),
                _buildRecoverNameField(textFieldWidth, messages, auth),
                SizedBox(height: 20),
                Text(
                  messages.recoverPasswordDescription,
                  key: kRecoverPasswordDescriptionKey,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyText2,
                ),
                SizedBox(height: 26),
                _buildRecoverButton(theme, messages),
                _buildBackButton(theme, messages, widget.loginTheme),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
