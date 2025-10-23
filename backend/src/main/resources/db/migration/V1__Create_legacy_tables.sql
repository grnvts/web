-- Старые таблицы (только для временного хранения данных при миграции)
CREATE TABLE owner (
                       id        bigint not null primary key,
                       born_date timestamp,
                       name      varchar(5000) unique,
                       surname   varchar(5000) unique,
                       tc_no     varchar(255) unique
);

CREATE TABLE roles (
                       id      bigserial primary key,
                       name    varchar(60) unique,
                       user_id bigint
);

CREATE TABLE users (
                       id            bigint       not null primary key,
                       born_date     timestamp,
                       created_date  timestamp,
                       email         varchar(255) unique,
                       image         varchar(255),
                       name          varchar(255),
                       password      varchar(255),
                       real_password varchar(255),
                       status        integer,
                       surname       varchar(255),
                       uname         varchar(200) not null
);

CREATE TABLE building (
                          id              bigint not null primary key,
                          building_adress varchar(1000),
                          building_name   varchar(1000),
                          created_at      timestamp,
                          start_date      date unique,
                          user_id         bigint references users
);

CREATE TABLE apartment (
                           id               bigint not null primary key,
                           apartment_detail varchar(255),
                           apartment_no     varchar(255),
                           created_date     timestamp,
                           building_id      bigint not null references building,
                           owner_id         bigint references owner
);

CREATE TABLE building_adress (
                                 id          bigint not null primary key,
                                 building_no varchar(255),
                                 city        varchar(255),
                                 district    varchar(255),
                                 image       varchar(255),
                                 quarter     varchar(255),
                                 street      varchar(255),
                                 building_id bigint not null unique references building
);

CREATE TABLE flat (
                      id               bigint not null primary key,
                      apartment_detail varchar(255),
                      apartment_no     varchar(255),
                      created_date     timestamp,
                      building_id      bigint not null references building,
                      owner_id         bigint references owner
);

CREATE TABLE user_roles (
                            user_id bigint not null references users,
                            role_id bigint not null references roles,
                            primary key (user_id, role_id)
);

CREATE TABLE users_buildings (
                                 user_id      bigint not null references users,
                                 buildings_id bigint not null unique references building
);