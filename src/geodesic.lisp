;;; geodesic.h

;; Copyright (c) 2017 Victor Anyakin <anyakinvictor@yahoo.com>
;; All rights reserved.

;; Redistribution and use in source and binary forms, with or without
;; modification, are permitted provided that the following conditions are met:
;;     * Redistributions of source code must retain the above copyright
;;       notice, this list of conditions and the following disclaimer.
;;     * Redistributions in binary form must reproduce the above copyright
;;       notice, this list of conditions and the following disclaimer in the
;;       documentation and/or other materials provided with the distribution.
;;     * Neither the name of the organization nor the
;;       names of its contributors may be used to endorse or promote products
;;       derived from this software without specific prior written permission.

;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
;; ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
;; WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
;; DISCLAIMED. IN NO EVENT SHALL COPYRIGHT HOLDER BE LIABLE FOR ANY
;; DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
;; (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
;; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
;; ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
;; (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
;; SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

;;; Bindings for the geodesic routines from the geodesic.h file.
;;; First part of the file are plain CFFI declarations. Second part
;;; defines higher-level wrappers that make working with the lower
;;; level C functions more Lispy and convenient

(in-package :cl-proj)

;; --------------------------------------------------------

;; recommended values to use with GEOD-INIT
(defconstant +equatorial-radius+ 6378137d0)
(defconstant +flattening+ (float (/ 1 298.257223563) 0.0d0))
(export '(+equatorial-radius+ +flattening+))

;; --------------------------------------------------------

(cffi:defcfun ("geod_init" GEOD-INIT) :void
  "Initialize a geod_geodesic object.

@param[out] g a pointer to the object to be initialized.
@param[in] a the equatorial radius (meters).
@param[in] f the flattening."
  (g (:pointer (:struct geod-geodesic)))
  (a :double)
  (f :double))
(export '(geod-init))

;; --------------------------------------------------------

(cffi:defcfun ("geod_lineinit" GEOD-LINEINIT) :void
  "Initialize a geod_geodesicline object.

@param[out] l a pointer to the object to be initialized.
@param[in] g a pointer to the geod_geodesic object specifying the
  ellipsoid.
@param[in] lat1 latitude of point 1 (degrees).
@param[in] lon1 longitude of point 1 (degrees).
@param[in] azi1 azimuth at point 1 (degrees).
@param[in] caps bitor'ed combination of geod_mask() values specifying the
  capabilities the geod_geodesicline object should possess, i.e., which
  quantities can be returned in calls to geod_position() and
  geod_genposition().

\e g must have been initialized with a call to geod_init().  \e lat1
should be in the range [&minus;90&deg;, 90&deg;].

The geod_mask values are [see geod_mask()]:
- \e caps |= GEOD_LATITUDE for the latitude \e lat2; this is
  added automatically,
- \e caps |= GEOD_LONGITUDE for the latitude \e lon2,
- \e caps |= GEOD_AZIMUTH for the latitude \e azi2; this is
  added automatically,
- \e caps |= GEOD_DISTANCE for the distance \e s12,
- \e caps |= GEOD_REDUCEDLENGTH for the reduced length \e m12,
- \e caps |= GEOD_GEODESICSCALE for the geodesic scales \e M12
  and \e M21,
- \e caps |= GEOD_AREA for the area \e S12,
- \e caps |= GEOD_DISTANCE_IN permits the length of the
  geodesic to be given in terms of \e s12; without this capability the
  length can only be specified in terms of arc length.
.
A value of \e caps = 0 is treated as GEOD_LATITUDE | GEOD_LONGITUDE |
GEOD_AZIMUTH | GEOD_DISTANCE_IN (to support the solution of the 'standard'
direct problem).
"
  (l (:pointer (:struct geod-geodesicline)))
  (g (:pointer (:struct geod-geodesic)))
  (lat1 :double)
  (lon1 :double)
  (azi1 :double)
  (caps :unsigned-int))

;; --------------------------------------------------------

(cffi:defcfun  ("geod_direct" GEOD-DIRECT) :void
  "Solve the direct geodesic problem.

@param[in] g a pointer to the geod_geodesic object specifying the
  ellipsoid.
@param[in] lat1 latitude of point 1 (degrees).
@param[in] lon1 longitude of point 1 (degrees).
@param[in] azi1 azimuth at point 1 (degrees).
@param[in] s12 distance between point 1 and point 2 (meters); it can be
  negative.
@param[out] plat2 pointer to the latitude of point 2 (degrees).
@param[out] plon2 pointer to the longitude of point 2 (degrees).
@param[out] pazi2 pointer to the (forward) azimuth at point 2 (degrees).

\e g must have been initialized with a call to geod_init().  \e lat1
should be in the range [&minus;90&deg;, 90&deg;].  The values of \e lon2
and \e azi2 returned are in the range [&minus;180&deg;, 180&deg;).  Any of
the 'return' arguments \e plat2, etc., may be replaced by 0, if you do not
need some quantities computed.

If either point is at a pole, the azimuth is defined by keeping the
longitude fixed, writing \e lat = &plusmn;(90&deg; &minus; &epsilon;), and
taking the limit &epsilon; &rarr; 0+.  An arc length greater that 180&deg;
signifies a geodesic which is not a shortest path.  (For a prolate
ellipsoid, an additional condition is necessary for a shortest path: the
longitudinal extent must not exceed of 180&deg;.)

Example, determine the point 10000 km NE of JFK:

   struct geod_geodesic g;
   double lat, lon;
   geod_init(&g, 6378137, 1/298.257223563);
   geod_direct(&g, 40.64, -73.78, 45.0, 10e6, &lat, &lon, 0);
   printf(\"%.5f %.5f\n\", lat, lon);
"
  (g (:pointer (:struct geod-geodesic)))
  (lat1 :double)
  (lon1 :double)
  (azi1 :double)
  (s12 :double)
  (plat2 (:pointer :double))
  (plon2 (:pointer :double))
  (pazi2 (:pointer :double)))

;; --------------------------------------------------------

(cffi:defcfun ("geod_inverse" GEOD-INVERSE) :void
  "Solve the inverse geodesic problem.

@param[in] g a pointer to the geod_geodesic object specifying the
  ellipsoid.
@param[in] lat1 latitude of point 1 (degrees).
@param[in] lon1 longitude of point 1 (degrees).
@param[in] lat2 latitude of point 2 (degrees).
@param[in] lon2 longitude of point 2 (degrees).
@param[out] ps12 pointer to the distance between point 1 and point 2
  (meters).
@param[out] pazi1 pointer to the azimuth at point 1 (degrees).
@param[out] pazi2 pointer to the (forward) azimuth at point 2 (degrees).

\e g must have been initialized with a call to geod_init().  \e lat1 and
\e lat2 should be in the range [&minus;90&deg;, 90&deg;].  The values of
\e azi1 and \e azi2 returned are in the range [&minus;180&deg;, 180&deg;).
Any of the 'return' arguments, \e ps12, etc., may be replaced by 0, if you
do not need some quantities computed.

If either point is at a pole, the azimuth is defined by keeping the
longitude fixed, writing \e lat = &plusmn;(90&deg; &minus; &epsilon;), and
taking the limit &epsilon; &rarr; 0+.

The solution to the inverse problem is found using Newton's method.  If
this fails to converge (this is very unlikely in geodetic applications
but does occur for very eccentric ellipsoids), then the bisection method
is used to refine the solution.

Example, determine the distance between JFK and Singapore Changi Airport:

   @code{.c}
   struct geod_geodesic g;
   double s12;
   geod_init(&g, 6378137, 1/298.257223563);
   geod_inverse(&g, 40.64, -73.78, 1.36, 103.99, &s12, 0, 0);
   printf(\"%.3f\n\", s12);
   @endcode
"
  (g (:pointer (:struct geod-geodesic)))
  (lat1 :double)
  (lon1 :double)
  (lat2 :double)
  (lon2 :double)
  (ps12 (:pointer :double))
  (pazi1 (:pointer :double))
  (pazi2 (:pointer :double)))

;; --------------------------------------------------------

(cffi:defcfun ("geod_position" GEOD-POSITION) :void
  "@short{Compute the position along a geod_geodesicline.}

 @arg[l]{a pointer to the geod_geodesicline object specifying the
   geodesic line.}
 @arg[s12]{distance between point 1 and point 2 (meters); it can be
   negative.}

 param[out] plat2 pointer to the latitude of point 2 (degrees).
 param[out] plon2 pointer to the longitude of point 2 (degrees); requires
   that \e l was initialized with \e caps |= GEOD_LONGITUDE.
 param[out] pazi2 pointer to the (forward) azimuth at point 2 (degrees).

 \e l must have been initialized with a call to geod_lineinit() with \e
 caps |= GEOD_DISTANCE_IN.  The values of \e lon2 and \e azi2 returned are
 in the range [&minus;180&deg;, 180&deg;).  Any of the 'return' arguments
 \e plat2, etc., may be replaced by 0, if you do not need some quantities
 computed.

 Example, compute way points between JFK and Singapore Changi Airport
 the 'obvious' way using geod_direct():

@begin{code}
struct geod_geodesic g;
double s12, azi1, lat[101],lon[101];
int i;
geod_init(&g, 6378137, 1/298.257223563);
geod_inverse(&g, 40.64, -73.78, 1.36, 103.99, &s12, &azi1, 0);
for (i = 0; i < 101; ++i) {
  geod_direct(&g, 40.64, -73.78, azi1, i * s12 * 0.01, lat + i, lon + i, 0);
  printf(\"%.5f %.5f\n\", lat[i], lon[i]);
}
@end{code}

 A faster way using geod_position():

@begin{code}
struct geod_geodesic g;
struct geod_geodesicline l;
double s12, azi1, lat[101],lon[101];
int i;
geod_init(&g, 6378137, 1/298.257223563);
geod_inverse(&g, 40.64, -73.78, 1.36, 103.99, &s12, &azi1, 0);
geod_lineinit(&l, &g, 40.64, -73.78, azi1, 0);
for (i = 0; i < 101; ++i) {
  geod_position(&l, i * s12 * 0.01, lat + i, lon + i, 0);
  printf(\"%.5f %.5f\n\", lat[i], lon[i]);
}
@end{code}
"
  (l (:pointer (:struct geod-geodesicline)))
  (s12 :double)
  (plat2 (:pointer :double))
  (plon2 (:pointer :double))
  (pazi2 (:pointer :double)))

;; --------------------------------------------------------

(cffi:defcfun ("geod_gendirect" GEOD-GENDIRECT) :double
  "The general direct geodesic problem.

@param[in] g a pointer to the geod_geodesic object specifying the
  ellipsoid.
@param[in] lat1 latitude of point 1 (degrees).
@param[in] lon1 longitude of point 1 (degrees).
@param[in] azi1 azimuth at point 1 (degrees).
@param[in] flags bitor'ed combination of geod_flags(); \e flags &
  GEOD_ARCMODE determines the meaning of \e s12_a12 and \e flags &
  GEOD_LONG_UNROLL 'unrolls' \e lon2.
@param[in] s12_a12 if \e flags & GEOD_ARCMODE is 0, this is the distance
  between point 1 and point 2 (meters); otherwise it is the arc length
  between point 1 and point 2 (degrees); it can be negative.
@param[out] plat2 pointer to the latitude of point 2 (degrees).
@param[out] plon2 pointer to the longitude of point 2 (degrees).
@param[out] pazi2 pointer to the (forward) azimuth at point 2 (degrees).
@param[out] ps12 pointer to the distance between point 1 and point 2
  (meters).
@param[out] pm12 pointer to the reduced length of geodesic (meters).
@param[out] pM12 pointer to the geodesic scale of point 2 relative to
  point 1 (dimensionless).
@param[out] pM21 pointer to the geodesic scale of point 1 relative to
  point 2 (dimensionless).
@param[out] pS12 pointer to the area under the geodesic
  (meters<sup>2</sup>).
@return \e a12 arc length of between point 1 and point 2 (degrees).

\e g must have been initialized with a call to geod_init().  \e lat1
should be in the range [&minus;90&deg;, 90&deg;].  The function value \e
a12 equals \e s12_a12 if \e flags & GEOD_ARCMODE.  Any of the 'return'
arguments, \e plat2, etc., may be replaced by 0, if you do not need some
quantities computed.

With \e flags & GEOD_LONG_UNROLL bit set, the longitude is 'unrolled' so
that the quantity \e lon2 &minus; \e lon1 indicates how many times and in
what sense the geodesic encircles the ellipsoid.
"
  (g (:pointer (:struct geod-geodesic)))
  (lat1 :double)
  (lon1 :double)
  (azi1 :double)
  (flags :unsigned-int)
  (s12_a12 :double)
  (plat2 (:pointer :double))
  (plon2 (:pointer :double))
  (pazi2 (:pointer :double))
  (ps12 (:pointer :double))
  (pm12 (:pointer :double))
  (p-M12 (:pointer :double))
  (pM21 (:pointer :double))
  (p-S12 (:pointer :double)))

;; --------------------------------------------------------

(cffi:defcfun  ("geod_geninverse" GEOD-GENINVERSE) :double
  "The general inverse geodesic calculation.

@param[in] g a pointer to the geod_geodesic object specifying the
  ellipsoid.
@param[in] lat1 latitude of point 1 (degrees).
@param[in] lon1 longitude of point 1 (degrees).
@param[in] lat2 latitude of point 2 (degrees).
@param[in] lon2 longitude of point 2 (degrees).
@param[out] ps12 pointer to the distance between point 1 and point 2
 (meters).
@param[out] pazi1 pointer to the azimuth at point 1 (degrees).
@param[out] pazi2 pointer to the (forward) azimuth at point 2 (degrees).
@param[out] pm12 pointer to the reduced length of geodesic (meters).
@param[out] pM12 pointer to the geodesic scale of point 2 relative to
  point 1 (dimensionless).
@param[out] pM21 pointer to the geodesic scale of point 1 relative to
  point 2 (dimensionless).
@param[out] pS12 pointer to the area under the geodesic
  (meters<sup>2</sup>).
@return \e a12 arc length of between point 1 and point 2 (degrees).

\e g must have been initialized with a call to geod_init().  \e lat1 and
\e lat2 should be in the range [&minus;90&deg;, 90&deg;].  Any of the
'return' arguments \e ps12, etc., may be replaced by 0, if you do not need
some quantities computed.
"
  (g (:pointer (:struct geod-geodesic)))
  (lat1 :double)
  (lon1 :double)
  (lat2 :double)
  (lon2 :double)
  (ps12 (:pointer :double))
  (pazi1 (:pointer :double))
  (pazi2 (:pointer :double))
  (pm12 (:pointer :double))
  (p-M12 (:pointer :double))
  (pM21 (:pointer :double))
  (p-S12 (:pointer :double)))

;; --------------------------------------------------------

(cffi:defcfun  ("geod_genposition" GEOD-GENPOSITION) :double
  "The general position function.

@param[in] l a pointer to the geod_geodesicline object specifying the
  geodesic line.
@param[in] flags bitor'ed combination of geod_flags(); \e flags &
  GEOD_ARCMODE determines the meaning of \e s12_a12 and \e flags &
  GEOD_LONG_UNROLL 'unrolls' \e lon2; if \e flags & GEOD_ARCMODE is 0,
  then \e l must have been initialized with \e caps |= GEOD_DISTANCE_IN.
@param[in] s12_a12 if \e flags & GEOD_ARCMODE is 0, this is the
  distance between point 1 and point 2 (meters); otherwise it is the
  arc length between point 1 and point 2 (degrees); it can be
  negative.
@param[out] plat2 pointer to the latitude of point 2 (degrees).
@param[out] plon2 pointer to the longitude of point 2 (degrees); requires
  that \e l was initialized with \e caps |= GEOD_LONGITUDE.
@param[out] pazi2 pointer to the (forward) azimuth at point 2 (degrees).
@param[out] ps12 pointer to the distance between point 1 and point 2
  (meters); requires that \e l was initialized with \e caps |=
  GEOD_DISTANCE.
@param[out] pm12 pointer to the reduced length of geodesic (meters);
  requires that \e l was initialized with \e caps |= GEOD_REDUCEDLENGTH.
@param[out] pM12 pointer to the geodesic scale of point 2 relative to
  point 1 (dimensionless); requires that \e l was initialized with \e caps
  |= GEOD_GEODESICSCALE.
@param[out] pM21 pointer to the geodesic scale of point 1 relative to
  point 2 (dimensionless); requires that \e l was initialized with \e caps
  |= GEOD_GEODESICSCALE.
@param[out] pS12 pointer to the area under the geodesic
  (meters<sup>2</sup>); requires that \e l was initialized with \e caps |=
  GEOD_AREA.
@return \e a12 arc length of between point 1 and point 2 (degrees).

\e l must have been initialized with a call to geod_lineinit() with \e
caps |= GEOD_DISTANCE_IN.  The value \e azi2 returned is in the range
[&minus;180&deg;, 180&deg;).  Any of the 'return' arguments \e plat2,
etc., may be replaced by 0, if you do not need some quantities
computed.  Requesting a value which \e l is not capable of computing
is not an error; the corresponding argument will not be altered.

With \e flags & GEOD_LONG_UNROLL bit set, the longitude is 'unrolled' so
that the quantity \e lon2 &minus; \e lon1 indicates how many times and in
what sense the geodesic encircles the ellipsoid.

Example, compute way points between JFK and Singapore Changi Airport
using geod_genposition().  In this example, the points are evenly space in
arc length (and so only approximately equally space in distance).  This is
faster than using geod_position() would be appropriate if drawing the path
on a map.
@code{.c}
struct geod_geodesic g;
struct geod_geodesicline l;
double a12, azi1, lat[101], lon[101];
int i;
geod_init(&g, 6378137, 1/298.257223563);
a12 = geod_geninverse(&g, 40.64, -73.78, 1.36, 103.99,
                      0, &azi1, 0, 0, 0, 0, 0);
geod_lineinit(&l, &g, 40.64, -73.78, azi1, GEOD_LATITUDE | GEOD_LONGITUDE);
for (i = 0; i < 101; ++i) {
  geod_genposition(&l, 1, i * a12 * 0.01,
                   lat + i, lon + i, 0, 0, 0, 0, 0, 0);
  printf(\"%.5f %.5f\n\", lat[i], lon[i]);
}
@endcode
"
  (l (:pointer (:struct geod-geodesicline)))
  (flags :unsigned-int)
  (s12_a12 :double)
  (plat2 (:pointer :double))
  (plon2 (:pointer :double))
  (pazi2 (:pointer :double))
  (ps12 (:pointer :double))
  (pm12 (:pointer :double))
  (p-M12 (:pointer :double))
  (pM21 (:pointer :double))
  (p-S12 (:pointer :double)))

;; --------------------------------------------------------

(cffi:defcfun ("geod_polygon_init" GEOD-POLYGON-INIT) :void
  "Initialize a geod_polygon object.

@param[out] p a pointer to the object to be initialized.
@param[in] polylinep non-zero if a polyline instead of a polygon.

If \e polylinep is zero, then the sequence of vertices and edges added by
geod_polygon_addpoint() and geod_polygon_addedge() define a polygon and
the perimeter and area are returned by geod_polygon_compute().  If \e
polylinep is non-zero, then the vertices and edges define a polyline and
only the perimeter is returned by geod_polygon_compute().

The area and perimeter are accumulated at two times the standard floating
point precision to guard against the loss of accuracy with many-sided
polygons.  At any point you can ask for the perimeter and area so far.

An example of the use of this function is given in the documentation for
geod_polygon_compute().
"
  (p (:pointer (:struct geod-polygon)))
  (polylinep :int))

;; --------------------------------------------------------

(cffi:defcfun ("geod_polygon_addpoint" GEOD-POLYGON-ADDPOINT) :void
  "Add a point to the polygon or polyline.

@param[in] g a pointer to the geod_geodesic object specifying the
  ellipsoid.
@param[in,out] p a pointer to the geod_polygon object specifying the
  polygon.
@param[in] lat the latitude of the point (degrees).
@param[in] lon the longitude of the point (degrees).

\e g and \e p must have been initialized with calls to geod_init() and
geod_polygon_init(), respectively.  The same \e g must be used for all the
points and edges in a polygon.  \e lat should be in the range
[&minus;90&deg;, 90&deg;].

An example of the use of this function is given in the documentation for
geod_polygon_compute().
"
  (g (:pointer (:struct geod-geodesic)))
  (p (:pointer (:struct geod-polygon)))
  (lat :double)
  (lon :double))

  ;; --------------------------------------------------------

(cffi:defcfun ("geod_polygon_addedge" GEOD-POLYGON-ADDEDGE) :void
  "Add an edge to the polygon or polyline.

@param[in] g a pointer to the geod_geodesic object specifying the
  ellipsoid.
@param[in,out] p a pointer to the geod_polygon object specifying the
  polygon.
@param[in] azi azimuth at current point (degrees).
@param[in] s distance from current point to next point (meters).

\e g and \e p must have been initialized with calls to geod_init() and
geod_polygon_init(), respectively.  The same \e g must be used for all the
points and edges in a polygon.  This does nothing if no points have been
added yet.  The \e lat and \e lon fields of \e p give the location of the
new vertex."
  (g (:pointer (:struct geod-geodesic)))
  (p (:pointer (:struct geod-polygon)))
  (azi :double)
  (s :double))

;; --------------------------------------------------------

(cffi:defcfun ("geod_polygon_compute" GEOD-POLYGON-COMPUTE) :unsigned-int
  "Return the results for a polygon.

@param[in] g a pointer to the geod_geodesic object specifying the
  ellipsoid.
@param[in] p a pointer to the geod_polygon object specifying the polygon.
@param[in] reverse if non-zero then clockwise (instead of
  counter-clockwise) traversal counts as a positive area.
@param[in] sign if non-zero then return a signed result for the area if
  the polygon is traversed in the 'wrong' direction instead of returning
  the area for the rest of the earth.
@param[out] pA pointer to the area of the polygon (meters<sup>2</sup>);
  only set if \e polyline is non-zero in the call to geod_polygon_init().
@param[out] pP pointer to the perimeter of the polygon or length of the
  polyline (meters).
@return the number of points.

The area and perimeter are accumulated at two times the standard floating
point precision to guard against the loss of accuracy with many-sided
polygons.  Only simple polygons (which are not self-intersecting) are
allowed.  There's no need to 'close' the polygon by repeating the first
vertex.  Set \e pA or \e pP to zero, if you do not want the corresponding
quantity returned.

Example, compute the perimeter and area of the geodesic triangle with
vertices (0&deg;N,0&deg;E), (0&deg;N,90&deg;E), (90&deg;N,0&deg;E).
@code{.c}
double A, P;
int n;
struct geod_geodesic g;
struct geod_polygon p;
geod_init(&g, 6378137, 1/298.257223563);
geod_polygon_init(&p, 0);

geod_polygon_addpoint(&g, &p,  0,  0);
geod_polygon_addpoint(&g, &p,  0, 90);
geod_polygon_addpoint(&g, &p, 90,  0);
n = geod_polygon_compute(&g, &p, 0, 1, &A, &P);
printf(\"%d %.8f %.3f\n\", n, P, A);
@endcode"
  (g (:pointer (:struct geod-geodesic)))
  (p (:pointer (:struct geod-polygon)))
  (reverse :int)
  (sign :int)
  (pa (:pointer :double))
  (pp (:pointer :double)))

;; --------------------------------------------------------

(cffi:defcfun ("geod_polygon_testpoint" GEOD-POLYGON-TESTPOINT) :unsigned-int
  "Return the results assuming a tentative final test point is added;
however, the data for the test point is not saved.  This lets you report a
running result for the perimeter and area as the user moves the mouse
cursor.  Ordinary floating point arithmetic is used to accumulate the data
for the test point; thus the area and perimeter returned are less accurate
than if geod_polygon_addpoint() and geod_polygon_compute() are used.

@param[in] g a pointer to the geod_geodesic object specifying the
  ellipsoid.
@param[in] p a pointer to the geod_polygon object specifying the polygon.
@param[in] lat the latitude of the test point (degrees).
@param[in] lon the longitude of the test point (degrees).
@param[in] reverse if non-zero then clockwise (instead of
  counter-clockwise) traversal counts as a positive area.
@param[in] sign if non-zero then return a signed result for the area if
  the polygon is traversed in the 'wrong' direction instead of returning
  the area for the rest of the earth.
@param[out] pA pointer to the area of the polygon (meters<sup>2</sup>);
  only set if \e polyline is non-zero in the call to geod_polygon_init().
@param[out] pP pointer to the perimeter of the polygon or length of the
  polyline (meters).
@return the number of points.

\e lat should be in the range [&minus;90&deg;, 90&deg;]."
  (g (:pointer (:struct geod-geodesic)))
  (p (:pointer (:struct geod-polygon)))
  (lat :double)
  (lon :double)
  (reverse :int)
  (sign :int)
  (pa (:pointer :double))
  (pp (:pointer :double)))

;; --------------------------------------------------------

(cffi:defcfun ("geod_polygon_testedge" GEOD-POLYGON-TESTEDGE) :unsigned-int
  "Return the results assuming a tentative final test point is added via an
azimuth and distance; however, the data for the test point is not saved.
This lets you report a running result for the perimeter and area as the
user moves the mouse cursor.  Ordinary floating point arithmetic is used
to accumulate the data for the test point; thus the area and perimeter
returned are less accurate than if geod_polygon_addedge() and
geod_polygon_compute() are used.

@param[in] g a pointer to the geod_geodesic object specifying the
  ellipsoid.
@param[in] p a pointer to the geod_polygon object specifying the polygon.
@param[in] azi azimuth at current point (degrees).
@param[in] s distance from current point to final test point (meters).
@param[in] reverse if non-zero then clockwise (instead of
  counter-clockwise) traversal counts as a positive area.
@param[in] sign if non-zero then return a signed result for the area if
  the polygon is traversed in the 'wrong' direction instead of returning
  the area for the rest of the earth.
@param[out] pA pointer to the area of the polygon (meters<sup>2</sup>);
  only set if \e polyline is non-zero in the call to geod_polygon_init().
@param[out] pP pointer to the perimeter of the polygon or length of the
  polyline (meters).
@return the number of points."

  (g (:pointer (:struct geod-geodesic)))
  (p (:pointer (:struct geod-polygon)))
  (azi :double)
  (s :double)
  (reverse :int)
  (sign :int)
  (pA (:pointer :double))
  (pP (:pointer :double)))

;; --------------------------------------------------------

(cffi:defcfun  ("geod_polygonarea" GEOD-POLYGONAREA) :void
  "A simple interface for computing the area of a geodesic polygon.

@param[in] g a pointer to the geod_geodesic object specifying the
  ellipsoid.
@param[in] lats an array of latitudes of the polygon vertices (degrees).
@param[in] lons an array of longitudes of the polygon vertices (degrees).
@param[in] n the number of vertices.
@param[out] pA pointer to the area of the polygon (meters<sup>2</sup>).
@param[out] pP pointer to the perimeter of the polygon (meters).

\e lats should be in the range [&minus;90&deg;, 90&deg;].

Only simple polygons (which are not self-intersecting) are allowed.
There's no need to 'close' the polygon by repeating the first vertex.  The
area returned is signed with counter-clockwise traversal being treated as
positive.

Example, compute the area of Antarctica:
@code{.c}
double
  lats[] = {-72.9, -71.9, -74.9, -74.3, -77.5, -77.4, -71.7, -65.9, -65.7,
            -66.6, -66.9, -69.8, -70.0, -71.0, -77.3, -77.9, -74.7},
  lons[] = {-74, -102, -102, -131, -163, 163, 172, 140, 113,
             88, 59, 25, -4, -14, -33, -46, -61};
struct geod_geodesic g;
double A, P;
geod_init(&g, 6378137, 1/298.257223563);
geod_polygonarea(&g, lats, lons, (sizeof lats) / (sizeof lats[0]), &A, &P);
printf(\"%.0f %.2f\n\", A, P);
@endcode"

  (g (:pointer (:struct geod-geodesic)))
  (lats (:pointer :double))
  (lons (:pointer :double))
  (n :int)
  (pa :pointer :double)
  (pp :pointer :double))

;; --------------------------------------------------------
;; HIGH LEVEL WRAPPERS
;; --------------------------------------------------------

(defun convert-flags-to-foreign (flags enum)
  "Converts list of flags from the given ENUM into a foreign/native
integer using bitwise OR (LOGIOR).

Flags can be declared using Groveler as a CENUM."
  (apply #'logior
         (map 'list
              #'(lambda (f)
                  (cffi:convert-to-foreign f enum))
              flags)))

;; --------------------------------------------------------

(defclass geo-object ()
  ((pointer
    :type (or null cffi:foreign-pointer)
    :initarg :pointer
    :accessor pointer
    :initform nil)))

;;---------------------------------------------------------

(defclass geodesic (geo-object) ())

;;---------------------------------------------------------

(defun make-geodesic (&key (a +equatorial-radius+) (f +flattening+))
  (let ((g (make-instance 'geodesic))
        (ptr (cffi:foreign-alloc '(:struct geod-geodesic))))
    (setf (pointer g) ptr)
    (tg:finalize g (lambda () (cffi:foreign-free ptr)))
    ;; avoid FLOATING-POINT-INVALID-OPERATION generated from within
    ;; the native code. SBCL-compatible approach
    #+sbcl
    (sb-int:with-float-traps-masked  (:invalid :divide-by-zero)
      (geod-init (pointer g) a f))
    #-sbcl
    (geod-init (pointer g) a f)
    g))

;;---------------------------------------------------------

(defun direct-problem (g lat1 lon1 azi1 s12)
  (cffi:with-foreign-objects ((plat2 :double 1)
                              (plon2 :double 1)
                              (pazi2 :double 1))

    (geod-direct (pointer g)
                 (float lat1 0.0d0)
                 (float lon1 0.0d0)
                 (float azi1 0.0d0)
                 (float s12 0.0d0)
                 plat2 plon2 pazi2)
    (values
     (cffi:mem-aref plat2 :double 0)
     (cffi:mem-aref plon2 :double 0)
     (cffi:mem-aref pazi2 :double 0))))

;;---------------------------------------------------------

(defun inverse-problem (g lat1 lon1 lat2 lon2)
  "@short{Solve the inverse geodesic problem.}

Returns three values:
* distance between point 1 and point 2 (meters).
* azimuth at point 1 (degrees).
* (forward) azimuth at point 2 (degrees).

Example, determine the distance between JFK and Singapore Changi
Airport:

 (let ((g (pj:make-geodesic)))
   (multiple-value-bind (ps12 pazi1 pazi2)
             (pj:inverse-problem g 40.64 -73.78 1.36 103.99)
           (declare (ignore pazi1 pazi2))
           (format t \"~,3f~%\" ps12)))

See: `GEOD-INVERSE'
"
  (cffi:with-foreign-objects ( ;; distance between point 1 and point 2
                              (ps12 :double 1)
                              ;; azimuth at point 1 (degrees)
                              (pazi1 :double 1)
                              ;; (forward) azimuth at point 2 (degrees)
                              (pazi2 :double 1))

    (geod-inverse (pointer g)
                  (float lat1 0.0d0)
                  (float lon1 0.0d0)
                  (float lat2 0.0d0)
                  (float lon2 0.0d0)
                  ps12 pazi1 pazi2)
    (values
     (cffi:mem-aref ps12 :double 0)
     (cffi:mem-aref pazi1 :double 0)
     (cffi:mem-aref pazi2 :double 0))))

;;---------------------------------------------------------

(export '(geodesic make-geodesic
          direct-problem inverse-problem))

;;---------------------------------------------------------

(defclass geo-line (geo-object) ())
(export 'geo-line)

;;---------------------------------------------------------

(defun make-geo-line (g lat1 lon1 azi1 &optional (caps nil))
  "@short{Initialize a geod_geodesicline object.}

@arg[g]{a pointer to the geod_geodesic object specifying the ellipsoid.}
@arg[lat1]{latitude of point 1 (degrees).}
@arg[lon1]{longitude of point 1 (degrees).}
@arg[azi1]{azimuth at point 1 (degrees).}
@arg[caps]{bitor'ed combination of geod_mask() values specifying the
  capabilities the geod_geodesicline object should possess, i.e.,
  which quantities can be returned in calls to geod_position() and
  geod_genposition().}

\e g must have been initialized with a call to geod_init().  \e lat1
should be in the range [&minus;90&deg;, 90&deg;].

The geod_mask values are see `GEOD-MASK':
- GEOD_LATITUDE for the latitude \e lat2; this is
  added automatically,
- GEOD_LONGITUDE for the latitude \e lon2,
- GEOD_AZIMUTH for the latitude \e azi2; this is
  added automatically,
- GEOD_DISTANCE for the distance \e s12,
- GEOD_REDUCEDLENGTH for the reduced length \e m12,
- GEOD_GEODESICSCALE for the geodesic scales \e M12
  and \e M21,
- GEOD_AREA for the area \e S12,
- GEOD_DISTANCE_IN permits the length of the
  geodesic to be given in terms of \e s12; without this capability the
  length can only be specified in terms of arc length.

A value of \e caps = 0 is treated as GEOD_LATITUDE | GEOD_LONGITUDE |
GEOD_AZIMUTH | GEOD_DISTANCE_IN (to support the solution of the 'standard'
direct problem).
"
  (let ((l (make-instance 'geo-line))
        (ptr (cffi:foreign-alloc '(:struct geod-geodesicline))))
    (setf (pointer l) ptr)
    (tg:finalize l (lambda () (cffi:foreign-free ptr)))
    (geod-lineinit
     (pointer l)
     (pointer g)
     (float lat1 0.0d0)
     (float lon1 0.0d0)
     (float azi1 0.0d0)
     (if caps
         (convert-flags-to-foreign caps 'geod-mask)
         0))
    l))
(export 'make-geo-line)

;;---------------------------------------------------------

(defun geo-position (l s12)
  "@short{Compute the position along a geod_geodesicline.}

 @arg[l]{a pointer to the geod_geodesicline object specifying the geodesic line.}
 @arg[s12]{distance between point 1 and point 2 (meters); it can be negative.}

 param[out] plat2 pointer to the latitude of point 2 (degrees).
 param[out] plon2 pointer to the longitude of point 2 (degrees); requires
   that \e l was initialized with \e caps |= GEOD_LONGITUDE.
 param[out] pazi2 pointer to the (forward) azimuth at point 2 (degrees).

 \e l must have been initialized with a call to geod_lineinit() with \e
 caps |= GEOD_DISTANCE_IN.  The values of \e lon2 and \e azi2 returned are
 in the range [&minus;180&deg;, 180&deg;).  Any of the 'return' arguments
 \e plat2, etc., may be replaced by 0, if you do not need some quantities
 computed.

 Example, compute way points between JFK and Singapore Changi Airport
 the 'obvious' way using GEO-DIRECT:

@begin{code}
(let ((g (pj:make-geodesic)))
  (multiple-value-bind (s12 azi1 azi2)
      (pj:inverse-problem g 40.64 -73.78 1.36 103.99)
    (loop :for i :from 0 :to 100
       :do (multiple-value-bind (lati loni azii)
	       (pj:direct-problem g 40.64 -73.78 azi1 (* i s12 0.01))
	     (declare (ignore azii))
	     (format t \"~,5f ~,5f~%\" lati loni)))))
@end{code}

 A faster way using GEOD-POSITION:

@begin{code}
(let ((g (pj:make-geodesic)))
  (multiple-value-bind (s12 azi1 azi2)
      (pj:inverse-problem g 40.64 -73.78 1.36 103.99)
    (declare (ignore azi2))
    (let ((l (pj:make-geo-line g 40.64 -73.78 azi1)))
      (loop :for i :from 0 :to 100
         :do (multiple-value-bind (lati loni azii)
                 (pj:geo-position l (* s12 i 0.01))
               (declare (ignore azii))
               (format t \"~,5f ~,5f~%\" lati loni))))))
@end{code}
"
  (cffi:with-foreign-objects ((plat2 :double 1)
                              (plon2 :double 1)
                              (pazi2 :double 1))
    (geod-position
     (pointer l)
     (float s12 0.0d0)
     plat2 plon2 pazi2)
    (values
     (cffi:mem-aref plat2 :double 0)
     (cffi:mem-aref plon2 :double 0)
     (cffi:mem-aref pazi2 :double 0))))
(export 'geo-position)

;;---------------------------------------------------------

(defun general-direct-problem (g lat1 lon1 azi1 flags s12_a12)
  "@short{The general direct geodesic problem.}

@arg[g]{a pointer to the geod_geodesic object specifying the ellipsoid.}
@arg[lat1]{latitude of point 1 (degrees).}
@arg[lon1]{longitude of point 1 (degrees).}
@arg[azi1]{azimuth at point 1 (degrees).}
@arg[flags]{bitor'ed combination of geod_flags(); \e flags &
  GEOD_ARCMODE determines the meaning of \e s12_a12 and \e flags &
  GEOD_LONG_UNROLL 'unrolls' \e lon2.}
@arg[s12_a12]{if flags & GEOD_ARCMODE is 0, this is the distance
  between point 1 and point 2 (meters); otherwise it is the arc length
  between point 1 and point 2 (degrees); it can be negative.}

@param[out] plat2 pointer to the latitude of point 2 (degrees).
@param[out] plon2 pointer to the longitude of point 2 (degrees).
@param[out] pazi2 pointer to the (forward) azimuth at point 2 (degrees).
@param[out] ps12 pointer to the distance between point 1 and point 2
  (meters).
@param[out] pm12 pointer to the reduced length of geodesic (meters).
@param[out] pM12 pointer to the geodesic scale of point 2 relative to
  point 1 (dimensionless).
@param[out] pM21 pointer to the geodesic scale of point 1 relative to
  point 2 (dimensionless).
@param[out] pS12 pointer to the area under the geodesic
  (meters<sup>2</sup>).
@return \e a12 arc length of between point 1 and point 2 (degrees).

\e g must have been initialized with a call to geod_init().  \e lat1
should be in the range [&minus;90&deg;, 90&deg;].  The function value \e
a12 equals \e s12_a12 if \e flags & GEOD_ARCMODE.  Any of the 'return'
arguments, \e plat2, etc., may be replaced by 0, if you do not need some
quantities computed.

With \e flags & GEOD_LONG_UNROLL bit set, the longitude is 'unrolled' so
that the quantity \e lon2 &minus; \e lon1 indicates how many times and in
what sense the geodesic encircles the ellipsoid.
"
  (cffi:with-foreign-objects ((plat2 :double 1)
                              (plon2 :double 1)
                              (pazi2 :double 1)
                              (ps12 :double 1)
                              (pm12 :double 1)
                              (p-m12 :double 1)
                              (pm21 :double 1)
                              (p-s12 :double 1))

    (let ((a12 (geod-gendirect
                (pointer g)
                (float lat1 0.0d0)
                (float lon1 0.0d0)
                (float azi1 0.0d0)
                (cffi:convert-to-foreign flags 'geod-flags)
                (float s12_a12 0.0d0)
                plat2 plon2 pazi2
                ps12 pm12 p-M12
                pM21 p-S12)))

      (values a12
              (cffi:mem-aref plat2 :double 0)
              (cffi:mem-aref plon2 :double 0)
              (cffi:mem-aref pazi2 :double 0)
              (cffi:mem-aref ps12 :double 0)
              (cffi:mem-aref pm12 :double 0)
              (cffi:mem-aref p-M12 :double 0)
              (cffi:mem-aref pM21 :double 0)
              (cffi:mem-aref p-S12 :double 0)))))

;;---------------------------------------------------------

(defun general-inverse-problem (g lat1 lon1 lat2 lon2)
  "@short{The general inverse geodesic calculation.}

@arg[g]{GEO-GEODESIC object specifying the ellipsoid.}
@param[in] lat1 latitude of point 1 (degrees).
@param[in] lon1 longitude of point 1 (degrees).
@param[in] lat2 latitude of point 2 (degrees).
@param[in] lon2 longitude of point 2 (degrees).
@param[out] ps12 pointer to the distance between point 1 and point 2
 (meters).
@param[out] pazi1 pointer to the azimuth at point 1 (degrees).
@param[out] pazi2 pointer to the (forward) azimuth at point 2 (degrees).
@param[out] pm12 pointer to the reduced length of geodesic (meters).
@param[out] pM12 pointer to the geodesic scale of point 2 relative to
  point 1 (dimensionless).
@param[out] pM21 pointer to the geodesic scale of point 1 relative to
  point 2 (dimensionless).
@param[out] pS12 pointer to the area under the geodesic
  (meters<sup>2</sup>).
@return \e a12 arc length of between point 1 and point 2 (degrees).

\e g must have been initialized with a call to geod_init().  \e lat1 and
\e lat2 should be in the range [&minus;90&deg;, 90&deg;].
"
  (cffi:with-foreign-objects ((ps12  :double 1)
                              (pazi1 :double 1)
                              (pazi2 :double 1)
                              (pm12  :double 1)
                              (p-M12 :double 1)
                              (pM21  :double 1)
                              (p-S12 :double 1))
    (let ((a12 (geod-geninverse
                (pointer g)
                (float lat1 0.0d0)
                (float lon1 0.0d0)
                (float lat2 0.0d0)
                (float lon2 0.0d0)
                ps12 pazi1 pazi2
                pm12 p-M12 pM21 p-S12)))
      (values a12
              (cffi:mem-aref ps12  :double 0)
              (cffi:mem-aref pazi1 :double 0)
              (cffi:mem-aref pazi2 :double 0)
              (cffi:mem-aref pm12  :double 0)
              (cffi:mem-aref p-M12 :double 0)
              (cffi:mem-aref pM21  :double 0)
              (cffi:mem-aref p-S12 :double 0)))))
(export 'general-inverse-problem)

;;---------------------------------------------------------
(defun general-position (l flags s12_a12)
  "@short{The general position function.}

@arg[l]{GEO-LINE object specifying the geodesic line.}
@arg[flags] bitor'ed combination of GEOD-FLAGS; \e flags &
  GEOD_ARCMODE determines the meaning of \e s12_a12 and \e flags &
  GEOD_LONG_UNROLL 'unrolls' \e lon2; if \e flags & GEOD_ARCMODE is 0,
  then \e l must have been initialized with \e caps |= GEOD_DISTANCE_IN.
@param[in] s12_a12 if \e flags & GEOD_ARCMODE is 0, this is the
  distance between point 1 and point 2 (meters); otherwise it is the
  arc length between point 1 and point 2 (degrees); it can be
  negative.
@param[out] plat2 pointer to the latitude of point 2 (degrees).
@param[out] plon2 pointer to the longitude of point 2 (degrees); requires
  that \e l was initialized with \e caps |= GEOD_LONGITUDE.
@param[out] pazi2 pointer to the (forward) azimuth at point 2 (degrees).
@param[out] ps12 pointer to the distance between point 1 and point 2
  (meters); requires that \e l was initialized with \e caps |=
  GEOD_DISTANCE.
@param[out] pm12 pointer to the reduced length of geodesic (meters);
  requires that \e l was initialized with \e caps |= GEOD_REDUCEDLENGTH.
@param[out] pM12 pointer to the geodesic scale of point 2 relative to
  point 1 (dimensionless); requires that \e l was initialized with \e caps
  |= GEOD_GEODESICSCALE.
@param[out] pM21 pointer to the geodesic scale of point 1 relative to
  point 2 (dimensionless); requires that \e l was initialized with \e caps
  |= GEOD_GEODESICSCALE.
@param[out] pS12 pointer to the area under the geodesic
  (meters<sup>2</sup>); requires that \e l was initialized with \e caps |=
  GEOD_AREA.
@return \e a12 arc length of between point 1 and point 2 (degrees).

\e l must have been initialized with a call to geod_lineinit() with \e
caps |= GEOD_DISTANCE_IN.  The value \e azi2 returned is in the range
[&minus;180&deg;, 180&deg;).  Any of the 'return' arguments \e plat2,
etc., may be replaced by 0, if you do not need some quantities
computed.  Requesting a value which \e l is not capable of computing
is not an error; the corresponding argument will not be altered.

With \e flags & GEOD_LONG_UNROLL bit set, the longitude is 'unrolled' so
that the quantity \e lon2 &minus; \e lon1 indicates how many times and in
what sense the geodesic encircles the ellipsoid.

Example, compute way points between JFK and Singapore Changi Airport
using geod_genposition().  In this example, the points are evenly space in
arc length (and so only approximately equally space in distance).  This is
faster than using geod_position() would be appropriate if drawing the path
on a map.

(let ((g (pj:make-geodesic)))
  (multiple-value-bind (a12 azi1 azi2)
      (pj:general-inverse-problem g 40.64 -73.78 1.36 103.99)
    (declare (ignore azi2))
    (let ((l (pj:make-geo-line g 40.64 -73.78 azi1 '(:latitude :longitude)))))
      (loop :for i :from 0 :to 100
         :do (multiple-value-bind (s12 lati loni)
                 (general-position l '(:arcmode) (* i a12 0.01))
               (declare (ignore s12))
               (format t \"~,5f ~,5f~%\" lati loni))))))
"
  (cffi:with-foreign-objects ((plat2 :double 1)
                              (plon2 :double 1)
                              (pazi2 :double 1)
                              (ps12  :double 1)
                              (pm12  :double 1)
                              (p-M12 :double 1)
                              (pM21  :double 1)
                              (p-S12 :double 1))
    (let ((a12 (geod-genposition
                (pointer l)
                (convert-flags-to-foreign flags 'geod-flags)
                (float s12_a12 0.0d0)
                plat2 plon2 pazi2 ps12
                pm12 p-M12 pM21 p-S12)))
      (values a12
              (cffi:mem-aref plat2 :double 0)
              (cffi:mem-aref plon2 :double 0)
              (cffi:mem-aref pazi2 :double 0)
              (cffi:mem-aref ps12  :double 0)
              (cffi:mem-aref pm12  :double 0)
              (cffi:mem-aref p-M12 :double 0)
              (cffi:mem-aref pM21  :double 0)
              (cffi:mem-aref p-S12 :double 0)))))
(export 'general-position)

;;---------------------------------------------------------

(defclass geo-polygon (geo-object) ())
(export 'geo-polygon)

;;---------------------------------------------------------

(defun make-geo-polygon (&optional polylinep)
  "@short{Initialize a geod_polygon object.}

@arg[polylinep]{non-NIL if a polyline instead of a polygon.}

If \e polylinep is NIL, then the sequence of vertices and edges added by
geod_polygon_addpoint() and geod_polygon_addedge() define a polygon and
the perimeter and area are returned by geod_polygon_compute().  If \e
polylinep is non-zero, then the vertices and edges define a polyline and
only the perimeter is returned by geod_polygon_compute().

The area and perimeter are accumulated at two times the standard floating
point precision to guard against the loss of accuracy with many-sided
polygons.  At any point you can ask for the perimeter and area so far.

An example of the use of this function is given in the documentation for
geod_polygon_compute().
"
  (let ((l (make-instance 'geo-polygon))
        (ptr (cffi:foreign-alloc '(:struct geod-polygon))))
    (setf (pointer l) ptr)
    (tg:finalize l (lambda () (cffi:foreign-free ptr)))
    (geod-polygon-init ptr
                       (if polylinep 1 0))))
(export 'make-geo-polygon)

;;---------------------------------------------------------

(defun polygon-add-point (g p lat lon)
  (geod-polygon-addpoint
   (pointer g)
   (pointer p)
   (float lat 0.0d0)
   (float lon 0.0d0)))
(export 'polygon-add-point)

;;---------------------------------------------------------

(defun polygon-add-edge (g p azi s)
  (geod-polygon-addedge
   (pointer g)
   (pointer p)
   (float azi 0.0d0)
   (float s 0.0d0)))
(export 'polygon-add-edge)

;;---------------------------------------------------------

(defun polygon-compute (g p &key reverse sign)
  (cffi:with-foreign-objects ((pa :double 1)
                              (pp :double 1))
    (let ((count (geod-polygon-compute
                  (pointer g)
                  (pointer p)
                  (if reverse 1 0)
                  (if sign 1 0)
                  pa pp)))
      (values count
              (cffi:mem-aref pa :double 0)
              (cffi:mem-aref pp :double 0)))))
(export 'polygon-compute)

;;---------------------------------------------------------
;; "geod_polygon_testpoint" GEOD-POLYGON-TESTPOINT) :unsigned-int
(defun polygon-test-point (g p lat lon &key reverse sign)
  (cffi:with-foreign-objects ((pa :double 1)
                              (pp :double 1))

    (let ((count
           (geod-polygon-testpoint
            (pointer g)
            (pointer p)
            (float lat 0.0d0)
            (float lon 0.0d0)
            (if reverse 1 0)
            (if sign 1 0)
            pa pp)))
      (values count
              (cffi:mem-aref pa :double 0)
              (cffi:mem-aref pp :double 0)))))
(export 'polygon-test-point)

;;---------------------------------------------------------
;; "geod_polygon_testedge" GEOD-POLYGON-TESTEDGE) :unsigned-int
(defun polygon-test-edge (g p azi s &key reverse sign)
  (cffi:with-foreign-objects ((pa :double 1)
                              (pp :double 1))
    (let ((count
           (geod-polygon-testedge
            (pointer g)
            (pointer p)
            (float azi 0.0d0)
            (float s 0.0d0)
            (if reverse 1 0)
            (if sign 1 0)
            pa pp)))
      (values count
              (cffi:mem-aref pa :double 0)
              (cffi:mem-aref pp :double 0)))))

;;---------------------------------------------------------

(defun polygon-area (g lats lons)
  "@short{A simple interface for computing the area of a geodesic polygon.}

@param[in] g a pointer to the geod_geodesic object specifying the
  ellipsoid.
@param[in] lats an array of latitudes of the polygon vertices (degrees).
@param[in] lons an array of longitudes of the polygon vertices (degrees).
@param[in] n the number of vertices.
@param[out] pA pointer to the area of the polygon (meters<sup>2</sup>).
@param[out] pP pointer to the perimeter of the polygon (meters).

\e lats should be in the range [&minus;90&deg;, 90&deg;].

Only simple polygons (which are not self-intersecting) are allowed.
There's no need to 'close' the polygon by repeating the first vertex.  The
area returned is signed with counter-clockwise traversal being treated as
positive.

Example, compute the area of Antarctica:

(let ((g (pj:make-geodesic))
      (lats '(-72.9 -71.9 -74.9 -74.3 -77.5 -77.4 -71.7 -65.9 -65.7
              -66.6 -66.9 -69.8 -70.0 -71.0 -77.3 -77.9 -74.7))
      (lons '(-74 -102 -102 -131 -163 163 172 140 113
              88 59 25 -4 -14 -33 -46 -61)))
  (multiple-value-bind (count pa pp)
      (pj:polygon-area g lats lons)
    (declare (ignore count))
    (list pa pp)))
"
  (let ((count (length lats)))
    (cffi:with-foreign-objects ((nlats :double count)
                                (nlons :double count)
                                (pa :double 1)
                                (pp :double 1))
      (loop :for lat :in lats
         :for lon :in lons
         :for i :from 0 :below count
         :do (setf (cffi:mem-aref nlats :double i) (float lat 0.0d0)
                   (cffi:mem-aref nlons :double i) (float lon 0.0d0)))

      (geod-polygonarea
       (pointer g) 
       nlats
       nlons
       (length lats)
       pa pp)
      (values count
              (cffi:mem-aref pa :double 0)
              (cffi:mem-aref pp :double 0)))))
(export 'polygon-area)

;; EOF
