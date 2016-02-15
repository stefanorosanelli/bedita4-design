-- max num characters
-- TINYTEXT     256
-- TEXT         65536
-- MEDIUMTEXT   16777216
-- LONGTEXT     4294967296

-- unsigned max values
-- TINYINT      255
-- SMALLINT     65535
-- MEDIUMINT    16777215
-- INT          4294967295
-- BIGINT       18446744073709551615


SET FOREIGN_KEY_CHECKS=0;

-- ------------------
--   USERS & AUTH
-- ------------------

DROP TABLE IF EXISTS `users`;
CREATE TABLE users (

  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  username VARCHAR(100) NOT NULL              COMMENT 'login user name',
  password TINYTEXT NULL                      COMMENT 'login password, if empty external auth is used',
  blocked BOOL NOT NULL DEFAULT 0             COMMENT 'user blocked flag',
  last_login DATETIME DEFAULT NULL            COMMENT 'last succcessful login datetime',
  last_login_err DATETIME DEFAULT NULL        COMMENT 'last login filaure datetime',
  num_login_err TINYINT NOT NULL DEFAULT 0    COMMENT 'number of consecutive login failures',
  created DATETIME NOT NULL                   COMMENT 'record creation date',
  -- from MySQL 5.6.5 `created` NOT NULL DATETIME DEFAULT CURRENT_TIMESTAMP,
  modified DATETIME NOT NULL                  COMMENT 'record last modification date',
  -- from MySQL 5.6.5 `modified` NOT NULL DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP

  PRIMARY KEY  (id),
  UNIQUE KEY (username)

) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT = 'authenticated users basic data';


DROP TABLE IF EXISTS `auth_providers`;
CREATE TABLE auth_providers (

  id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  provider_name TINYTEXT NOT NULL             COMMENT 'external provider name: facebook, google, github...',
  provider_url TINYTEXT NOT NULL              COMMENT 'external provider url',

  PRIMARY KEY  (id)

) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT = 'supported external auth providers';

DROP TABLE IF EXISTS `external_auth`;
CREATE TABLE external_auth (

  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id INT UNSIGNED NOT NULL               COMMENT 'reference to system user',
  auth_provider_id SMALLINT UNSIGNED NOT NULL COMMENT 'link to external auth provider: ',
  auth_params TEXT DEFAULT NULL               COMMENT 'external auth params, serialized JSON',
  -- From MySQL 5.7.8 JSON type

  PRIMARY KEY  (id),
  FOREIGN KEY (auth_provider_id) REFERENCES auth_providers(id),
  FOREIGN KEY(user_id)
    REFERENCES users(id)
      ON DELETE CASCADE
      ON UPDATE NO ACTION

) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT = 'user external auth data' ;

-- -------------
--   CONFIG
-- -------------

DROP TABLE IF EXISTS `config`;
CREATE TABLE config (

  name VARCHAR(255) NOT NULL                  COMMENT 'configuration parameter key',
  value TEXT NOT NULL                         COMMENT 'external provider name: facebook, google, github...',
  created DATETIME NOT NULL                   COMMENT 'creation date',

  PRIMARY KEY  (name)

) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT = 'configuration parameters' ;

-- -------------
--   OBJECTS
-- -------------

DROP TABLE IF EXISTS `object_types`;
CREATE TABLE object_types (

  id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(50) NOT NULL                 COMMENT 'object type name',
  module_name VARCHAR(100)                  COMMENT 'default module for object type',

  PRIMARY KEY (id),
  UNIQUE (name)

) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT 'obect types definitions';


DROP TABLE IF EXISTS `property_types`;
CREATE TABLE property_types (

  id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(50) NOT NULL                  COMMENT 'property type name',

  PRIMARY KEY (id),
  UNIQUE (name)

) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT 'property types definitions';


DROP TABLE IF EXISTS `properties`;
CREATE TABLE properties (

  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  object_type_id SMALLINT UNSIGNED NULL       COMMENT 'link to object_types.id',
  property_type_id SMALLINT UNSIGNED NOT NULL COMMENT 'link to property_type.id',
  multiple BOOL DEFAULT 0                     COMMENT 'multiple values for this property?',

  PRIMARY KEY(id),
  UNIQUE name_type(name, object_type_id),
  INDEX (name),
  INDEX (object_type_id),
  INDEX (property_type_id),

  FOREIGN KEY(object_type_id) REFERENCES object_types(id),
  FOREIGN KEY(property_type_id) REFERENCES property_types(id)

) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT = 'object properties definitions' ;


