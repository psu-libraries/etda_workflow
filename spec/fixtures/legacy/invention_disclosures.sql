DROP TABLE IF EXISTS `invention_disclosures`;
CREATE TABLE `invention_disclosures` (
  `id` bigint(20) NOT NULL,
  `submission_id` bigint(20) DEFAULT NULL,
  `id_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL);
INSERT INTO `invention_disclosures` (id, submission_id, id_number, created_at, updated_at)
VALUES
(1,
1,
'2016-1234',
'2016-01-01',
'2017-02-02'),
(2,
2,
'2018-abc',
'2018-01-01',
'2018-02-02');