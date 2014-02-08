## Getting started

This application should work right out of the box. It uses sqlite for its database. It was built with Ruby 2.0.0p247 and Rails 4.0.2 on Debian 7 (wheezy).

## Testing

Testing is accomplished with RSpec. The 'test' directory can be disregarded in favour of the 'spec' directory. After raking <tt>db:test:prepare</tt>, run the rspec tests with rake or with the rspec executable.

## Rdoc

Rdoc has been generated to describe classes and functions. Have a look in the 'doc' folder. The table of contents HTML file is a good place to start.

## A note about project requirements

I held a meeting with the project heads (or at least I would have done so if this had been a real project with real project heads) to verify the details of the operation of this application. The mechanics of the application, particularly with regard to recurring activities, were determined in part based on the following details. (Okay, in fact these were fabricated based on my understanding of the scope of this assignment.):

- We expect local usage only; no need to save or search by location
- We expect many more reads than writes
- In future, we may wish to support modifying an entire series of scheduled events
- After a proof of concept, other features should be addressed, including adding a Vendor model and user authentication

Original project requirements shall be addressed after the API is described.

## The API

A single RESTful controller is provided for the Activity model. A few points of instruction:

### index

The current implementation is simple, allowing the user to specify 'start', 'finish', and 'limit'. All three of these parameters are optional. These parameters restrict the scope of scheduled activities that will be rendered in the response based on start time, finish time, and quantity of results allowed. 'start' defaults to the present time; 'finish' is ignored if not supplied; and 'limit' defaults to 50.

### create

A quick look at the schema.rb file and the 'activity_params' private function in the controller will indicate what fields are allowed inside of 'params["activity"]'. One thing to note is that a Hash may be supplied for the attribute 'recurrence'. This hash should contain fields for the associated model ActivityFactory (see the schema and function Activity#create_activity_factory_wrapper).

### destroy

The destroy action does not destroy any records in the database; rather, it sets a 'deleted' flag, which prevents the given record from being scoped in the index action.

### add_booking

An Activity id and a name (of the person booking a slot on the Activity) are required in the params. This create a Booking record and decrements the bookings available on the Activity (via a callback on Booking).

### Recurring activities

When a recurring activity is created (i.e. when an Activity with a valid 'recurrence' attribute is created, thereby creating a ActivityFactory), Activity records are created for each instance of that recurring activity (up to one year in the future or the end date of the recurrence, whichever falls first) in order to facilitate querying over date ranges and customizing particular instances.

It is anticipated that in a future release, the 'whenever' gem shall be used to manage a cronjob for maintaining this one-year-in-future buffer by building out additional Activity records daily or weekly or monthly.

Activity records created in this way are associated with the ActivityFactory which created them, leaving an opening for developing support for modifying an entire series of Activity records at once.

Recurrence can be defined on a days-of-the-week or days-of-the-month basis, with a months-of-the-year constraint applied against either one. If a vendor wishes for similar activities to have different attribute values (for instance, a different price for the six o'clock class than for the eight o'clock class), it is expected that she/she shall create two different series of activities (a six o'clock Activity save Factory and an eight o'clock ActivityFactory).

It is admitted that this degree of configurability of recurrence omits some useful angles, such as specifying the first Tuesday of each month, but given the time constraints of the development schedule, this seems like a reasonable place to draw the line. With requirement creep, expanded recurrence configuration may yet be part of a future release.

## Project Requirements

### Core functionality

- Data model for activities -- no need to go crazy, it can be really simple and just have an Activity name and a Vendor name (e.g. activity = “surf lesson” and vendor = “Joe the Surf Instructor”)
  - There are two models in the application at this point: Activity and ActivityFactory. Activity represents a single instance of an event/activity. ActifityFactory represents a series of events (i.e. a recurring event); it is used to build Activity records. There is room for a Vendor model, and there are tentative plans for User and associated models.
- Ability to add and remove activity availability
  - This can be accomplished with the activities#add_booking action, described above. For more control (i.e. change availability without creating a Booking), use the activities#update action or the activities#destroy action, changing either the 'deleted' or 'bookings_available' field on an Activity.
- API ability to check activity day availability over a range (e.g. what days are available between 10/10/13 and 11/10/13?)
  - This is accomplished with the activities#index action. See above for details.
- API ability to check activity availability within a day (e.g. what times are available on 10/15/13?)
  - This is accomplished with the activities#index action. See above for details. (Specify a 'finish' param.)
- API ability to create bookings against activities with availability (= reduce remaining availability)
  - This can be accomplished with the activities#add_booking action, described above.
- Automated tests hitting the API for all the different cases
  - See the text under the 'Testing' header above.

### Things to think about

- A single instance of an activity tends to have limited quantity (e.g. the surf instructor will only take 8 at a time)
  - Set the 'bookings_available' field on the Activity or on the recurrence params.
- What if a vendor wants to charge different prices for the 8:00 tour and the 6:00 tour?
  - At this point, he must make two different activities/series.
- We probably don’t ever want to delete bookings due to some other API call
  - The #destroy function on ActivityStereotype is overridden to prevent this.
- How to add recurring availability for an activity (e.g. this is available every Monday @5pm)? 
  - Supply a Hash of params to <tt>params[:activities][:recurrence]</tt>. See 'Recurring activities' description above.