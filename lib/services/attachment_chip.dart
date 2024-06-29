// import 'package:enough_mail/enough_mail.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:enough_mail_flutter/enough_mail_flutter.dart';
// import 'package:iitk_mail_client/EmailCache/models/message.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:iitk_mail_client/pages/media_screen.dart';
// import 'package:logger/logger.dart';
// import 'package:enough_platform_widgets/enough_platform_widgets.dart';

// class AttachmentChip extends StatefulHookConsumerWidget {
//   const AttachmentChip({super.key, required this.info, required this.message});
//   final ContentInfo info;
//   final Message message;

//   @override
//   ConsumerState<AttachmentChip> createState() => _AttachmentChipState();
// }

// class _AttachmentChipState extends ConsumerState<AttachmentChip> {
//   MimePart? _mimePart;
//   bool _isDownloading = false;
//   MediaProvider? _mediaProvider;
//   final _width = 72.0;
//   final _height = 72.0;
//   final logger = Logger();

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     final mimeMessage = widget.message.mimeMessage;
//     _mimePart = mimeMessage.getPart(widget.info.fetchId);
//     if (_mimePart != null) {
//       try {
//         _mediaProvider =
//             MimeMediaProviderFactory.fromMime(mimeMessage, _mimePart!);
//       } catch (e, s) {
//         // _mediaProvider = MimeMediaProviderFactory.fromError(
//         //   title: ref.text.errorTitle,
//         //   text: ref.text.attachmentDecodeError(e.toString()),
//         // );
//         logger.e('Unable to decode mime-part: $e');
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final mediaType = widget.info.contentType?.mediaType;
//     final name = widget.info.fileName;
//     final mediaProvider = _mediaProvider;

//     if (mediaProvider == null) {
//       final fallbackIcon = IconService.instance.getForMediaType(mediaType);
//       return PlatformTextButton(
//         onPressed: _isDownloading ? null : _download,
//         child: Padding(
//           padding: const EdgeInsets.all(4),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: _buildPreviewWidget(true, fallbackIcon, name),
//           ),
//         ),
//       );
//     } else {
//       return Padding(
//         padding: const EdgeInsets.all(4),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(8),
//           child: PreviewMediaWidget(
//             mediaProvider: mediaProvider,
//             width: _width,
//             height: _height,
//             //showInteractiveDelegate: _showAttachment,
//             fallbackBuilder: _buildFallbackPreview,
//             interactiveFallbackBuilder: _buildInteractiveFallback,
//             useHeroAnimation: false,
//           ),
//         ),
//       );
//     }
//   }

//   Widget _buildFallbackPreview(BuildContext context, MediaProvider provider) {
//     final fallbackIcon = IconService.instance
//         .getForMediaType(MediaType.fromText(provider.mediaType));
//     return _buildPreviewWidget(false, fallbackIcon, provider.name);
//   }

//   Widget _buildPreviewWidget(
//       bool includeDownloadOption, IconData iconData, String? name) {
//     return SizedBox(
//       width: _width,
//       height: _height,
//       child: Stack(
//         children: [
//           Icon(iconData, size: _width, color: Colors.grey[700]),
//           if (name != null)
//             Align(
//               alignment: Alignment.bottomLeft,
//               child: Container(
//                 width: _width,
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [Color(0x00000000), Color(0xff000000)],
//                   ),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(4),
//                   child: Text(
//                     name,
//                     overflow: TextOverflow.fade,
//                     style: const TextStyle(fontSize: 8, color: Colors.white),
//                   ),
//                 ),
//               ),
//             ),
//           if (includeDownloadOption) ...[
//             Align(
//               alignment: Alignment.topLeft,
//               child: Container(
//                 width: _width,
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.bottomCenter,
//                     end: Alignment.topCenter,
//                     colors: [Color(0x00000000), Color(0xff000000)],
//                   ),
//                 ),
//                 child: const Padding(
//                   padding: EdgeInsets.all(4),
//                   child: Icon(Icons.download_rounded, color: Colors.white),
//                 ),
//               ),
//             ),
//             if (_isDownloading)
//               const Center(child: PlatformProgressIndicator()),
//           ],
//         ],
//       ),
//     );
//   }

//   Future _download() async {
//     // if (_isDownloading) return;
//     // setState(() {
//     //   _isDownloading = true;
//     // });
//     // try {
//     //   final fetchId = widget.message.uniqueId; // Assuming widget.info has fetchId
//     // final mimePart = await fetchMessagePart(widget.message, fetchId: fetchId);
//     //   _mimePart = mimePart;
//     //   _mediaProvider = MimeMediaProviderFactory.fromMime(
//     //     widget.message.mimeMessage,
//     //     mimePart,
//     //   );
//     //   final media = InteractiveMediaWidget(
//     //     mediaProvider: _mediaProvider!,
//     //     builder: _buildInteractiveMedia,
//     //     fallbackBuilder: _buildInteractiveFallback,
//     //   );
//     //   await _showAttachment(media);
//     // } on MailException catch (e) {
//     //   logger.e('Unable to download attachment: $e');
//     //   if (context.mounted) {
//     //     await LocalizedDialogHelper.showTextDialog(
//     //       ref,
//     //       ref.text.errorTitle,
//     //       ref.text.attachmentDownloadError(e.message ?? e.toString()),
//     //     );
//     //   }
//     // } finally {
//     //   if (mounted) {
//     //     setState(() {
//     //       _isDownloading = false;
//     //     });
//     //   }
//     // }
//   }

