import "package:iitk_mail_client/Storage/models/email.dart";
import "package:logger/logger.dart";
import "../initializeobjectbox.dart";
import "../../objectbox.g.dart";

final logger = Logger();

List<Email> getFilteredEmails({
  required String searchText,
  required String from,
  required DateTime? dateFrom,
  required DateTime? dateTo,
  required bool unread,
  required bool flagged,
  required bool hasAttachment,
}) {

  logger.i("db filtering emails");

  logger.i("$searchText\t$from\t$dateFrom\t$dateTo");

  final adjustedDateTo = dateTo != null ? dateTo.add(const Duration(days: 1)).subtract(const Duration(seconds: 1)) : null;

  final queryBuilder = objectbox.emailBox.query(
    (Email_.subject.contains(searchText, caseSensitive: false) |
    Email_.body.contains(searchText, caseSensitive: false)) &
    Email_.from.contains(from, caseSensitive: false) &
    (dateFrom != null ? Email_.receivedDate.greaterOrEqual(dateFrom.millisecondsSinceEpoch) : Email_.receivedDate.greaterThan(0)) &
    (adjustedDateTo != null ? Email_.receivedDate.lessOrEqual(adjustedDateTo.millisecondsSinceEpoch) : Email_.receivedDate.lessThan(DateTime.now().millisecondsSinceEpoch)) &
    (unread ? Email_.isRead.equals(false) : Email_.isRead.equals(true) | Email_.isRead.equals(false)) &
    (flagged ? Email_.isFlagged.equals(true) : Email_.isFlagged.equals(false) | Email_.isFlagged.equals(true)) &
    (hasAttachment ? Email_.hasAttachment.equals(true) : Email_.hasAttachment.equals(false) | Email_.hasAttachment.equals(true))
  ).order(Email_.uniqueId, flags: Order.descending);

  final query = queryBuilder.build();
  final emails = query.find();

  query.close();

  return emails;
}
