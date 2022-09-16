// RUN: circt-translate %s --export-systemc | FileCheck %s

// CHECK-LABEL: // stdout.h
// CHECK-NEXT: #ifndef STDOUT_H
// CHECK-NEXT: #define STDOUT_H

// CHECK: #include <systemc.h>
// CHECK: #include "nosystemheader"

emitc.include <"systemc.h">
emitc.include "nosystemheader"

// CHECK-EMPTY:
// CHECK-LABEL: SC_MODULE(submodule) {
systemc.module @submodule (%in0: !systemc.in<!systemc.uint<32>>, %in1: !systemc.in<!systemc.uint<32>>, %out0: !systemc.out<!systemc.uint<32>>) {
// CHECK-NEXT: sc_in<sc_uint<32>> in0;
// CHECK-NEXT: sc_in<sc_uint<32>> in1;
// CHECK-NEXT: sc_out<sc_uint<32>> out0;
// CHECK-NEXT: };
}

// CHECK-EMPTY:
// CHECK-LABEL: SC_MODULE(basic) {
systemc.module @basic (%port0: !systemc.in<i1>, %port1: !systemc.inout<!systemc.uint<64>>, %port2: !systemc.out<i64>, %port3: !systemc.out<!systemc.bv<1024>>, %port4: !systemc.out<i1>) {
  // CHECK-NEXT: sc_in<bool> port0;
  // CHECK-NEXT: sc_inout<sc_uint<64>> port1;
  // CHECK-NEXT: sc_out<uint64_t> port2;
  // CHECK-NEXT: sc_out<sc_bv<1024>> port3;
  // CHECK-NEXT: sc_out<bool> port4;
  // CHECK-NEXT: sc_signal<sc_uint<64>> sig;
  %sig = systemc.signal : !systemc.signal<!systemc.uint<64>>
  // CHECK-NEXT: sc_signal<sc_uint<32>> channel;
  %channel = systemc.signal : !systemc.signal<!systemc.uint<32>>
  // CHECK-NEXT: submodule submoduleInstance;
  %submoduleInstance = systemc.instance.decl @submodule : !systemc.module<submodule(in0: !systemc.in<!systemc.uint<32>>, in1: !systemc.in<!systemc.uint<32>>, out0: !systemc.out<!systemc.uint<32>>)>
  // CHECK-NEXT: uint32_t testvar;
  %testvar = systemc.cpp.variable : i32
  // CHECK-NEXT: uint32_t testvarwithinit = 42;
  %c42_i32 = hw.constant 42 : i32
  %testvarwithinit = systemc.cpp.variable %c42_i32 : i32
  // CHECK-EMPTY: 
  // CHECK-NEXT: SC_CTOR(basic) {
  systemc.ctor {
    // CHECK-NEXT: submoduleInstance.in0(channel);
    systemc.instance.bind_port %submoduleInstance["in0"] to %channel : !systemc.module<submodule(in0: !systemc.in<!systemc.uint<32>>, in1: !systemc.in<!systemc.uint<32>>, out0: !systemc.out<!systemc.uint<32>>)>, !systemc.signal<!systemc.uint<32>>
    // CHECK-NEXT: SC_METHOD(add);
    systemc.method %add
    // CHECK-NEXT: SC_THREAD(add);
    systemc.thread %add
  // CHECK-NEXT: }
  }
  // CHECK-EMPTY:
  // CHECK-NEXT: void add() {
  %add = systemc.func {
    // CHECK-NEXT: sig.write(port1.read());
    %0 = systemc.signal.read %port1 : !systemc.inout<!systemc.uint<64>>
    systemc.signal.write %sig, %0 : !systemc.signal<!systemc.uint<64>>
    // CHECK-NEXT: port2.write(42);
    %1 = hw.constant 42 : i64
    systemc.signal.write %port2, %1 : !systemc.out<i64>
    // CHECK-NEXT: port4.write(true);
    %2 = hw.constant 1 : i1
    systemc.signal.write %port4, %2 : !systemc.out<i1>
    // CHECK-NEXT: port4.write(false);
    %3 = hw.constant 0 : i1
    systemc.signal.write %port4, %3 : !systemc.out<i1>
    // CHECK-NEXT: testvar = 42;
    systemc.cpp.assign %testvar = %c42_i32 : i32
    // CHECK-NEXT: testvarwithinit = testvar;
    systemc.cpp.assign %testvarwithinit = %testvar : i32
  // CHECK-NEXT: }
  }
// CHECK-NEXT: };
}

