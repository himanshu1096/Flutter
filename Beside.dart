title: Row(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    icon,
    Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: SizedBox(child: Text(title, style: textStyle)),
    ),
    if (subtitleNote != null) ...[
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          subtitleNote!,
          style: TextStyle(
            fontSize: 14.0,
            color: fontColor,
            height: 1.0,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        ),
      ),
    ],
  ],
),