DROP TABLE IF EXISTS `property_options`;
CREATE TABLE property_options (

  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  property_id INT UNSIGNED NOT NULL           COMMENT 'link to properties.id',
  property_option TEXT NOT NULL               COMMENT 'option item value',
  PRIMARY KEY(id),
  FOREIGN KEY(property_id)
    REFERENCES properties(id)
      ON DELETE CASCADE
      ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT = 'available items of properties of type option' ;


DROP TABLE IF EXISTS `property_values`;
CREATE TABLE property_values (

  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  property_id INT UNSIGNED NOT NULL           COMMENT 'link to properties.id',
  object_id INT UNSIGNED NOT NULL             COMMENT 'link to objects.id',
  property_value TEXT NOT NULL                COMMENT 'property value of linked object',

  PRIMARY KEY(id),

  FOREIGN KEY(object_id)
    REFERENCES objects(id)
      ON DELETE CASCADE
      ON UPDATE NO ACTION,
  FOREIGN KEY(property_id)
    REFERENCES properties(id)
      ON DELETE CASCADE
      ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT = 'object properties values' ;


DROP TABLE IF EXISTS `objects`;
CREATE TABLE objects (

  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  type_id SMALLINT UNSIGNED NOT NULL        COMMENT 'object type id',
  status ENUM('on', 'off', 'draft', 'deleted') NOT NULL DEFAULT 'draft'  COMMENT 'object status: on, draft, off, deleted',
  uname VARCHAR(255) NOT NULL               COMMENT 'unique and url friendly resource name (slug)',
  locked BOOLEAN NOT NULL DEFAULT 0         COMMENT 'locked flag: some fields (status, uname,...) cannot be changed',
  created DATETIME NOT NULL                 COMMENT 'creation date',
  modified DATETIME NOT NULL                COMMENT 'last modification date',
  published DATETIME NOT NULL               COMMENT 'publication date, status set to ON',
  title TEXT NULL,
  description MEDIUMTEXT NULL,
  body MEDIUMTEXT NULL,
  extra MEDIUMTEXT NULL                     COMMENT 'object data extensions (JSON format)',
  -- From MySQL 5.7.8 use JSON type
  lang CHAR(3) NOT NULL                     COMMENT 'language used, ISO 639-3 code',
  created_by INT UNSIGNED NOT NULL          COMMENT 'user who created object',
  modified_by INT UNSIGNED NOT NULL         COMMENT 'last user to modify object',
  publish_start DATETIME NULL               COMMENT 'publish from this date on',
  publish_end DATETIME NULL                 COMMENT 'publish until this date',

  PRIMARY KEY (id),
  UNIQUE KEY (uname),
  INDEX (type_id),

  FOREIGN KEY(type_id)
    REFERENCES object_types(id)
      ON DELETE CASCADE
      ON UPDATE NO ACTION

) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT 'base table for all objects';

-- --------------------
--  CORE OBJECT TYPES
-- --------------------

DROP TABLE IF EXISTS `media`;
CREATE TABLE media (

  id INT UNSIGNED NOT NULL,
  uri TEXT NOT NULL                 COMMENT 'media uri: relative path on local filesystem or remote URL',
  name TEXT NULL                    COMMENT 'file name',
  mime_type TINYTEXT NOT NULL       COMMENT 'resource mime type',
  file_size INT(11) UNSIGNED NULL   COMMENT 'file size in bytes (if local)',
  hash_file VARCHAR(255) NULL       COMMENT 'md5 hash of local file',
  original_name TEXT NULL           COMMENT 'original name for uploaded file',
  width MEDIUMINT(6) UNSIGNED NULL  COMMENT '(image) width',
  height MEDIUMINT(6) UNSIGNED NULL COMMENT '(image) height',
  provider  TINYTEXT NULL           COMMENT 'external provider/service name',
  media_uid VARCHAR(255) NULL       COMMENT 'uid, used for remote videos',
  thumbnail TINYTEXT NULL           COMMENT 'remote media thumbnail URL',

  PRIMARY KEY(id),
  INDEX (hash_file),

  FOREIGN KEY(id)
    REFERENCES objects(id)
      ON DELETE CASCADE
      ON UPDATE NO ACTION

) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT 'media objects like images, audio, videos, files';


DROP TABLE IF EXISTS `profiles`;
CREATE TABLE profiles (
  id INT UNSIGNED NOT NULL,
  user_id INT UNSIGNED NULL         COMMENT 'link to users.id, if not null',
  name TINYTEXT NULL                COMMENT 'person name, can be NULL',
  surname TINYTEXT NULL             COMMENT 'person surname, can be NULL',
  email VARCHAR(100) NULL           COMMENT 'first email, can be NULL',
  person_title TINYTEXT NULL        COMMENT 'person title, for example Sir, Madame, Prof, Doct, ecc., can be NULL',
  gender TINYTEXT NULL              COMMENT 'gender, for example male, female, can be NULL',
  birthdate DATE NULL               COMMENT 'date of birth, can be NULL',
  deathdate DATE NULL               COMMENT 'date of death, can be NULL',
  company BOOL NOT NULL DEFAULT '0' COMMENT 'is a company, default: false',
  company_name TINYTEXT NULL        COMMENT 'name of company, can be NULL',
  company_kind TINYTEXT NULL        COMMENT 'type of company, can be NULL',
  street_address TEXT NULL          COMMENT 'address street, can be NULL',
  city TINYTEXT NULL                COMMENT 'city, can be NULL',
  zipcode TINYTEXT NULL             COMMENT 'zipcode, can be NULL',
  country TINYTEXT NULL             COMMENT 'country, can be NULL',
  state_name TINYTEXT NULL          COMMENT 'state, can be NULL',
  phone TINYTEXT NULL               COMMENT 'first phone number, can be NULL',
  website TEXT NULL                 COMMENT 'website url, can be NULL',

  PRIMARY KEY(id),
  UNIQUE KEY (email),

  FOREIGN KEY(user_id) REFERENCES users(id),

  FOREIGN KEY(id)
    REFERENCES objects(id)
      ON DELETE CASCADE
      ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT = 'user profiles, addressbook data' ;

-- -------------
--   RELATIONS
-- -------------

DROP TABLE IF EXISTS `relation_definitions`;
CREATE TABLE relation_definitions (

  name VARCHAR(100) NOT NULL            COMMENT 'relation name',
  label TINYTEXT NOT NULL               COMMENT 'relation label',
  inverse_name VARCHAR(100) NOT NULL    COMMENT 'inverse relation name',
  inverse_label TINYTEXT NOT NULL       COMMENT 'inverse relation label',
  params MEDIUMTEXT NULL                COMMENT 'relation parameters definitions (JSON format)',
-- From MySQL 5.7.8 use JSON type

  PRIMARY KEY (name),
  UNIQUE KEY (inverse_name)

) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT 'object relations definitions';


DROP TABLE IF EXISTS `relation_types`;
CREATE TABLE relation_types (

  name VARCHAR(255) NOT NULL                COMMENT 'relation name',
  type_id SMALLINT UNSIGNED NOT NULL        COMMENT 'object type id',
  position ENUM ('left', 'right') NOT NULL  COMMENT 'type position in relation',

  PRIMARY KEY name_type_position (name, type_id, position),

  FOREIGN KEY(name)
    REFERENCES relation_definitions(name)
      ON DELETE CASCADE
      ON UPDATE NO ACTION,
  FOREIGN KEY(type_id)
    REFERENCES object_types(id)
      ON DELETE CASCADE
      ON UPDATE NO ACTION

) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT 'type constraints in object relations';


DROP TABLE IF EXISTS `relations`;
CREATE TABLE relations (

  left_id INT UNSIGNED NOT NULL         COMMENT 'left part of the relation object id',
  name VARCHAR(255) NOT NULL            COMMENT 'relation name',
  right_id INT UNSIGNED NOT NULL        COMMENT 'right part of the relation object id',
  inv_name VARCHAR(255) NOT NULL        COMMENT 'inverse relation name',
  priority INT UNSIGNED NOT NULL        COMMENT 'priority order in relation',
  inv_priority INT UNSIGNED NOT NULL    COMMENT 'priority order in inverse relation',
  params MEDIUMTEXT NULL                COMMENT 'relation parameters (JSON format)',
-- From MySQL 5.7.8 use JSON type

  PRIMARY KEY left_name_right (left_id, name, right_id),
  INDEX (left_id),
  INDEX (right_id),

  FOREIGN KEY(left_id)
    REFERENCES objects(id)
      ON DELETE CASCADE
      ON UPDATE NO ACTION,
  FOREIGN KEY(right_id)
    REFERENCES objects(id)
      ON DELETE CASCADE
      ON UPDATE NO ACTION,
  FOREIGN KEY(name)
    REFERENCES relation_definitions(name)
      ON DELETE CASCADE
      ON UPDATE NO ACTION

) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT 'relations between objects';


-- -------------
--   TREE
-- -------------

DROP TABLE IF EXISTS `trees`;
CREATE TABLE trees (

  object_id INT UNSIGNED NOT NULL       COMMENT 'object id',
  parent_id INT UNSIGNED NULL           COMMENT 'parent object id',
  root_id INT UNSIGNED NOT NULL         COMMENT 'root id (for tree scoping)',
  tree_left INT NOT NULL                COMMENT 'left counter (for nested set model)',
  tree_right INT NOT NULL               COMMENT 'right counter (for nested set model)',
  depth INT UNSIGNED NOT NULL           COMMENT 'depth',
  menu INT UNSIGNED NOT NULL DEFAULT 1  COMMENT 'menu on/off',

  PRIMARY KEY(parent_id, object_id),
  INDEX object_parent (object_id, parent_id),
  INDEX root_left (root_id, tree_left),
  INDEX root_right (root_id, tree_right),
  INDEX (menu),

  FOREIGN KEY(object_id)
    REFERENCES objects(id)
      ON DELETE CASCADE
      ON UPDATE NO ACTION,
  FOREIGN KEY(parent_id)
    REFERENCES objects(id)
      ON DELETE CASCADE
      ON UPDATE NO ACTION,
  FOREIGN KEY(root_id)
    REFERENCES objects(id)
      ON DELETE CASCADE
      ON UPDATE NO ACTION

) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT 'tree structure';
