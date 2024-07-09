//===-- Passes.td - Conversion pass definitions ------------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains definitions for all dialect conversions.
//
//===----------------------------------------------------------------------===//

#ifndef CIRCT_CONVERSION_PASSES_TD
#define CIRCT_CONVERSION_PASSES_TD

include "mlir/Pass/PassBase.td"

//===----------------------------------------------------------------------===//
// ExportChiselInterface and ExportSplitChiselInterface
//===----------------------------------------------------------------------===//

def ExportChiselInterface : Pass<"export-chisel-interface", "firrtl::CircuitOp"> {
  let summary = "Emit a Chisel interface to a FIRRTL circuit";
  let description = [{
    This pass generates a Scala Chisel interface for the top level module of
    a FIRRTL circuit.
  }];

  let constructor = "createExportChiselInterfacePass()";
  let dependentDialects = [
    "circt::firrtl::FIRRTLDialect"
  ];
}

def ExportSplitChiselInterface : Pass<"export-split-chisel-interface", "firrtl::CircuitOp"> {
  let summary = "Emit a Chisel interface to a FIRRTL circuit to a directory of files";
  let description = [{
    This pass generates a Scala Chisel interface for the top level module of
    a FIRRTL circuit.
  }];

  let constructor = "createExportSplitChiselInterfacePass()";
  let dependentDialects = [
    "circt::firrtl::FIRRTLDialect"
  ];
  let options = [
    Option<"directoryName", "dir-name", "std::string",
            "", "Directory to emit into">
   ];
}

//===----------------------------------------------------------------------===//
// ExportVerilog and ExportSplitVerilog
//===----------------------------------------------------------------------===//

def TestApplyLoweringOption : Pass<"test-apply-lowering-options",
                                   "mlir::ModuleOp"> {
  let summary = "Apply lowering options";
  let description = [{
    This pass allows overriding lowering options.  It is intended for test
    construction.
  }];

  let constructor = "createTestApplyLoweringOptionPass()";
  let dependentDialects = [
    "circt::sv::SVDialect", "circt::comb::CombDialect", "circt::hw::HWDialect"
  ];
  let options = [
    Option<"options", "options", "std::string", "", "Lowering Options">
  ];
}

def LegalizeAnonEnums : Pass<"legalize-anon-enums", "mlir::ModuleOp"> {
  let summary = "Prepare anonymous enumeration types for ExportVerilog";
  let description = [{
    This pass transforms all anonymous enumeration types into typedecls to work
    around difference in how anonymous enumerations work in SystemVerilog.
  }];
  let constructor = "createLegalizeAnonEnumsPass()";
  let dependentDialects = [
    "circt::sv::SVDialect", "circt::comb::CombDialect", "circt::hw::HWDialect"
  ];
}

def PrepareForEmission : Pass<"prepare-for-emission",
                              "hw::HWModuleOp"> {
  let summary = "Prepare IR for ExportVerilog";
  let description = [{
    This pass runs only PrepareForEmission.
    It is not necessary for users to run this pass explicitly since
    ExportVerilog internally runs PrepareForEmission.
  }];

  let constructor = "createPrepareForEmissionPass()";
  let dependentDialects = [
    "circt::sv::SVDialect", "circt::comb::CombDialect", "circt::hw::HWDialect"
  ];
}

def ExportVerilog : Pass<"export-verilog", "mlir::ModuleOp"> {
  let summary = "Emit the IR to a (System)Verilog file";
  let description = [{
      This pass creates empty module bodies for external modules.  This is
      useful for linting to eliminate missing file errors.
  }];

  let constructor = "createExportVerilogPass()";
  let dependentDialects = [
    "circt::sv::SVDialect", "circt::comb::CombDialect", "circt::hw::HWDialect"
  ];
}

def ExportSplitVerilog : Pass<"export-split-verilog", "mlir::ModuleOp"> {
  let summary = "Emit the IR to a (System)Verilog directory of files";
  let description = [{
    This pass generates (System)Verilog for the current design, mutating it
    where necessary to be valid Verilog.
  }];

  let constructor = "createExportSplitVerilogPass()";
  let dependentDialects = [
    "circt::sv::SVDialect", "circt::comb::CombDialect", "circt::hw::HWDialect"
  ];

  let options = [
    Option<"directoryName", "dir-name", "std::string",
            "", "Directory to emit into">
   ];
}

//===----------------------------------------------------------------------===//
// FIRRTLToHW
//===----------------------------------------------------------------------===//

def LowerFIRRTLToHW : Pass<"lower-firrtl-to-hw", "mlir::ModuleOp"> {
  let summary = "Lower FIRRTL to HW";
  let description = [{
    Lower a module of FIRRTL dialect to the HW dialect family.
  }];
  let constructor = "circt::createLowerFIRRTLToHWPass()";
  let dependentDialects = ["comb::CombDialect", "hw::HWDialect",
                           "seq::SeqDialect", "sv::SVDialect",
                           "ltl::LTLDialect", "verif::VerifDialect"];
  let options = [
    Option<"disableMemRandomization", "disable-mem-randomization", "bool", "false",
            "Disable emission of memory randomization code">,
    Option<"disableRegRandomization", "disable-reg-randomization", "bool", "false",
            "Disable emission of register randomization code">,
    Option<"enableAnnotationWarning", "warn-on-unprocessed-annotations",
           "bool", "false",
    "Emit warnings on unprocessed annotations during lower-to-hw pass">,
    Option<"emitChiselAssertsAsSVA", "emit-chisel-asserts-as-sva",
           "bool", "false","Convert all Chisel asserts to SVA">
  ];
}

//===----------------------------------------------------------------------===//
// HWToSV
//===----------------------------------------------------------------------===//

def LowerHWToSV : Pass<"lower-hw-to-sv", "hw::HWModuleOp"> {
  let summary = "Convert HW to SV";
  let description = [{
    This pass converts various HW contructs to SV.
  }];
  let constructor = "circt::createLowerHWToSVPass()";
  let dependentDialects = ["sv::SVDialect"];
}

//===----------------------------------------------------------------------===//
// VerifToSV
//===----------------------------------------------------------------------===//

def LowerVerifToSV : Pass<"lower-verif-to-sv", "hw::HWModuleOp"> {
  let summary = "Convert Verif to SV";
  let description = [{
    This pass converts various Verif contructs to SV.
  }];
  let constructor = "circt::createLowerVerifToSVPass()";
  let dependentDialects = ["sv::SVDialect", "hw::HWDialect"];
}

#endif // CIRCT_CONVERSION_PASSES_TD
