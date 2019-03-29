DROP TABLE IF EXISTS `keywords`;
CREATE TABLE `keywords` (
  `id` bigint(20) NOT NULL,
  `submission_id` bigint(20) DEFAULT NULL,
  `word` text COLLATE utf8mb4_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `legacy_id` int(11) DEFAULT NULL);
INSERT INTO `keywords` (
id, submission_id, word, created_at, updated_at, legacy_id)
VALUES
(1,
1,
"LEZOOMPC",
"2003-03-20",
"2011-12-18",
4574),
(2,
1,
"Phase Configuration change",
"2003-03-20",
"2011-12-18",
4575),
(3,
1,
"Fractional flow formulation",
"2003-03-20",
"2001-12-18",
4576);