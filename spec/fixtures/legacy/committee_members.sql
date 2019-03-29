DROP TABLE IF EXISTS `committee_members`;
CREATE TABLE `committee_members` (
  `id` bigint(20) NOT NULL,
  `submission_id` bigint(20) DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_required` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `committee_role_id` bigint(20) DEFAULT NULL,
  `legacy_id` int(11) DEFAULT NULL);
INSERT INTO `committee_members` (
id, submission_id, name, email, is_required, created_at, updated_at, committee_role_id, legacy_id)
VALUES(
1,
1,
'Mr. Committee 1',
'mrc1@psu.edu',
1,
'2018-01-01',
'2018-02-01',
1,
NULL),
(2,
1,
'CMember2',
'cmr2@psu.edu',
1,
'2008-01-15',
'2008-02-01',
2,
15);