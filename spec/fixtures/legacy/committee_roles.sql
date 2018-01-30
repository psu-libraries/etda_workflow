DROP TABLE IF EXISTS `committee_roles`;
CREATE TABLE `committee_roles` (
  `id` bigint(20) NOT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `num_required` int(11) NOT NULL DEFAULT '0',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `degree_type_id` bigint(20) NOT NULL);
INSERT INTO `committee_roles` (id, name, num_required, is_active, degree_type_id)
VALUES
(1,
"Dissertation Advisor",
1,
true,
1),
(2,
"Committee Chair",
1,
true,
1),
(3,
"Committee Member",
2,
true,
1);