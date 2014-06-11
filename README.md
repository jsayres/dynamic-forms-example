# Dynamic-Forms

This is an example of one approach to writing an application that has two
audiences:

- Internal staff members who have access to modern technology and browsers and
  can be relied on to have javascript enabled
- External users mostly from schools, many of which are using outdated
  technology or typically have restrictions placed on its usage

Therefore, the administration interface—which is used exclusively by internal
staff—is a single page javascript app. (In this case using AngularJS as the
framework, but if I get some time I'd like to give React a go as well.)

This frontend is fed by a (REST-ish) backend API. Rails and Django are two
examples included here, and they were chosen because in addition to being able
to provide a backend API, they are also fully capable traditional web
frameworks. This made the development of the external-facing parts of the
application relatively easy.

The actual application is the start of a dynamic forms app. Forms are created,
edited, and published in the administration interface. They are then filled out
by external users. The responses can be viewed back in the admin area.

In addition, the forms are versioned, so that published forms can never be
overwritten, which would invalidate any data that was submitted for them by
external users.

