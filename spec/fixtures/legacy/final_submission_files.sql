DROP TABLE IF EXISTS `final_submission_files`;
CREATE TABLE `final_submission_files` (
  `id` bigint(20) NOT NULL,
  `submission_id` bigint(20) DEFAULT NULL,
  `asset` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `legacy_id` int(11) DEFAULT NULL);
INSERT INTO `final_submission_files`
(id, submission_id, asset, created_at, updated_at, legacy_id) VALUES
(1,
4,
"FinalSubmissionFile_1.pdf",
"2016-05-16",
"2016-05-16",
9),
(2,
5,
"FinalSubmissionFile_2.pdf",
"2016-05-16",
"2016-05-16",
10),
(3,
6,
"FinalSubmissionFile_3.pdf",
"2016-05-16",
"2016-05-16",
38);