.globl	asmb
.type	asmb, @function

asmb:
	cmp $0, %rsi				#n==0? modifies ZF and CF (clears CF in this case)
	jz afterloop				#nothing to do if n==0

loopbody:
	dec %rsi					#n-- Since n is not const, we may modify it
	rcrq $1, (%rdi, %rsi, 8)	#CF holds carry from previous iteration. no need to or.
	jnz loopbody

afterloop:
	ret


/*
void asmb(unsigned long x[], size_t n)	..eg: n=5 
{  
  unsigned long carry=0;  
  unsigned long next_carry;  
  long i;  
  for (i=n-1; i>=0; i--) {  		..i = 4,3,2,1,0
    next_carry = x[i] << 63;  		
    x[i] = (x[i] >> 1) | carry;  
    carry = next_carry;  
  }  
}
*/

