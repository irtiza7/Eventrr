<p align="center">
  <img src="./Eventrr/Eventrr/Assets.xcassets/LogoTransparent.imageset/Logo%20Transparent.png" alt="App Logo" width="150"/>
</p>

<h1 align="center">Eventrr</h1>

<p align="center">
  <img src="https://img.shields.io/badge/Language-Swift%205-orange.svg" alt="Language Badge"/>
  <img src="https://img.shields.io/badge/Platform-iOS%2015.0%2B-blue.svg" alt="Platform Badge"/>
  <img src="https://img.shields.io/badge/Framework-UIKit%20%7C%20SwiftUI-green.svg" alt="Framework Badge"/>
  <img src="https://img.shields.io/badge/Backend-Firebase-brightgreen.svg" alt="Backend Badge"/>
  <img src="https://img.shields.io/badge/Database-Firebase%20Firestore-yellowgreen.svg" alt="Database Badge"/>
</p>

Eventrr is an iOS event management app built using **Swift**, combining the power of **UIKit** and **SwiftUI** for an intuitive and modern user experience. The app leverages **Firebase** for backend services and cloud storage, with **Realm** used for local data persistence. Whether you're an admin managing events or an attendee joining them, Eventrr simplifies the entire process.

## Features

### Authentication Module

- **Login / Sign Up**: Users can log in or create an account with role selection (Admin/Attendee).
- **Password Reset**: Users can request a password reset link sent to their email.
- **Role Selection**: Users can choose their role upon signup, which tailors the app experience.

### Main Event Screen

- **Event List**: Displays a list of all created events.
- **Search Events**: Search for events by name or location.
- **Filter Events**: Filter events based on categories.

### Create Event Screen

- **Event Creation**: Create new events with details like:
  - Title
  - Category
  - Date & Time
  - Location (with the help of **MapKit** for location services)
  - Description

### My Events Screen

- **Admin View**: Shows a list of events created by the admin.
- **Attendee View**: Displays events that the attendee has joined.
- **Role-Based Data**: The screen dynamically shows data based on the user's role.

### Event Details Screen

- **Admin Actions**:
  - **Edit Event**: Navigate to the event creation screen to update event details.
  - **Delete Event**: Permanently remove the event.
- **Attendee Actions**:
  - **Join Event**: Option to join an event if not already joined.
  - **Leave Event**: Leave the event if already joined.

### Profile Screen

- **User Info**: Displays user's name and role.
- **Edit Profile**: Allows users to update their name and role.
- **Change Password**: Provides an option to change the user's password.
- **Logout**: Simple logout functionality.

## Technologies Used

- **Swift** with **UIKit** and **SwiftUI**
- **Firebase** for Authentication, Firestore, and Cloud Storage
- **Realm** for local data persistence
- **MapKit** and **Core Location** for location-based services
- **Combine** framework for handling asynchronous data streams

## Requirements

- Xcode 14.0 or later
- iOS 17.0 or later
- Swift 5.7 or later
- CocoaPods 1.10.1 or later
- Firebase Console (Firestore and Authentication enabled)
- Realm for local persistence

