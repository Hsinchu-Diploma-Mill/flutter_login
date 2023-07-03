part of auth_card;

class _RegisterNoticeCard extends StatefulWidget {
  _RegisterNoticeCard(
      {Key? key,
      required this.onAccept,
      this.loginTheme,
      required this.title,
      required this.message,
      this.imageAsset,
      this.mono,
      this.bodyTextAlign})
      : super(key: key);

  final Function onAccept;
  final LoginTheme? loginTheme;

  final String title;
  final String message;
  final String? imageAsset;

  final TextAlign? bodyTextAlign;

  final bool? mono;

  @override
  _RegisterNoticeCardState createState() => _RegisterNoticeCardState();
}

class _RegisterNoticeCardState extends State<_RegisterNoticeCard>
    with SingleTickerProviderStateMixin {
  AnimationController? _submitController;

  @override
  void initState() {
    super.initState();

    _submitController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _submitController!.dispose();
    super.dispose();
  }

  Future<bool> _submit() async {
    await _submitController!.reverse();
    widget.onAccept();
    return true;
  }

  void _decline() async {
    await showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('無法繼續'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('若您不同意條款，將無法使用本應用程式'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('退出應用程式'),
              onPressed: () {
                exit(0);
              },
            ),
            TextButton(
              child: const Text('返回'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  Widget _buildAcceptButton(ThemeData theme, LoginMessages messages) {
    return AnimatedButton(
      controller: _submitController,
      text: messages.acceptButtonText,
      onPressed: _submit,
    );
  }

  Widget _buildDeclineButton(ThemeData theme, LoginMessages messages) {
    return AnimatedButton(
      controller: _submitController,
      text: messages.declineButtonText,
      color: Color(0xFFADADAD),
      onPressed: _decline,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final messages = Provider.of<LoginMessages>(context, listen: false);
    final deviceSize = MediaQuery.of(context).size;
    final cardWidth = min(deviceSize.width * 0.75, 360.0);
    const cardPadding = 16.0;

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
            child: Column(
              children: [
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall,
                ),
                SizedBox(height: 20),
                ConstrainedBox(
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * .4),
                  child: SingleChildScrollView(
                    child: Text(
                      widget.message,
                      key: kRecoverPasswordDescriptionKey,
                      textAlign: widget.bodyTextAlign ?? TextAlign.center,
                      style: widget.mono == true
                          ? TextStyle(
                              fontFeatures: [FontFeature.tabularFigures()])
                          : theme.textTheme.bodyLarge,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                if (widget.imageAsset != null) Image.asset(widget.imageAsset!),
                SizedBox(height: 26),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildDeclineButton(theme, messages),
                      SizedBox(width: 9),
                      _buildAcceptButton(theme, messages),
                    ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
