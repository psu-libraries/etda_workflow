DROP TABLE IF EXISTS `degree_types`;
CREATE TABLE `degree_types` (
  `id` bigint(20) NOT NULL,
  `name` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL);
INSERT INTO `degree_types`
(`id`,
`name`,
`slug`)
VALUES
(1,
"Dissertation",
"dissertation"),
(2,
"Master Thesis",
"master_thesis");