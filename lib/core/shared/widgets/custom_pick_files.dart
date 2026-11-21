import 'package:easy_localization/easy_localization.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/material.dart';

import '../../constant/app_assets.dart';
import '../../helper/app_helper.dart';
import '../../style/app_colors.dart';
import '../../style/app_size.dart';
import 'custom_icon.dart';

class CustomPickFiles extends StatelessWidget {
  const CustomPickFiles({
    super.key,
    this.title,
    this.onPick,
    this.onDelete,
    this.description,
    this.selectedFiles,
    this.allowedExtensions,
    required this.allowMultiple,
  });

  final String? title;
  final String? description;
  final bool allowMultiple;
  final List<String>? allowedExtensions;
  final Function(PlatformFile)? onDelete;
  final List<PlatformFile>? selectedFiles;
  final Function(List<PlatformFile>)? onPick;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSize.padding(all: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppSize.getSize(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    title!,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: AppSize.getSize(14),
                      color: AppColors.typographyHeading,
                    ),
                  ),
                ),
                if (allowedExtensions?.isNotEmpty ?? false) ...[
                  SizedBox(width: AppSize.getWidth(8)),
                  Text(
                    '${allowedExtensions?.map((e) => e)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: AppSize.getSize(12),
                      color: AppColors.typographySubtitle,
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: AppSize.getHeight(12)),
          ],
          if (selectedFiles?.isNotEmpty ?? false) ...[
            ...selectedFiles!.asMap().entries.map((entry) {
              return Padding(
                padding: EdgeInsets.only(bottom: AppSize.getHeight(24)),
                child: CustomFileCard(file: entry.value, onDelete: onDelete),
              );
            }),
          ],
          InkWell(
            onTap: () async {
              final files = await AppHelper.pickFiles(
                allowMultiple: allowMultiple,
                allowedExtensions: allowedExtensions,
              );
              if (onPick != null) onPick!(files);
            },
            child: DottedBorder(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: double.infinity),
                  Container(
                    padding: EdgeInsets.all(AppSize.getSize(11)),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(AppSize.getSize(12)),
                    ),
                    child: Icon(
                      Icons.file_upload_outlined,
                      size: AppSize.getSize(24),
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: AppSize.getHeight(16)),
                  Text(
                    allowMultiple
                        ? "core.click_to_upload_files".tr()
                        : "core.click_to_upload_file".tr(),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: AppSize.getSize(14),
                      color: AppColors.typographyHeading,
                    ),
                  ),
                  if (description != null) ...[
                    SizedBox(height: AppSize.getHeight(2)),
                    Text(
                      description!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: AppSize.getSize(12),
                        color: AppColors.typographySubtitle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomFileCard extends StatelessWidget {
  const CustomFileCard({super.key, required this.file, required this.onDelete});

  final PlatformFile file;
  final Function(PlatformFile)? onDelete;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => OpenFile.open(file.path),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.insert_drive_file_outlined,
            size: AppSize.getSize(24),
            color: AppColors.iconPrimary,
          ),
          SizedBox(width: AppSize.getWidth(16)),
          Expanded(
            child: Text(
              '${file.path?.split("/").last}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: AppSize.getSize(14),
                color: AppColors.typographyHeading,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: AppSize.getWidth(16)),
          InkWell(
            onTap: () {
              if (onDelete != null) onDelete!(file);
            },
            child: CustomIcon(
              icon: AppIcons.deleteAttach,
              color: AppColors.iconDanger,
            ),
          ),
        ],
      ),
    );
  }
}