//   // Future _showAttachment(InteractiveMediaWidget media) {
//   //   if (_mimePart?.mediaType.sub == MediaSubtype.messageRfc822) {
//   //     final mime = _mimePart?.decodeContentMessage();
//   //     if (mime != null) {
//   //       //final message = Message.embedded(mime, widget.message);
//   //       return context.pushNamed(Routes.mailDetails, extra: message);
//   //     }
//   //   }
//   //   return context.pushNamed(Routes.interactiveMedia, extra: media);
//   // }

//   Widget _buildInteractiveFallback(
//       BuildContext context, MediaProvider mediaProvider) {
//     final sizeText = formatMemory(
//         mediaProvider.size, Localizations.localeOf(context).toString());
//     final iconData = IconService.instance
//         .getForMediaType(MediaType.fromText(mediaProvider.mediaType));
//     return Material(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Padding(padding: const EdgeInsets.all(8), child: Icon(iconData)),
//             Text(mediaProvider.name,
//                 style: Theme.of(context).textTheme.titleLarge),
//             if (sizeText != null)
//               Padding(padding: const EdgeInsets.all(8), child: Text(sizeText)),
//             PlatformTextButton(
//               child: Text("HI!"), //ref.text.attachmentActionOpen
//               onPressed: () => InteractiveMediaScreen.share(mediaProvider),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class IconService {
//   IconService._();

//   static final _instance = IconService._();

//   /// Returns the singleton instance
//   static IconService get instance => _instance;

//   static final _isCupertino = PlatformInfo.isCupertino;

//   // Icon getters for various icons
//   IconData get share => _isCupertino ? CupertinoIcons.share : Icons.share;
//   IconData get location =>
//       _isCupertino ? CupertinoIcons.location : Icons.location_on_outlined;
//   IconData get email => _isCupertino ? CupertinoIcons.mail : Icons.email;
//   // Add more icon getters as needed

//   // Utility methods for getting icons based on media type, mailbox, etc.
//   IconData getForMediaType(MediaType? mediaType) {
//     if (mediaType == null) {
//       return Icons.attachment;
//     }
//     switch (mediaType.top) {
//       case MediaToptype.text:
//         return Icons.short_text;

//       case MediaToptype.image:
//         return Icons.image;

//       case MediaToptype.audio:
//         return Icons.audiotrack;

//       case MediaToptype.video:
//         return Icons.ondemand_video;

//       case MediaToptype.application:
//         return Icons.apps;

//       case MediaToptype.multipart:
//         return Icons.apps;

//       case MediaToptype.message:
//         return Icons.message;

//       case MediaToptype.model:
//         return Icons.attachment;

//       case MediaToptype.font:
//         return Icons.font_download;

//       case MediaToptype.other:
//         return Icons.attachment;

//       // ignore: no_default_cases
//       default:
//         return Icons.attachment;
//     }
//   }

//   // IconData getForMailbox(Mailbox mailbox) {
//   //   var iconData = folderGeneric;
//   //   if (mailbox.isInbox) {
//   //     iconData = folderInbox;
//   //   } else if (mailbox.isDrafts) {
//   //     iconData = folderDrafts;
//   //   } else if (mailbox.isTrash) {
//   //     iconData = folderTrash;
//   //   } else if (mailbox.isSent) {
//   //     iconData = folderSent;
//   //   } else if (mailbox.isArchive) {
//   //     iconData = folderArchive;
//   //   } else if (mailbox.isJunk) {
//   //     iconData = folderJunk;
//   //   }

//   //   return iconData;
//   // }

//   static Widget buildNumericIcon(
//     BuildContext context,
//     int value, {
//     double? size,
//   }) {
//     switch (value) {
//       case 1:
//         return Icon(Icons.looks_one_outlined, size: size);
//       case 2:
//         return Icon(Icons.looks_two_outlined, size: size);
//       case 3:
//         return Icon(Icons.looks_3_outlined, size: size);
//       case 4:
//         return Icon(Icons.looks_4_outlined, size: size);
//       case 5:
//         return Icon(Icons.looks_5_outlined, size: size);
//       case 6:
//         return Icon(Icons.looks_6_outlined, size: size);
//       default:
//         final style = size == null ? null : TextStyle(fontSize: size * 0.8);
//         final borderColor = (Theme.of(context).brightness == Brightness.dark)
//             ? const Color(0xffeeeeee)
//             : const Color(0xff000000);
//         return Container(
//           decoration: BoxDecoration(border: Border.all(color: borderColor)),
//           child: Text(value.toString(), style: style),
//         );
//     }
//   }
// }
