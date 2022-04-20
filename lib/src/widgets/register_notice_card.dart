part of auth_card;

class _RegisterNoticeCard extends StatefulWidget {
  _RegisterNoticeCard(
      {Key? key,
      required this.onAccept,
      this.loginTheme,
      required this.title,
      required this.message,
      this.imageAsset})
      : super(key: key);

  final Function onAccept;
  final LoginTheme? loginTheme;

  final String title;
  final String message;
  final String? imageAsset;

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

  Widget _buildAcceptButton(ThemeData theme, LoginMessages messages) {
    return AnimatedButton(
      controller: _submitController,
      text: messages.acceptButtonText,
      onPressed: _submit,
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
                Text(
                  widget.message,
                  key: kRecoverPasswordDescriptionKey,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyText1,
                ),
                SizedBox(height: 10),
                if (widget.imageAsset != null) Image.asset(widget.imageAsset!),
                SizedBox(height: 26),
                _buildAcceptButton(theme, messages),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
