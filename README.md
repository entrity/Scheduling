## Getting started

This application should work right out of the box. It uses sqlite for its database. It was built with Ruby 2.0.0p247 and Rails 4.0.2 on Debian 7 (wheezy).

## Testing

Testing is accomplished withRSpec. The 'test' directory can be disregarded. After raking <tt>db:test:prepare</tt>, run the rspec tests with rake or with the rspec executable.

## Rdoc

Rdoc has been generated to describe classes and functions. Have a look in the 'doc' folder. The table of contents HTML file is a good place to start.

## Project requirements

I held a meeting with the project heads (or at least I would have done so if this had been a real project with real project heads) to verify the details of the operation of this application. The mechanics of the application, particularly with regard to recurring activities, were determined in part based on the following details. (Okay, in fact these were fabricated based on my understanding of the scope of this assignment.):

- We expect local usage only; no need to save or search by location
- We expect many more reads than writes
- In future, we may wish to support modifying an entire series of scheduled events
- After a proof of concept, other features should be addressed, including adding a Vendor model and user authentication

## The API

A single RESTful controller is provided for the Activity model. A few points of instruction:

### index

The current implementation is simple, allowing the user to specify 'start', 'finish', and 'limit'. All three of these parameters are optional. These parameters restrict the scope of scheduled activities that will be rendered in the response based on start time, finish time, and quantity of results allowed. 'start' defaults to the present time; 'finish' is ignored if not supplied; and 'limit' defaults to 50.

### create

A quick look at the schema.rb file and the 'activity_params' private function in the controller will indicate what fields are allowed inside of 'params["activity"]'. One thing to note is that a Hash may be supplied for the attribute 'recurrence'. This hash should contain fields for the associated model ActivityFactory (see the schema and function Activity#create_activity_factory_wrapper).

### destroy

The destroy action does not destroy any records in the database; rather, it sets a 'deleted' flag, which prevents the given record from being scoped in the index action.

### Recurring activities

When a recurring activity is created (i.e. when an Activity with a valid 'recurrence' attribute is created, thereby creating a ActivityFactory), Activity records are created for each instance of that recurring activity (up to one year in the future or the end date of the recurrence, whichever falls first) in order to facilitate querying over date ranges and customizing particular instances.

It is anticipated that in a future release, the 'whenever' gem shall be used to manage a cronjob for maintaining this one-year-in-future buffer by building out additional Activity records daily or weekly or monthly.

Activity records created in this way are associated with the ActivityFactory which created them, leaving an opening for developing support for modifying an entire series of Activity records at once.

Recurrence can be defined on a days-of-the-week or days-of-the-month basis, with a months-of-the-year constraint applied against either one. If a vendor wishes for similar activities to have different attribute values (for instance, a different price for the six o'clock class than for the eight o'clock class), it is expected that she/she shall create two different series of activities (a six o'clock Activity save Factory and an eight o'clock ActivityFactory).

It is admitted that this degree of configurability of recurrence omits some useful angles, such as specifying the first Tuesday of each month, but given the time constraints of the development schedule, this seems like a reasonable place to draw the line. With requirement creep, expanded recurrence configuration may yet be part of a future release.