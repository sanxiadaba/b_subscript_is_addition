	.file	"c_asm.c"
	.section	.text.unlikely,"x"
LCOLDB0:
	.text
LHOTB0:
	.p2align 4,,15
	.globl	_get_i
	.def	_get_i;	.scl	2;	.type	32;	.endef
_get_i:
LFB0:
	.cfi_startproc
	movl	8(%esp), %edx
	movl	4(%esp), %eax
	movl	(%eax,%edx,4), %eax
	ret
	.cfi_endproc
LFE0:
	.section	.text.unlikely,"x"
LCOLDE0:
	.text
LHOTE0:
	.section	.text.unlikely,"x"
LCOLDB1:
	.text
LHOTB1:
	.p2align 4,,15
	.globl	_get_commuted
	.def	_get_commuted;	.scl	2;	.type	32;	.endef
_get_commuted:
LFB1:
	.cfi_startproc
	movl	8(%esp), %edx
	movl	4(%esp), %eax
	movl	(%eax,%edx,4), %eax
	ret
	.cfi_endproc
LFE1:
	.section	.text.unlikely,"x"
LCOLDE1:
	.text
LHOTE1:
	.section	.text.unlikely,"x"
LCOLDB2:
	.text
LHOTB2:
	.p2align 4,,15
	.globl	_get_char
	.def	_get_char;	.scl	2;	.type	32;	.endef
_get_char:
LFB2:
	.cfi_startproc
	movl	8(%esp), %eax
	movl	4(%esp), %edx
	movsbl	(%edx,%eax), %eax
	ret
	.cfi_endproc
LFE2:
	.section	.text.unlikely,"x"
LCOLDE2:
	.text
LHOTE2:
	.ident	"GCC: (i686-posix-dwarf-rev0, Built by MinGW-W64 project) 4.9.4"
