	.text
	.def	@feat.00;
	.scl	3;
	.type	0;
	.endef
	.globl	@feat.00
.set @feat.00, 0
	.file	"main.b8591b61-cgu.0"
	.def	_ZN3std10sys_common9backtrace28__rust_begin_short_backtrace17hf6f40ea480fb9bb6E;
	.scl	3;
	.type	32;
	.endef
	.section	.text,"xr",one_only,_ZN3std10sys_common9backtrace28__rust_begin_short_backtrace17hf6f40ea480fb9bb6E
	.p2align	4, 0x90
_ZN3std10sys_common9backtrace28__rust_begin_short_backtrace17hf6f40ea480fb9bb6E:
.seh_proc _ZN3std10sys_common9backtrace28__rust_begin_short_backtrace17hf6f40ea480fb9bb6E
	subq	$40, %rsp
	.seh_stackalloc 40
	.seh_endprologue
	callq	*%rcx
	#APP
	#NO_APP
	nop
	addq	$40, %rsp
	retq
	.seh_endproc

	.def	_ZN3std2rt10lang_start17hcc3310dcf28634deE;
	.scl	2;
	.type	32;
	.endef
	.section	.text,"xr",one_only,_ZN3std2rt10lang_start17hcc3310dcf28634deE
	.globl	_ZN3std2rt10lang_start17hcc3310dcf28634deE
	.p2align	4, 0x90
_ZN3std2rt10lang_start17hcc3310dcf28634deE:
.seh_proc _ZN3std2rt10lang_start17hcc3310dcf28634deE
	subq	$56, %rsp
	.seh_stackalloc 56
	.seh_endprologue
	movq	%r8, %rax
	movq	%rdx, %r8
	movq	%rcx, 48(%rsp)
	movb	%r9b, 32(%rsp)
	leaq	__unnamed_1(%rip), %rdx
	leaq	48(%rsp), %rcx
	movq	%rax, %r9
	callq	_ZN3std2rt19lang_start_internal17h1149c819db815d35E
	nop
	addq	$56, %rsp
	retq
	.seh_endproc

	.def	_ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17hd73fe5ec1c00418aE;
	.scl	3;
	.type	32;
	.endef
	.section	.text,"xr",one_only,_ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17hd73fe5ec1c00418aE
	.p2align	4, 0x90
_ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17hd73fe5ec1c00418aE:
.seh_proc _ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17hd73fe5ec1c00418aE
	subq	$40, %rsp
	.seh_stackalloc 40
	.seh_endprologue
	movq	(%rcx), %rcx
	callq	_ZN3std10sys_common9backtrace28__rust_begin_short_backtrace17hf6f40ea480fb9bb6E
	xorl	%eax, %eax
	addq	$40, %rsp
	retq
	.seh_endproc

	.def	_ZN4core3ops8function6FnOnce40call_once$u7b$$u7b$vtable.shim$u7d$$u7d$17h6b05f33af3c5433fE;
	.scl	3;
	.type	32;
	.endef
	.section	.text,"xr",one_only,_ZN4core3ops8function6FnOnce40call_once$u7b$$u7b$vtable.shim$u7d$$u7d$17h6b05f33af3c5433fE
	.p2align	4, 0x90
_ZN4core3ops8function6FnOnce40call_once$u7b$$u7b$vtable.shim$u7d$$u7d$17h6b05f33af3c5433fE:
.seh_proc _ZN4core3ops8function6FnOnce40call_once$u7b$$u7b$vtable.shim$u7d$$u7d$17h6b05f33af3c5433fE
	subq	$40, %rsp
	.seh_stackalloc 40
	.seh_endprologue
	movq	(%rcx), %rcx
	callq	_ZN3std10sys_common9backtrace28__rust_begin_short_backtrace17hf6f40ea480fb9bb6E
	xorl	%eax, %eax
	addq	$40, %rsp
	retq
	.seh_endproc

	.def	_ZN4core3ptr85drop_in_place$LT$std..rt..lang_start$LT$$LP$$RP$$GT$..$u7b$$u7b$closure$u7d$$u7d$$GT$17hd689c8437ce010baE;
	.scl	3;
	.type	32;
	.endef
	.section	.text,"xr",one_only,_ZN4core3ptr85drop_in_place$LT$std..rt..lang_start$LT$$LP$$RP$$GT$..$u7b$$u7b$closure$u7d$$u7d$$GT$17hd689c8437ce010baE
	.p2align	4, 0x90
