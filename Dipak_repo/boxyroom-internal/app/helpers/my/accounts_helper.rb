module My::AccountsHelper
  OPTIONS_FOR_GENDER = {:male => "Male", :female => "Female"}

  def options_for_gender
    map = {}
    OPTIONS_FOR_GENDER.each do |key, value|
      map[value] = key.to_s
    end
    map
  end

  def options_for_currency(value= "default")
    map = {}
    AVAIL_CURRENCY.each_key {|key|
      name = AVAIL_CURRENCY[key]['name']
      sym = AVAIL_CURRENCY[key]['sym']
      if value == "sym"
        map[sym] = sym.to_s
      else
        map[name] = sym.to_s
      end
    }
    map.sort
  end
  def get_user_name(user_id)
    user = User.find(user_id)
    return user.first_name
  end


end
