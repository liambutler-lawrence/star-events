# StarEvents
Phunware interview project

## Web service

I make a network request to retrieve the JSON response upon each launch of the app. A spinner is shown while the network call is being performed.

No specification was made for the difference between the timestamp and date fields. Therefore, I made the assumption to sort the events by their timestamp, but present their date to the user.

## Persistence

I am using Core Data to persist the events retrieved from the JSON service. This is preferable over simpler solutions such as NSUserDefaults or plist due to the "object array" structure defined in the JSON. In addition, Core Data allows the use of NSFetchedResultsController, which encapsulates collection view data source logic, including update notifications. 

Since it is not efficient to store raw images in Core Data, I am saving the event images to the filesystem using that event's "id" field from the JSON response. However, it is still inefficient to read from the filesystem every time the collection view delegate methods are called. Therefore, I am using a shared NSCache object to keep the images in memory, which improves scrolling fluidity in the list screen.

On subsequent launches of the app (after data has been persisted), the saved data is shown immediately to the user with full interaction capability. If a successful service call is made, the persisted data is overwritten and the UI updated. 

## Animations

- I implemented the complete transition animation described in the video. I am using custom UIViewControllerAnimatedTransitioning objects for both the "present detail" and "dismiss detail" interactions.
- For the detail screen scroll behavior, I used a trigger point where the title label becomes hidden during scrolling to animate (fade in/out) the navigation bar title.

## Deep Linking

I implemented this challenge requirement using the URL scheme "starevents". The following hostnames are supported:
- events: Opens the list of events
- event (with integer query parameter "id"): Opens the detail screen for a specific event, using the "id" field from the JSON response

Examples:
- starevents://events
- starevents://event?id=8
