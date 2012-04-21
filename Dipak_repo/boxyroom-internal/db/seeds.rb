# Seed User

# Admin User
@user1 = User.create(
  :email                    => "studyroom@dchua.com", 
  :password                 => "maverick", 
  :password_confirmation    => "maverick", 
  :first_name                => "Administrator", 
  :last_name                 => "Staff", 
  :is_admin                 => true)

  @user1.roles.create(:title => "admin")

# Tenant 1 / Landlord 2
@user2 = User.create(
  :email                    => "zhchua@gmail.com",
  :password                 => "maverick",
  :password_confirmation    => "maverick",
  :first_name                => "David",
  :last_name                 => "Chua",
  :is_admin                 => false)

  @user2.roles.create(:title => "user")
# Tenant 2 / Landlord 1

@user3 = User.create(
  :email                   => "me@dchua.com",
  :password                => "maverick",
  :password_confirmation   => "maverick",
  :first_name               => "Pheng",
  :last_name                => "Huat",
  :is_admin                => false)

  @user3.roles.create(:title => "user")
# Property 1

Property.create!(
  :title                   => "One-bedroom apartment near Gare du Nord. Very convenient.",
  :description             => "Looking for students. Preferably female.",
  :country_id              => 74,
  :city                    => "Paris",
  :category                => "Whole Apartment",
  :facilities_nearby        => "7-11 2 blocks away",
  :landlord_address          => false,
  :transport_nearby         => "Subway just 15 minutes walk away",
  :status                  => "pending",
  :user_id                 => @user3.id,
  :monthly_rental           => 10.40,
  :rental_period            => 12,
  :street_name              => "Maxfeld Str",
  :occupancy               => 2
)

# Property 2


Property.create!(
  :title                   => "Faubourg Saint-Honore studio. Next to Lavapie metro stop.",
  :description             => "Clean and tidy tenants wanted",
  :country_id              => 74,
  :city                    => "Paris",
  :category                => "Whole Apartment",
  :facilities_nearby        => "Indian restaurant just downstairs",
  :landlord_address          => false,
  :transport_nearby         => "none",
  :status                  => "pending",
  :user_id                 => @user2.id,
  :monthly_rental           => 50.21,
  :rental_period            => 12,
  :street_name              => "Maxfeld Str",
  :occupancy               => 3
)

# Application 1

@app = Application.new
@app.user = @user2
@app.property = Property.find(1)
@app.profile = Profile.new
@app.save!

# Application 2

@app2 = Application.new
@app2.user = @user3
@app2.property = Property.find(2)
@app2.profile = Profile.new
@app2.save!


# Activate!
#
@user1.activate!
@user2.activate!
@user3.activate!
