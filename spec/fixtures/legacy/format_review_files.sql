DROP TABLE IF EXISTS `format_review_files`;
CREATE TABLE `format_review_files` (
  `id` bigint(20) NOT NULL,
  `submission_id` bigint(20) DEFAULT NULL,
  `asset` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `legacy_id` int(11) DEFAULT NULL);
INSERT INTO `format_review_files`
(id, submission_id, asset, created_at, updated_at, legacy_id) VALUES
(1,
1,
"CarolKingThesisforFormatReview.pdf",
"2016-05-16",
"2016-05-16",
3),
(2,
2,
"FormatUnderReview.pdf",
"2016-05-16",
"2016-05-16",
1005),
(3,
2,
"MathHonorsThesis3.pdf",
"2016-05-16",
"2016-05-16",
381);