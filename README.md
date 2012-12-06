# Lightweight Activities Standalone

This is a Rails application intended to provide a platform for authoring and using Lightweight activities. It is developed as a standalone version of the code original developed for the [Lightweight Activities Plugin.](https://github.com/concord-consortium/lightweight-activities-plugin). Much of the code (including this README) has been migrated directly from that plugin.

## Getting started

1. Check out the code: if you have access, use
        git clone git@github.com:concord-consortium/lightweight-standalone.git

otherwise, use

        git clone https://github.com/pjmorse/lightweight-standalone.git

2. Install the necessary gems:

        cd lightweight-standalone
        bundle install

3. Initialize the database, with seed data:

        rake db:drop db:create db:migrate db:seed

(If you would prefer to start with an empty database, leave the `db:seed` off the end.)

4. Launch the application

        rails s

6. Browse to the app in your browser: [http://localhost:3000/](http://localhost:3000/)

## Deploying

If you have rights to deploy to [http://lightweight-mw.concord.org](http://lightweight-mw.concord.org)

        cap deploy

should be sufficient to deploy from the master branch of this repository. If you're using a different branch, or deploying to a different server, you will want to edit `config/deploy.rb`.

## Running RSpec tests
From the main plugin directory, run

      RAILS_ENV=test rspec spec

You may first need to initialize the test database:

      RAILS_ENV=test rake db:create db:migrate

The RSpec tests live in spec/.

To re-initialize the test database, use the "initialize the database" command above:

      RAILS_ENV=test rake db:drop db:create db:migrate

### Adding Embeddable support

To support new Embeddables:

* Add a model definition and controller in `app/models/embeddable/` `app/controllers/embeddable/`, respectively. The controller should have the necessary code to accept in-place-editing updates of individual fields in the Embeddable.
* Add the resource to the "embeddable" namespace in `config/routes.rb`.
* Add a view directory at `app/views/embeddable/<embeddable_name>`
* Provide a `_lightweight.html.haml` partial within that view directory (for showing the Embeddable within an InteractivePage)
* Provide a `_author.html.haml` partial as well (for editing the Embeddable)
* Add the Embeddable's name as a string to the the `SUPPORTED_EMBEDDABLES` constant in `config/initializers/embeddables.rb`.