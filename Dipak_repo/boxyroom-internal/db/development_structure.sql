CREATE TABLE "applications" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "property_id" integer, "created_at" datetime, "updated_at" datetime, "profile_id" integer, "state" varchar(255));
CREATE TABLE "messages" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "subject" varchar(255), "body" text, "read" boolean DEFAULT 'f', "sender_type" varchar(255), "sender_id" integer, "receiver_type" varchar(255), "receiver_id" integer, "trashed_by_sender" boolean DEFAULT 'f', "trashed_by_receiver" boolean DEFAULT 'f', "created_at" datetime, "updated_at" datetime);
CREATE TABLE "profiles" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(255), "user_id" integer, "gender" varchar(255), "fullname" varchar(255), "country" varchar(255), "address" text, "hometel" varchar(255), "worktel" varchar(255), "mobiletel" varchar(255), "dateofbirth" date, "lengthatcurrentaddress" date, "currentlandlordname" varchar(255), "currentlandlordtel" varchar(255), "reasonsforleaving" text, "petsno" integer, "petsbreed" varchar(255), "workstudyname" varchar(255), "workstudystartdate" date, "workstudyenddate" date, "workstudyadminname" varchar(255), "workstudyadmintel" varchar(255), "workstudyadminemail" varchar(255), "referencename" varchar(255), "referencerelationship" varchar(255), "referencetel" varchar(255), "created_at" datetime, "updated_at" datetime);
CREATE TABLE "properties" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "title" varchar(255), "description" text, "country" varchar(255), "city" varchar(255), "streetname" varchar(255), "postalcode" integer, "rentalperiod" integer NOT NULL, "landlordlivein" boolean DEFAULT 'f', "category" varchar(255) NOT NULL, "facilitiesnearby" varchar(255), "transportnearby" varchar(255), "status" varchar(255) DEFAULT 'pending', "user_id" integer, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "schema_migrations" ("version" varchar(255) NOT NULL);
CREATE TABLE "users" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "firstname" varchar(255), "lastname" varchar(255), "birthdate" date, "occupation" varchar(255), "profile_image_url" varchar(255), "about" varchar(255), "email" varchar(255) NOT NULL, "crypted_password" varchar(255) NOT NULL, "password_salt" varchar(255) NOT NULL, "level" varchar(255), "persistence_token" varchar(255) NOT NULL, "perishable_token" varchar(255) NOT NULL, "active" boolean DEFAULT 'f' NOT NULL, "failed_login_count" integer DEFAULT 0 NOT NULL, "current_login_ip" varchar(255), "last_login_ip" varchar(255), "current_login_at" datetime, "last_login_at" datetime, "created_at" datetime, "updated_at" datetime);
CREATE INDEX "index_messages_on_receiver_type_and_receiver_id_and_created_at" ON "messages" ("receiver_type", "receiver_id", "created_at");
CREATE UNIQUE INDEX "unique_schema_migrations" ON "schema_migrations" ("version");
INSERT INTO schema_migrations (version) VALUES ('20091002023953');

INSERT INTO schema_migrations (version) VALUES ('20091004003521');

INSERT INTO schema_migrations (version) VALUES ('20091004134251');

INSERT INTO schema_migrations (version) VALUES ('20091005125205');

INSERT INTO schema_migrations (version) VALUES ('20091022045356');

INSERT INTO schema_migrations (version) VALUES ('20091022082455');

INSERT INTO schema_migrations (version) VALUES ('20091022143701');