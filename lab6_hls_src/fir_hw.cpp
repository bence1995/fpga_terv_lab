#include "fir.h"

#define N 512

void fir_hw(
		ap_uint<16> tlast_dnum,
		ap_uint<3> smpl_rd_num,
		ap_uint<9> tap_num_m1,
		coeff_t coeff_hw[N],
		din_t *input_l,
		din_t *input_r,
		out_stream_struct *res)
{
#pragma HLS INTERFACE ap_hs port=input_r
#pragma HLS INTERFACE ap_hs port=input_l
#pragma HLS DATA_PACK variable=res
#pragma HLS INTERFACE ap_ctrl_none port=return
#pragma HLS INTERFACE s_axilite port=coeff_hw
#pragma HLS INTERFACE s_axilite port=smpl_rd_num
#pragma HLS INTERFACE s_axilite port=tap_num_m1

///////////////////////////////////////////////////////////////////////////////////
//VARIABLES
///////////////////////////////////////////////////////////////////////////////////

	//Left and Right channel buffer and select
	static din_t buff_l[N];
#pragma HLS ARRAY_PARTITION variable=buff_l complete dim=1
	static din_t buff_r[N];
#pragma HLS ARRAY_PARTITION variable=buff_r complete dim=1

	static int lr = 0;
	din_t *input_ptr;
	din_t *buff_ptr;

	//Sample counter
	static ap_uint<16> cntr = 0;

	//Output
	out_stream_struct out_data;

	//TLAST counter
	static ap_uint<16> tlast_cntr = 0;

	//Coefficient pointer
	coeff_t * coeff_ptr;

	//Iterator
	int i;

///////////////////////////////////////////////////////////////////////////////////
//LEFT / RIGHT CHANNELS
///////////////////////////////////////////////////////////////////////////////////

	if(lr == 0)
	{
		lr = 1;
		buff_ptr = buff_l;
		input_ptr = input_l;
	}
	else
	{
		lr = 0;
		buff_ptr = buff_r;
		input_ptr = input_r;
	}

///////////////////////////////////////////////////////////////////////////////////
//SHIFT
///////////////////////////////////////////////////////////////////////////////////

	if(lr == 0)
		for_shift_l: for (i = N; i >= 0; i--)
		#pragma HLS UNROLL
		{
			buff_l[i] = (i == 0) ? *input_l : buff_l[i - 1];
		}
	else
		for_shift_r: for (i = N; i >= 0; i--)
		#pragma HLS UNROLL
		{
			buff_r[i] = (i == 0) ? *input_r : buff_r[i - 1];
		}

///////////////////////////////////////////////////////////////////////////////////
//MAC
///////////////////////////////////////////////////////////////////////////////////

	accu_t acc = 0;
	if(lr == 0)
		for_mac_l: for (i = 0; i <= tap_num_m1; i++)
		{
			#pragma HLS LOOP_TRIPCOUNT min=128 max=512
			acc = acc + (coeff_hw[i] * buff_l[i]);
		}
	else
		for_mac_r: for (i = 0; i <= tap_num_m1; i++)
		{
			#pragma HLS LOOP_TRIPCOUNT min=128 max=512
			acc = acc + (coeff_hw[i] * buff_r[i]);
		}

///////////////////////////////////////////////////////////////////////////////////
//OUTPUT
///////////////////////////////////////////////////////////////////////////////////

	cntr++;

	//LEFT
	if ( (cntr % (smpl_rd_num << 1) ) == 0)
	{
		out_data.tdata = acc;
		tlast_cntr++;
	}

	//RIGHT
	if ( (cntr % (smpl_rd_num << 1) ) == 1)
	{
		out_data.tdata = acc;
		tlast_cntr++;
	}


///////////////////////////////////////////////////////////////////////////////////
//GENERATE TLAST
///////////////////////////////////////////////////////////////////////////////////

	//ez nem lesz jó
	if (tlast_cntr % tlast_dnum == 0)
		out_data.tlast = 1;
	else
		out_data.tlast = 0;




	*res = out_data;
}