// CHECK-LABEL: SC_MODULE(nativeCTypes)
// CHECK-NEXT: sc_in<bool> port0;
// CHECK-NEXT: sc_in<uint8_t> port1;
// CHECK-NEXT: sc_in<uint16_t> port2;
// CHECK-NEXT: sc_in<uint32_t> port3;
// CHECK-NEXT: sc_in<uint64_t> port4;
// CHECK-NEXT: sc_in<bool> port5;
// CHECK-NEXT: sc_in<int8_t> port6;
// CHECK-NEXT: sc_in<int16_t> port7;
// CHECK-NEXT: sc_in<int32_t> port8;
// CHECK-NEXT: sc_in<int64_t> port9;
// CHECK-NEXT: sc_in<bool> port10;
// CHECK-NEXT: sc_in<uint8_t> port11;
// CHECK-NEXT: sc_in<uint16_t> port12;
// CHECK-NEXT: sc_in<uint32_t> port13;
// CHECK-NEXT: sc_in<uint64_t> port14;
systemc.module @nativeCTypes (%port0: !systemc.in<i1>,
                              %port1: !systemc.in<i8>,
                              %port2: !systemc.in<i16>,
                              %port3: !systemc.in<i32>,
                              %port4: !systemc.in<i64>,
                              %port5: !systemc.in<si1>,
                              %port6: !systemc.in<si8>,
                              %port7: !systemc.in<si16>,
                              %port8: !systemc.in<si32>,
                              %port9: !systemc.in<si64>,
                              %port10: !systemc.in<ui1>,
                              %port11: !systemc.in<ui8>,
                              %port12: !systemc.in<ui16>,
                              %port13: !systemc.in<ui32>,
                              %port14: !systemc.in<ui64>) {}

// CHECK-LABEL: SC_MODULE(systemCTypes)
// CHECK-NEXT: sc_in<sc_int_base> p0;
// CHECK-NEXT: sc_in<sc_int<32>> p1;
// CHECK-NEXT: sc_in<sc_uint_base> p2;
// CHECK-NEXT: sc_in<sc_uint<32>> p3;
// CHECK-NEXT: sc_in<sc_signed> p4;
// CHECK-NEXT: sc_in<sc_bigint<256>> p5;
// CHECK-NEXT: sc_in<sc_unsigned> p6;
// CHECK-NEXT: sc_in<sc_biguint<256>> p7;
// CHECK-NEXT: sc_in<sc_bv_base> p8;
// CHECK-NEXT: sc_in<sc_bv<1024>> p9;
// CHECK-NEXT: sc_in<sc_lv_base> p10
// CHECK-NEXT: sc_in<sc_lv<1024>> p11
// CHECK-NEXT: sc_in<sc_logic> p12;
systemc.module @systemCTypes (%p0: !systemc.in<!systemc.int_base>,
                              %p1: !systemc.in<!systemc.int<32>>,
                              %p2: !systemc.in<!systemc.uint_base>,
                              %p3: !systemc.in<!systemc.uint<32>>,
                              %p4: !systemc.in<!systemc.signed>,
                              %p5: !systemc.in<!systemc.bigint<256>>,
                              %p6: !systemc.in<!systemc.unsigned>,
                              %p7: !systemc.in<!systemc.biguint<256>>,
                              %p8: !systemc.in<!systemc.bv_base>,
                              %p9: !systemc.in<!systemc.bv<1024>>,
                              %p10: !systemc.in<!systemc.lv_base>,
                              %p11: !systemc.in<!systemc.lv<1024>>,
                              %p12: !systemc.in<!systemc.logic>) {}

