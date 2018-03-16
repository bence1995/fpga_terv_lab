#ifndef FIR_H
#define FIR_H

#include "ap_int.h"
#include "ap_fixed.h"

#define N 512

struct out_stream_struct
{
	ap_fixed<32, 1> tdata;
	bool tlast;
};

//	AP_FIXED
//	<W, I, Q, O, N>
//	W: Total width in bits
//	I: Number of integer bits
//	Q: Quantization mode
//	O: Overflow/saturation mode
//	N: Number of saturation bits in wrap mode

typedef ap_fixed<24, 1, AP_TRN, AP_SAT> din_t;

typedef ap_fixed<31, 1, AP_TRN, AP_SAT> coeff_t;

typedef ap_fixed<31, 1, AP_TRN, AP_SAT> accu_t;

void fir_hw(
		ap_uint<16> tlast_dnum,
		ap_uint<3> smpl_rd_num,
		ap_uint<9> tap_num_m1,
		coeff_t coeff_hw[N],
		din_t *input_l,
		din_t *input_r,
		out_stream_struct *res);


#endif
