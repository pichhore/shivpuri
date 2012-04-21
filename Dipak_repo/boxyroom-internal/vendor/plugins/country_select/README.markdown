CountrySelect
=============

Provides a simple helper to get an HTML select list of countries.  The list of countries comes from the ISO 3166 standard.  While it is a relatively neutral source of country names, it will still offend some users.

Users are strongly advised to evaluate the suitability of this list given their user base.

This plugin has been changed to provide database support, saving the id instead of the full name.

Usage
=====

Create a model named `Country` (app/models/country.rb):

	class Country < ActiveRecord::Base
	end

To create the `countries` table and import all countries run the rake task:

	rake countries:setup
	
If you need to drop, create or import separately, run the tasks below:

	rake countries:create
	rake countries:drop
	rake countries:import

In your form, just call the `country_select` method:

	<% form_for @user do |f| %>
		<%= f.country_select :country_id %>
	<% end %>

Or:

	<%= country_select @user, :country_id %>

You can specify the priority country list:

	<%= f.country_select :country_id, %w(us gb ca jp br), :include_blank => true %>

Remember to provide the priority list as an array with all country codes you want; this will be converted to
country name and id.

Copyright (c) 2008 Michael Koziarski, released under the MIT license
