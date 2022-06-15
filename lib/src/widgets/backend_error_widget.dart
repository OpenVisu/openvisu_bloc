import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:openvisu_repository/openvisu_repository.dart';
import 'package:universal_html/html.dart' as html;
import 'package:universal_html/parsing.dart' as parser;

class BackendErrorStateWidget extends StatelessWidget {
  final Function? onReload;
  final BackendErrorInformation info;

  const BackendErrorStateWidget({
    Key? key,
    this.onReload,
    required this.info,
  }) : super(key: key);

  TextSpan _buildYiiExceptionMessage(
      BuildContext context, YiiExceptionInformation info) {
    return TextSpan(
      style: DefaultTextStyle.of(context).style,
      children: <TextSpan>[
        TextSpan(
          text: '${info.name}\n',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(text: 'Type: ${info.type}\n'),
        TextSpan(
          text: '${info.message}\n',
        ),
        TextSpan(
          text: '${info.file} (Line: ${info.line})\n',
        ),
        TextSpan(text: 'Code: ${info.code}\n'),
      ],
    );
  }

  TextSpan _buildYiiUnprocessableEntityInformation(
    BuildContext context,
    YiiUnprocessableEntityInformation info,
  ) {
    return TextSpan(
      style: DefaultTextStyle.of(context).style,
      children: <TextSpan>[
        const TextSpan(
          text: 'The data could not be saved:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        for (final String fieldName in info.errors.keys) ...{
          TextSpan(
            text: '\n - $fieldName: ',
          ),
          TextSpan(
            text: info.errors[fieldName]!.join(', '),
          ),
        }
      ],
    );
  }

  TextSpan _buildHtmlError(BuildContext context, final HtmlError info) {
    html.Document document = parser.parseHtmlDocument(info.html);
    String? title = document.getElementsByTagName('title').first.text;
    return TextSpan(
      style: DefaultTextStyle.of(context).style,
      children: <TextSpan>[
        TextSpan(
          text: 'HtmlError: $title',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ), /*
        TextSpan(
          text: '\n${info.html}',
        ),*/
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    TextSpan alertMessage =
        TextSpan(text: 'Format for ${info.toString()} not yet implemented');
    if (info is YiiExceptionInformation) {
      alertMessage =
          _buildYiiExceptionMessage(context, info as YiiExceptionInformation);
    } else if (info is YiiErrorInformation) {
      alertMessage = const TextSpan(text: 'TODO YiiErrorInformation');
    } else if (info is YiiUnprocessableEntityInformation) {
      alertMessage = _buildYiiUnprocessableEntityInformation(
          context, info as YiiUnprocessableEntityInformation);
    } else if (info is HtmlError) {
      alertMessage = _buildHtmlError(context, info as HtmlError);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          color: Colors.red.shade300,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: RichText(text: alertMessage),
          ),
        ),
        if (onReload != null)
          Center(
            child: TextButton(
              onPressed: () => onReload!(),
              child: const FaIcon(FontAwesomeIcons.arrowRotateRight),
            ),
          ),
      ],
    );
  }
}
