class InsertState < ActiveRecord::Migration
  def self.up
    states = State.find(:all)
    if states.size == 0
      execute "INSERT INTO `states` VALUES ('1011','Alabama','AL'),('10110','District of Columbia','DC'),('10111','Federated States of Micronesia','FM'),('10112','Florida','FL'),('10113','Georgia','GA'),('10114','Guam','GU'),('10115','Hawaii','HI'),('10116','Idaho','ID'),('10117','Illinois','IL'),('10118','Indiana','IN'),('10119','Iowa','IA'),('1012','Alaska','AK'),('10120','Kansas','KS'),('10121','Kentucky','KY'),('10122','Louisiana','LA'),('10123','Maine','ME'),('10124','Marshall Islands','MH'),('10125','Maryland','MD'),('10126','Massachusetts','MA'),('10127','Michigan','MI'),('10128','Minnesota','MN'),('10129','Mississippi','MS'),('1013','American Samoa','AS'),('10130','Missouri','MO'),('10131','Montana','MT'),('10132','Nebraska','NE'),('10133','Nevada','NV'),('10134','New Hampshire','NH'),('10135','New Jersey','NJ'),('10136','New Mexico','NM'),('10137','New York','NY'),('10138','North Carolina','NC'),('10139','North Dakota','ND'),('1014','Arizona','AZ'),('10140','Northern Mariana Islands','MP'),('10141','Ohio','OH'),('10142','Oklahoma','OK'),('10143','Oregon','OR'),('10144','Palau','PW'),('10145','Pennsylvania','PA'),('10146','Puerto Rico','PR'),('10147','Rhode Island','RI'),('10148','South Carolina','SC'),('10149','South Dakota','SD'),('1015','Arkansas','AR'),('10150','Tennessee','TN'),('10151','Texas','TX'),('10152','Utah','UT'),('10153','Vermont','VT'),('10154','Virgin Islands','VI'),('10155','Virginia','VA'),('10156','Washington','WA'),('10157','West Virginia','WV'),('10158','Wisconsin','WI'),('10159','Wyoming','WY'),('1016','California','CA'),('10160',NULL,'ON'),('10161',NULL,'BC'),('10162',NULL,'MB'),('10163',NULL,'SK'),('10164',NULL,'UK'),('10165',NULL,'BS'),('1017','Colorado','CO'),('1018','Connecticut','CT'),('1019','Delaware','DE');"
    end
  end

  def self.down
    states = State.find(:all)
    if states.size > 0
      execute "delete from states;"
    end
  end
end