_ZN4core3ptr85drop_in_place$LT$std..rt..lang_start$LT$$LP$$RP$$GT$..$u7b$$u7b$closure$u7d$$u7d$$GT$17hd689c8437ce010baE:
	retq

	.def	_ZN4main4main17hd0d97daef3a32cf2E;
	.scl	3;
	.type	32;
	.endef
	.section	.text,"xr",one_only,_ZN4main4main17hd0d97daef3a32cf2E
	.p2align	4, 0x90
_ZN4main4main17hd0d97daef3a32cf2E:
.seh_proc _ZN4main4main17hd0d97daef3a32cf2E
	pushq	%r14
	.seh_pushreg %r14
	pushq	%rsi
	.seh_pushreg %rsi
	pushq	%rdi
	.seh_pushreg %rdi
	pushq	%rbx
	.seh_pushreg %rbx
	subq	$104, %rsp
	.seh_stackalloc 104
	.seh_endprologue
	movl	$233, 36(%rsp)
	leaq	36(%rsp), %rax
	movq	%rax, 40(%rsp)
	leaq	_ZN4core3fmt3num3imp52_$LT$impl$u20$core..fmt..Display$u20$for$u20$i32$GT$3fmt17h30d65600b45ce7efE(%rip), %r14
	movq	%r14, 48(%rsp)
	leaq	__unnamed_2(%rip), %rdi
	movq	%rdi, 72(%rsp)
	movq	$2, 80(%rsp)
	movq	$0, 56(%rsp)
	leaq	40(%rsp), %rbx
	movq	%rbx, 88(%rsp)
	movq	$1, 96(%rsp)
	leaq	56(%rsp), %rcx
	callq	_ZN3std2io5stdio6_print17hce7a376ab49946d5E
	movl	$233, 32(%rsp)
	leaq	32(%rsp), %rsi
	movq	%rsi, 40(%rsp)
	movq	%r14, 48(%rsp)
	movq	%rdi, 72(%rsp)
	movq	$2, 80(%rsp)
	movq	$0, 56(%rsp)
	movq	%rbx, 88(%rsp)
	movq	$1, 96(%rsp)
	leaq	56(%rsp), %rcx
	callq	_ZN3std2io5stdio6_print17hce7a376ab49946d5E
	movl	$666, 32(%rsp)
	movq	%rsi, 40(%rsp)
	movq	%r14, 48(%rsp)
	movq	%rdi, 72(%rsp)
	movq	$2, 80(%rsp)
	movq	$0, 56(%rsp)
	movq	%rbx, 88(%rsp)
	movq	$1, 96(%rsp)
	leaq	56(%rsp), %rcx
	callq	_ZN3std2io5stdio6_print17hce7a376ab49946d5E
	nop
	addq	$104, %rsp
	popq	%rbx
	popq	%rdi
	popq	%rsi
	popq	%r14
	retq
	.seh_endproc

	.def	main;
	.scl	2;
	.type	32;
	.endef
	.section	.text,"xr",one_only,main
	.globl	main
	.p2align	4, 0x90
main:
.seh_proc main
	subq	$56, %rsp
	.seh_stackalloc 56
	.seh_endprologue
	movq	%rdx, %r9
	movslq	%ecx, %r8
	leaq	_ZN4main4main17hd0d97daef3a32cf2E(%rip), %rax
	movq	%rax, 48(%rsp)
	movb	$0, 32(%rsp)
	leaq	__unnamed_1(%rip), %rdx
	leaq	48(%rsp), %rcx
	callq	_ZN3std2rt19lang_start_internal17h1149c819db815d35E
	nop
	addq	$56, %rsp
	retq
	.seh_endproc

	.section	.rdata,"dr",one_only,__unnamed_1
	.p2align	3
__unnamed_1:
	.quad	_ZN4core3ptr85drop_in_place$LT$std..rt..lang_start$LT$$LP$$RP$$GT$..$u7b$$u7b$closure$u7d$$u7d$$GT$17hd689c8437ce010baE
	.asciz	"\b\000\000\000\000\000\000\000\b\000\000\000\000\000\000"
	.quad	_ZN4core3ops8function6FnOnce40call_once$u7b$$u7b$vtable.shim$u7d$$u7d$17h6b05f33af3c5433fE
	.quad	_ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17hd73fe5ec1c00418aE
	.quad	_ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17hd73fe5ec1c00418aE

	.section	.rdata,"dr",one_only,__unnamed_3
	.p2align	3
__unnamed_3:

	.section	.rdata,"dr",one_only,__unnamed_4
__unnamed_4:
	.byte	10

	.section	.rdata,"dr",one_only,__unnamed_2
	.p2align	3
__unnamed_2:
	.quad	__unnamed_3
	.zero	8
	.quad	__unnamed_4
	.asciz	"\001\000\000\000\000\000\000"

