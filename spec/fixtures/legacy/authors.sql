DROP TABLE IF EXISTS `authors`;
CREATE TABLE `authors` (
  `id` bigint(20) NOT NULL,
  `access_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `first_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `middle_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `alternate_email_address` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `psu_email_address` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `phone_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `address_1` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `address_2` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `city` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `state` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `zip` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_alternate_email_public` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `remember_created_at` datetime DEFAULT NULL,
  `sign_in_count` int(11) NOT NULL DEFAULT '0',
  `current_sign_in_at` datetime DEFAULT NULL,
  `last_sign_in_at` datetime DEFAULT NULL,
  `current_sign_in_ip` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_sign_in_ip` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `country` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `legacy_id` int(11) DEFAULT NULL,
  `is_admin` tinyint(1) DEFAULT NULL,
  `guest` tinyint(1) DEFAULT '0',
  `is_site_admin` tinyint(1) DEFAULT '0',
  `psu_idn` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `confidential_hold` tinyint(1) DEFAULT NULL,
  `confidential_hold_set_at` datetime DEFAULT NULL
);

INSERT INTO `authors` (
  `id`,
  `access_id`,
  `first_name`,
  `last_name`,
  `middle_name`,
  `alternate_email_address`,
  `psu_email_address`,
  `phone_number`,
  `address_1`,
  `address_2`,
  `city`,
  `state`,
  `zip`,
  `is_alternate_email_public`,
  `created_at`,
  `updated_at`,
  `remember_created_at`,
  `sign_in_count`,
  `current_sign_in_at`,
  `last_sign_in_at`,
  `current_sign_in_ip`,
  `last_sign_in_ip`,
  `country`,
  `legacy_id`,
  `is_admin`,
  `guest`,
  `is_site_admin`,
  `psu_idn`,
  `confidential_hold`,
  `confidential_hold_set_at`)
VALUES
	(1, "ggg555", "George", "Great", "The", "ggg@gmail.com", "ggg555@psu.edu", "555-555-5555", "555 Five Dr", "", "FiveCity", "PA", "16805", 0, "2009-11-30", "2016-04-14", NULL, 0, NULL, NULL, NULL, NULL, NULL, 9, NULL, 0, 0, "955555555", NULL, NULL),
	(2, "hhh111", "Henry", "Hamil", "H", "hhh111@gmail.com", "hhh111@psu.edu", "999 999 9999", "999 Nine Lane", "", "State College", "PA", "16801", 1, "2009-11-25", "2011-12-18", NULL, 0, NULL, NULL, NULL, NULL, 13, NULL, 0, 0, NULL, NULL, NULL, NULL),
	(3, "aaa000", "Author", "Andrews", "A.", "aaa@gmail.com", "aaa@psu.edu", "888-888-8888", "888 Eight Drive apt#201", "", "State College", "PA", "16808", 1, "2009-12-01", "2016-04-05", NULL, 0, NULL, NULL, NULL, NULL, 27, NULL, 0, 0, NULL, NULL, NULL, NULL);


