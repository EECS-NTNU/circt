; RUN: firtool %s | FileCheck %s

; Test that a wire in an inlined instance get the proper Trace Annotation.
circuit Foo: %[[
  {
    "class":"chisel3.experimental.Trace$TraceNameAnnotation",
    "target":"~Foo|Foo/bar:Bar>_x",
    "chiselTarget":"~Foo|Foo/bar:Bar>_x"
  },
  {
    "class": "firrtl.passes.InlineAnnotation",
    "target": "~Foo|Bar"
  }
]]
  module Bar:
    input a: UInt<1>
    output b: UInt<1>

    node _x = a
    b <= _x

  module Foo:
    input a: UInt<1>
    output b: UInt<1>

    inst bar of Bar

    bar.a <= a
    b <= bar.b

; Wire "_x" should not be optimized away.
;
; CHECK-LABEL: module Foo
; CHECK:         wire [[_x:[A-Za-z0-9_]+]]

; The final Annotation target matches the wire name.
;
; CHECK-LABEL: FILE "Foo.anno.json"
; CHECK:         "class": "chisel3.experimental.Trace$TraceNameAnnotation",
; CHECK-NEXT:    "target": "~Foo|Foo>[[_x]]",
; CHECK-NEXT:    "chiselTarget": "~Foo|Foo/bar:Bar>_x"