## Setup and Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/yourusername/eventrr.git

   ```

2. Install dependencies using CocoaPods:

   ```bash
   pod install

   ```

3. Open the project in Xcode:

   ```bash
   open Eventrr.xcworkspace

   ```

4. Set up Firebase:

   - Create a Firebase project and add your iOS app.
   - Download the `GoogleService-Info.plist` file and include it in the Xcode project.
   - Enable **Firestore** and **Authentication** in Firebase Console.

5. Build and run the project on your preferred device or simulator.

## How to Use

- **Admin Role**: Create and manage events, edit or delete events, and view all event attendees.
- **Attendee Role**: Join or leave events, view event details, and manage your profile.

## Future Enhancements

- Push notifications for event updates.
- In-app chat for event attendees.
- Integration with calendar services to add events directly.

## Screenshots

### Login Screen

| Light Mode                                           | Dark Mode                                          |
| ---------------------------------------------------- | -------------------------------------------------- |
| ![Login Light](./Eventrr/Screenshots/LoginLight.png) | ![Login Dark](./Eventrr/Screenshots/LoginDark.png) |

### Signup Screen

| Light Mode                                             | Dark Mode                                            |
| ------------------------------------------------------ | ---------------------------------------------------- |
| ![Signup Light](./Eventrr/Screenshots/SignupLight.png) | ![Signup Dark](./Eventrr/Screenshots/SignupDark.png) |

### Events List Screen

| Light Mode                                                      | Dark Mode                                                     |
| --------------------------------------------------------------- | ------------------------------------------------------------- |
| ![Events List Light](./Eventrr/Screenshots/EventsListLight.png) | ![Events List Dark](./Eventrr/Screenshots/EventsListDark.png) |

### My Events List Screen

| Light Mode                                                           | Dark Mode                                                          |
| -------------------------------------------------------------------- | ------------------------------------------------------------------ |
| ![My Events List Light](./Eventrr/Screenshots/MyEventsListLight.png) | ![My Events List Dark](./Eventrr/Screenshots/MyEventsListDark.png) |

### Event Details Screen

| Light Mode                                                                        | Dark Mode                                                                       |
| --------------------------------------------------------------------------------- | ------------------------------------------------------------------------------- |
| ![Event Details Light (Admin View)](./Eventrr/Screenshots/EventDetailsLight1.png) | ![Event Details Dark (Admin View)](./Eventrr/Screenshots/EventDetailsDark1.png) |

| Light Mode                                                                           | Dark Mode                                                                          |
| ------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------- |
| ![Event Details Light (Attendee View)](./Eventrr/Screenshots/EventDetailsLight2.png) | ![Event Details Dark (Attendee View)](./Eventrr/Screenshots/EventDetailsDark2.png) |

### Create/Update Event Screen

| Light Mode                                                                | Dark Mode                                                               |
| ------------------------------------------------------------------------- | ----------------------------------------------------------------------- |
| ![Create/Update Event Light](./Eventrr/Screenshots/CreateEventLight1.png) | ![Create/Update Event Dark](./Eventrr/Screenshots/CreateEventDark1.png) |

| Light Mode                                                                | Dark Mode                                                               |
| ------------------------------------------------------------------------- | ----------------------------------------------------------------------- |
| ![Create/Update Event Light](./Eventrr/Screenshots/CreateEventLight2.png) | ![Create/Update Event Dark](./Eventrr/Screenshots/CreateEventDark2.png) |

### Select Location Screen

| Light Mode                                                              | Dark Mode                                                             |
| ----------------------------------------------------------------------- | --------------------------------------------------------------------- |
| ![Select Location Light](./Eventrr/Screenshots/SelectLocationLight.png) | ![Select Location Dark](./Eventrr/Screenshots/SelectLocationDark.png) |

### Profile Screen

| Light Mode                                               | Dark Mode                                              |
| -------------------------------------------------------- | ------------------------------------------------------ |
| ![Profile Light](./Eventrr/Screenshots/ProfileLight.png) | ![Profile Dark](./Eventrr/Screenshots/ProfileDark.png) |

### Edit Profile Screen

| Light Mode                                                        | Dark Mode                                                       |
| ----------------------------------------------------------------- | --------------------------------------------------------------- |
| ![Edit Profile Light](./Eventrr/Screenshots/EditProfileLight.png) | ![Edit Profile Dark](./Eventrr/Screenshots/EditProfileDark.png) |

### Change Password Screen

| Light Mode                                                              | Dark Mode                                                             |
| ----------------------------------------------------------------------- | --------------------------------------------------------------------- |
| ![Change Password Light](./Eventrr/Screenshots/ChangePasswordLight.png) | ![Change Password Dark](./Eventrr/Screenshots/ChangePasswordDark.png) |
