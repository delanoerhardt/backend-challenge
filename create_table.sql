CREATE TABLE equipment_table
(
 _id      uuid NOT NULL,
 tool     varchar(50) NOT NULL,
 CONSTRAINT PK_equipment_table PRIMARY KEY ( _id )
);

CREATE TABLE ingredient_table
(
 _id      uuid NOT NULL,
 food     varchar(35) NOT NULL,
 CONSTRAINT PK_ingredient_table PRIMARY KEY ( _id )
);

CREATE TABLE recipe_table
(
 _id         uuid NOT NULL,
 name        varchar(50) NOT NULL,
 description varchar(150) NOT NULL,
 CONSTRAINT PK_recipe_table PRIMARY KEY ( _id )
);

CREATE INDEX fkIdx_0 ON recipe_table
(
 _id
);

CREATE TABLE ingredient_of_recipe
(
 recipe_id     uuid NOT NULL,
 ingredient_id uuid NOT NULL,
 quantity_unit varchar(10) NOT NULL,
 quantity      varchar(30) NOT NULL,
 CONSTRAINT PK_ingredient_of_recipe PRIMARY KEY ( recipe_id, ingredient_id ),
 CONSTRAINT FK_40 FOREIGN KEY ( recipe_id ) REFERENCES recipe_table ( _id ),
 CONSTRAINT FK_44 FOREIGN KEY ( ingredient_id ) REFERENCES ingredient_table ( _id )
);

CREATE INDEX fkIdx_3 ON ingredient_of_recipe
(
 recipe_id
);

CREATE INDEX fkIdx_4 ON ingredient_of_recipe
(
 ingredient_id
);

CREATE TABLE equipment_of_recipe
(
 recipe_id    uuid NOT NULL,
 equipment_id uuid NOT NULL,
 quantity int NOT NULL,
 CONSTRAINT PK_equipment_of_recipe PRIMARY KEY ( recipe_id, equipment_id ),
 CONSTRAINT FK_53 FOREIGN KEY ( equipment_id ) REFERENCES equipment_table ( _id ),
 CONSTRAINT FK_56 FOREIGN KEY ( recipe_id ) REFERENCES recipe_table ( _id )
);

CREATE INDEX fkIdx_1 ON equipment_of_recipe
(
 equipment_id
);

CREATE INDEX fkIdx_2 ON equipment_of_recipe
(
 recipe_id
);