// CHECK-LABEL: SC_MODULE(emitcEmission)
systemc.module @emitcEmission () {
  // CHECK: SC_CTOR
  systemc.ctor {
    // CHECK-NEXT: int five = 5;
    // CHECK-NEXT: printf("result: %ld\0A", (long) (*(&five)));
    %0 = "emitc.constant"() {value = #emitc.opaque<"5"> : !emitc.opaque<"int">} : () -> !emitc.opaque<"int">
    %five = systemc.cpp.variable %0 : !emitc.opaque<"int">
    %1 = emitc.apply "&"(%five) : (!emitc.opaque<"int">) -> !emitc.ptr<!emitc.opaque<"int">>
    %2 = emitc.apply "*"(%1) : (!emitc.ptr<!emitc.opaque<"int">>) -> !emitc.opaque<"int">
    %3 = emitc.cast %2: !emitc.opaque<"int"> to !emitc.opaque<"long">
    emitc.call "printf" (%3) {args=["result: %ld\n", 0 : index]} : (!emitc.opaque<"long">) -> ()

    // CHECK-NEXT: size_t idx;
    %idx = systemc.cpp.variable : index
    // CHECK-NEXT: int* somePtr = (int*) malloc(4);
    %4 = hw.constant 4 : i32
    %5 = emitc.call "malloc" (%4) : (i32) -> !emitc.ptr<!emitc.opaque<"void">>
    %6 = emitc.cast %5 : !emitc.ptr<!emitc.opaque<"void">> to !emitc.ptr<!emitc.opaque<"int">>
    %somePtr = systemc.cpp.variable %6 : !emitc.ptr<!emitc.opaque<"int">>
  }
}

// CHECK-LABEL: SC_MODULE(CppEmission)
systemc.module @CppEmission () {
  // CHECK-EMPTY:
  // CHECK-NEXT: ~CppEmission() override {
  systemc.cpp.destructor {
    // CHECK-NEXT: delete (new submodule);
    %0 = systemc.cpp.new() : () -> !emitc.ptr<!emitc.opaque<"submodule">>
    systemc.cpp.delete %0 : !emitc.ptr<!emitc.opaque<"submodule">>

    // CHECK-NEXT: int* arr = (int*) (new int[5]);
    %1 = systemc.cpp.new() : () -> !emitc.ptr<!emitc.opaque<"int[5]">>
    %2 = emitc.cast %1 : !emitc.ptr<!emitc.opaque<"int[5]">> to !emitc.ptr<!emitc.opaque<"int">>
    %arr = systemc.cpp.variable %2 : !emitc.ptr<!emitc.opaque<"int">>
    // CHECK-NEXT: delete arr;
    systemc.cpp.delete %arr : !emitc.ptr<!emitc.opaque<"int">>

    // CHECK-NEXT: std::tuple<uint32_t, uint32_t>* tup = new std::tuple<uint32_t, uint32_t>(1, 2);
    %3 = hw.constant 1 : i32
    %4 = hw.constant 2 : i32
    %5 = systemc.cpp.new(%3, %4) : (i32, i32) -> !emitc.ptr<!emitc.opaque<"std::tuple<uint32_t, uint32_t>">>
    %tup = systemc.cpp.variable %5 : !emitc.ptr<!emitc.opaque<"std::tuple<uint32_t, uint32_t>">>
    // CHECK-NEXT: delete tup;
    systemc.cpp.delete %tup : !emitc.ptr<!emitc.opaque<"std::tuple<uint32_t, uint32_t>">>
  // CHECK-NEXT: }
  }
}

// CHECK: #endif // STDOUT_H
