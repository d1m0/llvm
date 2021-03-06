; RUN: llc < %s -mtriple=x86_64-apple-darwin  -mcpu=corei7 | FileCheck %s
; ModuleID = '<stdin>'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-apple-darwin11.2.0"

; During legalization, the vselect mask is 'type legalized' into a 
; wider BUILD_VECTOR. This causes the introduction of a new
; sign_extend_inreg in the DAG.
;
; A sign_extend_inreg of a vector of ConstantSDNode or undef can be
; always folded into a simple build_vector.
;
; Make sure that the sign_extend_inreg is simplified and that we
; don't generate psll, psraw and pblendvb from the vselect.

; CHECK-LABEL: foo8
; CHECK-NOT: psll
; CHECK-NOT: psraw
; CHECK-NOT: pblendvb
; CHECK: ret
define void @foo8(float* nocapture %RET) nounwind {
allocas:
  %resultvec.i = select <8 x i1> <i1 false, i1 true, i1 false, i1 true, i1 false, i1 true, i1 false, i1 true>, <8 x i8> <i8 1, i8 2, i8 3, i8 4, i8 5, i8 6, i8 7, i8 8>, <8 x i8> <i8 100, i8 100, i8 100, i8 100, i8 100, i8 100, i8 100, i8 100>
  %uint2float = uitofp <8 x i8> %resultvec.i to <8 x float>
  %ptr = bitcast float * %RET to <8 x float> *
  store <8 x float> %uint2float, <8 x float>* %ptr, align 4
  ret void
}

