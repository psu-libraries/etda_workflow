DROP TABLE IF EXISTS `inbound_lion_path_records`;
CREATE TABLE `inbound_lion_path_records` (
  `id` int(20) NOT NULL,
  `author_id` bigint(20) DEFAULT NULL,
  `current_data` text COLLATE utf8mb4_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lion_path_degree_code` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL);
INSERT INTO `inbound_lion_path_records`(
`id`,
`author_id`,
`current_data`,
`created_at`,
`updated_at`,
`lion_path_degree_code`
)
VALUES(1, NULL, NULL, NULL, NULL, NULL);
