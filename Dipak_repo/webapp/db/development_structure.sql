CREATE TABLE `activity_categories` (
  `id` varchar(36) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `activity_logs` (
  `id` varchar(36) NOT NULL,
  `activity_category_id` varchar(255) DEFAULT NULL,
  `user_id` varchar(36) DEFAULT NULL,
  `profile_id` varchar(36) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `session_id` varchar(255) DEFAULT NULL,
  `ip_address` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `seller_profile_id` varchar(36) DEFAULT NULL,
  `seller_profile_name` varchar(255) DEFAULT NULL,
  `profile_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `activity_category_id` (`activity_category_id`),
  KEY `seller_profile_id` (`seller_profile_id`),
  CONSTRAINT `activity_logs_ibfk_1` FOREIGN KEY (`activity_category_id`) REFERENCES `activity_categories` (`id`),
  CONSTRAINT `activity_logs_ibfk_2` FOREIGN KEY (`seller_profile_id`) REFERENCES `seller_profiles` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `acts_as_xapian_jobs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `model` varchar(255) NOT NULL,
  `model_id` varchar(255) NOT NULL,
  `action` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_acts_as_xapian_jobs_on_model_and_model_id` (`model`,`model_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `ad_clicks` (
  `id` varchar(36) NOT NULL,
  `ad_id` varchar(36) NOT NULL,
  `user_id` varchar(36) DEFAULT NULL,
  `profile_id` varchar(36) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ad_id` (`ad_id`),
  CONSTRAINT `ad_clicks_ibfk_1` FOREIGN KEY (`ad_id`) REFERENCES `ads` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `ad_views` (
  `id` varchar(36) NOT NULL,
  `ad_id` varchar(36) NOT NULL,
  `user_id` varchar(36) DEFAULT NULL,
  `profile_id` varchar(36) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ad_id` (`ad_id`),
  CONSTRAINT `ad_views_ibfk_1` FOREIGN KEY (`ad_id`) REFERENCES `ads` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `ads` (
  `id` varchar(36) NOT NULL,
  `name` varchar(255) NOT NULL,
  `height` int(11) NOT NULL,
  `width` int(11) NOT NULL,
  `image_path` varchar(255) NOT NULL,
  `link` varchar(255) NOT NULL,
  `target_page` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_ads_on_name` (`name`),
  KEY `index_ads_on_target_page` (`target_page`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `alert_definitions` (
  `id` varchar(36) NOT NULL,
  `title` varchar(255) NOT NULL,
  `message` varchar(500) NOT NULL,
  `details` text NOT NULL,
  `trigger_delay_days` int(11) DEFAULT NULL,
  `trigger_cutoff_days` int(11) DEFAULT NULL,
  `auto_expire_days` int(11) DEFAULT NULL,
  `alert_trigger_type_id` varchar(36) NOT NULL,
  `trigger_parameter_value` varchar(255) DEFAULT NULL,
  `disabled` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `user_class_id` int(11) DEFAULT NULL,
  `amps` tinyint(1) DEFAULT NULL,
  `amps_gold` tinyint(1) DEFAULT NULL,
  `top1` tinyint(1) DEFAULT NULL,
  `re_volution` tinyint(1) DEFAULT NULL,
  `rei_mkt_dept` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_alert_definitions_on_alert_trigger_type_id` (`alert_trigger_type_id`),
  KEY `user_class_id` (`user_class_id`),
  CONSTRAINT `alert_definitions_ibfk_1` FOREIGN KEY (`user_class_id`) REFERENCES `user_classes` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `alert_trigger_types` (
  `id` varchar(36) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` varchar(255) NOT NULL,
  `method_name` varchar(255) NOT NULL,
  `parameter_description` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `alerts` (
  `id` varchar(36) NOT NULL,
  `event_time` datetime DEFAULT NULL,
  `dismissed` tinyint(1) NOT NULL,
  `user_id` varchar(36) NOT NULL,
  `alert_definition_id` varchar(36) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_alerts_on_user_id` (`user_id`),
  KEY `index_alerts_on_alert_definition_id` (`alert_definition_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `associate_testimonials` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `testimonial_id` varchar(36) NOT NULL,
  `firstname` varchar(255) DEFAULT NULL,
  `lastname` varchar(255) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `likes` text,
  `suggestions` text,
  `mkt_release` tinyint(1) DEFAULT '0',
  `closing_date` datetime DEFAULT NULL,
  `sales_price` int(11) DEFAULT NULL,
  `tx_comments` text,
  `type` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `name_private` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `testimonial_id` (`testimonial_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `badge_images` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `badge_id` int(11) NOT NULL,
  `content_type` varchar(255) DEFAULT NULL,
  `filename` varchar(255) DEFAULT NULL,
  `size` int(11) DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `thumbnail` varchar(255) DEFAULT NULL,
  `width` int(11) DEFAULT NULL,
  `height` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `badge_id` (`badge_id`),
  KEY `parent_id` (`parent_id`),
  CONSTRAINT `badge_images_ibfk_1` FOREIGN KEY (`badge_id`) REFERENCES `badges` (`id`),
  CONSTRAINT `badge_images_ibfk_2` FOREIGN KEY (`parent_id`) REFERENCES `badge_images` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `badge_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` varchar(36) NOT NULL,
  `badge_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `badge_id` (`badge_id`),
  CONSTRAINT `badge_users_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `badge_users_ibfk_2` FOREIGN KEY (`badge_id`) REFERENCES `badges` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `badges` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `profiles_added` int(11) DEFAULT NULL,
  `properties_added` int(11) DEFAULT NULL,
  `properties_sold` int(11) DEFAULT NULL,
  `certification` varchar(255) DEFAULT NULL,
  `membership_time` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `email_subject` text,
  `email_body` text,
  `buyer_added` varchar(255) DEFAULT NULL,
  `profile_completeness` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `buyer_engagement_infos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `retail_buyer_profile_id` varchar(36) NOT NULL,
  `note_type` varchar(255) DEFAULT NULL,
  `subject` text,
  `description` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `retail_buyer_profile_id` (`retail_buyer_profile_id`),
  CONSTRAINT `buyer_engagement_infos_ibfk_1` FOREIGN KEY (`retail_buyer_profile_id`) REFERENCES `retail_buyer_profiles` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `buyer_notifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` varchar(255) DEFAULT NULL,
  `summary_type` varchar(255) DEFAULT NULL,
  `email_intro` text,
  `email_closing` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `subject` text,
  `trust_responder_series` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `buyer_notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `buyer_user_images` (
  `id` varchar(36) NOT NULL,
  `user_id` varchar(36) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `parent_id` varchar(36) DEFAULT NULL,
  `content_type` varchar(255) DEFAULT NULL,
  `filename` varchar(255) DEFAULT NULL,
  `thumbnail` varchar(255) DEFAULT NULL,
  `size` int(11) DEFAULT NULL,
  `width` int(11) DEFAULT NULL,
  `height` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `buyer_user_images_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `buyer_web_pages` (
  `id` varchar(36) NOT NULL,
  `user_territory_id` varchar(36) DEFAULT NULL,
  `tag_line` varchar(255) DEFAULT NULL,
  `header` varchar(255) DEFAULT NULL,
  `opening_text` varchar(400) DEFAULT NULL,
  `permalink_text` varchar(255) DEFAULT NULL,
  `active` tinyint(1) DEFAULT NULL,
  `dynamic_css` varchar(255) DEFAULT NULL,
  `local_phone` varchar(255) DEFAULT NULL,
  `domain_permalink_text` varchar(255) DEFAULT NULL,
  `domain_type` varchar(255) DEFAULT NULL,
  `ua_number` varchar(255) DEFAULT NULL,
  `map_location` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_territory_id` (`user_territory_id`),
  CONSTRAINT `buyer_web_pages_ibfk_1` FOREIGN KEY (`user_territory_id`) REFERENCES `user_territories` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `consumer_tokens` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` varchar(36) NOT NULL,
  `type` varchar(30) DEFAULT NULL,
  `token` varchar(255) DEFAULT NULL,
  `secret` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_consumer_tokens_on_token` (`token`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `contest_invitations` (
  `id` varchar(36) NOT NULL,
  `from_name` varchar(255) DEFAULT NULL,
  `from_email` varchar(255) DEFAULT NULL,
  `to_name` varchar(255) DEFAULT NULL,
  `to_email` varchar(255) DEFAULT NULL,
  `campaign_code` varchar(255) DEFAULT NULL,
  `first_visited_url` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `accepted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `contract_buyer_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `contract_seller_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `counties` (
  `id` varchar(36) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `territory_id` varchar(36) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `territory_id` (`territory_id`),
  CONSTRAINT `counties_ibfk_1` FOREIGN KEY (`territory_id`) REFERENCES `territories` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `daily_activity_scores` (
  `id` varchar(36) NOT NULL,
  `user_id` varchar(36) NOT NULL,
  `created_at` date DEFAULT NULL,
  `score` float DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `digest_histories` (
  `id` varchar(36) NOT NULL,
  `user_id` varchar(36) NOT NULL,
  `digest_sent_flag` varchar(1) NOT NULL,
  `last_process_date` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `digest_histories_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `email_alert_definitions` (
  `id` varchar(36) NOT NULL,
  `title` varchar(255) NOT NULL,
  `disabled` tinyint(1) DEFAULT NULL,
  `alert_trigger_type_id` varchar(36) NOT NULL,
  `trigger_parameter_value` varchar(255) DEFAULT NULL,
  `trigger_delay_days` int(11) DEFAULT NULL,
  `email_subject` varchar(500) NOT NULL,
  `message_body` text NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `email_type` varchar(255) DEFAULT 'property_profile',
  PRIMARY KEY (`id`),
  KEY `index_email_alert_definitions_on_alert_trigger_type_id` (`alert_trigger_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `email_alert_to_users` (
  `id` varchar(36) NOT NULL,
  `event_time` datetime DEFAULT NULL,
  `user_id` varchar(36) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `user_email_alert_definition_id` varchar(36) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `user_email_alert_definition_id` (`user_email_alert_definition_id`),
  CONSTRAINT `email_alert_to_users_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `email_alert_to_users_ibfk_2` FOREIGN KEY (`user_email_alert_definition_id`) REFERENCES `user_email_alert_definitions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `email_alerts` (
  `id` varchar(36) NOT NULL,
  `event_time` datetime DEFAULT NULL,
  `user_id` varchar(36) NOT NULL,
  `email_alert_definition_id` varchar(36) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `profile` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_email_alerts_on_user_id` (`user_id`),
  KEY `index_email_alerts_on_email_alert_definition_id` (`email_alert_definition_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `featured_profiles` (
  `id` varchar(36) NOT NULL,
  `profile_type` varchar(255) DEFAULT NULL,
  `profile_id` varchar(36) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `profile_id` (`profile_id`),
  CONSTRAINT `featured_profiles_ibfk_1` FOREIGN KEY (`profile_id`) REFERENCES `profiles` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `feedbacks` (
  `id` varchar(36) NOT NULL,
  `user_id` varchar(36) DEFAULT NULL,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `ip_address` varchar(255) DEFAULT NULL,
  `comments` text,
  `cgi_env` text,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `feedbacks_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `feeds` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` varchar(36) DEFAULT NULL,
  `territory_id` varchar(255) DEFAULT NULL,
  `activity_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `territory_id` (`territory_id`),
  CONSTRAINT `feeds_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `feeds_ibfk_2` FOREIGN KEY (`territory_id`) REFERENCES `territories` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `investment_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `investor_message_delete_histories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `message` varchar(255) DEFAULT NULL,
  `deleted_by` varchar(255) DEFAULT NULL,
  `sender` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `investor_message_recipients` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `investor_message_id` int(11) DEFAULT NULL,
  `reciever_id` varchar(36) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `is_read` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `investor_message_id` (`investor_message_id`),
  KEY `reciever_id` (`reciever_id`),
  CONSTRAINT `investor_message_recipients_ibfk_1` FOREIGN KEY (`investor_message_id`) REFERENCES `investor_messages` (`id`),
  CONSTRAINT `investor_message_recipients_ibfk_2` FOREIGN KEY (`reciever_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `investor_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `subject` varchar(255) DEFAULT NULL,
  `body` text,
  `sender_id` varchar(36) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `marked_as_spam` tinyint(1) DEFAULT '0',
  `spam_reason` text,
  PRIMARY KEY (`id`),
  KEY `sender_id` (`sender_id`),
  CONSTRAINT `investor_messages_ibfk_1` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `investor_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` varchar(255) DEFAULT NULL,
  `investor_type` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `investor_types_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `investor_website_images` (
  `id` varchar(36) NOT NULL,
  `investor_website_id` varchar(36) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `parent_id` varchar(36) DEFAULT NULL,
  `content_type` varchar(255) DEFAULT NULL,
  `filename` varchar(255) DEFAULT NULL,
  `thumbnail` varchar(255) DEFAULT NULL,
  `size` int(11) DEFAULT NULL,
  `width` int(11) DEFAULT NULL,
  `height` int(11) DEFAULT NULL,
  KEY `investor_website_id` (`investor_website_id`),
  CONSTRAINT `investor_website_images_ibfk_1` FOREIGN KEY (`investor_website_id`) REFERENCES `investor_websites` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `investor_websites` (
  `id` varchar(36) NOT NULL,
  `user_id` varchar(36) NOT NULL,
  `header` varchar(255) DEFAULT NULL,
  `permalink_text` varchar(255) DEFAULT NULL,
  `dynamic_css` varchar(255) DEFAULT NULL,
  `home_page_text` text,
  `about_us_page_text` text,
  `domain_type` varchar(255) DEFAULT NULL,
  `ua_number` varchar(255) DEFAULT NULL,
  `active` tinyint(1) DEFAULT NULL,
  `tagline` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `display_our_philosophy_page` tinyint(1) DEFAULT NULL,
  `display_why_invest_with_us_page` tinyint(1) DEFAULT NULL,
  `our_philosophy_page_text` text,
  `why_invest_with_us_page_text` text,
  `banner_image_path` varchar(255) DEFAULT NULL,
  `layout` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `investor_websites_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `invitations` (
  `id` varchar(36) NOT NULL,
  `user_id` varchar(36) NOT NULL,
  `to_email` varchar(255) NOT NULL,
  `to_first_name` varchar(255) DEFAULT NULL,
  `to_last_name` varchar(255) DEFAULT NULL,
  `invitation_message` text NOT NULL,
  `created_at` datetime NOT NULL,
  `accepted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `invitations_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `lah_shopping_cart_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `product_name` varchar(255) DEFAULT NULL,
  `quantity` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `user_id` varchar(36) NOT NULL,
  `bundle_one` tinyint(1) DEFAULT '0',
  `bundle_two` tinyint(1) DEFAULT '0',
  `gold_upsell` tinyint(1) DEFAULT '0',
  `reim_pro_upsell` tinyint(1) DEFAULT '0',
  `product_id_detail` varchar(255) DEFAULT NULL,
  `customer_id_detail` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `lah_shopping_cart_users_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `latlongs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `seq` int(11) NOT NULL,
  `lat` float NOT NULL,
  `lng` float NOT NULL,
  `zcta_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `zcta_id` (`zcta_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `logged_exceptions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `exception_class` varchar(255) DEFAULT NULL,
  `controller_name` varchar(255) DEFAULT NULL,
  `action_name` varchar(255) DEFAULT NULL,
  `message` text,
  `backtrace` text,
  `environment` text,
  `request` text,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `map_lah_product_with_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `product_name` varchar(255) DEFAULT NULL,
  `user_id` varchar(36) NOT NULL,
  `amps` tinyint(1) DEFAULT '0',
  `amps_gold` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `top1` tinyint(1) DEFAULT '0',
  `re_volution` tinyint(1) DEFAULT '0',
  `rei_mkt_dept` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `map_lah_product_with_users_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `my_websites` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `domain_name` varchar(255) DEFAULT NULL,
  `site_id` varchar(255) DEFAULT NULL,
  `site_type` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `user_id` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `my_websites_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `partner_accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` varchar(36) NOT NULL,
  `permalink` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `pending_icontact_user_lists` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` varchar(36) DEFAULT NULL,
  `list_name` varchar(255) DEFAULT NULL,
  `list_id_detail` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `is_processed` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `pending_icontact_user_lists_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `profile_contracts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `seller_property_profile_id` varchar(255) DEFAULT NULL,
  `contract_buyer_type_id` int(11) DEFAULT NULL,
  `contract_seller_type_id` int(11) DEFAULT NULL,
  `seller_write_in` varchar(255) DEFAULT NULL,
  `buyer_write_in` varchar(255) DEFAULT NULL,
  `my_buyer` varchar(255) DEFAULT NULL,
  `contract` mediumtext,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `seller_property_profile_id` (`seller_property_profile_id`),
  KEY `contract_buyer_type_id` (`contract_buyer_type_id`),
  KEY `contract_seller_type_id` (`contract_seller_type_id`),
  CONSTRAINT `profile_contracts_ibfk_1` FOREIGN KEY (`seller_property_profile_id`) REFERENCES `seller_property_profiles` (`id`),
  CONSTRAINT `profile_contracts_ibfk_2` FOREIGN KEY (`contract_buyer_type_id`) REFERENCES `contract_buyer_types` (`id`),
  CONSTRAINT `profile_contracts_ibfk_3` FOREIGN KEY (`contract_seller_type_id`) REFERENCES `contract_seller_types` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `profile_delete_reasons` (
  `id` varchar(36) NOT NULL,
  `profile_type_id` varchar(36) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `profile_type_id` (`profile_type_id`),
  CONSTRAINT `profile_delete_reasons_ibfk_1` FOREIGN KEY (`profile_type_id`) REFERENCES `profile_types` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `profile_favorites` (
  `id` varchar(36) NOT NULL,
  `profile_id` varchar(36) NOT NULL,
  `target_profile_id` varchar(36) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `is_near` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `profile_id` (`profile_id`),
  KEY `target_profile_id` (`target_profile_id`),
  CONSTRAINT `profile_favorites_ibfk_1` FOREIGN KEY (`profile_id`) REFERENCES `profiles` (`id`),
  CONSTRAINT `profile_favorites_ibfk_2` FOREIGN KEY (`target_profile_id`) REFERENCES `profiles` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `profile_field_engine_indices` (
  `id` varchar(36) NOT NULL,
  `profile_id` varchar(36) NOT NULL,
  `is_owner` tinyint(1) NOT NULL,
  `zip_code` varchar(255) NOT NULL,
  `property_type` varchar(255) NOT NULL,
  `beds` int(11) NOT NULL,
  `baths` int(11) NOT NULL,
  `square_feet` int(11) NOT NULL,
  `square_feet_min` int(11) NOT NULL,
  `square_feet_max` int(11) NOT NULL,
  `price` int(11) DEFAULT NULL,
  `price_min` int(11) DEFAULT NULL,
  `price_max` int(11) DEFAULT NULL,
  `units` int(11) NOT NULL,
  `units_min` int(11) NOT NULL,
  `units_max` int(11) NOT NULL,
  `acres` int(11) NOT NULL,
  `acres_min` int(11) NOT NULL,
  `acres_max` int(11) NOT NULL,
  `privacy` varchar(255) DEFAULT NULL,
  `property_type_sort_order` int(11) DEFAULT NULL,
  `has_profile_image` tinyint(1) NOT NULL DEFAULT '0',
  `is_primary_profile` tinyint(1) DEFAULT '0',
  `profile_created_at` datetime DEFAULT NULL,
  `has_features` tinyint(1) DEFAULT '0',
  `has_description` tinyint(1) DEFAULT '0',
  `profile_type_id` varchar(36) DEFAULT NULL,
  `user_id` varchar(36) DEFAULT NULL,
  `max_mon_pay` int(11) DEFAULT NULL,
  `max_dow_pay` int(11) DEFAULT NULL,
  `min_mon_pay` int(11) DEFAULT NULL,
  `min_dow_pay` int(11) DEFAULT NULL,
  `contract_end_date` date DEFAULT NULL,
  `status` varchar(255) DEFAULT 'active',
  `notification_active` tinyint(1) DEFAULT '0',
  `notification_email` varchar(255) DEFAULT NULL,
  `deal_terms` text,
  `video_tour` varchar(255) DEFAULT NULL,
  `embed_video` text,
  `notification_phone` varchar(255) DEFAULT NULL,
  `investment_type_id` int(11) NOT NULL DEFAULT '1',
  `after_repair_value` int(11) NOT NULL,
  `value_determined_by` text NOT NULL,
  `total_repair_needed` int(11) NOT NULL,
  `repair_calculated_by` text NOT NULL,
  `max_purchase_value` int(11) NOT NULL,
  `arv_repairs_value` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_profile_field_engine_indices_on_profile_id` (`profile_id`),
  KEY `index_profile_field_engine_indices_on_zip_code` (`zip_code`),
  KEY `index_profile_field_engine_indices_on_is_owner` (`is_owner`),
  KEY `index_profile_field_engine_indices_on_property_type` (`property_type`),
  KEY `index_profile_field_engine_indices_on_beds` (`beds`),
  KEY `index_profile_field_engine_indices_on_baths` (`baths`),
  KEY `index_profile_field_engine_indices_on_square_feet` (`square_feet`),
  KEY `index_profile_field_engine_indices_on_square_feet_min` (`square_feet_min`),
  KEY `index_profile_field_engine_indices_on_square_feet_max` (`square_feet_max`),
  KEY `index_profile_field_engine_indices_on_price` (`price`),
  KEY `index_profile_field_engine_indices_on_price_min` (`price_min`),
  KEY `index_profile_field_engine_indices_on_price_max` (`price_max`),
  KEY `index_profile_field_engine_indices_on_units` (`units`),
  KEY `index_profile_field_engine_indices_on_units_min` (`units_min`),
  KEY `index_profile_field_engine_indices_on_units_max` (`units_max`),
  KEY `index_profile_field_engine_indices_on_acres` (`acres`),
  KEY `index_profile_field_engine_indices_on_acres_min` (`acres_min`),
  KEY `index_profile_field_engine_indices_on_acres_max` (`acres_max`),
  KEY `index_profile_field_engine_indices_on_privacy` (`privacy`),
  KEY `index_profile_field_engine_indices_on_property_type_sort_order` (`property_type_sort_order`),
  KEY `index_profile_field_engine_indices_on_has_profile_image` (`has_profile_image`),
  KEY `index_profile_field_engine_indices_on_is_primary_profile` (`is_primary_profile`),
  KEY `index_profile_field_engine_indices_on_profile_created_at` (`profile_created_at`),
  KEY `index_profile_field_engine_indices_on_has_features` (`has_features`),
  KEY `index_profile_field_engine_indices_on_has_description` (`has_description`),
  KEY `index_profile_field_engine_indices_on_profile_type_id` (`profile_type_id`),
  KEY `index_profile_field_engine_indices_on_user_id` (`user_id`),
  KEY `investment_type_id` (`investment_type_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `profile_fields` (
  `id` varchar(36) NOT NULL,
  `profile_id` varchar(36) NOT NULL,
  `key` varchar(255) NOT NULL,
  `value` varchar(255) DEFAULT NULL,
  `value_text` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `profile_id` (`profile_id`),
  KEY `index_profile_fields_on_key` (`key`),
  KEY `index_profile_fields_on_value` (`value`),
  CONSTRAINT `profile_fields_ibfk_1` FOREIGN KEY (`profile_id`) REFERENCES `profiles` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `profile_images` (
  `id` varchar(36) NOT NULL,
  `profile_id` varchar(36) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `content_type` varchar(255) DEFAULT NULL,
  `filename` varchar(255) DEFAULT NULL,
  `size` int(11) DEFAULT NULL,
  `parent_id` varchar(36) DEFAULT NULL,
  `thumbnail` varchar(255) DEFAULT NULL,
  `width` int(11) DEFAULT NULL,
  `height` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `default_photo` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `profile_id` (`profile_id`),
  CONSTRAINT `profile_images_ibfk_1` FOREIGN KEY (`profile_id`) REFERENCES `profiles` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `profile_matches_counts` (
  `id` varchar(36) NOT NULL,
  `profile_id` varchar(36) NOT NULL,
  `count` int(11) DEFAULT '0',
  `status` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_profile_matches_counts_on_profile_id` (`profile_id`),
  CONSTRAINT `profile_matches_counts_ibfk_1` FOREIGN KEY (`profile_id`) REFERENCES `profiles` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `profile_matches_details` (
  `id` varchar(36) NOT NULL,
  `source_profile_id` varchar(36) NOT NULL,
  `target_profile_id` varchar(36) NOT NULL,
  `is_near` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_profile_matches_details_on_source_profile_id` (`source_profile_id`),
  KEY `index_profile_matches_details_on_target_profile_id` (`target_profile_id`),
  CONSTRAINT `profile_matches_details_ibfk_1` FOREIGN KEY (`source_profile_id`) REFERENCES `profiles` (`id`),
  CONSTRAINT `profile_matches_details_ibfk_2` FOREIGN KEY (`target_profile_id`) REFERENCES `profiles` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `profile_message_delete_histories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `subject` varchar(255) DEFAULT NULL,
  `deleted_by` varchar(255) DEFAULT NULL,
  `sender` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `profile_message_recipients` (
  `id` varchar(36) NOT NULL,
  `from_profile_id` varchar(36) NOT NULL,
  `to_profile_id` varchar(36) NOT NULL,
  `viewed_at` datetime DEFAULT NULL,
  `profile_message_id` varchar(36) NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `archived` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `from_profile_id` (`from_profile_id`),
  KEY `to_profile_id` (`to_profile_id`),
  KEY `profile_message_id` (`profile_message_id`),
  CONSTRAINT `profile_message_recipients_ibfk_1` FOREIGN KEY (`from_profile_id`) REFERENCES `profiles` (`id`),
  CONSTRAINT `profile_message_recipients_ibfk_2` FOREIGN KEY (`to_profile_id`) REFERENCES `profiles` (`id`),
  CONSTRAINT `profile_message_recipients_ibfk_3` FOREIGN KEY (`profile_message_id`) REFERENCES `profile_messages` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `profile_messages` (
  `id` varchar(36) NOT NULL,
  `body` text,
  `created_at` datetime DEFAULT NULL,
  `subject` varchar(255) DEFAULT NULL,
  `reply_to_profile_message_id` varchar(36) DEFAULT NULL,
  `marked_as_spam` tinyint(1) DEFAULT '0',
  `spam_reason` text,
  PRIMARY KEY (`id`),
  KEY `reply_to_profile_message_id` (`reply_to_profile_message_id`),
  CONSTRAINT `profile_messages_ibfk_1` FOREIGN KEY (`reply_to_profile_message_id`) REFERENCES `profile_messages` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `profile_seller_lead_mappings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `profile_id` varchar(36) NOT NULL,
  `seller_profile_id` varchar(36) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `seller_property_profile_id` varchar(36) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `profile_id` (`profile_id`),
  KEY `seller_profile_id` (`seller_profile_id`),
  KEY `seller_property_profile_id` (`seller_property_profile_id`),
  CONSTRAINT `profile_seller_lead_mappings_ibfk_1` FOREIGN KEY (`profile_id`) REFERENCES `profiles` (`id`),
  CONSTRAINT `profile_seller_lead_mappings_ibfk_2` FOREIGN KEY (`seller_profile_id`) REFERENCES `seller_profiles` (`id`),
  CONSTRAINT `profile_seller_lead_mappings_ibfk_3` FOREIGN KEY (`seller_property_profile_id`) REFERENCES `seller_property_profiles` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `profile_sites` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `profile_id` varchar(36) NOT NULL,
  `site_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `syndicated` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `profile_id` (`profile_id`),
  CONSTRAINT `profile_sites_ibfk_1` FOREIGN KEY (`profile_id`) REFERENCES `profiles` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `profile_types` (
  `id` varchar(36) NOT NULL DEFAULT '',
  `name` varchar(255) DEFAULT NULL,
  `permalink` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_profile_types_on_permalink` (`permalink`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `profile_views` (
  `id` varchar(36) NOT NULL,
  `profile_id` varchar(36) NOT NULL,
  `viewed_by_profile_id` varchar(36) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `profile_id` (`profile_id`),
  KEY `viewed_by_profile_id` (`viewed_by_profile_id`),
  CONSTRAINT `profile_views_ibfk_1` FOREIGN KEY (`profile_id`) REFERENCES `profiles` (`id`),
  CONSTRAINT `profile_views_ibfk_2` FOREIGN KEY (`viewed_by_profile_id`) REFERENCES `profiles` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `profiles` (
  `id` varchar(36) NOT NULL,
  `profile_type_id` varchar(36) NOT NULL,
  `user_id` varchar(36) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `permalink` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `delete_reason` text,
  `profile_delete_reason_id` varchar(36) DEFAULT NULL,
  `marked_as_spam` tinyint(1) DEFAULT '0',
  `private_display_name` varchar(255) DEFAULT NULL,
  `default_photo_url` varchar(255) DEFAULT NULL,
  `default_std_thumbnail_url` varchar(255) DEFAULT NULL,
  `default_micro_thumbnail_url` varchar(255) DEFAULT NULL,
  `admin_delete_comment` text,
  `country` varchar(255) DEFAULT 'US',
  `investment_type_id` int(11) NOT NULL DEFAULT '1',
  `profile_delete_date` datetime DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `random_string` varchar(255) DEFAULT NULL,
  `is_profile_need_help` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_profiles_on_permalink` (`permalink`),
  KEY `index_profiles_on_profile_type_id` (`profile_type_id`),
  KEY `index_profiles_on_user_id` (`user_id`),
  KEY `investment_type_id` (`investment_type_id`),
  CONSTRAINT `profiles_ibfk_1` FOREIGN KEY (`profile_type_id`) REFERENCES `profile_types` (`id`),
  CONSTRAINT `profiles_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `profiles_ibfk_3` FOREIGN KEY (`investment_type_id`) REFERENCES `investment_types` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `responder_sequence_assign_to_seller_profiles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `seller_responder_sequence_id` varchar(255) DEFAULT NULL,
  `mail_number` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `seller_property_profile_id` varchar(36) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `seller_responder_sequence_id` (`seller_responder_sequence_id`),
  KEY `seller_property_profile_id` (`seller_property_profile_id`),
  CONSTRAINT `responder_sequence_assign_to_seller_profiles_ibfk_1` FOREIGN KEY (`seller_responder_sequence_id`) REFERENCES `seller_responder_sequences` (`id`),
  CONSTRAINT `responder_sequence_assign_to_seller_profiles_ibfk_2` FOREIGN KEY (`seller_property_profile_id`) REFERENCES `seller_property_profiles` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `retail_buyer_profiles` (
  `id` varchar(36) NOT NULL,
  `user_territory_id` varchar(36) DEFAULT NULL,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `alternate_phone` varchar(255) DEFAULT NULL,
  `email_address` varchar(255) DEFAULT NULL,
  `active` tinyint(1) DEFAULT NULL,
  `activation_code` varchar(255) DEFAULT NULL,
  `activated_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `terms_of_use` varchar(255) NOT NULL,
  `profile_id` varchar(36) DEFAULT NULL,
  `mail_number` int(11) DEFAULT '0',
  `welcome_email_subscription` tinyint(1) DEFAULT '1',
  `daily_email_subscription` tinyint(1) DEFAULT '1',
  `weekly_email_subscription` tinyint(1) DEFAULT '1',
  `trust_responder_subscription` tinyint(1) DEFAULT '1',
  `is_archive` tinyint(1) DEFAULT '0',
  `delete_reason` varchar(255) DEFAULT NULL,
  `delete_comment` text,
  PRIMARY KEY (`id`),
  KEY `user_territory_id` (`user_territory_id`),
  KEY `profile_id` (`profile_id`),
  CONSTRAINT `retail_buyer_profiles_ibfk_1` FOREIGN KEY (`user_territory_id`) REFERENCES `user_territories` (`id`),
  CONSTRAINT `retail_buyer_profiles_ibfk_2` FOREIGN KEY (`profile_id`) REFERENCES `profiles` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `retail_profile_field_engine_indices` (
  `id` varchar(36) NOT NULL,
  `retail_buyer_profile_id` varchar(36) DEFAULT NULL,
  `zip_code` varchar(255) DEFAULT NULL,
  `property_type` varchar(255) DEFAULT NULL,
  `beds` int(11) DEFAULT NULL,
  `baths` int(11) DEFAULT NULL,
  `square_feet_min` int(11) DEFAULT NULL,
  `square_feet_max` int(11) DEFAULT NULL,
  `units_min` int(11) DEFAULT NULL,
  `units_max` int(11) DEFAULT NULL,
  `acres_min` int(11) DEFAULT NULL,
  `acres_max` int(11) DEFAULT NULL,
  `max_mon_pay` int(11) DEFAULT NULL,
  `max_dow_pay` int(11) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `county` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `stories` varchar(255) DEFAULT NULL,
  `garage` varchar(255) DEFAULT NULL,
  `livingrooms` varchar(255) DEFAULT NULL,
  `waterfront` varchar(255) DEFAULT NULL,
  `pool` varchar(255) DEFAULT NULL,
  `water` varchar(255) DEFAULT NULL,
  `sewer` varchar(255) DEFAULT NULL,
  `electricity` varchar(255) DEFAULT NULL,
  `natural_gas` varchar(255) DEFAULT NULL,
  `trees` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `retail_buyer_profile_id` (`retail_buyer_profile_id`),
  CONSTRAINT `retail_profile_field_engine_indices_ibfk_1` FOREIGN KEY (`retail_buyer_profile_id`) REFERENCES `retail_buyer_profiles` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `schema_info` (
  `version` int(11) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `seller_engagement_infos` (
  `id` varchar(36) NOT NULL,
  `seller_property_profile_id` varchar(36) NOT NULL,
  `note_type` varchar(255) DEFAULT NULL,
  `subject` text,
  `description` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `scratch_pad_tag` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `seller_property_profile_id` (`seller_property_profile_id`),
  CONSTRAINT `seller_engagement_infos_ibfk_1` FOREIGN KEY (`seller_property_profile_id`) REFERENCES `seller_property_profiles` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `seller_financial_infos` (
  `id` varchar(36) NOT NULL,
  `seller_property_profile_id` varchar(36) NOT NULL,
  `financial_loan_number` varchar(255) DEFAULT NULL,
  `origination_date` varchar(255) DEFAULT NULL,
  `original_loan_payment` varchar(255) DEFAULT NULL,
  `monthly_payment` varchar(255) DEFAULT NULL,
  `interest_rate` varchar(255) DEFAULT NULL,
  `estimated_balance` varchar(255) DEFAULT NULL,
  `loan_type` varchar(255) DEFAULT NULL,
  `loan_term` varchar(255) DEFAULT NULL,
  `last_payment_date` varchar(255) DEFAULT NULL,
  `back_payment` varchar(255) DEFAULT NULL,
  `lender` varchar(255) DEFAULT NULL,
  `loan_number` varchar(255) DEFAULT NULL,
  `other_financial_note` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `price_need` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `seller_property_profile_id` (`seller_property_profile_id`),
  CONSTRAINT `seller_financial_infos_ibfk_1` FOREIGN KEY (`seller_property_profile_id`) REFERENCES `seller_property_profiles` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `seller_lead_opt_ins` (
  `id` varchar(36) NOT NULL,
  `seller_website_id` varchar(36) NOT NULL,
  `seller_first_name` varchar(255) DEFAULT NULL,
  `seller_email` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `seller_website_id` (`seller_website_id`),
  CONSTRAINT `seller_lead_opt_ins_ibfk_1` FOREIGN KEY (`seller_website_id`) REFERENCES `seller_websites` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `seller_lead_testimonails` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `subject` text,
  `testimonial` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `seller_profiles` (
  `id` varchar(36) NOT NULL,
  `user_id` varchar(36) NOT NULL,
  `seller_website_id` varchar(36) DEFAULT NULL,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `alternate_phone` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `date_created` varchar(255) DEFAULT NULL,
  `need_to_sell_in` varchar(255) DEFAULT NULL,
  `seller_motivation` text,
  `bankruptcy` varchar(255) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `home_included` varchar(255) DEFAULT NULL,
  `bankruptcy_expiration` datetime DEFAULT NULL,
  `divorce` varchar(255) DEFAULT NULL,
  `relation_with_spouse` text,
  `additional_contact_notes` text,
  `source` varchar(255) DEFAULT NULL,
  `price_want` varchar(255) DEFAULT NULL,
  `bird_dog_locator` varchar(255) DEFAULT NULL,
  `is_archive` tinyint(1) DEFAULT '0',
  `delete_reason` varchar(255) DEFAULT NULL,
  `delete_comment` text,
  `admin_delete_comment` text,
  `amps_cold` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `seller_website_id` (`seller_website_id`),
  CONSTRAINT `seller_profiles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `seller_profiles_ibfk_2` FOREIGN KEY (`seller_website_id`) REFERENCES `seller_websites` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `seller_property_owners` (
  `id` varchar(36) NOT NULL,
  `seller_property_profile_id` varchar(36) NOT NULL,
  `owner_name` varchar(255) DEFAULT NULL,
  `is_seller_lead_owner` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `seller_property_profile_id` (`seller_property_profile_id`),
  CONSTRAINT `seller_property_owners_ibfk_1` FOREIGN KEY (`seller_property_profile_id`) REFERENCES `seller_property_profiles` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `seller_property_profiles` (
  `id` varchar(36) NOT NULL,
  `seller_profile_id` varchar(36) NOT NULL,
  `is_owner` tinyint(1) DEFAULT '1',
  `zip_code` varchar(255) DEFAULT NULL,
  `property_type` varchar(255) DEFAULT NULL,
  `property_address` varchar(255) DEFAULT NULL,
  `beds` int(11) DEFAULT NULL,
  `baths` int(11) DEFAULT NULL,
  `square_feet` int(11) DEFAULT NULL,
  `price` int(11) DEFAULT NULL,
  `units` int(11) DEFAULT NULL,
  `acres` int(11) DEFAULT NULL,
  `privacy` varchar(255) DEFAULT 'public',
  `description` varchar(255) DEFAULT NULL,
  `has_description` tinyint(1) DEFAULT NULL,
  `has_features` tinyint(1) DEFAULT NULL,
  `property_type_sort_order` tinyint(1) DEFAULT NULL,
  `has_profile_image` tinyint(1) DEFAULT NULL,
  `profile_type_id` varchar(255) DEFAULT NULL,
  `min_mon_pay` int(11) DEFAULT NULL,
  `min_dow_pay` int(11) DEFAULT NULL,
  `status` varchar(255) DEFAULT 'active',
  `contract_end_date` date DEFAULT NULL,
  `profile_created_at` datetime DEFAULT NULL,
  `deal_terms` text,
  `video_tour` varchar(255) DEFAULT NULL,
  `embed_video` text,
  `notification_email` varchar(255) DEFAULT NULL,
  `notification_phone` varchar(255) DEFAULT NULL,
  `garage` varchar(255) DEFAULT NULL,
  `stories` varchar(255) DEFAULT NULL,
  `neighborhood` varchar(255) DEFAULT NULL,
  `trees` varchar(255) DEFAULT NULL,
  `natural_gas` varchar(255) DEFAULT NULL,
  `electricity` varchar(255) DEFAULT NULL,
  `sewer` varchar(255) DEFAULT NULL,
  `water` varchar(255) DEFAULT NULL,
  `pool` varchar(255) DEFAULT NULL,
  `livingrooms` varchar(255) DEFAULT NULL,
  `fencing` varchar(255) DEFAULT NULL,
  `school_elementary` varchar(255) DEFAULT NULL,
  `school_middle` varchar(255) DEFAULT NULL,
  `school_high` varchar(255) DEFAULT NULL,
  `breakfast_area` varchar(255) DEFAULT NULL,
  `formal_dining` varchar(255) DEFAULT NULL,
  `waterfront` varchar(255) DEFAULT NULL,
  `condo_community_name` varchar(255) DEFAULT NULL,
  `feature_tags` varchar(255) DEFAULT NULL,
  `total_actual_rent` varchar(255) DEFAULT NULL,
  `county` varchar(255) DEFAULT NULL,
  `barn` varchar(255) DEFAULT NULL,
  `manufactured_home` varchar(255) DEFAULT NULL,
  `house` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `foundation_type` varchar(255) DEFAULT NULL,
  `roof_age` varchar(255) DEFAULT NULL,
  `mobile_or_manufactured_home` varchar(255) DEFAULT NULL,
  `property_conditions` varchar(255) DEFAULT NULL,
  `repairs_needed` text,
  `mortgage_current` varchar(255) DEFAULT NULL,
  `last_payment_made` varchar(255) DEFAULT NULL,
  `asking_home_price` varchar(255) DEFAULT NULL,
  `home_listed` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `selling_reason` text,
  `subdivision` varchar(255) DEFAULT NULL,
  `lot_size` varchar(255) DEFAULT NULL,
  `out_bldgs` varchar(255) DEFAULT NULL,
  `occupied_by` varchar(255) DEFAULT NULL,
  `occupied_rent` int(11) DEFAULT NULL,
  `occupied_lease_up` varchar(255) DEFAULT NULL,
  `min_price` int(11) DEFAULT NULL,
  `tax_app_values` int(11) DEFAULT NULL,
  `arv` int(11) DEFAULT NULL,
  `home_listed_agent` varchar(255) DEFAULT NULL,
  `home_listed_expiration_date` datetime DEFAULT NULL,
  `estimated_home_value` int(11) DEFAULT NULL,
  `additional_property_detail` text,
  `last_list_price` varchar(255) DEFAULT NULL,
  `tax_appraised_value` varchar(255) DEFAULT NULL,
  `price_bottom` varchar(255) DEFAULT NULL,
  `legal_description` varchar(255) DEFAULT NULL,
  `is_new` tinyint(1) DEFAULT '1',
  `responder_sequence_subscription` tinyint(1) DEFAULT '1',
  `country` varchar(255) DEFAULT 'US',
  PRIMARY KEY (`id`),
  KEY `seller_profile_id` (`seller_profile_id`),
  KEY `profile_type_id` (`profile_type_id`),
  CONSTRAINT `seller_property_profiles_ibfk_1` FOREIGN KEY (`seller_profile_id`) REFERENCES `seller_profiles` (`id`),
  CONSTRAINT `seller_property_profiles_ibfk_2` FOREIGN KEY (`profile_type_id`) REFERENCES `profile_types` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `seller_responder_sequence_mappings` (
  `id` varchar(36) NOT NULL,
  `email_number` int(11) DEFAULT NULL,
  `seller_responder_sequence_id` varchar(36) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `email_subject` text,
  `email_body` text,
  PRIMARY KEY (`id`),
  KEY `seller_responder_sequence_id` (`seller_responder_sequence_id`),
  CONSTRAINT `seller_responder_sequence_mappings_ibfk_2` FOREIGN KEY (`seller_responder_sequence_id`) REFERENCES `seller_responder_sequences` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `seller_responder_sequences` (
  `id` varchar(36) NOT NULL,
  `sequence_name` varchar(255) DEFAULT NULL,
  `interval` int(11) DEFAULT NULL,
  `sequence_type` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `user_id` varchar(255) DEFAULT NULL,
  `active` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `seller_responder_sequences_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `seller_websites` (
  `id` varchar(36) NOT NULL,
  `user_id` varchar(36) NOT NULL,
  `header` varchar(255) DEFAULT NULL,
  `home_page_main_text_1` text,
  `permalink_text` varchar(255) DEFAULT NULL,
  `dynamic_css` varchar(255) DEFAULT NULL,
  `home_page_video_tour` varchar(255) DEFAULT NULL,
  `home_page_embed_video` varchar(255) DEFAULT NULL,
  `active` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `home_page_default_video` tinyint(1) DEFAULT NULL,
  `lead_funnel_video_tour` varchar(255) DEFAULT NULL,
  `lead_funnel_embed_video` varchar(255) DEFAULT NULL,
  `about_us_page_text` text,
  `lead_funnel_default_video` tinyint(1) DEFAULT NULL,
  `home_page_main_text_2` text,
  `meta_title` varchar(255) DEFAULT NULL,
  `meta_description` varchar(255) DEFAULT NULL,
  `domain_type` varchar(255) DEFAULT NULL,
  `ua_number` varchar(255) DEFAULT NULL,
  `landing_page_headline` text,
  `results_page_copy` text,
  `thankyou_page_headline` text,
  `thankyou_page_copy` text,
  `seller_magnet` tinyint(1) DEFAULT '0',
  `results_page_content` text,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `seller_websites_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `session_id` varchar(255) DEFAULT NULL,
  `data` text,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_sessions_on_session_id` (`session_id`),
  KEY `index_sessions_on_updated_at` (`updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `shopping_cart_order_transaction_failures` (
  `id` varchar(36) NOT NULL,
  `user_id` varchar(36) NOT NULL,
  `shopping_cart_name` varchar(255) DEFAULT NULL,
  `shopping_cart_customer_id_detail` varchar(255) DEFAULT NULL,
  `shopping_cart_product_id_detail` varchar(255) DEFAULT NULL,
  `shopping_cart_product_name` varchar(255) DEFAULT NULL,
  `shopping_cart_order_id_detail` varchar(255) DEFAULT NULL,
  `shopping_cart_user_email` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `shopping_cart_order_transaction_failures_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `shopping_cart_user_details` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `shopping_cart_customer_id_detail` varchar(255) DEFAULT NULL,
  `user_name` varchar(255) DEFAULT NULL,
  `user_id` varchar(36) DEFAULT NULL,
  `user_email` varchar(255) DEFAULT NULL,
  `shopping_cart_name` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `shopping_cart_user_details_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `shopping_cart_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `product_name` varchar(255) DEFAULT NULL,
  `quantity` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `site_stat_types` (
  `id` varchar(36) NOT NULL,
  `name` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `site_stats` (
  `id` varchar(36) NOT NULL,
  `site_stat_type_id` varchar(36) DEFAULT NULL,
  `user_id` varchar(36) DEFAULT NULL,
  `profile_id` varchar(36) DEFAULT NULL,
  `value_num` int(11) DEFAULT NULL,
  `stats_date` date NOT NULL,
  `created_on` date NOT NULL,
  PRIMARY KEY (`id`),
  KEY `site_stat_type_id` (`site_stat_type_id`),
  CONSTRAINT `site_stats_ibfk_1` FOREIGN KEY (`site_stat_type_id`) REFERENCES `site_stat_types` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `site_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` varchar(36) NOT NULL,
  `site_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `site_users_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `smtp_notifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `event` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `category` varchar(255) DEFAULT NULL,
  `reason` varchar(255) DEFAULT NULL,
  `attempt` varchar(255) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `response` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `social_media_accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `url` varchar(255) DEFAULT NULL,
  `user_id` varchar(36) DEFAULT NULL,
  `url_type_id` int(11) DEFAULT NULL,
  `site_type_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `social_media_accounts_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `spam_claims` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `claim_type` varchar(255) DEFAULT NULL,
  `claim_id` varchar(255) DEFAULT NULL,
  `created_by_user_id` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `squeeze_page_opt_ins` (
  `id` varchar(36) NOT NULL,
  `user_territory_id` varchar(36) DEFAULT NULL,
  `retail_buyer_first_name` varchar(255) DEFAULT NULL,
  `retail_buyer_email` varchar(255) DEFAULT NULL,
  `mail_number` int(11) DEFAULT '0',
  `trust_responder_subscription` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `user_territory_id` (`user_territory_id`),
  CONSTRAINT `squeeze_page_opt_ins_ibfk_1` FOREIGN KEY (`user_territory_id`) REFERENCES `user_territories` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `states` (
  `id` varchar(36) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `state_code` varchar(255) DEFAULT NULL,
  `country` varchar(255) DEFAULT 'us',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `super_contract_integrations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `state_id` varchar(255) DEFAULT NULL,
  `contract` longtext,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `state_id` (`state_id`),
  CONSTRAINT `super_contract_integrations_ibfk_1` FOREIGN KEY (`state_id`) REFERENCES `states` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `syndicate_properties` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `profile_id` varchar(36) NOT NULL,
  `contract_end_date` date DEFAULT NULL,
  `deal_terms` varchar(255) DEFAULT NULL,
  `price` varchar(255) DEFAULT NULL,
  `embed_video` varchar(255) DEFAULT NULL,
  `min_dow_pay` int(11) DEFAULT NULL,
  `acres` float DEFAULT NULL,
  `zip_code` varchar(255) DEFAULT NULL,
  `water` varchar(255) DEFAULT NULL,
  `property_address` varchar(255) DEFAULT NULL,
  `school_high` varchar(255) DEFAULT NULL,
  `school_middle` varchar(255) DEFAULT NULL,
  `feature_tags` varchar(255) DEFAULT NULL,
  `units` varchar(255) DEFAULT NULL,
  `baths` float DEFAULT NULL,
  `school_elementary` varchar(255) DEFAULT NULL,
  `county` varchar(255) DEFAULT NULL,
  `total_actual_rent` int(11) DEFAULT NULL,
  `property_type` varchar(255) DEFAULT NULL,
  `sewer` varchar(255) DEFAULT NULL,
  `neighborhood` varchar(255) DEFAULT NULL,
  `square_feet` int(11) DEFAULT NULL,
  `beds` int(11) DEFAULT NULL,
  `condo_community_name` varchar(255) DEFAULT NULL,
  `livingrooms` int(11) DEFAULT NULL,
  `video_tour` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `min_mon_pay` int(11) DEFAULT NULL,
  `garage` varchar(255) DEFAULT NULL,
  `stories` int(11) DEFAULT NULL,
  `pool` varchar(255) DEFAULT NULL,
  `waterfront` varchar(255) DEFAULT NULL,
  `manufactured_home` varchar(255) DEFAULT NULL,
  `house` varchar(255) DEFAULT NULL,
  `barn` varchar(255) DEFAULT NULL,
  `fencing` varchar(255) DEFAULT NULL,
  `natural_gas` varchar(255) DEFAULT NULL,
  `electricity` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `business_phone` varchar(255) DEFAULT NULL,
  `business_email` varchar(255) DEFAULT NULL,
  `image_link` varchar(255) DEFAULT NULL,
  `property_link` varchar(255) DEFAULT NULL,
  `published_date` date DEFAULT NULL,
  `latitude` float DEFAULT NULL,
  `longitude` float DEFAULT NULL,
  `agent_email` varchar(255) DEFAULT NULL,
  `country` varchar(255) DEFAULT 'US',
  `state` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `profile_id` (`profile_id`),
  CONSTRAINT `syndicate_properties_ibfk_1` FOREIGN KEY (`profile_id`) REFERENCES `profiles` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `temp_temp_temp` (
  `id` int(100) NOT NULL AUTO_INCREMENT,
  `zip_id` int(100) DEFAULT NULL,
  `county_id` int(100) DEFAULT NULL,
  `territory_id` int(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=801 DEFAULT CHARSET=latin1;

CREATE TABLE `territories` (
  `id` varchar(36) NOT NULL,
  `territory_name` varchar(255) DEFAULT NULL,
  `state_id` varchar(255) DEFAULT NULL,
  `reim_name` varchar(255) DEFAULT NULL,
  `country` varchar(255) DEFAULT 'us',
  PRIMARY KEY (`id`),
  KEY `state_id` (`state_id`),
  CONSTRAINT `territories_ibfk_1` FOREIGN KEY (`state_id`) REFERENCES `states` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `territory_counties` (
  `id` varchar(36) NOT NULL,
  `county_id` varchar(36) DEFAULT NULL,
  `territory_id` varchar(36) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `county_id` (`county_id`),
  KEY `territory_id` (`territory_id`),
  CONSTRAINT `territory_counties_ibfk_1` FOREIGN KEY (`county_id`) REFERENCES `counties` (`id`),
  CONSTRAINT `territory_counties_ibfk_2` FOREIGN KEY (`territory_id`) REFERENCES `territories` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `territory_id_zip_code` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `territory_id` varchar(255) DEFAULT NULL,
  `zip_code` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=962 DEFAULT CHARSET=latin1;

CREATE TABLE `testimonial_pictures` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `testimonial_id` varchar(36) NOT NULL,
  `content_type` varchar(255) DEFAULT NULL,
  `filename` varchar(255) DEFAULT NULL,
  `size` int(11) DEFAULT NULL,
  `parent_id` varchar(36) DEFAULT NULL,
  `thumbnail` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `testimonial_id` (`testimonial_id`),
  CONSTRAINT `testimonial_pictures_ibfk_1` FOREIGN KEY (`testimonial_id`) REFERENCES `testimonials` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `testimonials` (
  `id` varchar(36) NOT NULL,
  `investor_fname` varchar(255) DEFAULT NULL,
  `investor_lname` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `phone_number` varchar(255) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `closing_date` datetime DEFAULT NULL,
  `strategies` varchar(255) DEFAULT NULL,
  `sales_price` int(11) DEFAULT NULL,
  `gross_profit` int(11) DEFAULT NULL,
  `cash_flow` int(11) DEFAULT NULL,
  `deal_source` text,
  `problems_faced` text,
  `tools_used` varchar(255) DEFAULT NULL,
  `comments` text,
  `lessons_or_tips` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `market_release` tinyint(1) DEFAULT '1',
  `other_tools` varchar(255) DEFAULT NULL,
  `sales_estimate` tinyint(1) DEFAULT '0',
  `picture_types` varchar(255) DEFAULT NULL,
  `partner_account_id` int(11) NOT NULL,
  `name_private` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `tips` (
  `id` varchar(36) NOT NULL,
  `tip_text` varchar(255) DEFAULT NULL,
  `target_page` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `trust_responder_mail_series` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `buyer_notification_id` int(11) DEFAULT NULL,
  `trust_responder_summary_type` varchar(255) DEFAULT NULL,
  `email_body` text,
  `email_subject` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `buyer_notification_id` (`buyer_notification_id`),
  CONSTRAINT `trust_responder_mail_series_ibfk_1` FOREIGN KEY (`buyer_notification_id`) REFERENCES `buyer_notifications` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `user_classes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_type` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `user_type_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `user_company_images` (
  `id` varchar(36) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `parent_id` varchar(36) DEFAULT NULL,
  `content_type` varchar(255) DEFAULT NULL,
  `filename` varchar(255) DEFAULT NULL,
  `thumbnail` varchar(255) DEFAULT NULL,
  `size` int(11) DEFAULT NULL,
  `width` int(11) DEFAULT NULL,
  `height` int(11) DEFAULT NULL,
  `user_id` varchar(36) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `user_company_images_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `user_company_infos` (
  `id` varchar(36) NOT NULL,
  `user_id` varchar(36) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `business_name` varchar(255) NOT NULL,
  `business_address` varchar(255) NOT NULL,
  `business_phone` varchar(255) NOT NULL,
  `business_email` varchar(255) NOT NULL,
  `city` varchar(255) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `zipcode` varchar(7) DEFAULT NULL,
  `country` varchar(255) DEFAULT 'US',
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `user_company_infos_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `user_email_alert_definitions` (
  `id` varchar(36) NOT NULL,
  `title` varchar(255) NOT NULL,
  `disabled` tinyint(1) DEFAULT NULL,
  `trigger_parameter_value` varchar(255) DEFAULT NULL,
  `trigger_delay_days` int(11) DEFAULT NULL,
  `email_subject` varchar(500) NOT NULL,
  `message_body` text NOT NULL,
  `email_type` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `user_email_alert_notifications` (
  `id` varchar(36) NOT NULL,
  `title` varchar(255) NOT NULL,
  `disabled` tinyint(1) DEFAULT NULL,
  `alert_trigger_type_id` varchar(36) NOT NULL,
  `email_type` varchar(255) DEFAULT NULL,
  `trigger_parameter_value` varchar(255) DEFAULT NULL,
  `trigger_delay_days` int(11) DEFAULT NULL,
  `email_subject` varchar(500) NOT NULL,
  `message_body` text NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_email_alert_notifications_on_alert_trigger_type_id` (`alert_trigger_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `user_focus_investors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` varchar(36) NOT NULL,
  `is_longterm_hold` tinyint(1) DEFAULT '0',
  `is_fix_and_flip` tinyint(1) DEFAULT '0',
  `is_wholesale` tinyint(1) DEFAULT '0',
  `is_lines_and_notes` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `user_focus_investors_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `user_purchased_products` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` varchar(36) NOT NULL,
  `bundle_one` tinyint(1) DEFAULT '0',
  `bundle_two` tinyint(1) DEFAULT '0',
  `gold_upsell` tinyint(1) DEFAULT '0',
  `reim_pro_upsell` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `user_purchased_products_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `user_territories` (
  `id` varchar(36) NOT NULL,
  `user_id` varchar(36) DEFAULT NULL,
  `territory_id` varchar(36) DEFAULT NULL,
  `sequeeze_page_number` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `territory_id` (`territory_id`),
  CONSTRAINT `user_territories_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `user_territories_ibfk_2` FOREIGN KEY (`territory_id`) REFERENCES `territories` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `user_transaction_histories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` varchar(36) NOT NULL,
  `transanction_detail` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `user_transaction_histories_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `users` (
  `id` varchar(36) NOT NULL,
  `login` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `home_phone` varchar(255) DEFAULT NULL,
  `business_phone` varchar(255) DEFAULT NULL,
  `mobile_phone` varchar(255) DEFAULT NULL,
  `crypted_password` varchar(40) DEFAULT NULL,
  `salt` varchar(40) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `remember_token` varchar(255) DEFAULT NULL,
  `remember_token_expires_at` datetime DEFAULT NULL,
  `activation_code` varchar(40) DEFAULT NULL,
  `activated_at` datetime DEFAULT NULL,
  `last_login_at` datetime DEFAULT NULL,
  `previous_login_at` datetime DEFAULT NULL,
  `security_token` varchar(40) DEFAULT NULL,
  `security_token_expiry` datetime DEFAULT NULL,
  `digest_frequency` varchar(1) DEFAULT 'D',
  `admin_flag` tinyint(1) NOT NULL DEFAULT '0',
  `preferred_digest_format` varchar(10) DEFAULT 'html',
  `direct_message_frequency` varchar(1) NOT NULL DEFAULT 'I',
  `license_number` varchar(255) DEFAULT NULL,
  `user_class_id` int(11) DEFAULT NULL,
  `user_status` varchar(255) DEFAULT NULL,
  `is_infusionsoft` tinyint(1) DEFAULT '0',
  `number_of_territory` int(11) DEFAULT NULL,
  `investor_focus` varchar(255) DEFAULT NULL,
  `investing_since` date DEFAULT NULL,
  `about_me` text,
  `real_estate_experience` text,
  `customer_record` int(11) DEFAULT NULL,
  `auto_syndication` tinyint(1) DEFAULT '1',
  `activity_score` float DEFAULT '0',
  `add_user_comment` text,
  `is_user_have_access_to_reim` tinyint(1) DEFAULT '1',
  `tou_accepted_at` datetime DEFAULT NULL,
  `user_login_count_after_failed_payment` int(11) DEFAULT NULL,
  `is_user_have_failed_payment` tinyint(1) DEFAULT '0',
  `failed_payment_date` varchar(255) DEFAULT NULL,
  `fb_access_token` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_users_on_login` (`login`),
  KEY `user_class_id` (`user_class_id`),
  CONSTRAINT `users_ibfk_1` FOREIGN KEY (`user_class_id`) REFERENCES `user_classes` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `zctas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `zcta` int(11) NOT NULL,
  `zip_id` int(11) NOT NULL,
  `points` text,
  `levels` text,
  PRIMARY KEY (`id`),
  KEY `zip_id` (`zip_id`)
) ENGINE=MyISAM AUTO_INCREMENT=42852 DEFAULT CHARSET=latin1;

CREATE TABLE `zips` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `zip` varchar(7) NOT NULL,
  `state` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `lat` float DEFAULT NULL,
  `lng` float DEFAULT NULL,
  `direction` varchar(255) DEFAULT NULL,
  `county_id` varchar(255) DEFAULT NULL,
  `territory_id` varchar(255) DEFAULT NULL,
  `country` varchar(255) DEFAULT 'us',
  PRIMARY KEY (`id`),
  KEY `index_zips_on_zip` (`zip`),
  KEY `county_id` (`county_id`),
  KEY `territory_id` (`territory_id`)
) ENGINE=MyISAM AUTO_INCREMENT=41718 DEFAULT CHARSET=latin1;

INSERT INTO schema_migrations (version) VALUES ('1');

INSERT INTO schema_migrations (version) VALUES ('10');

INSERT INTO schema_migrations (version) VALUES ('100');

INSERT INTO schema_migrations (version) VALUES ('101');

INSERT INTO schema_migrations (version) VALUES ('102');

INSERT INTO schema_migrations (version) VALUES ('103');

INSERT INTO schema_migrations (version) VALUES ('104');

INSERT INTO schema_migrations (version) VALUES ('105');

INSERT INTO schema_migrations (version) VALUES ('106');

INSERT INTO schema_migrations (version) VALUES ('107');

INSERT INTO schema_migrations (version) VALUES ('108');

INSERT INTO schema_migrations (version) VALUES ('109');

INSERT INTO schema_migrations (version) VALUES ('11');

INSERT INTO schema_migrations (version) VALUES ('110');

INSERT INTO schema_migrations (version) VALUES ('111');

INSERT INTO schema_migrations (version) VALUES ('112');

INSERT INTO schema_migrations (version) VALUES ('113');

INSERT INTO schema_migrations (version) VALUES ('114');

INSERT INTO schema_migrations (version) VALUES ('115');

INSERT INTO schema_migrations (version) VALUES ('116');

INSERT INTO schema_migrations (version) VALUES ('117');

INSERT INTO schema_migrations (version) VALUES ('118');

INSERT INTO schema_migrations (version) VALUES ('119');

INSERT INTO schema_migrations (version) VALUES ('12');

INSERT INTO schema_migrations (version) VALUES ('120');

INSERT INTO schema_migrations (version) VALUES ('121');

INSERT INTO schema_migrations (version) VALUES ('122');

INSERT INTO schema_migrations (version) VALUES ('123');

INSERT INTO schema_migrations (version) VALUES ('124');

INSERT INTO schema_migrations (version) VALUES ('125');

INSERT INTO schema_migrations (version) VALUES ('126');

INSERT INTO schema_migrations (version) VALUES ('127');

INSERT INTO schema_migrations (version) VALUES ('128');

INSERT INTO schema_migrations (version) VALUES ('129');

INSERT INTO schema_migrations (version) VALUES ('13');

INSERT INTO schema_migrations (version) VALUES ('130');

INSERT INTO schema_migrations (version) VALUES ('131');

INSERT INTO schema_migrations (version) VALUES ('132');

INSERT INTO schema_migrations (version) VALUES ('133');

INSERT INTO schema_migrations (version) VALUES ('134');

INSERT INTO schema_migrations (version) VALUES ('135');

INSERT INTO schema_migrations (version) VALUES ('136');

INSERT INTO schema_migrations (version) VALUES ('137');

INSERT INTO schema_migrations (version) VALUES ('138');

INSERT INTO schema_migrations (version) VALUES ('139');

INSERT INTO schema_migrations (version) VALUES ('14');

INSERT INTO schema_migrations (version) VALUES ('140');

INSERT INTO schema_migrations (version) VALUES ('141');

INSERT INTO schema_migrations (version) VALUES ('142');

INSERT INTO schema_migrations (version) VALUES ('143');

INSERT INTO schema_migrations (version) VALUES ('144');

INSERT INTO schema_migrations (version) VALUES ('145');

INSERT INTO schema_migrations (version) VALUES ('146');

INSERT INTO schema_migrations (version) VALUES ('147');

INSERT INTO schema_migrations (version) VALUES ('148');

INSERT INTO schema_migrations (version) VALUES ('149');

INSERT INTO schema_migrations (version) VALUES ('15');

INSERT INTO schema_migrations (version) VALUES ('150');

INSERT INTO schema_migrations (version) VALUES ('151');

INSERT INTO schema_migrations (version) VALUES ('152');

INSERT INTO schema_migrations (version) VALUES ('153');

INSERT INTO schema_migrations (version) VALUES ('154');

INSERT INTO schema_migrations (version) VALUES ('155');

INSERT INTO schema_migrations (version) VALUES ('156');

INSERT INTO schema_migrations (version) VALUES ('157');

INSERT INTO schema_migrations (version) VALUES ('158');

INSERT INTO schema_migrations (version) VALUES ('159');

INSERT INTO schema_migrations (version) VALUES ('16');

INSERT INTO schema_migrations (version) VALUES ('160');

INSERT INTO schema_migrations (version) VALUES ('161');

INSERT INTO schema_migrations (version) VALUES ('162');

INSERT INTO schema_migrations (version) VALUES ('163');

INSERT INTO schema_migrations (version) VALUES ('164');

INSERT INTO schema_migrations (version) VALUES ('165');

INSERT INTO schema_migrations (version) VALUES ('166');

INSERT INTO schema_migrations (version) VALUES ('167');

INSERT INTO schema_migrations (version) VALUES ('168');

INSERT INTO schema_migrations (version) VALUES ('17');

INSERT INTO schema_migrations (version) VALUES ('18');

INSERT INTO schema_migrations (version) VALUES ('19');

INSERT INTO schema_migrations (version) VALUES ('2');

INSERT INTO schema_migrations (version) VALUES ('20');

INSERT INTO schema_migrations (version) VALUES ('20110304140526');

INSERT INTO schema_migrations (version) VALUES ('20110316134723');

INSERT INTO schema_migrations (version) VALUES ('20110318115306');

INSERT INTO schema_migrations (version) VALUES ('20110322084049');

INSERT INTO schema_migrations (version) VALUES ('20110322133437');

INSERT INTO schema_migrations (version) VALUES ('20110325150136');

INSERT INTO schema_migrations (version) VALUES ('20110328100510');

INSERT INTO schema_migrations (version) VALUES ('20110330111902');

INSERT INTO schema_migrations (version) VALUES ('20110405121633');

INSERT INTO schema_migrations (version) VALUES ('20110420095316');

INSERT INTO schema_migrations (version) VALUES ('20110420105405');

INSERT INTO schema_migrations (version) VALUES ('20110420121157');

INSERT INTO schema_migrations (version) VALUES ('20110422112707');

INSERT INTO schema_migrations (version) VALUES ('20110422120217');

INSERT INTO schema_migrations (version) VALUES ('20110422150916');

INSERT INTO schema_migrations (version) VALUES ('20110425112511');

INSERT INTO schema_migrations (version) VALUES ('20110425112532');

INSERT INTO schema_migrations (version) VALUES ('20110425154643');

INSERT INTO schema_migrations (version) VALUES ('20110428185301');

INSERT INTO schema_migrations (version) VALUES ('20110503115608');

INSERT INTO schema_migrations (version) VALUES ('20110505131201');

INSERT INTO schema_migrations (version) VALUES ('20110505150556');

INSERT INTO schema_migrations (version) VALUES ('20110506070517');

INSERT INTO schema_migrations (version) VALUES ('20110506114845');

INSERT INTO schema_migrations (version) VALUES ('20110509113524');

INSERT INTO schema_migrations (version) VALUES ('20110510055815');

INSERT INTO schema_migrations (version) VALUES ('20110510093236');

INSERT INTO schema_migrations (version) VALUES ('20110511092702');

INSERT INTO schema_migrations (version) VALUES ('20110512120120');

INSERT INTO schema_migrations (version) VALUES ('20110512122132');

INSERT INTO schema_migrations (version) VALUES ('20110513133739');

INSERT INTO schema_migrations (version) VALUES ('20110516085635');

INSERT INTO schema_migrations (version) VALUES ('20110518083450');

INSERT INTO schema_migrations (version) VALUES ('20110519090626');

INSERT INTO schema_migrations (version) VALUES ('20110519110927');

INSERT INTO schema_migrations (version) VALUES ('20110521125337');

INSERT INTO schema_migrations (version) VALUES ('20110521131231');

INSERT INTO schema_migrations (version) VALUES ('20110522014822');

INSERT INTO schema_migrations (version) VALUES ('20110524145148');

INSERT INTO schema_migrations (version) VALUES ('20110525063052');

INSERT INTO schema_migrations (version) VALUES ('20110525095951');

INSERT INTO schema_migrations (version) VALUES ('20110526100717');

INSERT INTO schema_migrations (version) VALUES ('20110526185613');

INSERT INTO schema_migrations (version) VALUES ('20110527073956');

INSERT INTO schema_migrations (version) VALUES ('20110528071407');

INSERT INTO schema_migrations (version) VALUES ('20110530081814');

INSERT INTO schema_migrations (version) VALUES ('20110530111100');

INSERT INTO schema_migrations (version) VALUES ('20110531132145');

INSERT INTO schema_migrations (version) VALUES ('20110605100121');

INSERT INTO schema_migrations (version) VALUES ('20110608094636');

INSERT INTO schema_migrations (version) VALUES ('20110609061429');

INSERT INTO schema_migrations (version) VALUES ('20110614071947');

INSERT INTO schema_migrations (version) VALUES ('20110615121135');

INSERT INTO schema_migrations (version) VALUES ('20110617065142');

INSERT INTO schema_migrations (version) VALUES ('20110617084418');

INSERT INTO schema_migrations (version) VALUES ('20110621091204');

INSERT INTO schema_migrations (version) VALUES ('20110621094724');

INSERT INTO schema_migrations (version) VALUES ('20110622114641');

INSERT INTO schema_migrations (version) VALUES ('20110622123234');

INSERT INTO schema_migrations (version) VALUES ('20110623083343');

INSERT INTO schema_migrations (version) VALUES ('20110624091652');

INSERT INTO schema_migrations (version) VALUES ('20110628144530');

INSERT INTO schema_migrations (version) VALUES ('20110629115857');

INSERT INTO schema_migrations (version) VALUES ('20110701073357');

INSERT INTO schema_migrations (version) VALUES ('20110701103236');

INSERT INTO schema_migrations (version) VALUES ('20110701104407');

INSERT INTO schema_migrations (version) VALUES ('20110702145717');

INSERT INTO schema_migrations (version) VALUES ('20110704112211');

INSERT INTO schema_migrations (version) VALUES ('20110708133931');

INSERT INTO schema_migrations (version) VALUES ('20110712070324');

INSERT INTO schema_migrations (version) VALUES ('20110713131118');

INSERT INTO schema_migrations (version) VALUES ('20110719052706');

INSERT INTO schema_migrations (version) VALUES ('20110719081235');

INSERT INTO schema_migrations (version) VALUES ('20110722071002');

INSERT INTO schema_migrations (version) VALUES ('20110723000513');

INSERT INTO schema_migrations (version) VALUES ('20110725102704');

INSERT INTO schema_migrations (version) VALUES ('20110727141935');

INSERT INTO schema_migrations (version) VALUES ('20110804142938');

INSERT INTO schema_migrations (version) VALUES ('20110808101544');

INSERT INTO schema_migrations (version) VALUES ('20110809144534');

INSERT INTO schema_migrations (version) VALUES ('20110811061649');

INSERT INTO schema_migrations (version) VALUES ('20110811135933');

INSERT INTO schema_migrations (version) VALUES ('20110815204738');

INSERT INTO schema_migrations (version) VALUES ('20110818143508');

INSERT INTO schema_migrations (version) VALUES ('20110824083136');

INSERT INTO schema_migrations (version) VALUES ('20110824090911');

INSERT INTO schema_migrations (version) VALUES ('20110824103405');

INSERT INTO schema_migrations (version) VALUES ('20110825071445');

INSERT INTO schema_migrations (version) VALUES ('20110825073212');

INSERT INTO schema_migrations (version) VALUES ('20110829050203');

INSERT INTO schema_migrations (version) VALUES ('20110829070335');

INSERT INTO schema_migrations (version) VALUES ('20110829070551');

INSERT INTO schema_migrations (version) VALUES ('20110829074255');

INSERT INTO schema_migrations (version) VALUES ('20110829074524');

INSERT INTO schema_migrations (version) VALUES ('20110829132346');

INSERT INTO schema_migrations (version) VALUES ('20110830130256');

INSERT INTO schema_migrations (version) VALUES ('20110830142409');

INSERT INTO schema_migrations (version) VALUES ('20110830144005');

INSERT INTO schema_migrations (version) VALUES ('20110831133742');

INSERT INTO schema_migrations (version) VALUES ('20110902103723');

INSERT INTO schema_migrations (version) VALUES ('20110902142342');

INSERT INTO schema_migrations (version) VALUES ('20110903231846');

INSERT INTO schema_migrations (version) VALUES ('20110907155722');

INSERT INTO schema_migrations (version) VALUES ('20110913130036');

INSERT INTO schema_migrations (version) VALUES ('20110916133616');

INSERT INTO schema_migrations (version) VALUES ('20110919115433');

INSERT INTO schema_migrations (version) VALUES ('20110919214756');

INSERT INTO schema_migrations (version) VALUES ('20110921130725');

INSERT INTO schema_migrations (version) VALUES ('20110921130730');

INSERT INTO schema_migrations (version) VALUES ('20110921132529');

INSERT INTO schema_migrations (version) VALUES ('20110921132530');

INSERT INTO schema_migrations (version) VALUES ('20110922170705');

INSERT INTO schema_migrations (version) VALUES ('20110922180231');

INSERT INTO schema_migrations (version) VALUES ('20110923105545');

INSERT INTO schema_migrations (version) VALUES ('20110927110909');

INSERT INTO schema_migrations (version) VALUES ('20110927174955');

INSERT INTO schema_migrations (version) VALUES ('20110928082825');

INSERT INTO schema_migrations (version) VALUES ('20110929061822');

INSERT INTO schema_migrations (version) VALUES ('20110929120133');

INSERT INTO schema_migrations (version) VALUES ('20110930144247');

INSERT INTO schema_migrations (version) VALUES ('20111003043424');

INSERT INTO schema_migrations (version) VALUES ('20111006171724');

INSERT INTO schema_migrations (version) VALUES ('20111009224655');

INSERT INTO schema_migrations (version) VALUES ('20111011093848');

INSERT INTO schema_migrations (version) VALUES ('20111012084729');

INSERT INTO schema_migrations (version) VALUES ('20111013082557');

INSERT INTO schema_migrations (version) VALUES ('20111014105522');

INSERT INTO schema_migrations (version) VALUES ('20111014110314');

INSERT INTO schema_migrations (version) VALUES ('20111014110803');

INSERT INTO schema_migrations (version) VALUES ('20111014121602');

INSERT INTO schema_migrations (version) VALUES ('20111018094523');

INSERT INTO schema_migrations (version) VALUES ('20111018194840');

INSERT INTO schema_migrations (version) VALUES ('20111021220557');

INSERT INTO schema_migrations (version) VALUES ('20111024050336');

INSERT INTO schema_migrations (version) VALUES ('20111102092733');

INSERT INTO schema_migrations (version) VALUES ('20111102110709');

INSERT INTO schema_migrations (version) VALUES ('20111102123423');

INSERT INTO schema_migrations (version) VALUES ('20111103071335');

INSERT INTO schema_migrations (version) VALUES ('20111103085606');

INSERT INTO schema_migrations (version) VALUES ('20111103105618');

INSERT INTO schema_migrations (version) VALUES ('20111103113312');

INSERT INTO schema_migrations (version) VALUES ('20111104105028');

INSERT INTO schema_migrations (version) VALUES ('20111108182126');

INSERT INTO schema_migrations (version) VALUES ('20111110160444');

INSERT INTO schema_migrations (version) VALUES ('20111111065901');

INSERT INTO schema_migrations (version) VALUES ('20111111141905');

INSERT INTO schema_migrations (version) VALUES ('20111116121301');

INSERT INTO schema_migrations (version) VALUES ('20111117001719');

INSERT INTO schema_migrations (version) VALUES ('20111117065523');

INSERT INTO schema_migrations (version) VALUES ('20111117105628');

INSERT INTO schema_migrations (version) VALUES ('20111117114042');

INSERT INTO schema_migrations (version) VALUES ('20111118113459');

INSERT INTO schema_migrations (version) VALUES ('20111118190722');

INSERT INTO schema_migrations (version) VALUES ('20111122053336');

INSERT INTO schema_migrations (version) VALUES ('20111123100244');

INSERT INTO schema_migrations (version) VALUES ('20111130134155');

INSERT INTO schema_migrations (version) VALUES ('21');

INSERT INTO schema_migrations (version) VALUES ('22');

INSERT INTO schema_migrations (version) VALUES ('23');

INSERT INTO schema_migrations (version) VALUES ('24');

INSERT INTO schema_migrations (version) VALUES ('25');

INSERT INTO schema_migrations (version) VALUES ('26');

INSERT INTO schema_migrations (version) VALUES ('27');

INSERT INTO schema_migrations (version) VALUES ('28');

INSERT INTO schema_migrations (version) VALUES ('29');

INSERT INTO schema_migrations (version) VALUES ('3');

INSERT INTO schema_migrations (version) VALUES ('30');

INSERT INTO schema_migrations (version) VALUES ('31');

INSERT INTO schema_migrations (version) VALUES ('32');

INSERT INTO schema_migrations (version) VALUES ('33');

INSERT INTO schema_migrations (version) VALUES ('34');

INSERT INTO schema_migrations (version) VALUES ('35');

INSERT INTO schema_migrations (version) VALUES ('36');

INSERT INTO schema_migrations (version) VALUES ('37');

INSERT INTO schema_migrations (version) VALUES ('38');

INSERT INTO schema_migrations (version) VALUES ('39');

INSERT INTO schema_migrations (version) VALUES ('4');

INSERT INTO schema_migrations (version) VALUES ('40');

INSERT INTO schema_migrations (version) VALUES ('41');

INSERT INTO schema_migrations (version) VALUES ('42');

INSERT INTO schema_migrations (version) VALUES ('43');

INSERT INTO schema_migrations (version) VALUES ('44');

INSERT INTO schema_migrations (version) VALUES ('45');

INSERT INTO schema_migrations (version) VALUES ('46');

INSERT INTO schema_migrations (version) VALUES ('47');

INSERT INTO schema_migrations (version) VALUES ('48');

INSERT INTO schema_migrations (version) VALUES ('49');

INSERT INTO schema_migrations (version) VALUES ('5');

INSERT INTO schema_migrations (version) VALUES ('50');

INSERT INTO schema_migrations (version) VALUES ('51');

INSERT INTO schema_migrations (version) VALUES ('515415341');

INSERT INTO schema_migrations (version) VALUES ('52');

INSERT INTO schema_migrations (version) VALUES ('53');

INSERT INTO schema_migrations (version) VALUES ('54');

INSERT INTO schema_migrations (version) VALUES ('55');

INSERT INTO schema_migrations (version) VALUES ('56');

INSERT INTO schema_migrations (version) VALUES ('57');

INSERT INTO schema_migrations (version) VALUES ('58');

INSERT INTO schema_migrations (version) VALUES ('59');

INSERT INTO schema_migrations (version) VALUES ('6');

INSERT INTO schema_migrations (version) VALUES ('60');

INSERT INTO schema_migrations (version) VALUES ('61');

INSERT INTO schema_migrations (version) VALUES ('62');

INSERT INTO schema_migrations (version) VALUES ('63');

INSERT INTO schema_migrations (version) VALUES ('64');

INSERT INTO schema_migrations (version) VALUES ('65');

INSERT INTO schema_migrations (version) VALUES ('66');

INSERT INTO schema_migrations (version) VALUES ('67');

INSERT INTO schema_migrations (version) VALUES ('68');

INSERT INTO schema_migrations (version) VALUES ('69');

INSERT INTO schema_migrations (version) VALUES ('7');

INSERT INTO schema_migrations (version) VALUES ('70');

INSERT INTO schema_migrations (version) VALUES ('71');

INSERT INTO schema_migrations (version) VALUES ('72');

INSERT INTO schema_migrations (version) VALUES ('73');

INSERT INTO schema_migrations (version) VALUES ('74');

INSERT INTO schema_migrations (version) VALUES ('75');

INSERT INTO schema_migrations (version) VALUES ('76');

INSERT INTO schema_migrations (version) VALUES ('77');

INSERT INTO schema_migrations (version) VALUES ('78');

INSERT INTO schema_migrations (version) VALUES ('79');

INSERT INTO schema_migrations (version) VALUES ('8');

INSERT INTO schema_migrations (version) VALUES ('80');

INSERT INTO schema_migrations (version) VALUES ('81');

INSERT INTO schema_migrations (version) VALUES ('82');

INSERT INTO schema_migrations (version) VALUES ('83');

INSERT INTO schema_migrations (version) VALUES ('84');

INSERT INTO schema_migrations (version) VALUES ('85');

INSERT INTO schema_migrations (version) VALUES ('86');

INSERT INTO schema_migrations (version) VALUES ('87');

INSERT INTO schema_migrations (version) VALUES ('88');

INSERT INTO schema_migrations (version) VALUES ('89');

INSERT INTO schema_migrations (version) VALUES ('9');

INSERT INTO schema_migrations (version) VALUES ('90');

INSERT INTO schema_migrations (version) VALUES ('91');

INSERT INTO schema_migrations (version) VALUES ('92');

INSERT INTO schema_migrations (version) VALUES ('93');

INSERT INTO schema_migrations (version) VALUES ('94');

INSERT INTO schema_migrations (version) VALUES ('95');

INSERT INTO schema_migrations (version) VALUES ('96');

INSERT INTO schema_migrations (version) VALUES ('97');

INSERT INTO schema_migrations (version) VALUES ('98');

INSERT INTO schema_migrations (version) VALUES ('99');