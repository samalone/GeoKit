# GeoKit

GeoKit provides Linux implementations of structures from CoreLocation and MapKit,
Apple's frameworks for location-based services on iOS and macOS.  All structures
are `Codable` so they can be easily encoded and decoded from JSON.

| CoreLocation/MapKit    | GeoKit           | Units                   |
| ---------------------- | ---------------- | ----------------------- |
| CLLocationDegrees      | Degrees          | degrees                 |
| CLLocationDirection    | Direction        | degrees from true north |
| CLLocationDistance     | Distance         | meters                  |
| CGPoint                | Point            |                         |
| CLLocationSpeed        | WindSpeed        | knots                   |
| CLLocationCoordinate2D | Coordinate       |                         |
| MKCoordinateSpan       | CoordinateSpan   |                         |
| MKCoordinateRegion     | CoordinateRegion |                         |

GeoKit also provides extensions to these structures
to perform geographic calculations.

An API reference is available at https://samalone.github.io/GeoKit/documentation/geokit
