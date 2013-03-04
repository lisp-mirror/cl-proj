;;; This file was automatically generated by SWIG (http://www.swig.org).
;;; Version 2.0.4 and then hand-crafted to make the glue code more usable.

;; Copyright (c) 2012, 2013 Victor Anyakin <anyakinvictor@yahoo.com>
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

(in-package :cl-proj)

(cl:defconstant +PJ-VERSION+ 470)

(cffi:defcvar ("pj_release" PJ-RELEASE)
    :string)

(cl:defconstant +RAD-TO-DEG+ 57.29577951308232d0)

(cl:defconstant +DEG-TO-RAD+ .0174532925199432958d0)

(cffi:defcvar ("pj_errno" PJ-ERRNO)
    :int)

(cffi:defcstruct projUV
    (u :double)
  (v :double))

(cffi:defcfun ("pj_fwd" PJ-FWD) projUV
  "Forward cartographic projection."
  (arg0 projUV)
  (arg1 :pointer))

(cffi:defcfun ("pj_inv" PJ-INV) projUV
  "Inverse cartographic projection."
  (arg0 projUV)
  (arg1 :pointer))

(cffi:defcfun ("pj_transform" PJ-TRANSFORM) :int
  "@short{Transform between coordinate systems.}

The PJ-TRANSFORM function may be used to transform points between the
two provided coordinate systems.  In addition to converting between
cartographic projection coordinates and geographic coordinates, this
function also takes care of datum shifts if possible between the
source and destination coordinate system.  Unlike @fun{PJ-FWD} and
@fun{PJ-INV} it is also allowable for the coordinate system
definitions (PJ *) to be geographic coordinate systems (defined as
+proj=latlong).  The x, y and z arrays contain the input values of the
points, and are replaced with the output values.  The point_offset
should indicate the spacing the of x,y,z arrays, normally 1.  The
function returns zero on success, or the error number (also in
@variable{pj-errno}) on failure.

The z array may be passed as NULL if Z values are not available. 

@arg[src]{source (input) coordinate system.}

@arg[dst]{destination (output) coordinate system.}

@arg[point_count]{the number of points to be processed (the size of the x/y/z arrays).}

@arg[point_offset]{the step size from value to value (measured in
 doubles) within the x/y/z arrays - normally 1 for a packed array. May
 be used to operate on xyz interleaved point arrays.}

X/Y/Z: The array of X, Y and Z coordinate values passed as input,
and modified in place for output. The Z may optionally be NULL.

@return{The return is zero on success, or a PROJ.4 error code.}

Memory associated with the projection may be freed with @fun{pj-free}."

  (src :pointer)
  (dst :pointer)
  (point_count :long)
  (point_offset :int)
  (x (:pointer :double))
  (y (:pointer :double))
  (z (:pointer :double)))

(cffi:defcfun ("pj_datum_transform" PJ-DATUM-TRANSFORM) :int
  (src :pointer)
  (dst :pointer)
  (point_count :long)
  (point_offset :int)
  (x (:pointer :double))
  (y (:pointer :double))
  (z (:pointer :double)))

(cffi:defcfun ("pj_geocentric_to_geodetic" PJ-GEOCENTRIC-TO-GEODETIC) :int
  (a :double)
  (es :double)
  (point_count :long)
  (point_offset :int)
  (x (:pointer :double))
  (y (:pointer :double))
  (z (:pointer :double)))

(cffi:defcfun ("pj_geodetic_to_geocentric" PJ-GEODETIC-TO-GEOCENTRIC) :int
  (a :double)
  (es :double)
  (point_count :long)
  (point_offset :int)
  (x (:pointer :double))
  (y (:pointer :double))
  (z (:pointer :double)))

(cffi:defcfun ("pj_compare_datums" PJ-COMPARE-DATUMS) :int
  (srcdefn :pointer)
  (dstdefn :pointer))

(cffi:defcfun ("pj_apply_gridshift" PJ-APPLY-GRIDSHIFT) :int
  (arg0 :string)
  (arg1 :int)
  (point_count :long)
  (point_offset :int)
  (x (:pointer :double))
  (y (:pointer :double))
  (z (:pointer :double)))

(cffi:defcfun ("pj_deallocate_grids" PJ-DEALLOCATE-GRIDS) :void)

(cffi:defcfun ("pj_is_latlong" PJ-IS-LATLONG) :int
  (arg0 :pointer))

(cffi:defcfun ("pj_is_geocent" PJ-IS-GEOCENT) :int
  (arg0 :pointer))

(cffi:defcfun ("pj_pr_list" PJ-PR-LIST) :void
  (arg0 :pointer))

(cffi:defcfun ("pj_free" PJ-FREE) :void
  (arg0 :pointer))

(cffi:defcfun ("pj_set_finder" PJ-SET-FINDER) :void
  (arg0 :pointer))

(cffi:defcfun ("pj_set_searchpath" PJ-SET-SEARCHPATH) :void
  (count :int)
  (path :pointer))

(cffi:defcfun ("pj_init" PJ-INIT) :pointer
  (arg0 :int)
  (arg1 :pointer))

(cffi:defcfun ("pj_init_plus" PJ-INIT-PLUS) :pointer
  "@short{Convert a string representation of a coordinate system definition
 into an internal representation.}

This function converts a string representation of a coordinate system
definition into a projPJ object suitable for use with other API
functions. On failure the function will return NULL and set
pj_errno. The definition should be of the general form \"+proj=tmerc
+lon_0 +datum=WGS84\". Refer to PROJ.4 documentation and the General
Parameters notes for additional details.

Coordinate system objects allocated with PJ-INIT-PLUS should be
deallocated with @fun{PJ-FREE}."
  (arg0 :string))

(cffi:defcfun ("pj_get_def" PJ-GET-DEF) :string
  (arg0 :pointer)
  (arg1 :int))

(cffi:defcfun ("pj_latlong_from_proj" PJ-LATLONG-FROM-PROJ) :pointer
  (arg0 :pointer))

(cffi:defcfun ("pj_malloc" PJ-MALLOC) :pointer
  (arg0 :pointer))

(cffi:defcfun ("pj_dalloc" PJ-DALLOC) :void
  (arg0 :pointer))

(cffi:defcfun ("pj_strerrno" PJ-STRERRNO) :string
  (arg0 :int))

(cffi:defcfun ("pj_get_errno_ref" PJ-GET-ERRNO-REF) :pointer)

(cffi:defcfun ("pj_get_release" PJ-GET-RELEASE) :string)

(cffi:defcfun ("pj_acquire_lock" PJ-ACQUIRE-LOCK) :void)

(cffi:defcfun ("pj_release_lock" PJ-RELEASE-LOCK) :void)

(cffi:defcfun ("pj_cleanup_lock" PJ-CLEANUP-LOCK) :void)

