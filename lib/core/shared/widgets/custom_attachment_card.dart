import 'package:flutter/material.dart';

import '../../helper/app_helper.dart';
import '../../style/app_colors.dart';
import '../../style/app_size.dart';

class AttachmentFileCard extends StatelessWidget {
  const AttachmentFileCard({super.key, required this.file, this.serve = false});

  final bool serve;
  final String file;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => AppHelper.downloadAndOpenFile(file, serve: serve),
      child: Row(
        children: [
          Icon(Icons.file_present, size: AppSize.getSize(20)),
          SizedBox(width: AppSize.getWidth(12)),
          Expanded(
            child: Text(
              file.split('/').last,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: AppSize.getSize(12),
                color: AppColors.typographyHeading,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
