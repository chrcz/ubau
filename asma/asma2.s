.globl asma /*globl or global makes the symbol visible to other programs during linking*/
	.type	asma, @function /*instead of @ we may also use %,"" or some letters..*/
asma:

#	xorq	%r11, %r11	/*clear r11. it will hold the CF in its msb later*/
	rcrq	$1, 8(%rdi)	/*put lsb of x[1] into CF*/
	rcrq	$1, (%rdi)	/*put lsb of x[1] into CF*/
#	rcrq	$1, %r11	/*rotate CF into msb of rax. carry = x[1] << 63; */
#	clc			/*clear CF so we only rotate 0 into msb of rdi*/
#	rcrq	$1, (%rdi)	/* x[0] = x[0] >> 1; */
#	orq	%r11, (%rdi)	/* x[0] = x[0] | carry */
	ret
/*
TODO: check if a label inside asma is needed.		NOPE :)
check what happens if .text is ommited.			STILL WORKS YAY

void asma(unsigned long x[])  ..operates on array
{  
  unsigned long carry;  
  carry = x[1] << 63;  .. x[1] * 2^63 
  x[1] = x[1] >> 1;  ..x[1] / 2^1 = x[1] / 2
  x[0] = (x[0] >> 1)|carry;  ..(x[0] / 2) followed by bitwise inclusive OR of result and carry
} 				.. 0101 | 0011 = 0111
*/

