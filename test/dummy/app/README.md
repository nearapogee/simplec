# Example.com
  An example application to showcase how Simplec works inside your Rails application. Follow the steps below to run the dummy app in your local environment.

# Running Dummy Application
  1. Create simplec postgres user

        # -s for superuser in development
        createuser -s simplec

  2. Create databases and add pgcrypto

        rake db:create

        # required for gen_random_uuid() function
        # used for ids in Simplec models
        #
        psql simplec_development -c "CREATE EXTENSION pgcrypto;"

  3. Migrate database

        rake db:migrate

  4. Run the documentation server

        gem install yard
        yard server -r --no-cache --no-save --verbose --debug --backtrace

# Using Example.com
  1. Create an example user in seeds.db
        
        You can use this code: sysadmin = User.create! email: 'sysadmin@example.com', password: 'password', sysadmin: true
  
  2. You may want to add a few entries into your /etc/hosts file, i.e. admin.site.loc, www.site.loc, site.loc all resolving to 127.0.0.1 so you can use subdomains locally.

  3. Run server on your port of choice and then admin.site.loc:3030 (or whichever port you choose).

  4. You will see the admin page, and from there you can navigate, add subpages or subdomains. 

# Footer Links
  Links in the footer are subpages and are populated into the footer automatically. Client should add these pages through the admin interface rather than hardcoding them into the view. If URLs to subpages are hardcoded into the view, they will not persist when the site is removed from client's local server. 

  The method for looping through subpage links can be found in application.html.erb.

  







 

