DROP TABLE IF EXISTS `degrees`;
CREATE TABLE `degrees` (
  `id` bigint(20) NOT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `degree_type_id` bigint(20) NOT NULL,
  `legacy_id` int(11) DEFAULT NULL,
  `legacy_old_id` int(11) DEFAULT NULL
);
INSERT INTO `degrees` (id, name, description, is_active, created_at, updated_at, degree_type_id, legacy_id, legacy_old_id)
VALUES
(1,
"PHD",
"Doctor of Philosophy",
true,
"2008-09-02",
"2011-12-18",
1,
11,
1),
(2,
"Electrical Engineering",
"Master of Science",
false,
"2016-05-16",
"2016-09-14",
2,
23,
0);