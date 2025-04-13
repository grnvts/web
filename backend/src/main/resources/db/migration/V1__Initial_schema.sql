create table owner
(
    id        bigint not null
        primary key,
    born_date timestamp,
    name      varchar(5000)
        constraint uk_jryjfrl809i37qthat5rwpnq5
            unique,
    surname   varchar(5000)
        constraint uk_3r8tfcurr66f46mtdrod5tpdy
            unique,
    tc_no     varchar(255)
        constraint uk_5vwtdkuxl7cjyki51l82mtmat
            unique
);

alter table owner
    owner to root;

create table roles
(
    id      bigserial
        primary key,
    name    varchar(60)
        constraint uk_nb4h0p6txrmfc0xbrd1kglp9t
            unique,
    user_id bigint
);

alter table roles
    owner to root;

create table users
(
    id            bigint       not null
        primary key,
    born_date     timestamp,
    created_date  timestamp,
    email         varchar(255)
        constraint uk_6dotkott2kjsp8vw4d0m25fb7
            unique,
    image         varchar(255),
    name          varchar(255),
    password      varchar(255),
    real_password varchar(255),
    status        integer,
    surname       varchar(255),
    uname         varchar(200) not null
);

alter table users
    owner to root;

create table building
(
    id              bigint not null
        primary key,
    building_adress varchar(1000),
    building_name   varchar(1000),
    created_at      timestamp,
    start_date      date
        constraint uk_b4l920g2jcapc393uomsd24hx
            unique,
    user_id         bigint
        constraint fk8hxciy4bv5w4jcyjqk4piqvdh
            references users
);

alter table building
    owner to root;

create table apartment
(
    id               bigint not null
        primary key,
    apartment_detail varchar(255),
    apartment_no     varchar(255),
    created_date     timestamp,
    building_id      bigint not null
        constraint fkmjjff7q9e4qfyop2w1vafy619
            references building,
    owner_id         bigint
        constraint fk7t1un6qju29sa9xgcoytdedhi
            references owner
);

alter table apartment
    owner to root;

create table building_adress
(
    id          bigint not null
        primary key,
    building_no varchar(255),
    city        varchar(255),
    district    varchar(255),
    image       varchar(255),
    quarter     varchar(255),
    street      varchar(255),
    building_id bigint not null
        constraint uk_j8g1ojyyqdv31hyf1jj323q1c
            unique
        constraint fkk8sk06u4umkthekhclms57iff
            references building
);

alter table building_adress
    owner to root;

create table flat
(
    id               bigint not null
        primary key,
    apartment_detail varchar(255),
    apartment_no     varchar(255),
    created_date     timestamp,
    building_id      bigint not null
        constraint fkcuvibqssnlnlcvkphbl35qud1
            references building,
    owner_id         bigint
        constraint fk4bllgecffn8wf83tdpkmy47ru
            references owner
);

alter table flat
    owner to root;

create table user_roles
(
    user_id bigint not null
        constraint fkhfh9dx7w3ubf1co1vdev94g3f
            references users,
    role_id bigint not null
        constraint fkh8ciramu9cc9q3qcqiv4ue8a6
            references roles,
    primary key (user_id, role_id)
);

alter table user_roles
    owner to root;

create table users_buildings
(
    user_id      bigint not null
        constraint fkrsias7mtq25aiy0c5yr6htrdl
            references users,
    buildings_id bigint not null
        constraint uk_4xw0pmb2a41i1039hqffl3n87
            unique
        constraint fkk7nqiernaxf5pc1ll138wdab
            references building
);

alter table users_buildings
    owner to root;

