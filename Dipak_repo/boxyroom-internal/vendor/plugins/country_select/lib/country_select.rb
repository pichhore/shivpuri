# CountrySelect
module ActionView
  module Helpers
    module FormOptionsHelper
      # Return select and option tags for the given object and method, using country_options_for_select to generate the list of option tags.
      def country_select(object, method, priority_countries = nil, options = {}, html_options = {})
        InstanceTag.new(object, method, self, options.delete(:object)).to_country_select_tag(priority_countries, options, html_options)
      end
      # Returns a string of option tags for pretty much any country in the world. Supply a country name as +selected+ to
      # have it marked as the selected option tag. You can also supply an array of countries as +priority_countries+, so
      # that they will be listed above the rest of the (long) list.
      #
      # NOTE: Only the option tags are returned, you have to wrap this call in a regular HTML select tag.
      def country_options_for_select(selected = nil, priority_countries = nil)
        country_options = ""

        if priority_countries
          priority_countries = priority_countries.collect do |code|
            index = COUNTRIES_CODES.index(code)
            [COUNTRIES_NAMES[index], index + 1]
          end
          
          country_options += options_for_select(priority_countries, selected)
          country_options += "<option value=\"\" disabled=\"disabled\">-------------</option>\n"
        end
        COUNTRIES_OPTIONS.delete(["Afghanistan", 1])
        return country_options + options_for_select(COUNTRIES_OPTIONS, selected)
      end
      # All the countries included in the country_options output.
      COUNTRIES = [
        ["Afghanistan", "af"], ["Aland Islands", "ax"], ["Albania", "al"], ["Algeria", "dz"], 
        ["American Samoa", "as"], ["Andorra", "ad"], ["Angola", "ao"], ["Anguilla", "ai"], 
        ["Antarctica", "aq"], ["Antigua And Barbuda", "ag"], ["Argentina", "ar"], ["Armenia", "am"], 
        ["Aruba", "aw"], ["Australia", "au"], ["Austria", "at"], ["Azerbaijan", "az"], ["Bahamas", "bs"], 
        ["Bahrain", "bh"], ["Bangladesh", "bd"], ["Barbados", "bb"], ["Belarus", "by"], ["Belgium", "be"], 
        ["Belize", "bz"], ["Benin", "bj"], ["Bermuda", "bm"], ["Bhutan", "bt"], ["Bolivia", "bo"], 
        ["Bosnia And Herzegovina", "ba"], ["Botswana", "bw"], ["Bouvet Island", "bv"], ["Brazil", "br"], 
        ["British Indian Ocean Territory", "io"], ["Brunei Darussalam", "bn"], ["Bulgaria", "bg"], 
        ["Burkina Faso", "bf"], ["Burundi", "bi"], ["Cambodia", "kh"], ["Cameroon", "cm"], ["Canada", "ca"], 
        ["Cape Verde", "cv"], ["Cayman Islands", "ky"], ["Central African Republic", "cf"], ["Chad", "td"], 
        ["Chile", "cl"], ["China", "cn"], ["Christmas Island", "cx"], ["Cocos (Keeling) Islands", "cc"], 
        ["Colombia", "co"], ["Comoros", "km"], ["Congo", "cg"], ["Congo, The Democratic Republic Of The", "cd"], 
        ["Cook Islands", "ck"], ["Costa Rica", "cr"], ["Cote D'ivoire", "ci"], ["Croatia", "hr"], ["Cuba", "cu"], 
        ["Cyprus", "cy"], ["Czech Republic", "cz"], ["Denmark", "dk"], ["Djibouti", "dj"], ["Dominica", "dm"], 
        ["Dominican Republic", "do"], ["Ecuador", "ec"], ["Egypt", "eg"], ["El Salvador", "sv"], 
        ["Equatorial Guinea", "gq"], ["Eritrea", "er"], ["Estonia", "ee"], ["Ethiopia", "et"], 
        ["Falkland Islands (Malvinas)", "fk"], ["Faroe Islands", "fo"], ["Fiji", "fj"], ["Finland", "fi"], 
        ["France", "fr"], ["French Guiana", "gf"], ["French Polynesia", "pf"], ["French Southern Territories", "tf"], 
        ["Gabon", "ga"], ["Gambia", "gm"], ["Georgia", "ge"], ["Germany", "de"], ["Ghana", "gh"], ["Gibraltar", "gi"], 
        ["Greece", "gr"], ["Greenland", "gl"], ["Grenada", "gd"], ["Guadeloupe", "gp"], ["Guam", "gu"], 
        ["Guatemala", "gt"], ["Guernsey", "gg"], ["Guinea", "gn"], ["Guinea Bissau", "gw"], ["Guyana", "gy"], 
        ["Haiti", "ht"], ["Heard Island And Mcdonald Islands", "hm"], ["Holy See (Vatican City State)", "va"], 
        ["Honduras", "hn"], ["Hong Kong", "hk"], ["Hungary", "hu"], ["Iceland", "is"], ["India", "in"], 
        ["Indonesia", "id"], ["Iran, Islamic Republic Of", "ir"], ["Iraq", "iq"], ["Ireland", "ie"], 
        ["Isle Of Man", "im"], ["Israel", "il"], ["Italy", "it"], ["Jamaica", "jm"], ["Japan", "jp"], 
        ["Jersey", "je"], ["Jordan", "jo"], ["Kazakhstan", "kz"], ["Kenya", "ke"], ["Kiribati", "ki"], 
        ["Korea, Democratic People's Republic Of", "kp"], ["Korea, Republic Of", "kr"], ["Kuwait", "kw"], 
        ["Kyrgyzstan", "kg"], ["Lao People's Democratic Republic", "la"], ["Latvia", "lv"], ["Lebanon", "lb"], 
        ["Lesotho", "ls"], ["Liberia", "lr"], ["Libyan Arab Jamahiriya", "ly"], ["Liechtenstein", "li"], 
        ["Lithuania", "lt"], ["Luxembourg", "lu"], ["Macao", "mo"], ["Macedonia, The Former Yugoslav Republic Of", "mk"], 
        ["Madagascar", "mg"], ["Malawi", "mw"], ["Malaysia", "my"], ["Maldives", "mv"], ["Mali", "ml"], ["Malta", "mt"], 
        ["Marshall Islands", "mh"], ["Martinique", "mq"], ["Mauritania", "mr"], ["Mauritius", "mu"], ["Mayotte", "yt"], 
        ["Mexico", "mx"], ["Micronesia, Federated States Of", "fm"], ["Moldova, Republic Of", "md"], ["Monaco", "mc"], 
        ["Mongolia", "mn"], ["Montenegro", "me"], ["Montserrat", "ms"], ["Morocco", "ma"], ["Mozambique", "mz"], 
        ["Myanmar", "mm"], ["Namibia", "na"], ["Nauru", "nr"], ["Nepal", "np"], ["Netherlands", "nl"], 
        ["Netherlands Antilles", "an"], ["New Caledonia", "nc"], ["New Zealand", "nz"], ["Nicaragua", "ni"], 
        ["Niger", "ne"], ["Nigeria", "ng"], ["Niue", "nu"], ["Norfolk Island", "nf"], ["Northern Mariana Islands", "mp"], 
        ["Oman", "om"], ["Pakistan", "pk"], ["Palau", "pw"], ["Palestinian Territory, Occupied", "ps"], ["Panama", "pa"], 
        ["Papua New Guinea", "pg"], ["Paraguay", "py"], ["Peru", "pe"], ["Philippines", "ph"], ["Pitcairn", "pn"], 
        ["Poland", "pl"], ["Portugal", "pt"], ["Puerto Rico", "pr"], ["Qatar", "qa"], ["Reunion", "re"], ["Romania", "ro"], 
        ["Russian Federation", "ru"], ["Rwanda", "rw"], ["Saint Barthelemy", "bl"], ["Saint Helena", "sh"], 
        ["Saint Kitts And Nevis", "kn"], ["Saint Lucia", "lc"], ["Saint Martin", "mf"], ["Saint Pierre And Miquelon", "pm"], 
        ["Saint Vincent And The Grenadines", "vc"], ["Samoa", "ws"], ["San Marino", "sm"], ["Sao Tome And Principe", "st"], 
        ["Saudi Arabia", "sa"], ["Senegal", "sn"], ["Serbia", "rs"], ["Seychelles", "sc"], ["Sierra Leone", "sl"], 
        ["Singapore", "sg"], ["Slovakia", "sk"], ["Slovenia", "si"], ["Solomon Islands", "sb"], ["Somalia", "so"], 
        ["South Africa", "za"], ["South Georgia And The South Sandwich Islands", "gs"], ["Spain", "es"], ["Sri Lanka", "lk"], 
        ["Sudan", "sd"], ["Suriname", "sr"], ["Svalbard And Jan Mayen", "sj"], ["Swaziland", "sz"], ["Sweden", "se"], 
        ["Switzerland", "ch"], ["Syrian Arab Republic", "sy"], ["Taiwan", "tw"], ["Tajikistan", "tj"], 
        ["Tanzania, United Republic Of", "tz"], ["Thailand", "th"], ["Timor Leste", "tl"], ["Togo", "tg"], ["Tokelau", "tk"], 
        ["Tonga", "to"], ["Trinidad And Tobago", "tt"], ["Tunisia", "tn"], ["Turkey", "tr"], ["Turkmenistan", "tm"], 
        ["Turks And Caicos Islands", "tc"], ["Tuvalu", "tv"], ["Uganda", "ug"], ["Ukraine", "ua"], 
        ["United Arab Emirates", "ae"], ["United Kingdom", "gb"], ["United States", "us"], 
        ["United States Minor Outlying Islands", "um"], ["Uruguay", "uy"], ["Uzbekistan", "uz"], ["Vanuatu", "vu"], 
        ["Venezuela", "ve"], ["Viet Nam", "vn"], ["Virgin Islands, British", "vg"], ["Virgin Islands, U.S.", "vi"], 
        ["Wallis And Futuna", "wf"], ["Western Sahara", "eh"], ["Yemen", "ye"], ["Zambia", "zm"], ["Zimbabwe", "zw"]
      ] unless const_defined?("COUNTRIES")
      
      COUNTRIES_NAMES = COUNTRIES.collect {|c| c[0] }
      COUNTRIES_CODES = COUNTRIES.collect {|c| c[1] }
      COUNTRIES_OPTIONS = COUNTRIES.to_enum(:each_with_index).collect {|c, i| [c[0], i + 1] }
    end
    
    class InstanceTag
      def to_country_select_tag(priority_countries, options, html_options)
        html_options = html_options.stringify_keys
        add_default_name_and_id(html_options)
        value = value(object)
        content_tag("select",
          add_options(
            country_options_for_select(value, priority_countries),
            options, value
          ), html_options
        )
      end
    end
    
    class FormBuilder
      def country_select(method, priority_countries = nil, options = {}, html_options = {})
        @template.country_select(@object_name, method, priority_countries, options.merge(:object => @object), html_options)
      end
    end
  end
end