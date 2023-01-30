# GeoKit

GeoKit provides a common base library for the course-server and the Isosceles app.

- It defines types that are compatible with Apple's CoreLocation on iOS,
  while defining the same types for Linux.
  - [Distance](https://samalone.github.io/GeoKit/documentation/geokit/distance) in meters
  - [Direction](https://samalone.github.io/GeoKit/documentation/geokit/direction) in degress from true north
  - [WindSpeed](https://samalone.github.io/GeoKit/documentation/geokit/windspeed) in knots
  - [Coordinate](https://samalone.github.io/GeoKit/documentation/geokit/coordinate) as a latitude/longitude pair
- It extends the Coordinate type with functions to perform geographic calculations
- It defines the datatypes for exchanging data with the course-server
  - [WeatherStation](https://samalone.github.io/GeoKit/documentation/geokit/weatherstation)
  - [WindInformation](https://samalone.github.io/GeoKit/documentation/geokit/windinformation)
  - [Layout](https://samalone.github.io/GeoKit/documentation/geokit/layout)
  - [Locus](https://samalone.github.io/GeoKit/documentation/geokit/locus)
  - [MarkSpec](https://samalone.github.io/GeoKit/documentation/geokit/markspec)
  - [Course](https://samalone.github.io/GeoKit/documentation/geokit/course)

An API reference is available at https://samalone.github.io/GeoKit/documentation/geokit
